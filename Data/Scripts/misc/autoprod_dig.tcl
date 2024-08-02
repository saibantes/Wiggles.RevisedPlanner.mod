##nagelfar syntax def_class x x x x x cl
##nagelfar syntax obj_init cl
##nagelfar syntax handle_event x cl
##nagelfar syntax method dm
def_class AutoprodDigsiteFinder none none 0 {} {
    def_event evt_timer0

    obj_init {
        #proc log {text {with_flush 0}} {
        #    global logFileID
        #    set str [format "%.2f %.3f %s" [gettime] [expr {[clock clicks]/1000.0}] $text]
        #    if {[catch {
        #        puts $logFileID $str
        #        if {$with_flush} {flush $logFileID}
        #    }] == 1} {
        #        if {[catch {
        #            set logFileID [open "data/_log/[get_objname this].txt" "w"]
        #            puts $logFileID $str
        #            if {$with_flush} {flush $logFileID}
        #        }] == 1} {
        #            print "log [get_objname this] $str"
        #        }
        #    }
        #}

        # check if x|y point is marked as digged AND also yet unvisited
        proc is_dig_point {x y} {
            upvar new_map new_map
            global new_site_id ;#old_map old_id_to_new_id
            if {[info exists new_map($x,$y)]} {return 0}
            if {![is_dig_marked $x $y [expr {$x+1}] [expr {$y+1}]]} {return 0}
            set new_map($x,$y) $new_site_id
            return 1
        }

        set state "init"
        set minx 0
        set miny 0
        set maxx 0
        set maxy 0
        set new_site_id 0
        set new_entries {}
        set old_entries {}
        set dig_sizes {}
        set old_sizes {}
        set new_dig_points {}
        set old_dig_points {}

        proc timer_proc {} {
#if {[catch {
            set start_time [clock clicks]
            global state
            global minx miny maxx maxy
            global block_y
            global new_entries new_site_id old_entries
            global old_sizes dig_sizes
#            global new_map old_map
            global active_lines active_blocks
            switch $state {
                "init" {
                    # We are about to check the player's dig markings,
                    # which doesn't make sense for any player other than the local one.
                    if {[get_local_player] != [get_owner this]} return
                    #log "init"
#                    set minx [vector_unpackx [map getoffset]]
#                    set miny [vector_unpacky [map getoffset]]
#                    set maxx [expr {$minx + [get_map_width]}]
#                    set maxy [expr {$miny + [get_map_height]}]

                    set minx [hmax 0     [lindex [scrollrange] 0]]
                    set miny [hmax 0     [lindex [scrollrange] 1]]
                    set maxx             [lindex [scrollrange] 2]
                    set maxy             [lindex [scrollrange] 3]
                    
                    set old_entries $new_entries
                    global old_dig_points new_dig_points
                    set old_dig_points $new_dig_points
                    set new_dig_points {}
                    set old_sizes $dig_sizes
                    set dig_sizes {}
                    set active_lines {}
                    set active_blocks {}
                    
                    set block_y $miny
                    set new_entries {}
                    set new_site_id 0
                    
                    set state "scan_lines"
                }
                "scan_lines" {
                    #log "line $block_y"
                    for {set i 0} {$i < 4} {incr i} {
                        set next_block_y [expr {$block_y + 15}]
                        if {[is_dig_marked $minx $block_y $maxx $next_block_y]} {
                            lappend active_lines "$minx $block_y $maxx $next_block_y"
                        }
                        if {$next_block_y >= $maxy} {
                            set state "scan_blocks"
                            return
                        } else {
                            set block_y $next_block_y
                        }
                    }
#                    log "next"
                }
                "scan_blocks" {
                    if {[llength $active_lines]} {
                        set line [lindex $active_lines 0]
                        set minx         [lindex $line 0]
                        set block_y      [lindex $line 1]
                        set maxx         [lindex $line 2]
                        set next_block_y [lindex $line 3]
                        set active_lines [lrange $active_lines 1 end]
                        #log "blocks in $block_y"
                        ##nagelfar variable next_block_x
                        for {set block_x $minx} {$block_x < $maxx} {set block_x $next_block_x} {
                            set next_block_x [expr {$block_x + 16}]
                            if {[is_dig_marked $block_x $block_y $next_block_x $next_block_y]} {
                                lappend active_blocks "$block_x $block_y $next_block_x $next_block_y"
                            }
                        }
                    } else {
                        set state "scan_pixels"
                    }
#                    log "next"
                }
                "scan_pixels" {
                    if {[llength $active_blocks]} {
                        set block [lindex $active_blocks 0]
                        set block_x      [lindex $block 0]
                        set block_y      [lindex $block 1]
                        set next_block_x [lindex $block 2]
                        set next_block_y [lindex $block 3]
                        set active_blocks [lrange $active_blocks 1 end]
                        
                        #log "going through block $block_x $block_y"
                        
                        global new_dig_points
                        array set new_map $new_dig_points

                        ##nagelfar variable next_point_y
                        for {set point_y $block_y} {$point_y < $next_block_y} {set point_y $next_point_y} {
                            set next_point_y [expr {$point_y+1}]
                            for {set point_x $block_x} {$point_x < $next_block_x} {incr point_x} {
                                if {[is_dig_point $point_x $point_y]} {
                                    lappend new_entries "$point_x $point_y"
                                    set site_size 1
                                    set x0 $point_x
                                    set y  $point_y
                                    set digging 1
                                    while {$digging} {
                                        set y_p1 [expr {$y+1}]
                                        set y_m1 [expr {$y-1}]
                                        foreach dir {+1 -1} {
                                            set x $x0
                                            while 1 {
                                                lappend queue $x $y_p1
                                                lappend queue $x $y_m1
                                                if {![is_dig_point [incr x $dir] $y]} break
                                                incr site_size
                                            }
                                        }
                                        while {$digging} {
                                            if {[llength $queue] == 0} {
                                                set digging 0
                                                break
                                            }
                                            set x0 [lindex $queue end-1]
                                            set y  [lindex $queue end]
                                            set queue [lrange $queue 0 end-2]
                                            if {[is_dig_point $x0 $y]} {
                                                incr site_size
                                                break
                                            }
                                        }
                                    }
                                    #log "digsize $new_site_id is $site_size big, starting at $point_x|$point_y" 0
                                    incr new_site_id
                                    lappend dig_sizes $site_size
                                }
                            }
                        }
                        set new_dig_points [array get new_map]
#                        log "next"
                    } else {
                        #log "digsites: $new_entries"
                        set state "init"
                    }
                }
                default {
                    set state "init"
                }
            }
            #log "dig scanning took [expr {[clock clicks]-$start_time}] clicks" 1
#} msg] == 1} {
#    log $msg 1
#}
        } ;# timer_proc
        
        proc get_cave_id {pos} {
            set index [expr {round([vector_unpackx $pos])}],[expr {round([vector_unpacky $pos])}]
            set i [lsearch $::old_dig_points $index]
            if {$i >= 0} {
                return [lindex $::old_dig_points [expr {$i+1}]]
            } else {
                return -1
            }
        }
        
        proc get_assigned_sites {gnome} {
            # get the site at the current digging position
            set pos [ref_get $gnome current_digpos]
            if {[llength $pos] < 2} {
                return {}
            }
            set site_id [get_cave_id $pos]
            set result {}
            if {$site_id >= 0} {
                lappend result $site_id
            }
            # get the site the gnome would dig next
            # this might be a different site than before, when two sites are very close
            set pos [dig_next [get_digedge $pos $gnome] $gnome]
            set site_id [get_cave_id $pos]
            if {$site_id >= 0} {
                lappend result $site_id
                
                # get sites related to the last one
                global old_sizes old_entries
                set posx [vector_unpackx $pos]
                set posy [vector_unpacky $pos]
                set index -1
                foreach site $old_entries {
                    incr index
                    set pos2 [get_digedge $site $gnome]
                    set pos2x [vector_unpackx $pos2]
                    if {$pos2x < 0} continue
                    set pos2y [vector_unpacky $pos2]
                    #log "checking nearby digsites: $index -> X:$pos2x-$posx Y:$pos2y-$posy size1:[lindex $old_sizes $index] size2:[lindex $old_sizes $site_id]"
                    if {(abs($pos2x-$posx) <= 16) &&
                        (abs($pos2y-$posy) <= 10) &&
                        (([lindex $old_sizes $index] < 54) || ([lindex $old_sizes $site_id] < 54))} {
                        lappend result $index
                    }
                }
            }
            return $result
        }
        
        timer_event this evt_timer0 -repeat -1 -interval 0.02
    }
    
    handle_event evt_timer0 {
        timer_proc
    }
    
    method get_caves {} {
        return $::old_entries
    }
    method get_assigned_sites {gnome} {
        return [get_assigned_sites $gnome]
    }
    
}


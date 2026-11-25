proc autoprod_ex {owner} {
#if {0 != [catch {
    set start_time [clock clicks]
    #log_static "X: got called by [get_objname this]" 0
    # get the digsites
    set digsite_finder [obj_query 0 -owner $owner -class AutoprodDigsiteFinder]
    if {$digsite_finder == 0} {
        set digsite_finder [new AutoprodDigsiteFinder]
#        set_objname $digsite_finder _AutoprodDigsiteFinder_$owner
        set_owner $digsite_finder $owner
    }
    # get some statistics over all working gnomes
    # get the list of preferred_workers for each workplace
    set gnomes [obj_query 0 -type gnome -owner $owner]
    set available_gnomes {}
    set busy_gnomes {}
    set busy_places {}
    set busy_digsites {}
    set busy_invent_places {}
    set gnomes_active 0
    set num_gnomes 0
    set num_hoverboard  0
    set num_reithamster 0
    set num_kettensaege 0
    set num_zwille      0
    set num_hammer      0
    set num_strahl      0
    set num_injured     0
    set max_inv         0
    foreach gnome $gnomes {
        set current_workplace [ref_get $gnome ::current_workplace]
        lappend busy_places $current_workplace
        set digpos ""
        if {$current_workplace == "dig"} {
            set gnome_sites [call_method $digsite_finder get_assigned_sites $gnome]
            #log_static "sites for [get_objname $gnome]: $gnome_sites" 0
            set busy_digsites [concat $busy_digsites $gnome_sites]
        }
        set workclass [ref_get $gnome ::current_workclass]
        if {[string compare -length 2 $workclass "Bp"] == 0 } {
            lappend busy_invent_places $current_workplace
            #log_static "[get_objname $gnome] is inventing $workclass at $current_workplace" 0
        }

#        log_static "X: [format {%-11s is in state %-18s, last_workplace=%-4s (%s), %s} [get_objname $gnome] [state_get $gnome] [prod_gnome_get_last_workplace $gnome] [get_objname [prod_gnome_get_last_workplace $gnome]] ($digpos)]" 0
        #log_static "X: [format {%-11s is in state %-18s, current_workplace=%-4s (%s), %s, %s} [get_objname $gnome] [state_get $gnome] $current_workplace [get_objname $current_workplace] $workclass ($digpos)]" 0
        if {([get_remaining_sparetime $gnome] > 0) && ([get_attrib $gnome atr_Hitpoints] < 0.97)} {
            incr num_injured
        }
        if {([get_remaining_sparetime $gnome] == 0) && [get_prodautoschedule $gnome]} {
            lappend preferred_workers([prod_gnome_get_preferred_workplace $gnome]) $gnome
            incr num_gnomes
            set max_inv [hmax $max_inv [inv_getsize $gnome]]
            if {[inv_find $gnome "Kettensaege"] >= 0}    {incr num_kettensaege}
            if {[inv_find $gnome "Steinschleuder"] >= 0} {incr num_zwille}
            if {[inv_find $gnome "Hoverboard"] >= 0} {
                incr num_hoverboard
            } elseif {[inv_find $gnome "Reithamster"] >= 0} {
                incr num_reithamster
            }
            if {[inv_find $gnome "Kristallstrahl"] >= 0} {
                incr num_strahl
            } elseif {[inv_find $gnome "Presslufthammer"] >= 0} {
                incr num_hammer
            }
            set gnome_state [state_get $gnome]
            # TODO: check again: state idle
            # work_idle        : worktime, but nothing to do yet
            # prodfill_dispatch: worktime, nothing to do, idle animation
            # work_dispatch    : currently working, but when current_workplace==0: about to transition into work_idle
            if {($gnome_state == "work_idle") || ($gnome_state == "prodfill_dispatch") || 
                (($gnome_state == "work_dispatch") && ($current_workplace == 0))} {
                lappend available_gnomes $gnome
                
                # check if at least 10 seconds into working hours
                if {[gethours]-[get_worktime $gnome laststart] >= 10.0/150} {
                    #if {!$gnomes_active} {log_static "X: [get_objname $gnome] is active at [gethours]" 0}
                    set gnomes_active 1
                }
            } elseif {$gnome_state == "work_dispatch"} {
                lappend busy_gnomes $gnome
            }
        }
    }
    if {$available_gnomes == ""} {
        #log_static "X: noone available for work"
        return
    }
    if {!$gnomes_active} {
        #log_static "X: work time just started, give 'em some slack!"
        return
    }
    # check for pending inventions
    set possible_inventors {}
    set possible_invention_places {}
    foreach place [obj_query 0 -type {production energy protection store} -owner $owner] {
        if {[get_prod_enabled $place] && 
            [get_prodautoschedule $place] && 
            [get_buildupstate $place] &&
            ![get_prod_pack $place] &&
            ([lsearch $busy_invent_places $place] < 0)
        } then {
            set items [call_method $place get_autoprod_inventions]
            if {[llength $items] > 0} {
                #log_static "X: [get_objname $place] wants to invent ($items)" 0
                foreach item $items {
                    set task [list $place {} "invent" $item]
                    set best_score -1e37
                    foreach gnome $available_gnomes {
                        if {[gnome_invent_possible $gnome $item]} {
                            set score [call_method $gnome autoprod_rate_task $task $num_gnomes $num_kettensaege $num_hammer $num_strahl $num_reithamster $num_hoverboard $max_inv $num_injured]
                            #log_static [format "X: %-11s rated %-20s -> %9.2f" [get_objname $gnome] [lrange $task 0 2] $score] 0
                            if {$score > $best_score} {
                                set best_score $score
                                set best_gnome $gnome
                            }
                        }
                    }
                    if {$best_score > -1e36} {
                        #log_static "$best_score $best_gnome $place ($busy_places) $item ($available_gnomes)"
                        lappend possible_inventors $best_gnome
                        if {[lsearch $busy_places $place] < 0} {
                            #log_static "X: assigning [get_objname $best_gnome] to invent $item" 0
                            if {[call_method $best_gnome autoprodx_do $task]} {
                                lappend busy_places $place
                                set available_gnomes [lnand $best_gnome $available_gnomes]
                            }
                        } else {
                            #log_static "X: but this place is still busy" 0
                        }
                        break
                    } else {
                        foreach gnome $busy_gnomes {
                            if {[gnome_invent_possible $gnome $item]} {
                                #log_static "X: [get_objname $gnome] could invent $item, but is busy" 0
                                lappend possible_invention_places $place
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    set str {}
    foreach gnome $possible_inventors {lappend str [get_objname $gnome]}
    #log_static "X: reserving inventors: ($str)" 0
    set str {}
    foreach place $possible_invention_places {lappend str [get_objname $place]}
    #log_static "X: reserving places for inventions: ($str)" 0
    
    set tasks {}
    # look through all production sites
    foreach place [obj_query 0 -type {production energy protection store elevator} -owner $owner] {
        if {[get_prodautoschedule $place] && ([lsearch $busy_places $place] < 0)} {
            set task [call_method $place get_autoprod]
            #log_static "X: [get_objname $place]: $task" 0
            if {$task != ""} {
                if [info exists preferred_workers($place)] {
                    set my_preferred_workers $preferred_workers($place)
                } else {
                    set my_preferred_workers {}
                }
                lappend tasks [linsert $task 0 $place $my_preferred_workers]
            }
        }
    }
    # look through all digsites
    #log_static "busy digsites: $busy_digsites" 0
    set idx 0
    foreach digsite [call_method $digsite_finder get_caves] {
        if {[lsearch $busy_digsites $idx] < 0} {
            lappend tasks [list "dig" {} "dig" $digsite]
            #log_static "digsite ($digsite) needs scheduling" 0
        } else {
            #log_static "digsite ($digsite) is busy" 0
        }
        incr idx
    }
    #log_static "X: all tasks: $tasks" 0
    # rate all gnome <-> task combinations
    set assignments {}
    foreach task $tasks {
        foreach gnome $available_gnomes {
            set score [call_method $gnome autoprod_rate_task $task $num_gnomes $num_kettensaege $num_hammer $num_strahl $num_reithamster $num_hoverboard $max_inv $num_injured]
            # assigning inventors is done further up, here we just reserve possible inventors and invention places
            # for later by giving them a really bad score
            if {[lsearch $possible_invention_places [lindex $task 0]] >= 0} {
                fincr score -50000
            }
            if {[lsearch $possible_inventors $gnome] >= 0} {
                fincr score -50000
            }
            if {$score > -1e36} {
                #log_static [format "X: %-11s rated %-20s -> %9.2f" [get_objname $gnome] [lrange $task 0 2] $score] 0
                lappend assignments [list $score $gnome $task]
            }
        }
    }
    # go through all possible assignments, from highest score (best) to lowest
    set assignments [lsort -index 0 -real $assignments]
    for {set index [expr {[llength $assignments]-1}]} {$index >= 0} {incr index -1} {
        set assignment [lindex $assignments $index]
        set gnome [lindex $assignment 1]
        set task  [lindex $assignment 2]
        set place [lindex $task 0]
        
        if {[info exists gnome_assigned($gnome)]} continue
        lrem assignments $index
        if {[info exists place_assigned($place)]} continue
        
        #log_static "X: $gnome ([get_objname $gnome]) [lindex $task 2] $place ([get_objname $place])" 0
        #obj_eval $place [list log "assigned [get_objname $gnome]"]
        if {![call_method $gnome autoprodx_do $task] && ($place != "dig")} {
            # gnome is not yet 10 seconds idle, will do it later -> unlock $place for now
            #log_static "X: [get_objname $gnome] won't do it, unlocking" 0
            call_method $place autoprod_stop
        }
        set gnome_assigned($gnome) 1
        set place_assigned($place) 1
    }
    # go through the left-over places to unlock potentially reserved items
    foreach task $tasks {
        set place [lindex $task 0]
        if {![info exists place_assigned($place)] && ($place != "dig")} {
            #log_static "noone will work for $place ([get_objname $place]), unlocking" 0
            call_method $place autoprod_stop
            set place_assigned($place) 1
        }
    }

    #log_static "X: autoprod planning took [expr {[clock clicks]-$start_time}] clicks" 1
#} result]} {
    #log_static $result
#}
} ;# autoprod_ex


#==================================================================================================

proc get_disable_old_autoprod {} {
    # check if human player
    #log "owner type of [get_objname this] is [get_objownertype this]"
    return [expr {[get_objownertype this] == 1}]
}

# can this gnome make this invention?
proc gnome_invent_possible {gnome item} {
    # TODO: isn't that totaly inefficient?
    set tttsection_tocall $item
    call scripts/misc/techtreetunes.tcl
    ##nagelfar ignore Suspicious variable name
    foreach {stat level} [join [set tttinvent_$item]] {
        if {[get_attrib $gnome $stat] < $level} {
            return 0
        }
    }
    return 1
}


#proc log {text {with_flush 0}} {
#    global logFileID
#    set str [format "%.2f %.2f %s" [gettime] [expr {[clock clicks]/1000.0}] $text]
#    if {[catch {
#        puts $logFileID $str
#        if {$with_flush} {flush $logFileID}
#    }] == 1} {
#        if {[catch {
#            set logFileID [open "data/_log/[get_objname this]-[get_ref this].txt" "a"]
#            puts $logFileID ""
#            puts $logFileID $str
#            if {$with_flush} {flush $logFileID}
#        }] == 1} {
#            print "log [get_objname this] $str"
#        }
#    }
#}

proc log_static {text {with_flush 1}} {
#    global logFileID_static
#    set str [format "%.2f %.2f %s" [gettime] [expr {[clock clicks]/1000.0}] $text]
#    if {[catch {
#        puts $logFileID_static $str
#        if {$with_flush} {
#            close $logFileID_static
#            unset logFileID_static
#        }
#    }] == 1} {
#        if {[catch {
#            set logFileID_static [open "data/_log/_autoprod.txt" "a"]
#            puts $logFileID_static $str
#            if {$with_flush} {
#                close $logFileID_static
#                unset logFileID_static
#            }
#        }] == 1} {
#            print "log [get_objname this] $str"
#        }
#    }
}

# search through the code segment for the access to the manager pointer
# Wiggles 1.0.814 and 1.0.844 have
#   8B 0D xx xx xx xx ; 8B 8C 81 88 04 00 00 ; 85 C9 (MOV ECX, [xxxxxxxx] ; MOV ECX,[ECX+EAX*4+0x488] ; TEST ECX,ECX)
# 2.1.1.10 has:
#      A1 xx xx xx xx ; 8B 8C 98 88 04 00 00 ; 85 C9 (MOV EAX, [xxxxxxxx] ; MOV ECX,[EAX+EBX*4+0x488] ; TEST ECX,ECX)
# This proc will return the address for the xxxxxxxx (thus a pointer to the pointer).
# Only part of these sequences is needed to uniquely identify the code sequence. However, the longer the 
# consecutive fixed part, the faster we can search for it.
proc find_manager_access_ptr {} {
    for {set addr 0x10000} {$addr <= 0x1400000} {set addr [expr {($addr/0x10000+1)*0x10000}]} {
        if {[catch {
            # only consider segments starting with "MZ" (the exe file magic number)
            if {[peek $addr] != 77} continue
            incr addr
            if {[peek $addr] != 90} continue
            incr addr 0x1000
            set end_addr [expr {$addr + 0x3ab000}]
            for {} {$addr < $end_addr} {incr addr 9} {
                set data [peek $addr]
                if {$data == 0} {
                    set data2 [peek [expr {$addr-1}]]
                    if {$data2 == 0} {
                        set result [expr {$addr-10}]
                    } elseif {$data2 == 4} {
                        set result [expr {$addr-9}]
                    } else {
                        continue
                    }
                } elseif {$data == -117} {
                    set result [expr {$addr-4}]
                } elseif {$data == 4} {
                    set result [expr {$addr-8}]
                } elseif {$data == -123} {
                    set result [expr {$addr-11}]
                } elseif {$data == -55} {
                    set result [expr {$addr-12}]
                } elseif {$data == -120} {
                    set result [expr {$addr-7}]
                } elseif {$data == -127} {
                    set result [expr {$addr-6}]
                } elseif {$data == -116} {
                    set result [expr {$addr-5}]
                } elseif {$data == -104} {
                    set result [expr {$addr-6}]
                } else {
                    continue
                }
                if {([peek [expr {$result+4}]] == -117) && ([peek [expr {$result+5}]] == -116) 
                            && ([peek [expr {$result+7}]] == -120) && ([peek [expr {$result+8}]] == 4)
                            && ([peek [expr {$result+9}]] == 0)    && ([peek [expr {$result+10}]] == 0)
                            && ([peek [expr {$result+11}]] == -123) && ([peek [expr {$result+12}]] == -55)
                            && (([peek [expr {$result-1}]] == 13) || ([peek [expr {$result-1}]] == -95))} {
                    #log [format "XX: found access at 0x%x" $result]
                    return $result
                }
            }
        }] == 2} {
            return $result
        }
    }
    return 0
}
# "peek" returns an 8-bit value. Here is the 32-bit variant of that.
proc peek32 {addr} {
  return [expr {([peek $addr]&0xff)+0x100*([peek [expr {$addr+1}]]&0xff)+0x10000*([peek [expr {$addr+2}]]&0xff)+0x1000000*([peek [expr {$addr+3}]]&0xff)}]
}
# "poke" changes an 8-bit location in memory. Here is the 32-bit variant of that.
proc poke32 {addr value} {
  poke $addr $value
  poke [expr {$addr+1}] [expr {$value >> 8}]
  poke [expr {$addr+2}] [expr {$value >> 16}]
  poke [expr {$addr+3}] [expr {$value >> 24}]
}
# Set the production state to $state and the associated item class to $obj_class.
proc set_prod_state {objid state {obj_class ""}} {
    set object_table 0
    catch {
        if [catch {
            #log "XX: attempting to fetch autoprod_ex_object_table, this might fail on the first attempt"
            set object_table [ref_get 0 autoprod_ex_object_table]
        }] {
            # initialize, so that we try this only once
            ref_set 0 autoprod_ex_object_table 0
            #log "XX: autoprod_ex_object_table was missing, searching for object table"
            # this is the address of the pointer to the manager table
            set manager_ptr_address [find_manager_access_ptr]
            #log "XX: manager pointer address: $manager_ptr_address"
            # this is a pointer to the manager
            set manager_ptr [peek32 $manager_ptr_address]
            #log "XX: manager pointer: $manager_ptr"
            # this is the address of the manager
            set manager [peek32 $manager_ptr]
            #log "XX: manager: $manager"
            # the object table is 0x488 bytes into the manager's memory
            set object_table [expr {$manager + 0x488}]
            ref_set 0 autoprod_ex_object_table $object_table
        }
        #log "XX: object table: $object_table"
        set object  [peek32 [expr {$object_table + $objid*4}]]
        #log "XX: object: $object"
        if {[peek32 [expr {$object + 0xdc}]] == $objid} {
            set component [peek32 [expr {$object + 0x3e0}]]
            #log "XX: component: $component"
            if {[peek32 [expr {$component + 0x20}]] == $object} {
                poke [expr {$component + 0x1c}] $state
                poke32 [expr {$component + 0x48}] [ClassID $obj_class]
            }
        }
    }
    # always return true, because this function is called from the current_worklist
    return true
}

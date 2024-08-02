$start
$replace
		uplevel 2 $body
	}
}
$with
		uplevel 2 $body
	}
}

proc list_gnomes {} {
    foreach g [obj_query 0 -type gnome -owner [get_local_player]] {
        print [format "%4d: %s" $g [get_objname $g]]
    }
}

proc list_errors {} {
    foreach o [obj_query 0 -type {gnome production energy protection store}] {
        catch {
            set e [ref_get $o errorInfo]
            if {$e != ""} {
                print [format "%4d (%s): %s" $o [get_objname $o] $e]
            }
        }
    }
}

#proc log_flush {} {
#    foreach o [obj_query 0 {}] {
#        catch {
#            obj_eval $o {
#                log "flush" 1
#            }
#        }
#    }
#}

proc find_container objid {
    set result {}
    foreach container [obj_query 0 -sorting none] {
        if {[inv_find_obj $container $objid] != -1} {
            lappend result $container
        }
    }
    return $result
}

proc all_dig {obj} {
    obj_eval $obj {
        set state "init"
        timer_proc
        while {$state != "init"} timer_proc
    }
}

proc kill_all_creatures {} {
    set monsters [obj_query 0 -class {Kristallbrut Lavabrut Alienpflanze Fresspflanze Spinne Troll Wuker Schwefelwuker}]
    if {$monsters != 0} {
        foreach monster $monsters {
            del $monster
        }
    }
}

proc fix_fenris {} {
    set fenris [obj_query 0 -class Fenris]
    if {$fenris == 0} {
        print "no Fenris found"
    } elseif {[llength $fenris] != 2} {
        print "expected exactly two Fenris"
    } else {
        set fenris0 [lindex $fenris 0]
        set fenris1 [lindex $fenris 1]
        if {[dist_between $fenris0 $fenris1] > 0.5} {
            print "two Fenris are already separated"
        } else {
            set chairs {}
            foreach obj [obj_query 0 -class Info_Fenris] {
                if {[call_method $obj get_info type] == "chairsitting"} {
                    lappend chairs $obj
                }
            }
            if {[llength $chairs] != 2} {
                print "expected exactly two chairs"
            } else {
                set current_chair -1
                set idx 0
                foreach chair $chairs {
                    if {[dist_between $chair $fenris0] < 2.5} {
                        set current_chair $idx
                    }
                    incr idx
                }
                if {$current_chair < 0} {
                    print "Fenris is not on his chair"
                    return
                } elseif {$current_chair == 0}  {
                    set_pos $fenris1 [get_pos [lindex $chairs 1]]
                    call_method $fenris1 standup
                    timer_event $fenris1 evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]
                } else {
                    set_pos $fenris0 [get_pos [lindex $chairs 0]]
                    call_method $fenris0 standup
                    timer_event $fenris0 evt_timer0 -repeat 0 -userid 0 -attime [expr [gettime]+1]
                }
            }
        }
    }
}

proc show_happiness {{gnome ""}} {
    if {$gnome == ""} {
        set gnome [get_selectedobject]
    }
    obj_eval $gnome {
        set ctime [gettime]
        set verdict {"not ok" "ok"}
        set last_talk 0
        catch {set last_talk $::spt_last_talk}
        global spt_fun_stations
        print "[get_objname this]'s mood is [get_attrib this atr_Mood]"
        print "gnome age: [expr {([gettime]-$::birthtime) / 1800.0}] days"
        print "civilization state = $::civ_state"
        print "food variety:  $::funloss_eatvariety"
        print "place variety: $::funloss_placevariety"
        print "food quality:  $::funloss_eatquality"
        print "sleep quality: $::funloss_slpquality"
        print "home quality:  $::funloss_homequality"
        print "bath quality:  $::funloss_bthquality"
        print ""
        print "last time talking:        [expr {$ctime-$last_talk}       ] seconds ago -> [lindex $verdict [expr {($spt_fun_stations & 1) != 0}]]"
        print "last time place activity: [expr {$ctime-$::spt_last_place}] seconds ago -> [lindex $verdict [expr {($spt_fun_stations & 2) != 0}]]"
        print "last time at living room: [expr {$ctime-$::spt_last_home} ] seconds ago -> [lindex $verdict [expr {($spt_fun_stations & 4) != 0}]]"
        print "last time sex:            [expr {$ctime-$::spt_last_sex}  ] seconds ago -> [lindex $verdict [expr {($spt_fun_stations & 8) != 0}]]"
        print "last time with partner:   [expr {$ctime-$::spt_last_prtn} ] seconds ago -> [lindex $verdict [expr {($spt_fun_stations & 16) != 0}]]"
    }
}

proc print_time_log {} {
    obj_eval [get_selectedobject] {
        #proc time_line_log x {print $x}
        sparetime_time_log 0
        #rename time_line_log ""
    }
}

$end

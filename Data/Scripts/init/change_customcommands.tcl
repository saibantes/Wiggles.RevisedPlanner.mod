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

proc count_bytes {{b 0}} {
    global count
    array unset count
    set start_addr [expr {[find_base_address] + $b}]
    set end_addr   [expr {$start_addr + 0x3ab000}]
    for {set addr $start_addr} {$addr < $end_addr} {incr addr} {
        if {[catch {incr count([peek $addr])}] == 1} {set count([peek $addr]) 1}
    }
}
proc peek32 {addr} {
  return [expr {([peek $addr]&0xff)+0x100*([peek [expr {$addr+1}]]&0xff)+0x10000*([peek [expr {$addr+2}]]&0xff)+0x1000000*([peek [expr {$addr+3}]]&0xff)}]
}
proc find_base_address {} {
    for {set addr 0x400000} {$addr < 0x1400000} {incr addr 0x10000} {
        if {[catch {peek $addr}] == 0} {
            return $addr
        }
    }
    return 0
}
proc find_manager_access_ptr {} {
    set result2 0
    
    for {set addr 0x10000} {$addr <= 0x1400000} {set addr [expr {($addr/0x10000+1)*0x10000}]} {
        catch {
            if {[peek $addr] != 77} continue;
            incr addr
            if {[peek $addr] != 90} continue;
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
                    print [format "XX: found access at 0x%x" $result]
                    set result2 $result
                }
            }
        }
        #if {$result2 != 0} {return $result2}
    }
    return $result2
}
proc get_prod_state {objid} {
    set manager_access_ptr_ptr [find_manager_access_ptr]
    print "XX: manager pointer ptr: $manager_access_ptr_ptr"
    set manager_ptr [peek32 $manager_access_ptr_ptr]
    print "XX: manager ptr: $manager_ptr"
    set manager [peek32 $manager_ptr]
    print "XX: manager: $manager"
    set object  [peek32 [expr {$manager + 0x488 + $objid*4}]]
    print "XX: object: $object"
    if {[peek32 [expr {$object + 0xdc}]] == $objid} {
        set component [peek32 [expr {$object + 0x3e0}]]
        print "XX: component: $component"
        if {[peek32 [expr {$component + 0x20}]] == $object} {
            return [peek32 [expr {$component + 0x1c}]]
        }
    }
}
proc get_selected_prod_state {} {
    return [get_prod_state [get_selectedobject]]
}
$end

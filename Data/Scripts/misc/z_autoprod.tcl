##nagelfar syntax lrem v x
##nagelfar syntax lrep v x x
##nagelfar syntax fincr v x

# Meine Basis:
#   183 breit, 48 hoch

if {[in_class_def]} {
    method autoprodx_do {task} {
        autoprodx_do_proc $task
    }
    method autoprod_rate_task {task num_gnomes num_kettensaege num_hammer num_strahl num_reithamster num_hoverboard max_inv num_injured} {
        autoprod_rate_task $task $num_gnomes $num_kettensaege $num_hammer $num_strahl $num_reithamster $num_hoverboard $max_inv $num_injured
    }
} else {
    call scripts/misc/autoprod.tcl
    
    set idle_start_time 0
    set blacklist_digpos  {}
    set blacklist_digtime {}
    set blacklist_items     {}
    set blacklist_item_time {}

    #==================================================================================================

    proc autoprod_rate_task {task num_gnomes num_kettensaege num_hammer num_strahl num_reithamster num_hoverboard max_inv num_injured} {
        global blacklist_digpos blacklist_digtime blacklist_items blacklist_item_time
        for {set idx [expr {[llength $blacklist_digtime]-1}]} {$idx >= 0} {incr idx -1} {
            set list_item [lindex $blacklist_digtime $idx]
            if {[gettime] - [lindex $list_item 0] > 3*150} {
                #log "blacklisting of digging at ([lindex $blacklist_digpos $idx]) expired"
                lrem blacklist_digpos  $idx
                lrem blacklist_digtime $idx
            }
        }
        for {set idx [expr {[llength $blacklist_item_time]-1}]} {$idx >= 0} {incr idx -1} {
            if {[gettime] - [lindex $blacklist_item_time $idx] > 150} {
                #log "blacklisting of item [lindex $blacklist_items $idx] expired"
                lrem blacklist_items     $idx
                lrem blacklist_item_time $idx
            }
        }

        #log "X: considering $task" 0
        # I prefer working at my preferred workplace
        # I disfavor working at someone elses workplace
        # I prefer doing stuff required for my preferred workplace (transport, farming material, ...)
        # I disfavor doing anything at any place other than my preferred workplace
        # I disfavor working at a Dojo unless it is my preferred workplace
        # I disfavor harvesting at a Farm unless it is my preferred workplace
        # I prefer doing stuff I have the right equipment for (Hoverboard, Kettensaege, Kristallstrahl, Steinschleuder)
        # I disfavor transporting when I don't have enough inventory space for it
        # I prefer doing stuff I am good at
        # I prefer doing stuff I can learn from
        # I prefer work close to my current position
        global myref
        set place             [lindex $task 0]
        set preferred_workers [lindex $task 1]
        set type              [lindex $task 2]
        set items             [lindex $task 3]
        
        set my_preferred_workplace [prod_gnome_get_preferred_workplace this]
        set i_am_preferred [expr {$my_preferred_workplace == $place}]
        set max_distance 500
        set travel 0
        set score ""
        switch $type {
            "carry" {
                set destination [lindex $task 4]
                set target $place
                set max_distance 1e37
                set inv_space [expr {[inv_getsize this]-[inv_cnt this]}]
                if {$inv_space <= 0} {
                    #log "X:   I have no free inventory space" 0
                    return -1e37
                }
                set request_size [hmin $max_inv [llength $items]]
                set inv_overload [expr {ceil(double($request_size)/$inv_space)-1}]
                append score -$inv_overload*1000
                if {$inv_overload != 0} {log "X:   -$inv_overload * 1000 due to lack of inventory space ($inv_space)" 0}
                # check my distance to the destination(!) location
                set path [vector_sub [get_pos this] [get_pos $destination]]
                set travel [expr {abs([vector_unpackx $path]) + 3*abs([vector_unpacky $path])}]
                if {!$i_am_preferred && ($travel > 500) && ([dist_between this $place] > 15)} {
                    #log "X:   that is too far away!"
                    return -1e37
                }
                # the real travel is from the place (the items are near that) to the destination
                set path [vector_sub [get_pos $place] [get_pos $destination]]
                set travel [expr {abs([vector_unpackx $path]) + 3*abs([vector_unpacky $path])}]
                if {!$i_am_preferred} {
                    append score -1000
                }
            }
            "bringprod" {
                set travel [lindex $task 4]
                set running_hamster [lindex $task 5]
                set target [lindex $items 0]
                set inv_space [expr {[inv_getsize this]-[inv_cnt this]}]
                if {$inv_space <= 0} {
                    #log "X:   I have no free inventory space" 0
                    return -1e37
                }
                set inv_overload [expr {ceil(double([llength $items])/$inv_space)-1}]
                append score -$inv_overload*200
                #if {$inv_overload != 0} {log "X:   -$inv_overload * 200 due to lack of inventory space ($inv_space)" 0}
                if {$running_hamster && ([inv_find this "Steinschleuder"] < 0)} {
                    append score -1000.0
                    #log "X:   I don't have a Steinschleuder for that Hamster" 0
                }
            }
            "work" {
                set influence [lindex $task 4]
                set gain      [lindex $task 5]
                set target $place
                
                # For task "work", preference counts more than for all other tasks.
                # In addition, not being preferred is a negative.
                if {$i_am_preferred} {
                    #log "X:   I prefer that work place" 0
                    append score +10000.0
                } else {
                    #if [llength $preferred_workers] {log "X:   Someone else prefers that work place" 0}
                    append score -2000.0*[llength $preferred_workers]
                    # special case: Dojo has low priority, unless assigned
                    if {[get_objclass $place] == "Dojo"} {
                        append score -3000.0
                        #log "X:   I am not assigned to that Dojo, so I would rather avoid it" 0
                    }
                }
                
                # check weapons for guardhouse
                if {[string first "Bewachen" $items] >= 0} {
                    #log "X:   My best weapon is [get_best_weapon this]" 0
                    # TODO: include modifier for certain weapon/shield/amulet combination
                    append score -200+[lindex [get_best_weapon this] 2]*400
                }
                
                # consider my current experience
                #log "X:   work requirements are ($influence)" 0
                set exper [obj_eval $place [list prod_getgnomeexper $myref [list $influence]]]
                #log "X:   My attributes for this work have a score of $exper (0.0 .. 1.0)" 0
                append score +$exper*200
                
                # consider experience gain
                foreach exp_incr $gain {
                    set genre [lindex $exp_incr 0]
                    set factor [clan_exp_factor $genre]
                    set increase [expr {[lindex $exp_incr 1]*$factor}]
                    if {[get_attrib this $genre] < $increase*100} {
                        append score +$increase*2000
                        #log "X:   I can gain $increase more on $genre during this task" 0
                    } else {
                        #log "X:   I am already maxed out on $genre for this task, nothing more to learn" 0
                    }
                }
                
                # special case: hospital
                if {[string first "Heilen" $items] >= 0} {
                    set nextorder [prod_guest nextorder $place]
                    if {($::last_workplace == $place) && ($nextorder >= 0)} {
                        #log "X:   I already started working here"
                        append score +100
                    }
                    if {$num_injured <= 0} {
                        #log "X:   noone is injured"
                        append score -5000
                    }
                    if {$nextorder > 0} {
                        #log "X:   patient is waiting for $nextorder"
                        append score +$nextorder*10
                    }
                }
                
                # special case: brothel
                if {$items == "_Liebesdienst"} {
                    global stt_maxsearch_range gnome_gender
                    set half_search_range [expr {$stt_maxsearch_range*0.5}]
                    set plist [sparetime $place queryrect sex -$stt_maxsearch_range -$half_search_range $stt_maxsearch_range $half_search_range]
                    #log "X:     all brothels in range: ($plist)"
                    set num_brothel 1
                    set num_same_sex 0
                    foreach other_place $plist {
                        if {($other_place != $place) && ([get_prod_slot_cnt $other_place _Liebesdienst] > 0)} {
                            incr num_brothel
                            set other_worker [call_method $other_place get_last_worker]
                            #log "X:     $other_worker was recently working at $other_place"
                            if {($other_worker != 0) && ($other_worker != $myref)} {
                                if {$gnome_gender == [call_method $other_worker get_gender]} {
                                    incr num_same_sex
                                }
                            }
                        }
                    }
                    #log "X:   $num_same_sex out of $num_brothel brothels have the same gender"
                    if {$num_same_sex*2 >= $num_brothel} {
                        append score -4000
                    }
                }
                
                # TODO: bei Lager stärker Reithamster bevorzugen ("travel" ausrechnen oder abschätzen)
            }
            "invent" {
                set target $place
            }
            "unpack" {
                set travel [expr {abs([get_posx $place]-[vector_unpackx $items])+3*abs([get_posy $place]-[vector_unpacky $items])}]
                set target $place
                if {[inv_getsize this]-[inv_cnt this] < 1} {
                    #log "X:   I have no free inventory space" 0
                    return -1e37
                }
            }
            "pack" -
            "buildup" {
                #add_expattrib this exp_Transport [expr {$tttgain_supply*[clan_exp_factor exp_Transpor]}]
                set target $place
            }
            "harvest" {
                set preemptive [lindex $task 4]
                append score -400.0*$num_kettensaege/$num_gnomes
                if {[inv_find this "Kettensaege"] >= 0} {
                    append score +400
                } else {
                    append score +[get_attrib this exp_Holz]*200
                }
                if {$preemptive && !$i_am_preferred} {
                    append score -1000
                }
                if {[lsearch $blacklist_items $items] >= 0} {
                    append score -30000
                }
                set target $items
            }
            "mine" {
                set target $items
                set itemclass [get_objclass $items]
                if {$itemclass=="Eisenerzbrocken"||$itemclass=="Golderzbrocken"} {
                    set attr [hmin [get_attrib this exp_Metall] 0.4]
                } else {
                    set attr [hmin [get_attrib this exp_Stein] 0.4]
                }
                #log "X:   My attributes for mining $itemclass have a score of $attr" 0
                append score +$attr*400
            }
            "dig" {
                set target [get_digedge $items this]
                # reachable?
                if {[lindex $target 0] < 0} {
                    #log "X:   I can't reach that digsite"
                    return -1e37
                }
                # If dig_next of the target position is not a valid position, it means that
                # the dig mark is in free air.
                # There may or may not be some continuation of that dig site into gravel.
                if {[vector_unpackx [dig_next $target this]] < 0} {
                    #log "X:   digsite probably in free air"
                    if {[vector_dist $target [get_pos this]] > 20.0} {
                        return -1e37
                    }
                }
                global blacklist_digpos blacklist_digtime
                set idx [lsearch $blacklist_digpos $items]
                if {$idx >= 0} {
                    append score -300*[lindex [lindex $blacklist_digtime $idx] 1]
                }
                # TODO: Kristallstrahl is not suitable for vertical tunnels
                #       But how do we detect tunnel shape?
                append score -(1000.0*$num_strahl+500.0*$num_hammer)/$num_gnomes
                if {[inv_find this "Kristallstrahl"] >= 0} {
                    append score +1000
                } elseif {[inv_find this "Presslufthammer"] >= 0} {
                    append score +500
                }
                set attr [hmin [get_attrib this exp_Stein] 0.561]
                #log "X:  my attributes for digging have a score of $attr"
                append score +$attr*300
                # TODO: Consider experience gain?
                #       It does depend on the size of the hole though ...
                #       It would be the same as for "work", but with $tttgain_dig instead of $gain.
            }
            default {
                #log "X:   I don't know how to do that"
                return -1e37
            }
        }
        #if {$my_preferred_workplace} {log "X:   pref:[get_prod_total_task_cnt $my_preferred_workplace] && [get_prod_enabled $my_preferred_workplace] && [get_prodautoschedule $my_preferred_workplace] && [get_prod_schedule $my_preferred_workplace]" 0}
        if {$i_am_preferred} {
            #log "X:   I prefer working for that work place" 0
            append score +1000.0
            # if I have another preferred workplace,
            # and that workplace is active ...
        } elseif {$my_preferred_workplace && 
                 [get_prod_total_task_cnt $my_preferred_workplace] &&
                 [get_prod_enabled $my_preferred_workplace] &&
                 [get_prodautoschedule $my_preferred_workplace] &&
                 [get_prod_schedule $my_preferred_workplace]
        } then {
            #log "X:   I have a different preferred workplace that is active" 0
            set my_preferred_workplace_has_work 0
            # if my preferred workplace has actually fulfillable jobs
            #   (either buildable immediateyly or I can invent it now)
            foreach item [get_prod_task_list $my_preferred_workplace] {
                #log "X:   pref $item: [get_prod_slot_invented $my_preferred_workplace $item] ? [get_prod_slot_buildable $my_preferred_workplace $item] : [gnome_invent_possible this $item]" 0
                if {[get_prod_slot_invented $my_preferred_workplace $item] ?
                    [get_prod_slot_buildable $my_preferred_workplace $item] :
                    [gnome_invent_possible this $item]
                } then {
                    set my_preferred_workplace_has_work 1
                    break
                }
            }
            if {$my_preferred_workplace_has_work} {
                #log "X:   I prefer working elsewhere" 0
                append score -10000.0
            } else {
                #log "X:   My preferred workplace has currently no fulfillable tasks" 0
            }
        }
        
        if {[inv_find this "Hoverboard"] >= 0} {
            set my_speed 3.0
        } elseif {[inv_find this "Reithamster"] >= 0} {
            set my_speed 2.1
        } else {
            set my_speed 1.5
        }
        if {$travel > 0} {
            set average_speed [expr {($num_hoverboard*3.0 \
                                     +$num_reithamster*2.1 \
                                     +($num_gnomes-$num_hoverboard-$num_reithamster)*1.5) / $num_gnomes}]
            #log "X:   My speed is $my_speed, average gnome speed is $average_speed" 0
            append score +20*($travel/$average_speed-$travel/$my_speed)
        }
        # <target> is either an object ID or an x/y position
        if {[llength $target] == 1} {
            set target [get_pos $target]
        }
        set travel [expr {abs([get_posx this]-[vector_unpackx $target])+3*abs([get_posy this]-[vector_unpacky $target])}]
        #log "X:   My distance from the job would be $travel" 0
        if {($travel > $max_distance) && !$i_am_preferred} {
            #log "X:   that is too far away!"
            return -1e37
        }
        if {$travel <= 5} {
            #log "X:   I am already at that place"
            append score +25
        }
        append score -$travel/$my_speed
        
        ##nagelfar ignore Expr without braces
        #log "X:   total score is [expr $score] = $score"
        
        ##nagelfar ignore Expr without braces
        return [expr $score]
    }
    
    #==================================================================================================

    proc autoprodx_do_proc {task} {
        global current_plan current_workplace current_worktask current_workclass current_worklist
        global last_event idle_start_time liebesdienst_gender
        
        #if {$current_workplace !=0} {log "WARNUNG: current_workplace=$current_workplace"}
        #if {$current_worklist !=""} {log "WARNUNG: current_worklist=$current_worklist"}
        
        #log "X: idle timer: [expr {[gettime] - $idle_start_time}]"
#        if {$::idletimeout < 10} {return 0}
        set state [state_get this]
        if {(($state != "work_idle") && ($state != "prodfill_dispatch")) ||
            ([gettime] - $idle_start_time < 9.5)} {return 0}

        tasklist_clear this
        stop_prod
        notify_autoevent

        #log "X: starting assigned task $task" 0

        set last_event ""
        set liebesdienst_gender ""
        set current_plan "work"
        set current_workclass 0
        set current_workplace 0
        
        set place [lindex $task 0]
        set type  [lindex $task 2]
        set items [lindex $task 3]
        switch $type {
            "carry" {
                set destination [lindex $task 4]
                set current_worktask "carry"
                set current_workplace $place
                prod_change_muetze "transport"
                set_objworkicons this [get_objclass $place] arrow_right
                set lastcarry [expr {[inv_getsize this]-[inv_cnt this]-1}]
                set items [lrange $items 0 $lastcarry]
                prod_gnome_last_workplace this $place
                prod_gnome_state this transport [lindex $items 0] $place
                foreach item $items {
                    lappend current_worklist "set ::walkfail_tasks {{log walkfail} {expr 1}}; pickup_nofail $item; expr 1"
                }
                set drop_items {log "dropping all items because I couldn't find my destination"}
                foreach item $items {
                    lappend drop_items "if \{\[inv_find_obj this $item\]>=0\} \{beamto_world $item\}"
                }
                lappend current_worklist "set ::walkfail_tasks \"$drop_items\" ; expr 1"
                set is_first_item 1
                foreach item $items {
                    lappend current_worklist "if \{\[inv_find_obj this $item\]>=0\} \{prod_deliver $item $destination $is_first_item\} \{handle_pickupfail $item $place\}"
                    set is_first_item 0
                }
                lappend current_worklist "set ::walkfail_tasks {}; expr 1"
                lappend current_worklist "call_method $place autoprod_stop"
                state_triggerfresh this work_dispatch
            }
            "bringprod" {
                set current_worktask "bringprod"
                set current_workplace $place
                prod_change_muetze "transport"
                set_objworkicons this [get_objclass [lindex $items 0]] arrow_right [get_objclass $place]
                set lastcarry [expr {[inv_getsize this]-[inv_cnt this]-1}]
                set items [lrange $items 0 $lastcarry]
                prod_assignworker this $place
                prod_gnome_last_workplace this $place
                prod_gnome_state this transport [lindex $items 0] $place
#                set_prodalloclock $place 1
#                set_prodalloclock this 1
                foreach item $items {
                    # Problem: take_item löscht sowohl tasklist als auch current_worklist im Fehlerfall
                    # ignore errors in pickup, continue with all the other items!
                    # call pickup twice: Helps in particular with Hamsters, which might
                    #   move while we walk there.
                    if {[get_attrib $item farmed]} {
                        # walk close to items in farms first, 
                        # this helps with Hamsters, which may walk around
                        lappend current_worklist "set ::walkfail_tasks {{expr 1}}; walk_near_item $item 0.2 3; expr 1"
                    }
                    lappend current_worklist "set ::walkfail_tasks {{expr 1}}; pickup_nofail $item; expr 1"
                }
                #set drop_items {log "dropping all items because I couldn't find my destination"}
                foreach item $items {
                    lappend drop_items "if \{\[inv_find_obj this $item\]>=0\} \{beamto_world $item\}"
                }
                lappend current_worklist "set ::walkfail_tasks \"$drop_items\" ; expr 1"
                foreach item $items {
                    lappend current_worklist "if \{\[inv_find_obj this $item\]>=0\} \{prod_bringtoprod $item $place\} \{handle_pickupfail $item $place\}"
                }
                lappend current_worklist "set ::walkfail_tasks {}; expr 1"
                lappend current_worklist "call_method $place autoprod_stop"
#log "list=$current_worklist" 0
                state_triggerfresh this work_dispatch
            }
            "invent" -
            "work" {
                if {$type == "work"} {
                    set muetze [get_class_category $items]
                    #if {$muetze == "none"} {log "ERROR: hat confusion"}
                    #log "X: fitting hat is $muetze"
                    prod_gnome_state this build $place $items
                    prod_change_muetze $muetze
#log "set_objworkicons this [get_objclass $place] Hammer $items" 0
                    set_objworkicons this [get_objclass $place] Hammer [string trim $items _]
                } else {
                    prod_gnome_state this invent $place $items
                    set items Bp$items
                    set_objworkicons this question [get_objclass $place]
                    prod_change_muetze "erfinden"
                }
                set current_workclass $items
                set current_worktask "work"
                set current_workplace $place
#                set place_pos [get_pos $place]
#                if {[vector_dist $place_pos [get_pos this]] > 2.0} {
#                    lappend current_worklist "walk_pos \"[vector_setz $place_pos 14.0]\"; expr 1"
#                }
                # prod_autobuild and other prod_* procs must not be in current_worklist!
                # (doesn't work, because they overwrite current_worklist)
                # prod_autobuild should not be called directly here!
                # (doesn't quite work, because methods are called without using global namespace)
                tasklist_add this "prod_autobuild $items $place"
                if {![get_prod_switchmode $place]} {
                    ##nagelfar ignore Found constant * which is also a variable
                    tasklist_add this [list lappend current_worklist [list autoprod_reduce_workcount $place $items]]
                }
                ##nagelfar ignore Found constant * which is also a variable
                tasklist_add this [list lappend current_worklist [list call_method $place autoprod_finished]]
                
                prod_assignworker this $place
                prod_gnome_last_workplace this $place
                
                state_triggerfresh this work_dispatch
            }
            "harvest" {
                set current_worktask "harvest"
                # TODO: current_workclass
                set current_workplace $place
                prod_change_muetze "wood"
                set_objworkicons this Axt Pilz
                global walkfail_tasks
                set     walkfail_tasks {"unset walkfail_tasks"}
                lappend walkfail_tasks "lappend ::blacklist_items $items"
                lappend walkfail_tasks "lappend ::blacklist_item_time [gettime]"
                lappend walkfail_tasks "walkfail"
                harvest $items
                lappend current_worklist "set walkfail_tasks {}; expr 1"
                lappend current_worklist "call_method $place autoprod_stop"
                
                prod_gnome_last_workplace this $place
                prod_gnome_state this harvest $items
                
                state_triggerfresh this work_dispatch
            }
            "mine" {
                set current_worktask "mine"
                # TODO: current_workclass
                set current_workplace $place
                prod_change_muetze "stone"
                set_objworkicons this Spitzhacke [get_objclass $items]
                mine $items 3
                lappend current_worklist "call_method $place autoprod_stop"
                
                prod_gnome_last_workplace this $place
                prod_gnome_state this harvest $items
                
                state_triggerfresh this work_dispatch
            }
            "unpack" {
                global current_worknum current_workpos
                set current_worknum [lindex $task 4] ;# as_box
                set current_workpos [lindex $task 3]

                set current_workplace $place
                set current_worktask "unpack"
                prod_change_muetze "service"
                set_objworkicons this arrow_up [get_objclass $place]
                prod_gnome_state this unpack $place $current_workpos
                
                if {[pickup $place]} {
                    set     walkfail_tasks {"unset walkfail_tasks"}
                    lappend walkfail_tasks {log "X: failed to unpack, retrying"}
                    lappend walkfail_tasks [list prod_autounpack $place $current_workpos]
                    prod_autounpack $place $current_workpos
                    lappend current_worklist "set walkfail_tasks {}; expr 1"
                } else {
                    #log "X: couldn't pick up [get_objname $place]" 0
                }
            }
            "pack" {
                set current_workplace $place
                set current_worktask "pack"
                prod_change_muetze "service"
                set_objworkicons this arrow_down [get_objclass $place]
                prod_gnome_state this pack $place
                
                set_prod_unpack $place 0
                prod_autopack $place
            }
            "buildup" {
                set current_workplace $place
                set current_worktask "buildup"
                prod_change_muetze "service"
                set_objworkicons this arrow_up [get_objclass $place]
                prod_gnome_state this unpack $place [get_pos $place]
                
                prod_autobuildup $place
            }
            "dig" {
                global current_digpos idletimeout blacklist_digpos blacklist_digtime
                set current_worktask "dig"
                set current_workplace "dig"
                set current_digpos $items
                set idletimeout 0
                
                set idx [lsearch $blacklist_digpos $current_digpos]
                if {$idx >= 0} {
                    set list_item [lindex $blacklist_digtime $idx]
                    set count [expr {[lindex $list_item 1]+1}]
                    set list_item [list [gettime] $count]
                    #log "blacklisting digsite ($current_digpos) for the #$count time"
                    lrep blacklist_digtime $idx $list_item
                } else {
                    set count 1
                    set list_item [list [gettime] $count]
                    #log "blacklisting digsite ($current_digpos) for the #$count time"
                    lappend blacklist_digtime $list_item
                    lappend blacklist_digpos  $current_digpos
                }
                
                prod_change_muetze "stone"
                set_objworkicons this Spitzhacke
                dig_starttask $items
                prod_gnome_state this dig "$items"
                state_triggerfresh this work_dispatch
            }
            default {
                set current_worktask ""
                return 0
            }
        }
        return 1
    } ;# autoprodx_do_proc

    #==================================================================================================

    proc autoprod_reduce_workcount {place item} {
        if {[string equal -length 2 $item "Bp"]} {
            set item [string range $item 2 end]
        }
        set num [get_prod_slot_cnt $place $item]
        if {($num > 0) && ($num < 10)} {
            set_prod_slot_cnt $place $item [expr {$num-1}]
        }
        return true
    }
    
    #==================================================================================================

    # just like <proc pickup>, but calling <take_item_nofail> instead of <take_item>
    regsub -all {\mtake_item\M} [info body pickup] {take_item_nofail} pickup_new_body
    ##nagelfar ignore Non constant argument to proc
    proc pickup_nofail    [info args pickup]    $pickup_new_body
    
    #==================================================================================================

    # just like <proc take_item>, but don't delete $current_worklist
    regsub -all {set\s+current_worklist\s+{}} [info body take_item] {} take_item_new_body
    ##nagelfar ignore Non constant argument to proc
    proc take_item_nofail [info args take_item] $take_item_new_body

    #==================================================================================================
    
    proc handle_pickupfail {item place} {
        #if {[obj_valid $item]} {
        #    log "X: couldn't pick up [get_objname $item]" 0
        #} else {
        #    log "X: coldn't pick up item $item (invalid)"
        #}
        if {[path this [get_pos this] [get_pos $place]] >= 0} {
            call_method $place autoprod_blacklist $item
        }
        return true
    }
    
    #==================================================================================================

    # TODO: zwerg jetzt ausgewachsen?
    proc autoprod_ex_gnomeidle {gnome} {
        global current_workplace
        #log "X: $gnome is now idle"
        autoprod_ex [get_owner $gnome]
        return [expr {$current_workplace != 0}]
    }
    
    #==================================================================================================

    proc prod_deliver {item destination is_first_item} {
        set dest_z [get_posz $destination]
        set itempos [get_place -center [get_pos $destination] -rect -20 [expr {11-$dest_z}] 20 [expr {14.3-$dest_z}] -random [expr {$is_first_item?10:2}] -nearpos [get_pos this]]
        if {[lindex $itempos 0]<0} {
            set itempos [get_place -center [get_pos $destination] -rect -30 [expr {11-$dest_z}] 30 [expr {14.3-$dest_z}] -random [expr {$is_first_item?10:2}] -nearpos [get_pos this] -materials false]
            if {[lindex $itempos 0]<0} {
                set itempos [get_pos this]
                return true
            }
        }
        tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
        tasklist_addfront this "play_anim benda"
        tasklist_addfront this "rotate_towards \{$itempos\}"
        tasklist_addfront this "walk_near_item \{$itempos\} 0.7 0.1 auto 1.25"
        return true
    }
    


    
    #==================================================================================================

}



#Material liefern
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_PICKUP
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_TRANSFERPROD

#Produzieren
# EVT_AUTOPROD_WORKAT

#Pilz umhauen
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_HARVEST

#Auspacken
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_PICKUP
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_UNPACK
#Auspackkoordinaten:
# vector_sub [lindex [check_ghost_coll bbox this $item] 0] [get_negbbox $item]
# ist schlechter: vector_mul [eval vector_add [check_ghost_coll bbox this 442]] 0.5

#Energie
# EVT_AUTOPROD_WALK
# EVT_AUTOPROD_WORKAT


# get_remaining_sparetime -> 0 während der Arbeit, sonst 6.0 .. 0.0
# get_worktime next/laststart: springt um am Arbeitsanfang, absolute Stunden seit Spielanfang
# get_worktime next/lastend:   springt um zum Freizeitanfang, absolute Stunden seit Spielanfang
# start, end, duration: Anzahl Stunden pro Tag, fest
# -> [gethours] - 150*[get_worktime $gnome laststart]

# gnome_idle        -> Idle-Timer starten, bei 10s kann der Autoprod zuschlagen
# prod_gnomeidle    -> Idle-Timer starten




# Speed due to different transport mechanisms
# Speed just by running:  1.6
# Speed with Reithamster: 2.7
# Speed with Hoverboard:  3.0
# However, passing vertical shafts takes extra time. It takes more time the higher advanced
# the transport is.
# Assuming we have one Shaft every 75 units of length (VERY rough estimate), we have a 
# resulting speed of:
# Runnig: 1.5 ; Hamster: 2.1 ; Hoverboard: 3.0
# Vertical Speed on a ladder is roughly 1.0
# Vertical shafts are farther apart, so vertical movement requires additional horizontal
# movement to the next shaft.

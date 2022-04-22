##nagelfar syntax lrem v x
##nagelfar syntax fincr v x

if {[in_class_def]} {
    # select a task for this production facility
    method get_autoprod {} {
        get_autoprod_proc
    }
    method get_autoprod_inventions {} {
        get_autoprod_inventions_proc
    }
    method autoprod_stop  {} {
        autoprod_unlock_items
        return true
    }
    method autoprod_finished {} {
        catch {unset ::autoprod_planned_task}
        return true
    }
    method autoprod_blacklist {item} {
        lappend ::blacklist_items $item
        lappend ::blacklist_time [gettime]
    }

} else {
    # this only works if set_anim is called before including genericprod in obj_init of this class,
    # so we might need to fix it later
    set ::autoprod_negbbox [get_negbbox this]

    call scripts/misc/autoprod.tcl
    
    set autoprod_items {}
    set blacklist_items {}
    set blacklist_time {}
    
    proc autoprod_unlock_items {} {
        global autoprod_items
        #log "X: unlocking all items: $autoprod_items"
        foreach item $autoprod_items {
            set_lock $item 0
        }
        set autoprod_items {}
    }
    
    proc get_autoprod_inventions_proc {} {
        set inventions {}
        foreach item [get_prod_task_list this] {
            if {![get_prod_slot_invented this $item]} {
                #log "$item inventable: [get_prod_slot_inventable this $item]"
            }
            if {![get_prod_slot_invented this $item] && [get_prod_slot_inventable this $item]} {
                lappend inventions $item
            }
        }
        return $inventions
    }


    proc get_autoprod_proc {} {
#        log "X: enabled=[get_prod_enabled this] mat_need=[get_prod_materialneed this] sched=[get_prod_schedule this] builtup=[get_buildupstate this] boxed=[get_boxed this] directevents=[get_prod_directevents this] prodalloclock=[get_prodalloclock this]" 0
        autoprod_unlock_items
        if {[get_buildupstate this]} {
            set_prod_unpack  this 0
            set_prod_buildup this 0
        }
        if [get_prod_unpack this] {
            #log "X: unpack me"
            # OK, let's do some wild hacks!
            # This stupid engine won't tell us where to unpack the thing. But it tells us it's ghost's collision box.
            # Assumption: We are not unpacking it but just relocating the box when the diagonal of the ghost's collision box
            #             is smaller than 1.11 (boxes seem to be like 1.10739 in diagonal).
            # "get_negbbox" will tell us the coordinates of the corner relative to the anchor point, but for the box
            # if it is currently boxed. Just calling "set_boxed" and then immediately "get_negbbox" will not give
            # us the unboxed measures. Therefore we need to call "get_negbbox" on an already unboxed item.
            # We will try to do so during creation (see a few lines up), but that doesn't work always either.
            # When it didn't work we will query other instances of the same class and failing that, create
            # a temporary new instance.
            set ghost_bbox [check_ghost_coll bbox 0 this]
            #log "ghost: $ghost_bbox"
            if {$ghost_bbox != 0} {
                set ghost_size [eval vector_dist $ghost_bbox]
                set as_box [expr {$ghost_size < 1.11}]
                
                set myclass [get_objclass this]
                if {$as_box} {
                    set negbbox [get_negbbox this]
                } else {
                    global autoprod_negbbox
                    if {[llength $autoprod_negbbox] != 3} {
                        #log "need to figure out negbbox first"
                        # The variable autoprod_negbbox is normally set on object creation, but sometimes
                        # that doesn't work. Now we have to figure it out the hard way.
                        # First, try asking other instances of the same class if they already found it.
                        set found 0
                        foreach instance [obj_query 0 -class $myclass] {
                            catch {set autoprod_negbbox [ref_get $instance ::autoprod_negbbox]}
                            if {[llength $autoprod_negbbox] == 3} {
                                #log "[get_objname $instance] already knows: $autoprod_negbbox"
                                set found 1
                                break
                            }
                        }
                        if {!$found} {
                            # If noone else knows, we create a new object and measure that one.
                            # This is the slowest method possible, it will also count the object name
                            # one up (e.g. "Farm_1" -> "Farm_2").
                            set temp_obj [new $myclass]
                            set autoprod_negbbox [get_negbbox $temp_obj]
                            del $temp_obj
                            #log "had to create a fresh object: $autoprod_negbbox"
                        }
                    }
                    set negbbox $autoprod_negbbox
                }
                #log "negbbox: $negbbox"
                set ghost_pos [vector_sub [lindex $ghost_bbox 0] $negbbox]
                if {[string equal -length 6 $myclass "Leiter"]} {
                    #log "special case: Ladder"
                    set ghost_pos [vector_sety $ghost_pos [expr {[vector_unpacky [lindex $ghost_bbox 1]]-0.6}]]
                }
                #log "target pos: $ghost_pos"
                set ghost_pos  [vector_pack [expr {0.5*round(2*[vector_unpackx $ghost_pos])}]  \
                                            [expr {0.5*round(2*[vector_unpacky $ghost_pos])}]  \
                                            [expr {0.5*round(2*[vector_unpackz $ghost_pos])}]]
                #log "target pos: $ghost_pos"
                set ::autoprod_unpack_pos   $ghost_pos
                set ::autoprod_unpack_asbox $as_box
            } else {
                #log "no ghost for unpacking, using stored value" 1
                # reloading a saved game will not restore the ghosts, so we need to remember them for that case
                if {[catch {
                    set ghost_pos $::autoprod_unpack_pos
                    set as_box    $::autoprod_unpack_asbox
                }] != 0} {
                    #log "oopsie: no stored value, can't unpack" 1
                    return ""
                }
            }
            
            return "unpack \"$ghost_pos\" $as_box"
        }
        catch {unset ::autoprod_unpack_pos}
        catch {unset ::autoprod_unpack_asbox}
        if [get_prod_pack this] {
            #log "X: pack me"
            return "pack"
        }
        if [get_prod_buildup this] {
            #log "X: build me ([get_buildupstate this])"
            return "buildup"
        }
        if {![get_buildupstate this]} {
            return ""
        }
        if {![get_prod_enabled this]} {
            return ""
        }
        set tasks [get_prod_task_list this]
        if {![get_prod_schedule this]} {
            #log "X: no schedule here"
            # check if this is a Pilzfarm where we should cut down a Pilz
            #log "([get_objclass this] == Farm) && ($tasks == Pilz) && ![get_prod_materialneed this]"
            # TODO: this is a low-priority task
            if {([get_objclass this] == "Farm") && ($tasks == "Pilz") && ![get_prod_materialneed this]} {
                foreach c {Pilzhut Pilzstamm} {
                    set items [obj_query this "-class $c -boundingbox \{-2 -0.5 -3 2 0.5 2.5\} -flagneg contained"]
                    if {[llength $items] < 2} {
                        set pilze [obj_query this "-class Pilz -boundingbox \{-2 -0.5 -3 2 0.5 2.5\} -flagneg contained"]
                        while {[llength $pilze] > 0} {
                            set idx [irandom [llength $pilze]]
                            set item [lindex $pilze $idx]
                            if {($item != 0) && ([get_attrib $item PilzAge] == 3)} {
                                #log "X: so little stuff here, we might as well cut down another Pilz"
                                return "harvest $item"
                            }
                            lrem pilze $idx
                        }
                        return ""
                    }
                }
            }
            return ""
        }
        #if {[llength $tasks] > 0} {log "X: [get_objname this] wants to build ($tasks)" 0}
        # find a production task that can be build
        set task ""
        global autoprod_planned_task
        if {[info exists autoprod_planned_task]} {
            if {[lsearch $tasks $autoprod_planned_task] >= 0} {
                set task $autoprod_planned_task
                #log "X: already picked $task" 0
            } else {
                unset autoprod_planned_task
            }
        }
        set find_next_feasable_prod 1
        while {$find_next_feasable_prod} {
            set find_next_feasable_prod 0
            if {$task == ""} {
                while {[llength $tasks] > 0} {
                    # TODO: Zufall gewichten nach Zahl der Items
                    set idx [irandom [llength $tasks]]
                    set task [lindex $tasks $idx]
                    if {[get_prod_slot_buildable this $task] 
                    && [get_prod_slot_invented this $task] 
                    && [get_prod_slot_cnt this $task]} break
                    #log "X: $task can't be build" 0
                    lrem tasks $idx
                }
                if {[llength $tasks] == 0} {return ""}
                lrem tasks $idx
                #log "X: randomly picked $task" 0
            }
            if {![get_prod_materialneed this]} {
                #log "X: no material needed" 0
                set need_mat {}
            } else {
                set need_mat [call_method this prod_item_materials $task]
                set has_mat  [inv_list this]
                #log "X: already have items ($has_mat)" 0
                foreach item $has_mat {
                    set idx [lsearch -exact $need_mat [get_objclass $item]]
                    if {$idx >= 0} {
                        lrem need_mat $idx
                    }
                }
                #log "X: still need ($need_mat)" 0
            }
            if {[llength $need_mat] == 0} {
                #log "X: now get the job done!"
                ##nagelfar ignore Non constant argument to global
                global tttinfluence_$task tttgain_$task
                ##nagelfar ignore Suspicious variable name
                return "work $task \"[set tttinfluence_$task]\" \"[set tttgain_$task]\""
            }
            
            # remove expired items from blacklist
            global blacklist_items blacklist_time
            while {([llength $blacklist_time] > 0) && ([gettime] - [lindex $blacklist_time 0] > 3*150)} {
                #catch {log "X: blacklisting of [get_objname [lindex $blacklist_items 0]] expired" 0}
                lrem blacklist_items 0
                lrem blacklist_time 0
            }
            
            set my_x [get_posx this]
            set my_y [get_posy this]
            set bbox {-200 -100 -30 +200 +100 +30}
            set result {}
            
            set found_mat [concat \
                [obj_query this -class $need_mat -boundingbox $bbox -owner {own world} -visibility own -sorting none -flagneg {locked contained}]      \
                [obj_query this -class $need_mat -boundingbox $bbox -owner {own world} -visibility own -sorting none -flagneg locked -flagpos instore] \
            ]
            set mining_mat  {Stein Kohle Kristallerz Golderz Eisenerz}
            set mining_node {Steinbrocken Kohlebrocken Kristallerzbrocken Golderzbrocken Eisenerzbrocken}
            foreach raw_mat $mining_mat {
                if {[lsearch -exact $need_mat $raw_mat] >= 0} {
                    #log "X: also considering to mine ${raw_mat}brocken" 0
                    set found_mat [concat $found_mat [obj_query this -class ${raw_mat}brocken -boundingbox $bbox -owner {own world} -visibility own -sorting none -flagneg locked]]
                }
            }
            if {[land $need_mat {Pilzhut Pilzstamm}] != ""} {
                #log "X: also considering to cut down Pilze" 0
                set found_mat [concat $found_mat [obj_query this -class Pilz -boundingbox $bbox -owner {own world} -visibility own -sorting none -flagneg locked]]
            }
            set found_mat [lsort -unique $found_mat]
            set total_path 0.0
            set running_hamster 0
            global autoprod_items
            while {[llength $need_mat] > 0} {
                set min_dist 1e37
                set found_mat_idx 0
                foreach item $found_mat {
                    if {[lsearch $blacklist_items $item] >= 0} {
                        #log "[get_objname $item] is blacklisted" 0
                        continue
                    }
                    set found_class [get_objclass $item]
                    if {$found_class == "Pilz"} {
                        if {[get_attrib $item PilzAge] == 3} {
                            # a Pilz can supply both Pilzhut and Pilzstamm
                            set idx [lsearch $need_mat "Pilzhut"]
                            if {$idx < 0} {
                                set idx [lsearch $need_mat "Pilzstamm"]
                            }
                            # the cost of cutting down a Pilz is equivalent to a distance of <x>
                            set dist 50
                        } else {
                            # Possible optimization: remove underaged Pilz from list, so we don't consider
                            # it again. This messes up indices if we don't have all Pilz at the end.
                            set idx -1
                        }
                    } elseif {[lsearch $mining_node $found_class] >= 0} {
                        set idx [lsearch $need_mat [string range $found_class 0 end-7]]
                        # the cost of mining a Brocken is equivalent to a distance of <x>
                        set dist 50
                    } else {
                        set idx [lsearch $need_mat $found_class]
                        set dist 0
                    }
                    if {$idx >= 0} {
                        fincr dist [expr {abs($my_x-[get_posx $item])+abs($my_y-[get_posy $item])*3}]
                        if {($found_class == "Hamster") && !([get_attrib $item paralyzed] || [get_attrib $item farmed])} {
                            # non-paralyzed, non-farmed hamsters count as if <x> units further away
                            fincr dist 150
                        }
#log "found $item ([get_objname $item]) $dist away"
                        if {$dist < $min_dist} {
                            set min_dist $dist              ;# the distance of the closest found item so far
                            set closest_item $item          ;# the objid of the closest item found so far
                            set need_idx $idx               ;# the index in the $need_mat list of that item
                            set consume_idx $found_mat_idx  ;# the index in the $found_mat list of that item
                            set closest_class $found_class  ;# the item class of that item
                        }
                    }
                    incr found_mat_idx
                }
                # did we find anything in range?
                if {$min_dist > 2*200} {
                    #log "WARNUNG: couldn't find material"
                    # find another production item instead
                    catch {unset autoprod_planned_task}
                    set task ""
                    set find_next_feasable_prod 1
                    break
                }
                set autoprod_planned_task $task
                # if the closest matching item we found is a living Pilz, cut that down first
                if {$closest_class == "Pilz"} {
                    #log "X: better cut down that Pilz!"
                    set_lock $closest_item 1
                    lappend autoprod_items $closest_item
                    return "harvest $closest_item"
                }
                # if the closest matching item we found is a Brocken, mine that thing first
                if {[string match "*brocken" $closest_class]} {
                    #log "X: better mine that Brocken!"
                    set_lock $closest_item 1
                    lappend autoprod_items $closest_item
                    return "mine $closest_item"
                }
                # make note if the closest matching item is a freely running Hamster
                if {($closest_class == "Hamster") && !([get_attrib $closest_item paralyzed] || [get_attrib $closest_item farmed])} {
                    #log "X: The Hamster $closest_item it loose!" 0
                    set running_hamster 1
                }
#log "best item is #$consume_idx $closest_item ([get_objname $closest_item]), $min_dist away, needed as $need_idx"
                # keep a list of all found items in reverse order of finding
                set result [linsert $result 0 $closest_item]
                fincr total_path $min_dist
                # one less item we need to look for
                lrem need_mat $need_idx
                # don't use that item twice
                lrem found_mat $consume_idx
                # search for the next item around the position of the current item
                # (for best path when collecing all in one run)
                set my_x [get_posx $closest_item]
                set my_y [get_posy $closest_item]
            }
        }
        #log "X: bring me ($result)"
        foreach item $result {
            lappend autoprod_items $item
            set_lock $item 1
        }
        return [list "bringprod" $result $total_path $running_hamster]
    } ;# get_autoprod_proc
    
    proc autoprod_ex_prodchanged {} {
        #log "X: got production change on [get_objname this]"
        action this wait 0.5 {autoprod_ex [get_owner this]}
    } ;# autoprod_ex_prodchanged
}




#get_prod_buildup            ‹object›            get object unpack task state
#get_prod_directevents       ‹objref›            set switch production mode             ????
#get_prod_enabled            ‹objref›            get true if energy source is on        ????
#get_prod_exclusivemode      ‹objref›            set exclusive production mode          ????
#get_prod_materialneed       ‹objref›            set the need of materials              ????
#get_prod_ownerstrength      ‹object›            get object owner strength              ????
#get_prod_pack               ‹object›            get object pack task state
#get_prod_schedule           ‹objref›            set switch production mode             ????
#get_prod_slot_buildable     ‹object› ‹class›    check if slot is buildable             probably material availability -> not orange marked
#get_prod_slot_cnt           ‹object› ‹itemclass›    get task count for production slot
#get_prod_slot_inventable    ‹object› ‹class›
#get_prod_slot_invented      ‹object› ‹class›
#get_prod_slot_list          ‹object›
#get_prod_switchmode         ‹objref›            set switch production mode             Ein/Aus-Schalter statt Produktionszähler
#get_prod_task_list          ‹object›            get list of open tasks
#get_prod_toolneed           ‹objref›            set the need of tools                  vielleicht noch nicht implementiert?
#get_prod_total_task_cnt     ‹object›            get total number of open tasks
#get_prod_unpack             ‹object›            get object unpack task state
#get_prodalloclock           ‹objref›            get production alloc state             vielleich Material für die aktuelle Produktion?
#get_prodautoschedule        ‹objref›            get production auto schedule

#prod_assignworker                  ‹objref› ‹prodplace›    announce worker assignment
#prod_get_task_active_places        ‹owner› ‹class›         get list of prodplaces with active slots for this class
#prod_get_task_all_places           ‹owner› ‹class›         get list of prodplaces that can build this class
#prod_get_task_total_cnt            ‹owner› ‹class›         get total number of production tasks for this class
#prod_gnome_get_last_workplace      ‹objref›                get last work place
#prod_gnome_get_preferred_workplace ‹objref›                get preferred work place
#prod_gnome_last_workplace          ‹objref› [‹work-place›] announce current work place
#prod_gnome_preferred_workplace     ‹objref› [‹work-place›] announce preferred work place
#prod_gnome_state                   ‹objref› ...
#prod_gnomeidle                     ‹objref› [true|false]   announce worker is idle
#prod_valid                         ‹obj› ‹prod›            checks if is a non boxed, non contained , build and valid object with the same owner like
#proddump                           ‹player›                dump prodplanner state
#prodslot_override                  ...
#
#
#set_prod_buildup
#set_prod_directevents
#set_prod_enabled
#set_prod_exclusivemode
#set_prod_materialneed
#set_prod_ownerstrnength
#set_prod_pack
#set_prod_schedule
#set_prod_slot_cnt
#set_prod_switchmode
#set_prod_toolneed
#set_prod_unpack
#set_prodalloclock
#set_prodautoschedule



#dist_between (object)
#dist_between ‹objref› ‹objref›
#get the distance between 2 objects
#
#obj_find_list (object)
#obj_find_list ‹objref› ‹class-name› (‹max-dist›)
#get list of object references for given class
#list is sorted by distance. nearest first. max-dist default is infinite
#
#obj_find_nearest (object)
#obj_find_nearest ‹objref› ‹class-name-list› (‹max-dist›)
#find next object of given class,
#returns Reference to object, and Class name of object
#returns 0 if nothing found
#
#obj_query (object)
#obj_query ‹objref› ‹params›



# prod_enabled:      Türen: aus. Für Lager dann aus, wenn nichts zu tun ist.
# prod_schedule:     Lorenbahn: aus. Schule: Aus, während unterrichted wird. Farm: kompliziert
# prod_materialneed: Lorenbahn, Theater: aus. Bar, Farm: kompliziert
# prod_directevents: Fallen, Grabstein, Lorenbahn, TitanicPumpe: an

# prod_valid <obj> <prod>   prod=Produktionsstätte, obj=objekt der selben Fraktion


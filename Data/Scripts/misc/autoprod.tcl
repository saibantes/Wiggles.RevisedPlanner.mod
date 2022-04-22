##nagelfar syntax lrem v x
##nagelfar syntax fincr v x

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
        if {([get_remaining_sparetime $gnome] == 0) && [get_prodautoschedule $gnome]} {
            lappend preferred_workers([prod_gnome_get_preferred_workplace $gnome]) $gnome
            incr num_gnomes
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
                            set score [call_method $gnome autoprod_rate_task $task $num_gnomes $num_kettensaege $num_hammer $num_strahl $num_reithamster $num_hoverboard]
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
            set score [call_method $gnome autoprod_rate_task $task $num_gnomes $num_kettensaege $num_hammer $num_strahl $num_reithamster $num_hoverboard]
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

    #log_static "X: autoprod planning took [expr {[clock clicks]-$start_time}] clicks"
#} result]} {
    #log_static $result
#}
} ;# autoprod_ex


#==================================================================================================

# has the owner any gnome on duty for inventing this item?
#proc worktime_invent_possible {owner item} {
#    foreach gnome [obj_query 0 -type {gnome} -owner $owner] {
#        if {[get_remaining_sparetime $gnome] == 0} {
#            if [gnome_invent_possible $gnome $item] {
#                return 1
#            }
#        }
#    }
#    return 0
#}

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
#            set logFileID [open "data/_log/[get_objname this].txt" "w"]
#            puts $logFileID $str
#            if {$with_flush} {flush $logFileID}
#        }] == 1} {
#            print "log [get_objname this] $str"
#        }
#    }
#}

proc reset_autoprod_log {} {
#    catch {
#        file delete "data/_log/_autoprod.txt"
#    }
}

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

# TODO: method get_deliverypos


# prod_enabled:      Türen: aus. Für Lager dann aus, wenn nichts zu tun ist.
# prod_schedule:     Lorenbahn: aus. Schule: Aus, während unterrichted wird. Farm: kompliziert
# prod_materialneed: Lorenbahn, Theater: aus. Bar, Farm: kompliziert
# prod_directevents: Fallen, Grabstein, Lorenbahn, TitanicPumpe: an

# prod_valid <obj> <prod>   prod=Produktionsstätte, obj=objekt der selben Fraktion


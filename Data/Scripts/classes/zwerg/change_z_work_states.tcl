$start
$replace
		set current_workclass 0
		set last_event ""
		set event_repeat 0
		gnome_idle this 1
	}


$with
		set current_workclass 0
		set last_event ""
		set event_repeat 0
        set ::autoprod_triggered 0
        if {[state_get this] != "prodfill_dispatch"} {
            set ::idle_start_time [gettime]
        }
		if {![get_disable_old_autoprod]} {gnome_idle this 1} else {prod_gnomeidle this 1}
	}


$end
$start
$replace
//		log "[get_objname this]: WORK_IDLE IDLETIMEOUT = $idletimeout, CURRENT_PLAN = $current_plan"

		prod_gnome_state this idle

		incr idletimeout

$with
//		log "[get_objname this]: WORK_IDLE IDLETIMEOUT = $idletimeout, CURRENT_PLAN = $current_plan"

		prod_gnome_state this idle
        prod_gnome_last_workplace this 0

		incr idletimeout

$end
$start
$replace
			} else {
				if {[get_gnomeposition this]&&[get_prodautoschedule this]&&![walk_down_from_wall]} {return}
			}
		}

		if {$muetzen_counter < 0} {
$with
			} else {
				if {[get_gnomeposition this]&&[get_prodautoschedule this]&&![walk_down_from_wall]} {return}
			}
			if {$current_workplace != 0} {log "WARNING: current_workplace=$current_workplace"}
			if {[get_disable_old_autoprod]} {
				global autoprod_triggered
				if {$idletimeout >= $autoprod_triggered} {
					set autoprod_triggered [expr $idletimeout+10]
					if {[autoprod_ex_gnomeidle this]} return
				}
			}
		}

		if {$muetzen_counter < 0} {
$end

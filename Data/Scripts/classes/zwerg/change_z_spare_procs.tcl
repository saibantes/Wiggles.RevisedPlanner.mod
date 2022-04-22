$start
$replace
				set amount 1.0
			}
			set disappointment [expr {[hmax 0.0 [expr {$civ_state-[subst \$stt_eatciv_[get_objclass $place]]}]]-$besttaste*0.3}]
			set judgement [expr {(1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$disappointment*$disappointment))/$amount}]
			lappend qplacelist [list $place $judgement $disappointment $bestclass $pathcosts]
			if {[is_selected this]} {log "[get_objname $place]:o $offer,bc $bestclass,bt $besttaste,a $amount,pc $pathcosts"}
		}
$with
				set amount 1.0
			}
			set disappointment [expr {[hmax 0.0 [expr {$civ_state-[subst \$stt_eatciv_[get_objclass $place]]}]]-$besttaste*0.3}]
			set judgement [expr {($pathcosts/$stt_maxsearch_range + 10*$disappointment)/$amount}]
			lappend qplacelist [list $place $judgement $disappointment $bestclass $pathcosts]
			if {[is_selected this]} {log "[get_objname $place]:o $offer,bc $bestclass,bt $besttaste,a $amount,pc $pathcosts"}
		}
$end
$start
$replace
			}
		}
		set disappointment [hmax 0.0 [expr {$civ_state-[subst \$stt_slpciv_[get_objclass $place]]}]]
		set judgement [expr {1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$disappointment*$disappointment)}]
		log "[get_objname this]: [get_objname $place] jd ($judgement)"
		if {$judgement+$stt_slpciv_0<$civ_state} {lappend qreflist [list $place $judgement $disappointment]}
	}
	if {[llength $qreflist]} {
		if {[is_selected this]} {log "qrl: $qreflist"}
$with
			}
		}
		set disappointment [hmax 0.0 [expr {$civ_state-[subst \$stt_slpciv_[get_objclass $place]]}]]
		set judgement [expr {$pathcosts/$stt_maxsearch_range + 10*$disappointment}]
		log "[get_objname this]: [get_objname $place] jd ($judgement)"
		lappend qreflist [list $place $judgement $disappointment]
	}
	if {[llength $qreflist]} {
		if {[is_selected this]} {log "qrl: $qreflist"}
$end
$start
$replace
}
proc sparetime_slp_end {{finally 1}} {
	global sparetime_disapp_slp is_sleeping sparetime_disappointment sparetime_current_place
	if {$finally} {
		sparetime_check_in 0
		set sparetime_disapp_slp 0
$with
}
proc sparetime_slp_end {{finally 1}} {
	global sparetime_disapp_slp is_sleeping sparetime_disappointment sparetime_current_place
	global sparetime_seat
	if {$finally} {
		sparetime_check_in 0
		set sparetime_disapp_slp 0
$end
$start
$replace
			}
		}
		set disappointment [hmax 0.0 [expr {$civ_state-[subst \$stt_bthciv_[get_objclass $place]]}]]
		set judgement [expr {1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$disappointment*$disappointment)}]
		log "[get_objname this]: [get_objname $place] bath-jd ($judgement) ($disappointment)"
		if {$judgement+$stt_bthciv_0<$civ_state} {lappend plist [list $place $judgement $disappointment]}
	}
	if {$plist==""} {
		set spt_bath_disapp [expr {$civ_state - $stt_bthciv_0}]
$with
			}
		}
		set disappointment [hmax 0.0 [expr {$civ_state-[subst \$stt_bthciv_[get_objclass $place]]}]]
		set judgement [expr {$pathcosts/$stt_maxsearch_range + 10*$disappointment}]
		log "[get_objname this]: [get_objname $place] bath-jd ($judgement) ($disappointment)"
		lappend plist [list $place $judgement $disappointment]
	}
	if {$plist==""} {
		set spt_bath_disapp [expr {$civ_state - $stt_bthciv_0}]
$end
$start
$replace
}

proc sparetime_ill_start {} {
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 40 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	set found 0
$with
}

proc sparetime_ill_start {} {
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 160 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	set found 0
$end
$start
$replace
	if {![obj_valid $sparetime_current_place_ref]} {sparetime_checkin 0}
	prod_guest addorder $sparetime_current_place_ref $sparetime_seat
	set arzt [call_method $sparetime_current_place_ref get_worker]
	if {$arzt == 0 } {
		set patient 0
	} else {
		set patient [call_method $sparetime_current_place_ref get_patient]
	}
	if {[get_ref this] == $patient} { 
		set todo [call_method $sparetime_current_place_ref get_current_todo]
		switch $todo {
$with
	if {![obj_valid $sparetime_current_place_ref]} {sparetime_checkin 0}
	prod_guest addorder $sparetime_current_place_ref $sparetime_seat
	set arzt [call_method $sparetime_current_place_ref get_worker]
	set patient [call_method $sparetime_current_place_ref get_patient]
	if {[get_ref this] == $patient} { 
		set todo [call_method $sparetime_current_place_ref get_current_todo]
		switch $todo {
$end
$start
$replace
proc sparetime_ill_check {} {
	global sparetime_current_place sparetime_current_place_ref
	if {$sparetime_current_place=="Krankenhaus"} {return 1}
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 40 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	foreach hospital $hosp_list {
$with
proc sparetime_ill_check {} {
	global sparetime_current_place sparetime_current_place_ref
	if {$sparetime_current_place=="Krankenhaus"} {return 1}
	if {[set hosp_list [obj_query this "-class Krankenhaus -range 160 -owner own -flagneg boxed"]]==0} {
		return 0
	}
	foreach hospital $hosp_list {
$end

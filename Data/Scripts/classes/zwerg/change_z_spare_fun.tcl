$start
$replace
			} else {
				set place [lindex $qplace 0]
				set spt_fun_ignore 0
				if {[lindex $qplace 3]} {
					global sparetime_current_place_ref sparetime_reservation sparetime_disappointment
					global sparetime_current_place
					set link [call_method $place reserve_seat $myref]
					set sparetime_current_place_ref $place
					set sparetime_current_place [get_objclass $place]
$with
			} else {
				set place [lindex $qplace 0]
				set spt_fun_ignore 0
				global sparetime_reservation sparetime_disappointment
				if {[lindex $qplace 3]} {
					global sparetime_current_place_ref sparetime_current_place
					set link [call_method $place reserve_seat $myref]
					set sparetime_current_place_ref $place
					set sparetime_current_place [get_objclass $place]
$end
$start
$replace
				}
				set dummy [prod_guest getlink $place $link]
				tasklist_add this "walk_dummy $place $dummy"
				if {$spt_talk_desire>$spt_place_desire+30} {
					set sparetime_talkanswer 1
				} else {
$with
				}
				set dummy [prod_guest getlink $place $link]
				tasklist_add this "walk_dummy $place $dummy"
				set_objworkicons this [get_objclass $place]
				tasklist_add this "set_objworkicons this"
				if {$spt_talk_desire>$spt_place_desire+30} {
					set sparetime_talkanswer 1
				} else {
$end
$start
$replace
				sparetime_check_in $place
				set dummy [prod_guest getlink $place 0]
				tasklist_add this "walk_dummy $place $dummy"
				set sparetime_fun_mode "sex"
				set willing_to_reprod 0
				if {$oldmode!=$sparetime_fun_mode} {return 1} {return 0}
$with
				sparetime_check_in $place
				set dummy [prod_guest getlink $place 0]
				tasklist_add this "walk_dummy $place $dummy"
				set_objworkicons this [get_objclass $place]
				tasklist_add this "set_objworkicons this"
				set sparetime_fun_mode "sex"
				set willing_to_reprod 0
				if {$oldmode!=$sparetime_fun_mode} {return 1} {return 0}
$end
$start
$replace
				}
			}
			if {[lsearch $spt_favplaces $placename]!=-1} {set da [expr {$da * 2.0}]}
			set jm [expr {1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$da)}]
			if {$placefail} {
				lappend fplist [list $place $jm $placename $placefail]
			} else {
$with
				}
			}
			if {[lsearch $spt_favplaces $placename]!=-1} {set da [expr {$da * 2.0}]}
			
			set partner_not_there [expr {$reprod_partner&&[obj_valid $reprod_partner]&&($place != [call_method $reprod_partner get_sparetime_place])}]
			set is_not_fav [expr {[lsearch $spt_favplaces $placename] < 0}]
			set jm [expr {$pathcosts/$stt_maxsearch_range + $is_not_fav + 2*[lcount $::sparetime_recent_fun $placename] + 3*$partner_not_there}]
			
			if {$placefail} {
				lappend fplist [list $place $jm $placename $placefail]
			} else {
$end
$start
$replace
}
proc sparetime_home_find {} {
	global reprod_partner sparetime_fun_history sparetime_avoid_place
	global stt_maxsearch_range spt_home_desire
	set max_search_range [sparetime_searchrange]
	set half_search_range [expr {$max_search_range*0.5}]
	set plist [sparetime this queryrect home -$max_search_range -$half_search_range $max_search_range $half_search_range]
$with
}
proc sparetime_home_find {} {
	global reprod_partner sparetime_fun_history sparetime_avoid_place
	global stt_maxsearch_range civ_state
	set max_search_range [sparetime_searchrange]
	set half_search_range [expr {$max_search_range*0.5}]
	set plist [sparetime this queryrect home -$max_search_range -$half_search_range $max_search_range $half_search_range]
$end
$start
$replace
				}
			}
			set pathcosts [expr {abs([get_posx this]-[get_posx $place])+abs([get_posy this]-[get_posy $place])*3.0}]
			set da [expr {$spt_home_desire*0.2}]
			if {$reprod_partner&&[obj_valid $reprod_partner]} {
				if {$place == [call_method $reprod_partner get_sparetime_place]} {
					set pathcosts [expr {$pathcosts*0.5}]
					set da [expr {$da*0.5}]
				}
			}
			set jm [expr {1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$da)}]
			lappend qplist [list $place $jm $da]
		}
		if {$qplist==""} {return ""}
$with
				}
			}
			set pathcosts [expr {abs([get_posx this]-[get_posx $place])+abs([get_posy this]-[get_posy $place])*3.0}]
			set da [hmax 0.0 [expr {$civ_state-[set ::stt_homeciv_[get_objclass $place]]}]]
			if {$reprod_partner&&[obj_valid $reprod_partner]} {
				if {$place == [call_method $reprod_partner get_sparetime_place]} {
					set pathcosts [expr {$pathcosts*0.5}]
					set da [expr {$da*0.5}]
				}
			}
			set jm [expr {$pathcosts/$stt_maxsearch_range + 10*$da}]
			lappend qplist [list $place $jm $da]
		}
		if {$qplist==""} {return ""}
$end
$start
$replace
	set link $sparetime_seat
	set dummy [prod_guest getlink $place $link]
	tasklist_add this "walk_dummy $place $dummy"
	if {$spt_talk_desire>$spt_home_desire+30} {
		set sparetime_talkanswer 1
	} else {
$with
	set link $sparetime_seat
	set dummy [prod_guest getlink $place $link]
	tasklist_add this "walk_dummy $place $dummy"
	set_objworkicons this [get_objclass $place]
	tasklist_add this "set_objworkicons this"
	if {$spt_talk_desire>$spt_home_desire+30} {
		set sparetime_talkanswer 1
	} else {
$end
$start
$replace
			}
			if {[prod_guest guestfree $place]==-1} {log "no seat free at $place";continue}
			if {[get_prod_slot_cnt $place _Liebesdienst]==0} {log "no service at $place";continue}
			set worker [call_method $place get_current_worker]
			if {$worker!=0} {
				if {[call_method $worker get_gender]==$gnome_gender} {log "wrong gender at $place";continue}
			}
$with
			}
			if {[prod_guest guestfree $place]==-1} {log "no seat free at $place";continue}
			if {[get_prod_slot_cnt $place _Liebesdienst]==0} {log "no service at $place";continue}
			set worker [call_method $place get_last_worker]
			if {$worker!=0} {
				if {[call_method $worker get_gender]==$gnome_gender} {log "wrong gender at $place";continue}
			}
$end

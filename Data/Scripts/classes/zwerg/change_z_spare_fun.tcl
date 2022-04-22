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
					set da [expr {$da*0.5}]
				}
			}
			set jm [expr {1-(1-($pathcosts*$pathcosts)/($stt_maxsearch_range*$stt_maxsearch_range))*(1-$da)}]
			lappend qplist [list $place $jm $da]
		}
		if {$qplist==""} {return ""}
$with
					set da [expr {$da*0.5}]
				}
			}
			set jm [expr {$pathcosts/$stt_maxsearch_range + 10*$da}]
			lappend qplist [list $place $jm $da]
		}
		if {$qplist==""} {return ""}
$end

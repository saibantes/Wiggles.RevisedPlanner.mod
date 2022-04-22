$start
$replace
		}
		proc get_next_chief_action {} {
			global current_worker
			if {[dist_between this $current_worker]>10} {return {"prod_goworkdummy 0"}}
			global freeseats looktochief prod_guest_seats prod_guest_waits gueststates
			global guesttimer
			set rlst [list]
			set freetables ""
			set exper [prod_getgnomeexper $current_worker [call_method this prod_item_exp_infl Barbetrieb]]
			set exper [hmax 1.0 [expr {$exper+0.2}]]
$with
		}
		proc get_next_chief_action {} {
			global current_worker
			global freeseats looktochief prod_guest_seats prod_guest_waits gueststates
			global guesttimer
			set rlst [list]
			if {[dist_between this $current_worker]>10} {
                lappend rlst "prod_goworkdummy 0"
            }
			set freetables ""
			set exper [prod_getgnomeexper $current_worker [call_method this prod_item_exp_infl Barbetrieb]]
			set exper [hmax 1.0 [expr {$exper+0.2}]]
$end
$start
$replace
			for {set i 0} {$i<$prod_guest_seats} {incr i} {
				if {[lindex $gueststates $i]} {incr guestcnt}
				set order [prod_guest getorder this $i]
				lappend orderlist $order
				incr orderheight $order
				if {$order>$maxorder} {set mostorder $i;set maxorder $order}
			}
$with
			for {set i 0} {$i<$prod_guest_seats} {incr i} {
				if {[lindex $gueststates $i]} {incr guestcnt}
				set order [prod_guest getorder this $i]
				lappend orderlist [list $order $i]
				incr orderheight $order
				if {$order>$maxorder} {set mostorder $i;set maxorder $order}
			}
$end
$start
$replace
					}
					if {$mostbeercnt>$beercnt} {
						set othertable [expr [lindex $mostorder 0]^2]
						lappend othertable [expr $othertable^1]
						set mostothertablesorder 0
						foreach seat $othertable {
							set seatorder [prod_guest getorder this $seat]
							if {$seatorder} {
								if {$mostothertablesorder&&$mostbeercnt>$beercnt} {
									if {$mostothertablesorder<$seatorder} {
										set mostorder [lreplace $mostorder 2 2 $seat]
										set maxorder [lreplace $maxorder 2 2 $seatorder]
									}
								} else {
									incr beercnt
									lappend mostorder $seat
									lappend maxorder $seatorder
								}
							}
						}
					}
					lappend rlst "prod_walk_and_consume_itemtype Bier"
					lappend rlst "prod_goworkdummy 0"
					lappend rlst "prod_setworkdummy 0"
$with
					}
					if {$mostbeercnt>$beercnt} {
						set othertable [expr [lindex $mostorder 0]^2]
                        set otherseat [expr $othertable^1]
                        set othertableorder [prod_guest getorder this $othertable]
                        set othertableotherseatorder [prod_guest getorder this $otherseat]
                        if {$othertableorder+$othertableotherseatorder > 0} {
                            if {$othertableorder >= $othertableotherseatorder} {
                                lappend maxorder $othertableorder
                                lappend mostorder $othertable
                                incr beercnt
                            }
                            if {($mostbeercnt>$beercnt) && ($othertableotherseatorder>0)} {
                                lappend maxorder $othertableotherseatorder
                                lappend mostorder $otherseat
                                incr beercnt
                            }
                        }
                    }
					lappend rlst "prod_walk_and_consume_itemtype Bier"
					lappend rlst "prod_goworkdummy 0"
					lappend rlst "prod_setworkdummy 0"
$end

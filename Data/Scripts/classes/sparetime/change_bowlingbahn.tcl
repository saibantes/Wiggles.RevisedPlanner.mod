$start
$replace
				}
				1 {
					if {[ask_for_free_seat 1]} {
						set i [get_random_seat]
						lappend rlst "sparetime_take_seat $myref $i 2"
						lock_for_guest $i
						set_guest_state $gid 2
					} else {
						lappend rlst "rotate_toangle [random 1.6 2.5]"
						lappend rlst "play_anim scout"
$with
				}
				1 {
					if {[ask_for_free_seat 1]} {
                        // Der folgende Code geht aus zwei Gruenden nicht:
                        // 1. [get_random_seat] liefert Sitznummer 0..n zurueck. 
                        //    Fuer sparetime_take_seat ist 0 aber "nimm den ersten freien".
                        //    0 ist aber nicht mehr der erste freie, weil der gesperrt (lock_for_guest) wurde.
                        // 2. "set_guest_state $gid" geht nicht, weil durch "sparetime_take_seat" die Nummerierung geaendert wird.
                        //    Macht aber nichts, weil sparetime_take_seat den state ohnehin aendert (3. Parameter).
//						set i [get_random_seat]
//						lappend rlst "sparetime_take_seat $myref $i 2"
//						lock_for_guest $i
//						set_guest_state $gid 2
                        // Korrektur:
                        // sparetime_take_seat mit -1 als 2. Parameter wuerde bereits einen zufaelligen Platz nehmen.
                        // Allerdings wird dazu die Methode "get_random_seat" benoetigt (ist aber proc, nicht methode).
                        // Mit 0 als 2. Parameter wird der erste freie Platz verwendet - das ist gut genug.
                        // Es kann nicht passieren, dass ein anderer Zwerg den Platz wegnimmt,
                        // weil das erste Kommando in $rlst sofort ausgefuehrt wird, anstatt (wie der Rest) in die tasklist zu gehen.
                        lappend rlst "sparetime_take_seat $myref 0 2"
					} else {
						lappend rlst "rotate_toangle [random 1.6 2.5]"
						lappend rlst "play_anim scout"
$end
$start
$replace
							reset_guest_timer $gid
							set ranim leftright
						} else {
							if {[lsearch [tasklist_list $current_bowler] "play_anim bowllose"]/2==0} {
								set ranim boo
								set rmood 0.02
							} elseif {[lsearch [tasklist_list $current_bowler] "play_anim bowlwin"]/2==0} {
								set ranim [lindex {applaud cheer} [irandom 2]]
								set rmood 0.02
							} else {
$with
							reset_guest_timer $gid
							set ranim leftright
						} else {
							if {[lsearch [tasklist_list $current_bowler] "sparetime_place_relief bowllose *"]/2==0} {
								set ranim boo
								set rmood 0.02
							} elseif {[lsearch [tasklist_list $current_bowler] "sparetime_place_relief bowlwin *"]/2==0} {
								set ranim [lindex {applaud cheer} [irandom 2]]
								set rmood 0.02
							} else {
$end
$start
$replace
						lappend rlst "sparetime_filler_loop"
						lappend rlst "sparetime_place_relief $ranim $rmood"
						lappend rlst "sparetime_filler_loop"
					} else {
						set mostwait 0
						foreach id [lnand $gid {0 1 2}] {
$with
						lappend rlst "sparetime_filler_loop"
						lappend rlst "sparetime_place_relief $ranim $rmood"
						lappend rlst "sparetime_filler_loop"
						if {$myref != [call_method $current_bowler get_sparetime_place]} {
							log "ERROR: current_bowler=$current_bowler is not here"
							set current_bowler 0
						}
					} else {
						set mostwait 0
						foreach id [lnand $gid {0 1 2}] {
$end

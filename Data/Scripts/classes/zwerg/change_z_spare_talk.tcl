$start
$replace
				set zp [expr {15-$myz}]
				set pos [get_place -center $mypos -rect -6 $zn 6 $zp -rimdist 2.5 -walldist 1 -except this -nearpos $mypos]
				tasklist_add this "walk_pos \{$pos\}"
				tasklist_add this "rotate_towards $talk_listener"
				incr talk_step
			} else {
$with
				set zp [expr {15-$myz}]
				set pos [get_place -center $mypos -rect -6 $zn 6 $zp -rimdist 2.5 -walldist 1 -except this -nearpos $mypos]
				tasklist_add this "walk_pos \{$pos\}"
				set_objworkicons this Zipfelmuetze
				tasklist_add this "set_objworkicons this"
				tasklist_add this "rotate_towards $talk_listener"
				incr talk_step
			} else {
$end
$start
$replace
				}
				// log "[get_objname this]: goes to \{$pos\} ([get_pos $talk_leader]) ($i)"
				tasklist_add this "walk_pos \{$pos\}"
			}
		}
		1 { ;# auf Gesprächspartner warten
$with
				}
				// log "[get_objname this]: goes to \{$pos\} ([get_pos $talk_leader]) ($i)"
				tasklist_add this "walk_pos \{$pos\}"
				set_objworkicons this Zipfelmuetze
				tasklist_add this "set_objworkicons this"
			}
		}
		1 { ;# auf Gesprächspartner warten
$end

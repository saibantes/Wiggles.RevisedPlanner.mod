$start
$replace
						set funposs 1.0
						if {$at_Mo>0.5} {
							if {$funlack+$spt_fun_needs>5} {
								set sparetime_goal "$at_Mo- $at_Mo >(\$funlack-$funlack)"
								set funposs [hmax 1.0 [expr {$funlack-1.0}]]
								set take 0
							} elseif {$at_Mo<0.95} {
								set sparetime_goal "\$at_Mo- $at_Mo >(0.98-$at_Mo)"
								set take 1
							} else {
								set sparetime_goal "$at_Mo- $at_Mo >(-1)"
								set take 2
							}
						} else {
$with
						set funposs 1.0
						if {$at_Mo>0.5} {
							if {$funlack+$spt_fun_needs>5} {
								set sparetime_goal "\$at_Mo- $at_Mo >(\$funlack-$funlack)"
								set funposs [hmax 1.0 [expr {$funlack-1.0}]]
								set take 0
							} elseif {$at_Mo<0.95} {
								set sparetime_goal "\$at_Mo- $at_Mo >(0.98-$at_Mo)"
								set take 1
							} else {
								set sparetime_goal "\$at_Mo- $at_Mo >(-1)"
								set take 2
							}
						} else {
$end
$start
$replace
					"fun" {
						set funposs 1.0
						if {$funlack+$spt_fun_needs>5} {
							set sparetime_goal "$at_Mo- $at_Mo >(\$funlack-$funlack)"
							set funposs [hmax 1.0 [expr {$funlack-1.0}]]
							set take 4
						} elseif {$at_Mo<0.95} {
							set sparetime_goal "\$at_Mo- $at_Mo >(0.98-$at_Mo)"
							set take 5
						} else {
							set sparetime_goal "$at_Mo- $at_Mo >(-1)"
							set take 6
						}
						if {[lindex $sparetime_goal 1]>[get_attrib this atr_Mood]+0.01} {
$with
					"fun" {
						set funposs 1.0
						if {$funlack+$spt_fun_needs>5} {
							set sparetime_goal "\$at_Mo- $at_Mo >(\$funlack-$funlack)"
							set funposs [hmax 1.0 [expr {$funlack-1.0}]]
							set take 4
						} elseif {$at_Mo<0.95} {
							set sparetime_goal "\$at_Mo- $at_Mo >(0.98-$at_Mo)"
							set take 5
						} else {
							set sparetime_goal "\$at_Mo- $at_Mo >(-1)"
							set take 6
						}
						if {[lindex $sparetime_goal 1]>[get_attrib this atr_Mood]+0.01} {
$end
$start
$replace
			if {$maxstriker>$cstriker} {set work_strike 1} {set work_strike 0}
		}
		set civ_state [hmax $civ_state 0.05]
		set spt_fun_needs [hmax [expr {int($civ_state*10)}] 2]
		set imode 1
		foreach mode {place home sex prtn} {
			set timedist [expr {$ctime-[subst \$spt_last_$mode]}]
$with
			if {$maxstriker>$cstriker} {set work_strike 1} {set work_strike 0}
		}
		set civ_state [hmax $civ_state 0.05]
		set spt_fun_needs [hmin [hmax [expr {int($civ_state*10)}] 2] 5]
		set imode 1
		foreach mode {place home sex prtn} {
			set timedist [expr {$ctime-[subst \$spt_last_$mode]}]
$end
$start
$replace
		global $change_var
		global stt_${name}civ_$place
		set $change_var [expr {[subst \$$change_var]*0.3+([subst \$stt_${name}civ_$place]+0.2)*0.7}]
	}	
	proc sparetime_eat_variety {} {
		global funloss_eatvariety
		global sparetime_recent_food sparetime_eatclasses
		set val [expr {(10-[llength $sparetime_recent_food])*0.04+0.1}]
		foreach item $sparetime_eatclasses {
			set cnt [lcount $sparetime_recent_food $item]
			if {$cnt} {
				fincr val [expr {(15-$cnt)*0.01}]
			}
		}
		set funloss_eatvariety $val
	}
	proc sparetime_place_variety {} {
		global funloss_placevariety spt_favplaces sparetime_recent_fun
		set val [expr {(10-[llength $sparetime_recent_fun])*0.01+0.2}]
		set places {pub tht dsc fit bwl}
		foreach item [concat $places $spt_favplaces] {
			set cnt [lcount $sparetime_recent_fun $item]
			if {$cnt} {
				fincr val [expr {(15-$cnt)*0.008}]
			}
		}
		set funloss_placevariety $val
$with
		global $change_var
		global stt_${name}civ_$place
		set $change_var [expr {[subst \$$change_var]*0.3+([subst \$stt_${name}civ_$place]+0.2)*0.7}]
	}
	proc sparetime_eat_variety {} {
		global funloss_eatvariety
		global sparetime_recent_food sparetime_eatclasses
		set num_unique [llength [lsort -unique $sparetime_recent_food]]
		set empty_slots [expr {[llength $sparetime_eatclasses] - [llength $sparetime_recent_food]}]
		set val [expr {(2+$num_unique+[hmax 0 $empty_slots]) * 0.1}]
		
		set funloss_eatvariety $val
	}
	proc sparetime_place_variety {} {
		global funloss_placevariety spt_favplaces sparetime_recent_fun
		if {$gnome_age < 1800*6} {
			# Gnome is younger than 6 days -> don't judge place variety yet
			set val [expr $::civ_state + 0.05]
		} else {
			set val [expr {(10-[llength $sparetime_recent_fun])*0.01+0.2}]
			set places {pub tht dsc fit bwl}
			foreach item [concat $places $spt_favplaces] {
				set cnt [lcount $sparetime_recent_fun $item]
				if {$cnt} {
					fincr val [expr {(15-$cnt)*0.008}]
				}	
			}
		}
		set funloss_placevariety $val
$end
$start
$replace
		global tll_fl_funstations
		set sumloss 0.0
		set moodfactor 0.003
		if {$civ_state>$funloss_eatvariety} {
			set moodloss [expr {$civ_state-$funloss_eatvariety}]
			sparetime_talkissue_entry "eat" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatvariety $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_placevariety} {
			set moodloss [expr {$civ_state-$funloss_placevariety}]
			sparetime_talkissue_entry "fun" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_placevariety $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_eatquality} {
			set moodloss [expr {($civ_state-$funloss_eatquality)*0.5}]
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatquality $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_slpquality} {
			set moodloss [expr {$civ_state-$funloss_slpquality}]
			sparetime_talkissue_entry "slp" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_slpquality $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_homequality} {
			set moodloss [expr {($civ_state-$funloss_homequality)*0.5}]
			sparetime_talkissue_entry "fun" [expr {$moodloss*0.4}] 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_homequality $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_bthquality} {
			set moodloss [expr {$civ_state-$funloss_bthquality}]
			sparetime_talkissue_entry "bth" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_bthquality $moodloss
			fincr sumloss $moodloss
		}
		if {$civ_state>$funloss_slpquality} {
			set moodloss [expr {$civ_state-$funloss_slpquality}]
			sparetime_talkissue_entry "slp" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_slpquality $moodloss
			fincr sumloss $moodloss
		}
		set funstations 0
		for {set i 1} {$i<17} {set i [expr {$i<<1}]} {
			if {$i&$spt_fun_stations} {
$with
		global tll_fl_funstations
		set sumloss 0.0
		set moodfactor 0.003
		set gnome_age [expr {[gettime]-$::birthtime}]
		log "age: $gnome_age [expr $gnome_age/1800.0]"
		if {$gnome_age < 1800} {
			# Gnome is too young, can't judge quality yet
			set default_qual [expr {$civ_state + 0.05}]
			set funloss_eatquality  $default_qual
			set funloss_slpquality  $default_qual
			set funloss_homequality $default_qual
			set funloss_bthquality  $default_qual
		}
		set civ_require [hmin $civ_state [expr {[llength $::sparetime_eatclasses]*0.1}]]
		if {$civ_require>$funloss_eatvariety} {
			set moodloss [expr {$civ_state-$funloss_eatvariety}]
			sparetime_talkissue_entry "eat" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatvariety $moodloss
			fincr sumloss $moodloss
		}
		set civ_require [hmin $civ_state [expr {([llength $::spt_favplaces]+[llength {pub dsc tht fit bwl}])*0.1}]]
		if {$civ_require>$funloss_placevariety} {
			set moodloss [expr {$civ_state-$funloss_placevariety}]
			sparetime_talkissue_entry "fun" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_placevariety $moodloss
			fincr sumloss $moodloss
		}
		set civ_require [hmin $civ_state [expr $::stt_eatciv_Luxuskueche+0.19]]
		if {$civ_require>$funloss_eatquality} {
			set moodloss [expr {($civ_state-$funloss_eatquality)*0.5}]
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_eatquality $moodloss
			fincr sumloss $moodloss
		}
		set civ_require [hmin $civ_state [expr $::stt_slpciv_Luxusschlafzimmer+0.19]]
		if {$civ_require>$funloss_slpquality} {
			set moodloss [expr {$civ_state-$funloss_slpquality}]
			sparetime_talkissue_entry "slp" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_slpquality $moodloss
			fincr sumloss $moodloss
		}
		set civ_require [hmin $civ_state [expr $::stt_homeciv_Luxuswohnzimmer+0.19]]
		if {$civ_require>$funloss_homequality} {
			set moodloss [expr {($civ_state-$funloss_homequality)*0.5}]
			sparetime_talkissue_entry "fun" [expr {$moodloss*0.4}] 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_homequality $moodloss
			fincr sumloss $moodloss
		}
		set civ_require [hmin $civ_state [expr $::stt_bthciv_Luxusbad+0.19]]
		if {$civ_require>$funloss_bthquality} {
			set moodloss [expr {$civ_state-$funloss_bthquality}]
			sparetime_talkissue_entry "bth" $moodloss 0
			set moodloss [expr {$moodfactor*$moodloss}]
			fincr tll_fl_bthquality $moodloss
			fincr sumloss $moodloss
		}
		set funstations 0
		for {set i 1} {$i<17} {set i [expr {$i<<1}]} {
			if {$i&$spt_fun_stations} {
$end

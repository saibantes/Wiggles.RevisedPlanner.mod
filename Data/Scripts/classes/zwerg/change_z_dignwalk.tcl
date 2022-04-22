$start
$replace
// ----------------------------------------------------------------------

proc dig_starttask {startpos} {
	global current_digpose
	if {$startpos==0} {set current_digpos [get_pos this]} {global current_digpos}
	set startpos $current_digpos
	log "dig_starttask @ $startpos"
	log "mypos: [get_pos this]"
$with
// ----------------------------------------------------------------------

proc dig_starttask {startpos} {
	global current_digpose current_digpos
	if {$startpos==0} {set current_digpos [get_pos this]}
	set startpos $current_digpos
	log "dig_starttask @ $startpos"
	log "mypos: [get_pos this]"
$end
$start
$replace
}

proc dig_continue {{try 0}} {
	global current_time_plan current_worktask current_digpose current_tool_class
//	log "dig_continue"
	if { [get_remaining_sparetime this] == 0.0 || $current_worktask!="dig"} {
		if {$try>6} {dig_resetid this}
$with
}

proc dig_continue {{try 0}} {
	global current_time_plan current_worktask current_digpose current_tool_class current_digpos
//	log "dig_continue"
	if { [get_remaining_sparetime this] == 0.0 || $current_worktask!="dig"} {
		if {$try>6} {dig_resetid this}
$end
$start
$replace
			}
		}
		gnome_announce_dig this $digpoint
		if {[vector_unpacky $digpoint]>0&&$try<9} {
			//log "dig_continue ($digpoint) $try $hastorotate"
			if {!$laser&&![dig_check $digpoint $try]} {dig_continue [expr $try + 1];return}
$with
			}
		}
		gnome_announce_dig this $digpoint
        set current_digpos $digpoint
		if {[vector_unpacky $digpoint]>0&&$try<9} {
			//log "dig_continue ($digpoint) $try $hastorotate"
			if {!$laser&&![dig_check $digpoint $try]} {dig_continue [expr $try + 1];return}
$end
$start
$replace
}

proc dig_execute {digpoint} {
	global tttgain_dig tttinfluence_dig tttfailmax_dig current_digpose
	set digattr [get_attrib this exp_Stein]
	set minextrarange 3.0
	if {[string match {l?} $current_digpose]} {
$with
}

proc dig_execute {digpoint} {
	global tttgain_dig tttinfluence_dig tttfailmax_dig current_digpose current_digpos
	set digattr [get_attrib this exp_Stein]
	set minextrarange 3.0
	if {[string match {l?} $current_digpose]} {
$end
$start
$replace
	set dig_z [lindex $digpoint 2]
	set digcount [expr [hmax 0.5 [expr sqrt($digattr*$tttinfluence_dig*$airhammer)]]]
	gnome_announce_dig this $digpoint
	while {$laser||[vector_dist $digpoint $thispos]<(3.0+$digattr*2.0)&&abs([lindex $digpoint 2]-$dig_z)<2} {
		if {$laser||rand()<$digcount*[get_material $digpoint]*0.7} {
			if {[dig_apply $digpoint this]} {
$with
	set dig_z [lindex $digpoint 2]
	set digcount [expr [hmax 0.5 [expr sqrt($digattr*$tttinfluence_dig*$airhammer)]]]
	gnome_announce_dig this $digpoint
    set current_digpos $digpoint
	while {$laser||[vector_dist $digpoint $thispos]<(3.0+$digattr*2.0)&&abs([lindex $digpoint 2]-$dig_z)<2} {
		if {$laser||rand()<$digcount*[get_material $digpoint]*0.7} {
			if {[dig_apply $digpoint this]} {
$end
$start
$replace

// läuft in die Nähe eines Items (oder eines Punktes)

proc walk_near_item {item radius {tolerance 0.1} {speedtype auto}} {
	//log "WALK NEAR ITEM [get_objname this] pos: $item radius: $radius"
	set thispos [get_pos this]

$with

// läuft in die Nähe eines Items (oder eines Punktes)

proc walk_near_item {item radius {tolerance 0.1} {speedtype auto} {maxplus 2}} {
	//log "WALK NEAR ITEM [get_objname this] pos: $item radius: $radius"
	set thispos [get_pos this]

$end
$start
$replace
	}

    // Position zum Hinlaufen ermitteln
	set walkpos [vector_fix [get_place -center $itempos -nearpos $thispos -mindist $radius -circle [expr $radius +2] -except this]]
	//log "$walkpos"
	if {[lindex $walkpos 0]<0} {
        // fehlgeschlagen - 2. Versuch ohne Materials
		log "walk_near_item: get_place 1 failed"
   		set walkpos [vector_fix [get_place -center $itempos -nearpos $thispos -mindist $radius -circle [expr $radius +2] -except this -materials false]]
		//log "$walkpos"
    	if {[lindex $walkpos 0]<0} {
			log "walk_near_item: get_place 2 failed - last fallback is vector_fix!"
$with
	}

    // Position zum Hinlaufen ermitteln
	set walkpos [vector_fix [get_place -center $itempos -nearpos $thispos -mindist $radius -circle [expr $radius+$maxplus] -except this]]
	//log "$walkpos"
	if {[lindex $walkpos 0]<0} {
        // fehlgeschlagen - 2. Versuch ohne Materials
		log "walk_near_item: get_place 1 failed"
   		set walkpos [vector_fix [get_place -center $itempos -nearpos $thispos -mindist $radius -circle [expr $radius+$maxplus] -except this -materials false]]
		//log "$walkpos"
    	if {[lindex $walkpos 0]<0} {
			log "walk_near_item: get_place 2 failed - last fallback is vector_fix!"
$end

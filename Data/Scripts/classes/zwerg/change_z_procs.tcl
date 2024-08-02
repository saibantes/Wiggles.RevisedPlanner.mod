$start
$replace
// leert das gesamte Inventory

proc beamto_world_all {} {
	foreach item [inv_list this] {
		// zusätzliches inv_find_obj, weil beamto_world u.U. mehrere Items ablegt (bei Kiepen mit Inhalt z.B.)
		if {[inv_find_obj this $item] >= 0} {
$with
// leert das gesamte Inventory

proc beamto_world_all {} {
	set dropped 0
	foreach item [inv_list this] {
		if {[get_objtype $item] == "material"} {
			incr dropped
			beamto_world $item [get_roty this]
		}
	}
	if {$dropped} return
	foreach item [inv_list this] {
		// zusätzliches inv_find_obj, weil beamto_world u.U. mehrere Items ablegt (bei Kiepen mit Inhalt z.B.)
		if {[inv_find_obj this $item] >= 0} {
$end
$start
$replace
	} else {
		// putdown an bestimmter Position

		tasklist_add this "set_objworkicons this arrow_down [get_objclass $item]; walk_near_item \{$pos\} 0.7"
		tasklist_add this "rotate_towards \{$pos\}"
		tasklist_add this "play_anim benda"
		tasklist_add this "beam_from_inv_to_pos \{$item\} \{$pos\}"
$with
	} else {
		// putdown an bestimmter Position

		tasklist_add this "set_objworkicons this arrow_down [get_objclass $item]; walk_near_item \{$pos\} 0.7 0.1 auto 1.25"
		tasklist_add this "rotate_towards \{$pos\}"
		tasklist_add this "play_anim benda"
		tasklist_add this "beam_from_inv_to_pos \{$item\} \{$pos\}"
$end
$start
$replace
		tasklist_addfront this "beam_from_inv_to_pos \{$item\} \{$pos\}"
		tasklist_addfront this "play_anim benda"
		tasklist_addfront this "rotate_towards \{$pos\}"
		tasklist_addfront this "set_objworkicons this arrow_down [get_objclass $item]; walk_near_item \{$pos\} 0.7"
	}

	return true
$with
		tasklist_addfront this "beam_from_inv_to_pos \{$item\} \{$pos\}"
		tasklist_addfront this "play_anim benda"
		tasklist_addfront this "rotate_towards \{$pos\}"
		tasklist_addfront this "set_objworkicons this arrow_down [get_objclass $item]; walk_near_item \{$pos\} 0.7 0.1 auto 1.25"
	}

	return true
$end
$start
$replace
//		}
//	}
	lock_item $item
	stop_prod
	set bstep [call_method $item get_buildupstep]
	//log "PACK: bstep = $bstep"
	if { $bstep } {
$with
//		}
//	}
	lock_item $item
	if {![get_disable_old_autoprod]} stop_prod
	set bstep [call_method $item get_buildupstep]
	//log "PACK: bstep = $bstep"
	if { $bstep } {
$end
$start
$replace
	}

	lock_item $item
	stop_prod
	tasklist_add this "walk_outoftransit"
	tasklist_add this "rotate_toback"
	tasklist_add this "play_anim [putdown_anim]"
$with
	}

	lock_item $item
	if {![get_disable_old_autoprod]} stop_prod else {set_prod_unpack $item 0}
	tasklist_add this "walk_outoftransit"
	tasklist_add this "rotate_toback"
	tasklist_add this "play_anim [putdown_anim]"
$end

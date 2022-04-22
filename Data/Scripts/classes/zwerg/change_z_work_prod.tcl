$start
$replace
	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7"

	return true
}
$with
	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7 0.1 auto 1.25"

	return true
}
$end
$start
$replace
	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7"
	return true
}

$with
	tasklist_addfront this "beam_from_inv_to_pos $item \{$itempos\};play_anim bendb"
	tasklist_addfront this "play_anim benda"
	tasklist_addfront this "rotate_towards \{$itempos\}"
	tasklist_addfront this "walk_near_item \{$itempos\} 0.7 0.1 auto 1.25"
	return true
}

$end
$start
$replace
			return false
		}
	}
	tasklist_add this "walk_near_item \{$itempos\} 0.7"
	tasklist_add this "rotate_towards \{$itempos\}"
	tasklist_add this "play_anim benda" ;# prod_gnome_state this putdown $item
	tasklist_add this "beam_from_inv_to_pos $item \{$itempos\};set_roty $item [random 6.3];play_anim bendb"
$with
			return false
		}
	}
	tasklist_add this "walk_near_item \{$itempos\} 0.7 0.1 auto 1.25"
	tasklist_add this "rotate_towards \{$itempos\}"
	tasklist_add this "play_anim benda" ;# prod_gnome_state this putdown $item
	tasklist_add this "beam_from_inv_to_pos $item \{$itempos\};set_roty $item [random 6.3];play_anim bendb"
$end
$start
$replace

proc prod_heilen {artzt khaus_ref} {
	set patient [call_method $khaus_ref get_patient]
	if {$patient == 0} {
		set patient [prod_get_patient $khaus_ref]
		if {$patient == -1} {tasklist_add this "prod_leerlauf $khaus_ref"; return true}
		call_method $khaus_ref set_patient $patient
$with

proc prod_heilen {artzt khaus_ref} {
	set patient [call_method $khaus_ref get_patient]
	if {($patient == 0) || ![obj_valid $patient]} {
		set patient [prod_get_patient $khaus_ref]
		if {$patient == -1} {tasklist_add this "prod_leerlauf $khaus_ref"; return true}
		call_method $khaus_ref set_patient $patient
$end

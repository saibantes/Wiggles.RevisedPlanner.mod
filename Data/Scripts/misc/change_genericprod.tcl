$start
$replace
// genericprod.tcl

if {[in_class_def]} {
// class definition part

$with
// genericprod.tcl

call scripts/misc/prod_autoprod.tcl


if {[in_class_def]} {
// class definition part

$end
$start
$replace
		} else {
			free_unneeded_items
		}
	}


$with
		} else {
			free_unneeded_items
		}
		if {[get_disable_old_autoprod]} autoprod_ex_prodchanged
	}


$end
$start
$replace
		}
		append meth_def "\}"
		method prod_item_materials {item} $meth_def
		//method prod_item_materials {item} "
		//	global tttmaterial_$item
		//	return [subst \$tttmaterial_$item]
		//}
$with
		}
		append meth_def "\}"
		method prod_item_materials {item} $meth_def
		//method prod_item_materials {item} {
		//	global tttmaterial_$item
		//	return [subst \$tttmaterial_$item]
		//}
$end
$start
$replace

	method get_itemtasklist {itemtype gnomeref} {
		set current_worker $gnomeref
		if {[string range $itemtype 0 1]=="Bp"} {
			set current_itemtype [string range $itemtype 2 end]
		} else {
$with

	method get_itemtasklist {itemtype gnomeref} {
		set current_worker $gnomeref
		set last_worker $gnomeref
		if {[string range $itemtype 0 1]=="Bp"} {
			set current_itemtype [string range $itemtype 2 end]
		} else {
$end
$start
$replace
		global current_worker
		return $current_worker
	}

	method get_build_dummy {index} {
		global build_dummys
$with
		global current_worker
		return $current_worker
	}
	
	method get_last_worker {} {
		global last_worker
		if {$last_worker == 0} {return 0}
		log "@@@ checking $last_worker"
		if {![obj_valid $last_worker]} {
			set last_worker 0
		} else {
			log "@@@ ([ref_get $last_worker ::current_workplace] != [get_ref this])"
			set workplace [ref_get $last_worker ::current_workplace]
			if {($workplace != [get_ref this]) && ($workplace != 0)} {
				set last_worker 0
			}
		}
		log "@@@ -> $last_worker"
		return $last_worker
	}

	method get_build_dummy {index} {
		global build_dummys
$end
$start
$replace
	set max_buildup_step 	0
	set damage_dummys 		0
	set current_worker 		0
	set current_itemtype 	0
	set job_finished		0				;// wird gesetzt, wenn die Aufgabe eigentlich erledigt ist, Produktion aber noch läuft
	set info_string 		""
$with
	set max_buildup_step 	0
	set damage_dummys 		0
	set current_worker 		0
	set last_worker			0
	set current_itemtype 	0
	set job_finished		0				;// wird gesetzt, wenn die Aufgabe eigentlich erledigt ist, Produktion aber noch läuft
	set info_string 		""
$end

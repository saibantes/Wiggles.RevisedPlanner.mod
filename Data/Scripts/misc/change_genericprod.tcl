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

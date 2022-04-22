$start
$replace
		return [get_eatobjects $classlst]
	}
	method get_certain_object {classname} {
		set item [obj_query this "-class $classname -range 8 -flagneg \{contained locked\} -limit 1"]
		if {[get_lock $item]} {log "Gefundenes Item Nr. $item ([get_objname $item]) war gelockt!"
		} {return $item}
	}
$with
		return [get_eatobjects $classlst]
	}
	method get_certain_object {classname} {
		set item [obj_query this "-class $classname -range 11 -flagneg \{contained locked\} -limit 1"]
		if {[get_lock $item]} {log "Gefundenes Item Nr. $item ([get_objname $item]) war gelockt!"
		} {return $item}
	}
$end
$start
$replace
		proc get_eatobjects {classlst} {
			set rlst [list]
			foreach cn $classlst {
				set reflist [obj_query this "-class $cn -range 7 -flagneg \{contained locked\}"]
				if {$reflist!=0} {
					lappend rlst [llength $reflist]
				} else {
$with
		proc get_eatobjects {classlst} {
			set rlst [list]
			foreach cn $classlst {
				set reflist [obj_query this "-class $cn -range 10 -flagneg \{contained locked\}"]
				if {$reflist!=0} {
					lappend rlst [llength $reflist]
				} else {
$end

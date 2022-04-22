$start
$replace
		call scripts/classes/zwerg/pzwerg.tcl
		call scripts/classes/zwerg/actors.tcl
		call scripts/classes/zwerg/baby.tcl

		if { [startcache enabled] } {
			startcache write
$with
		call scripts/classes/zwerg/pzwerg.tcl
		call scripts/classes/zwerg/actors.tcl
		call scripts/classes/zwerg/baby.tcl
        call scripts/misc/autoprod_dig.tcl

		if { [startcache enabled] } {
			startcache write
$end

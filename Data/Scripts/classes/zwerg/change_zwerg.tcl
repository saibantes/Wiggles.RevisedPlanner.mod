$start
$replace
		call scripts/classes/zwerg/z_spare_reprod.tcl
		call scripts/classes/zwerg/z_work_strike.tcl
		call scripts/classes/items/calls/takeitems.tcl

		state_reset this
		state_trigger this idle
$with
		call scripts/classes/zwerg/z_spare_reprod.tcl
		call scripts/classes/zwerg/z_work_strike.tcl
		call scripts/classes/items/calls/takeitems.tcl
        call scripts/misc/z_autoprod.tcl

		state_reset this
		state_trigger this idle
$end
$start
$replace
	call scripts/classes/zwerg/z_spare_reprod.tcl
	call scripts/misc/genericfight.tcl
	call scripts/classes/zwerg/z_work_strike.tcl

	handle_event evt_timer0 {
		call_method this init
$with
	call scripts/classes/zwerg/z_spare_reprod.tcl
	call scripts/misc/genericfight.tcl
	call scripts/classes/zwerg/z_work_strike.tcl
    call scripts/misc/z_autoprod.tcl

	handle_event evt_timer0 {
		call_method this init
$end
$start
$replace

	state_enter idle {
		set idletimeout 0
		gnome_idle this 1
	}

	state idle {
$with

	state_enter idle {
		set idletimeout 0
		if {![get_disable_old_autoprod]} {gnome_idle this 1} else {prod_gnomeidle this 1}
	}

	state idle {
$end

$start
$replace
		}
		proc worker_break {who} {
			global progress worker_inplace breaked guest
			if {$progress||$breaked} {
				set step [hmax $progress $breaked]
				set rlst [list]
$with
		}
		proc worker_break {who} {
			global progress worker_inplace breaked guest
			set worker_inplace 0
			if {$progress||$breaked} {
				set step [hmax $progress $breaked]
				set rlst [list]
$end

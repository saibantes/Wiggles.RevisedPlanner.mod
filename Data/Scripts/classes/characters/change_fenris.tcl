$start
$replace

		set cup [obj_query this "-class Fenris_Krug -range 80 -limit 1"]

		set infoobjlist [obj_query this "-class Info_Fenris -range 200"]
		if {$infoobjlist != 0} {
			foreach obj $infoobjlist {
				set type [call_method $obj get_info type]
$with

		set cup [obj_query this "-class Fenris_Krug -range 80 -limit 1"]

		set infoobjlist [obj_query this "-class Info_Fenris -range 200 -sorting desc"]
		if {$infoobjlist != 0} {
			foreach obj $infoobjlist {
				set type [call_method $obj get_info type]
$end

$start
$replace
set item [obj_query this "-class $classname -range 8 -flagneg \{contained locked\} -limit 1"]
$with
set item [obj_query this "-class $classname -range 11 -flagneg \{contained locked\} -limit 1"]
$end

$start
$replace
set reflist [obj_query this "-class $cn -range 7 -flagneg \{contained locked\}"]
$with
set reflist [obj_query this "-class $cn -range 10 -flagneg \{contained locked\}"]
$end

$start
$replace
			lrep guests $id 0
			lrep gueststates $id 0
			lrep guesttimer $id 0
		}
		proc decide_dance {current gid} {
			global current_worker music
$with
			lrep guests $id 0
			lrep gueststates $id 0
			lrep guesttimer $id 0
			lrep dancecount $id 0
		}
		proc decide_dance {current gid} {
			global current_worker music
$end

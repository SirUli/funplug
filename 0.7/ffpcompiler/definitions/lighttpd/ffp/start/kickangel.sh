#!/ffp/bin/sh

# PROVIDE: kickangel
# REQUIRE: LOGIN
# BEFORE: lighttpd

. /ffp/etc/ffp.subr

name="kickangel"
start_cmd="kickangel_start"
stop_cmd="kickangel_info"
status_cmd="kickangel_info"
restart_cmd="kickangel_info"

kickangel_start(){
	echo "Will check 5 times if lighty is killed"
	for i in 1 2 3 4 5
	do
   		echo "Check #${i}"
		if [[ $(pidof lighttpd-angel) -gt 0 ]]; then
                	echo "Killing angel of lighttpd ..."
                	kill -9 `pidof lighttpd-angel`
			sleep  1
		else
			sleep 2
        	fi
		if [[ $(pidof lighttpd) -gt 0 ]]; then
                	echo "Killing lighttpd ..."
                	kill -9 `pidof lighttpd`
			sleep 1
		else
			if [[ $i -ne 5 ]]; then
				sleep 2
			fi
        	fi
	done
	echo "Hopefully killed"
}

kickangel_info(){
	echo "This program just kills lighttpd-angel and lighttpd, no stop, status or restart implemented"
}

run_rc_command "$1"

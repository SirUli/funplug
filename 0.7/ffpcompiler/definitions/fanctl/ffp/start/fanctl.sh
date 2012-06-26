#!/ffp/bin/sh

# PROVIDE: fanctl
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="fanctl"
start_cmd="fanctl_start"
stop_cmd="fanctl_stop"
status_cmd="fanctl_status"

fanctl_config="/ffp/etc/fanctl.conf"

fanctl_start()
{
        # Kill the old fan controller
        PID=$(/bin/pidof fancontrol)
        if [ -n "$PID" ]
        then
                kill -9 $PID
        fi
        if [ -e $fanctl_config ]; then
                /ffp/sbin/fanctl $fanctl_config >/dev/null 2>/dev/null </dev/null &
        else 
                /usr/sbin/fancontrol >/dev/null 2>/dev/null </dev/null &
        fi
}

fanctl_restart() {
	proc_stop fanctl
	if [ -e $fanctl_config ]; then
                /ffp/sbin/fanctl $fanctl_config >/dev/null 2>/dev/null </dev/null &
        else
		/usr/sbin/fancontrol >/dev/null 2>/dev/null </dev/null &
	fi
}

fanctl_stop()
{
    proc_stop fanctl
    /usr/sbin/fancontrol >/dev/null 2>/dev/null </dev/null &
}

fanctl_status()
{
    proc_status fanctl
}

run_rc_command "$1"
#!/ffp/bin/sh

# PROVIDE: rsyncd
# REQUIRE: LOGIN

# This script assumes that the rsync configuration includes
# pid file = /var/run/rsyncd.pid

conf_file=/ffp/etc/rsyncd.conf
pid_file=/var/run/rsyncd.pid

rsync_flags="--daemon --config=$conf_file"

rsyncd_start()
{
	if [ ! -r "$conf_file" ]; then
		echo "Error: Missing config file $conf_file"
		exit 1
	fi

	x=$(grep '^pid file' $conf_file | cut -d= -f2)
	if [ "$x" != "$pid_file" ]; then
		echo "Error: Missing or wrong pid file in $conf_file (expected: $pid_file)"
		exit 1
	fi

	echo "Starting /ffp/bin/rsync $rsync_flags"
	/ffp/bin/rsync $rsync_flags
}

rsyncd_stop()
{
	if [ -r "$pid_file" ]; then
		kill $(cat $pid_file) 2>/dev/null
	fi
}

rsyncd_status()
{
	if [ -r $pid_file ]; then
		rsync_pid=$(cat $pid_file)
		if pidof rsync | grep -wq $rsync_pid; then
			echo "rsyncd running: $rsync_pid"
		else
			echo "rsync not running ($pid_file stale)"
		fi
	else
		echo "rsyncd not running"
	fi
}

case "$1" in
	start)
		rsyncd_start
		;;
	stop)
		rsyncd_stop
		;;
	restart)
		rsyncd_stop
		sleep 1
		rsyncd_start
		;;
	status)
		rsyncd_status
		;;
	*)
		echo "Usage: $(basename $0) start|stop|restart|status"
		exit 1
		;;
esac

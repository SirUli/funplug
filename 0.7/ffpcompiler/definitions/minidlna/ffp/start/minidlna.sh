#!/ffp/bin/sh
# Startfile borrowed from KyLeKs minidlna-packages

# PROVIDE: minidlna
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="minidlna"
command="/ffp/sbin/minidlna"
restart_cmd="minidlna_restart"
start_cmd="minidlna_start"
stop_cmd="minidlna_stop"

pid_file="/ffp/var/run/minidlna.pid"

required_files="/ffp/etc/minidlna.conf"

minidlna_flags="-f /ffp/etc/minidlna.conf -P $pid_file"

rebuild_db=$2

minidlna_start()
{
	if [ ! -c /dev/inotify ]
	then
		mknod /dev/inotify c 10 63
		chmod 666 /dev/inotify
	fi
	if [ "x$rebuild_db" == "xr" ]; then
	    echo "Rebuilding minidlna database"
	    minidlna_flags="${minidlna_flags} -R"
	fi
	echo "Running ${command} ${minidlna_flags}"
	${command} ${minidlna_flags}
}

minidlna_stop()
{
	killall minidlna
}

minidlna_restart()
{
	killall minidlna
	${command} ${minidlna_flags}
}

run_rc_command "$1"


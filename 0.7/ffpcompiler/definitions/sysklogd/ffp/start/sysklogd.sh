#!/ffp/bin/sh

# PROVIDE: sysklog
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

TMPDIR=/ffp/tmp
export TMPDIR

name="sysklog"
start_cmd="sysklog_start";
stop_cmd="sysklog_stop";

sysklog_start()
{
        /ffp/sbin/klogd
        /ffp/sbin/syslogd -f /ffp/etc/syslog.conf
}

sysklog_stop()
{
        killall klogd
        killall syslogd
}

run_rc_command "$1"

#!/ffp/bin/sh

# PROVIDE: tftpd
# REQUIRE: LOGIN syslogd

. /ffp/etc/ffp.subr

name="tftpd"
command="/ffp/sbin/tftpd"

tftpd_flags="-L -4 -s /mnt/HD_a2/ "
start_cmd="tftpd_start"

tftpd_start()
{
        $command $tftpd_flags >/dev/null 2>/dev/null </dev/null &
}

run_rc_command "$1"

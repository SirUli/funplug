#!/ffp/bin/sh

# PROVIDE: uwremoveusbfromsmb
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="uwremoveusbfromsmb"
start_cmd="uwremoveusbfromsmb_start"
stop_cmd="uwremoveusbfromsmb_stop"

CRONTXT=/tmp/crontab.txt

uwremoveusbfromsmb_start() {
    # Run USB Remover
    /ffp/bin/perl /ffp/var/opt/uwremoveusbfromsmb/uwremoveusbfromsmb.pl
    # Restart Samba
    /usr/sbin/smb restart
}
uwremoveusbfromsmb_stop() {
    echo "To return to the old configuration, please reboot the NAS"
}

run_rc_command "$1"

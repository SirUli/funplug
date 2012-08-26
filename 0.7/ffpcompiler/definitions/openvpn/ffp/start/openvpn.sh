#!/ffp/bin/sh

# PROVIDE: openvpn
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="openvpn"
command="/ffp/sbin/openvpn"
required_files="/ffp/etc/openvpn.conf"
openvpn_flags="--daemon --persist-tun --persist-key --config /ffp/etc/openvpn.conf"

start_cmd="openvpn_start"
stop_cmd="openvpn_stop"
extra_commands="debug"
debug_cmd="openvpn_debug"

openvpn_start()
{
	mkdir -p /dev/net
	mknod /dev/net/tun c 10 200 > /dev/null 2>&1
	insmod /ffp/lib/modules/$(uname -r)/drivers/net/tun.ko > /dev/null 2>&1
	
	proc_start $command
}

openvpn_stop()
{
	
	echo Stopping OpenVPN
	proc_stop $command
	
	echo "Removing devices..."
	rm -f /dev/net/tun
	rmdir  /dev/net > /dev/null 2>&1
	sleep 3

	echo "Unloading modules ..."
	rmmod tun
}

openvpn_debug()
{
	# Remove --daemon
	export openvpn_flags="--persist-tun --persist-key --config /ffp/etc/openvpn.conf"
	openvpn_start
}

run_rc_command "$1"

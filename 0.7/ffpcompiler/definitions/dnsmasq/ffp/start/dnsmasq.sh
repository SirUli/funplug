#!/ffp/bin/sh

# PROVIDE: dnsmasq
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="dnsmasq"
command="/ffp/sbin/$name"
dnsmasq_flags=

run_rc_command "$1"

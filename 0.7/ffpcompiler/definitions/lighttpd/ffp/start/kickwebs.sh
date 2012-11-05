#!/ffp/bin/sh

# PROVIDE: kickwebs
# REQUIRE: LOGIN
# BEFORE: lighttpd

. /ffp/etc/ffp.subr
name="kickwebs"
start_cmd="kickwebs_start"
stop_cmd=:

kickwebs_start()
{
	if [[ $(pidof webs) -gt 0 ]]; then
		echo "Kicking webs ..."
		kill -9 `pidof webs`
        fi
}

run_rc_command "$1"


#!/ffp/bin/sh
# Original by fonz     (http://inreto.de)
# Modified by Uli Wolf (http://wolf-u.li / http://nas-tweaks.net)

# PROVIDE: lighttpd
# REQUIRE: LOGIN kickangel

. /ffp/etc/ffp.subr

name="lighttpd"
command="/ffp/sbin/lighttpd-angel"
# -D required as lighttpd-angel dies if not set
lighttpd_configuration="/ffp/etc/lighttpd.conf"
lighttpd_flags="-D -f $lighttpd_configuration"
required_files="/ffp/etc/lighttpd.conf"

extra_commands="check reload"
start_cmd="lighttpd_start"
check_cmd="lighttpd_check"
reload_cmd="lighttpd_reload"

lighttpd_start()
{
        echo "Starting lighttpd-angel"
	if [[ -d /srv && ! -h /srv ]]; then
		echo "/srv should not be a directory, just a symbolic link. Something went wrong, exiting"
		exit 1
	fi
	if [[ ! -h /srv ]]; then
		echo "Creating symbolic link"
		ln -snf /ffp/opt/srv /srv
	fi
	echo "Creating directories"
	mkdir -p /srv/www/{pages,logs,tmp}
	$command $lighttpd_flags >/dev/null 2>/dev/null </dev/null &
}

lighttpd_check()
{
        echo "Checking Configuration"
        $command -t -f $lighttpd_configuration
}

lighttpd_reload()
{
        echo "Checking configuration"
        configok=$($command -t -f $lighttpd_configuration 2> /dev/null|grep -c "Syntax OK")
        if [[ $configok -gt 0 ]]; then
                echo "Configuration is ok"
        else
                echo "Configuration is not ok, please run '$0 check'"
                exit 1
        fi
        echo "Reloading configuration ..."
        kill -HUP $(pidof lighttpd-angel)
        echo "Checking if the angel is still there ..."
        # Need to sleep a second otherwise the check doesn't work
        sleep 1
        if [[ $(pidof lighttpd-angel) -gt 0 ]]; then
                echo "Lighty is flying, everythings OK"
        else
                echo "Didn't find the angel, something wrong?"
                echo "Perhaps you didn't run '$0 check' before?"
        fi
}

run_rc_command "$1"

#!/ffp/bin/sh

# PROVIDE: nginx
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="nginx"
command="/ffp/sbin/nginx"
nginx_flags="-c /ffp/etc/nginx/nginx.conf"
required_files="/ffp/etc/nginx/nginx.conf"

start_cmd="nginx_start"
stop_cmd="nginx_stop"
extra_commands="configtest upgrade reload"
debug_cmd="nginx_configtest"
upgrade_cmd="nginx_upgrade"

nginx_start()
{
	nginx_configtest || return 1
	proc_start $command
        #$command $nginx_flags >/dev/null 2>/dev/null </dev/null &
}

nginx_stop()
{
        nginx_configtest || return 1
	proc_stop $command
	rm -f /ffp/var/run/nginx.pid
}

nginx_reload()
{
        nginx_configtest || return 1
        kill -HUP `cat /ffp/var/run/nginx.pid` &>/dev/null
}

nginx_upgrade()
{
        nginx_configtest || return 1
        kill -USR2 `cat /ffp/var/run/nginx.pid` &>/dev/null
        sleep 3

        if [ ! -f /ffp/var/run/nginx.pid.oldbin ]; then
                return 1
        fi

        if [ ! -f /ffp/var/run/nginx.pid ]; then
                return 1
        fi

        sleep 3 ; kill -WINCH `cat /ffp/var/run/nginx.pid.oldbin`
        kill -QUIT `cat /ffp/var/run/nginx.pid.oldbin`
}

nginx_configtest()
{
	$command $nginx_flags -t
}

run_rc_command "$1"


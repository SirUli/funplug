#!/ffp/bin/sh

# PROVIDE: mysqld
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="mysqld"
start_cmd="mysqld_start"
stop_cmd="mysqld_stop"
status_cmd="mysqld_status"

mysqld_flags="--skip-networking --user=root"

mysqld_start()
{
        echo "Starting mysql"
        SRVPATH=/ffp/opt/srv
	if [[ ! -h /srv ]]; then
                echo "Creating directories"
                SRVPATH=/ffp/opt/srv
                ln -snf $SRVPATH /srv
        fi
	echo "Checking for directories and creating them if required"
	mkdir -p /srv/mysql/{innodblogdir,binlog,log,tmp,datadir}
	/ffp/bin/mysqld_safe $mysqld_flags </dev/null &
}

mysqld_stop()
{
    proc_stop mysqld
}

mysqld_status()
{
    proc_status mysqld
}

run_rc_command "$1"

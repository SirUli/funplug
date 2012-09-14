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
        if [[ ! -h /srv ]]; then
                echo "Creating directories"
                SRVPATH=/ffp/opt/srv
                mkdir -p $SRVPATH/mysql/innodb/
                mkdir -p $SRVPATH/mysql/innodblogdir/
		mkdir -p $SRVPATH/mysql/binlog/
		mkdir -p $SRVPATH/mysql/log/
                mkdir -p $SRVPATH/mysql/tmp/
		mkdir -p $SRVPATH/mysql/datadir/
                ln -snf $SRVPATH /srv
        fi
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

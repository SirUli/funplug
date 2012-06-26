#!/ffp/bin/sh

# PROVIDE: uwfancontrol
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="uwfancontrol"
start_cmd="uwfancontrol_start"
stop_cmd="uwfancontrol_stop"

CRONTXT=/tmp/crontab.txt

uwfancontrol_start() {
    # Copy fancontrol
    /ffp/bin/cp /ffp/var/opt/uwfancontrol/uwfancontrol.sh /tmp/uwfancontrol.sh
    # Copy dns323-spindown
    /ffp/bin/cp /ffp/var/opt/uwfancontrol/dns323-spindown /tmp/dns323-spindown
    # Now make them executable
    chmod a+x /tmp/uwfancontrol.sh
    chmod a+x /tmp/dns323-spindown

    # start with existing crontab
    /bin/crontab -l > $CRONTXT

    # Add the Fan check job to execute every 5 Minutes
    /bin/echo "*/5  * * * * /tmp/uwfancontrol.sh &" >> $CRONTXT
    #          *    * * * *
    #          -    - - - -
    #          ¦    ¦ ¦ ¦ ¦
    #          ¦    ¦ ¦ ¦ +---- Weekday (0-7) (Sunday =0 oder =7)
    #          ¦    ¦ ¦ +------ Month (1-12)
    #          ¦    ¦ +-------- Day (1-31)
    #          ¦    +---------- Hour (0-23)
    #          +--------------- Minute (0-59)

    # install the new crontab
    /bin/crontab $CRONTXT

    # clean up tmp crontab
    /bin/rm $CRONTXT
}
uwfancontrol_stop() {
    # start with existing crontab, grep out uwfancontrol
    /bin/crontab -l|grep -v "uwfancontrol" > $CRONTXT
    # install the new crontab
    /bin/crontab $CRONTXT
    # clean up tmp crontab
    /bin/rm $CRONTXT
    echo "root">> /var/spool/cron/crontabs/cron.update
    # Restart normal fancontrol
    /usr/sbin/fancontrol & > /dev/null 2>&1 
    # Clear /tmp
    /bin/rm /tmp/uwfancontrol.sh
    /bin/rm /tmp/dns323-spindown
}

run_rc_command "$1"

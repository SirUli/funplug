#!/ffp/bin/sh

# PROVIDE: uwcron
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="uwcron"
start_cmd="uwcron_start"
stop_cmd="uwcron_stop"

CRONTXT=/tmp/crontab.txt
CRONDIR=/ffp/etc/cron.d

uwcron_start() {
    # Check if there is a cron to add
    if [[ $(ls -1 $CRONDIR|wc -l) -gt 0 ]]; then
        # Dump existing crontab
        /bin/crontab -l > $CRONTXT
	# Add a marker for begin of all uwcron-added cron-definitions
        /bin/echo "### UWCRON BEGIN ###" >> $CRONTXT
        # Add a warning
        /bin/echo "# DO NOT REMOVE OR CHANGE THE DEFINITIONS HERE" >> $CRONTXT
        /bin/echo "# FOR CHANGES GO TO THE CORRESPONDING FILES, SEE BELOW" >> $CRONTXT
	/bin/echo "" >> $CRONTXT
        for FILENAME in $(ls -1 $CRONDIR); do
            # Dump to crontab where the definition came from
	    uwcron_rpad "### BEG: Definition from $FILENAME " 80 "#" >> $CRONTXT
	    # Now copy each line
            /bin/cat $CRONDIR/$FILENAME >> $CRONTXT
            uwcron_rpad "### END: Definition from $FILENAME " 80 "#" >> $CRONTXT
            /bin/echo "" >> $CRONTXT
        done
	# Add a marker for end of all uwcron-added cron-definitions
        /bin/echo "### UWCRON END ###" >> $CRONTXT
	# Activate new crontab
	uwcron_executecrontab
    fi
}

uwcron_stop() {
    # start with existing crontab, grep out uwcron
    /bin/crontab -l|sed '/^### UWCRON BEGIN ###/,/^### UWCRON END ###/d' > $CRONTXT
    # Activate new crontab
    uwcron_executecrontab
}

# Helper: Activates new crontab
uwcron_executecrontab() {
    # install the new crontab
    /bin/crontab $CRONTXT
    # clean up tmp crontab
    /bin/rm $CRONTXT
    # Write to certain file to activate
    /bin/echo "root">> /var/spool/cron/crontabs/cron.update
}

# Right padding function
# Usage: WORD LENGTH CHAR
uwcron_rpad() {
    word="$1"
    while [ ${#word} -lt $2 ]; do
        word="$word$3";
    done;
    /bin/echo "$word";
}

run_rc_command "$1"

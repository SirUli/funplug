#!/ffp/bin/sh
TODAY=$(date +%s);
###############################################################################
# First load configuration
CONFIGFILE=/ffp/etc/ffpbackup/ffpbackup.conf
if [[ ! -f $CONFIGFILE ]]; then
	echo "Please configure first:"
	echo "Configuration file should be available at $CONFIGFILE"
	echo "Example is available at /ffp/etc/examples/ffpbackup/"
	echo "Exiting"
	exit 1
else
	# Load configuration
	. $CONFIGFILE
fi
###############################################################################
# Functions
# Create directory
function func_create_dir {
	if [[ ! -d $1 ]]; then
		mkdir -p $1
		return $?
	fi
}
###############################################################################
# Check verbosity
if [[ $VERBOSE -eq 1 ]]; then
	TARVERBOSE="-v"
fi
###############################################################################
# Check the general backup directory
func_create_dir $BACKUPDIR
if [[ $? -ne 0 ]]; then
	echo "Directory $BACKUPDIR not available, please check"
	exit 1
fi
###############################################################################
# Now create the specific directory for the backup
BACKUPDIRTODAY=$BACKUPDIR/$TODAY
func_create_dir $BACKUPDIRTODAY
if [[ $? -ne 0 ]]; then
        echo "Directory $BACKUPDIRTODAY not available, please check"
	exit 1
fi
###############################################################################
# Setup cleanup of old backups
DELOLDERTHAN=$(date --date "-$RETENTION Days" +%s);
DELOLDERDIRS=$(ls -gGl $BACKUPDIR| grep ^d| tr -s [:blank:] " " |cut -d' ' -f 7);
for DELOLDERDIR in $DELOLDERDIRS; do
	if [[ $DELOLDERDIR -lt $DELOLDERTHAN ]]; then
		echo "Deleting $BACKUPDIR/$DELOLDERDIR";
		#rm -Rf $BACKUPDIR/$DELOLDERDIR;
	fi
done
###############################################################################
# Check if Excludelist exists
if [[ -f /ffp/etc/ffpbackup/ffpbackup-exclude.conf ]]; then
	EXCLUDELIST="--exclude-from=/ffp/etc/ffpbackup/ffpbackup-exclude.conf"
else
	EXCLUDELIST=""
fi
###############################################################################
# check if we should log to the WebInterface
if [[ $WEBLOGGING = true ]]; then
DATE_FORMATTED="`date +\"%b %d  %T\"`"
STAT="FFPbackup wurde ausgelöst."
STR="$DATE_FORMATTED DNS-325 ffp-backup: $STAT"
echo "$STR" >> /var/log/user.log
fi
###############################################################################
# Perform the backup
# Switch to /ffp
cd /ffp
# Create tar file
tar $EXCLUDELIST $TARVERBOSE -zcf $BACKUPDIRTODAY/fun_plug.tgz *
if [[ $? -ne 0 ]]; then
	echo "Backup failed? See above"
	exit 1
fi
###############################################################################
# Create md5sum for later consistency check
md5sum $BACKUPDIRTODAY/fun_plug.tgz > $BACKUPDIRTODAY/fun_plug.tgz.md5
###############################################################################
chmod -R $BACKUPCHMOD $BACKUPDIR
chown -R $BACKUPCHOWN $BACKUPDIR
###############################################################################

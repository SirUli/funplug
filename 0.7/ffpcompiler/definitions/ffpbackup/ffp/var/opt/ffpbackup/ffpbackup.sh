#!/ffp/bin/sh
# AUTHORS:
# - Simon Groot Bramel
# - Uli Wolf (http://wolf-u.li)
TODAY=$(date +%s);
###############################################################################
# First load configuration
CONFIGFILE=/ffp/etc/ffpbackup/ffpbackup.conf
if [[ ! -f $CONFIGFILE ]]; then
	echo "Please configure FFPbackup first:"
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
# General logger
function func_log {
	DATE_FORMATTED=$(date +"%b %d  %T")
	LOGMESSAGE="$DATE_FORMATTED FFPbackup: $*"
	# Log to commandline if verbosity is set
	[[ $VERBOSE -eq 1 ]] && echo $LOGMESSAGE
	# Log to Webinterface of D-Link Devices
	[[ $WEBLOGGING -eq 1 ]] && echo $LOGMESSAGE >> /var/log/user.log
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
	func_log "Directory $BACKUPDIR not available, please check"
	exit 1
fi
###############################################################################
# Now create the specific directory for the backup
BACKUPDIRTODAY=$BACKUPDIR/$TODAY
func_create_dir $BACKUPDIRTODAY
if [[ $? -ne 0 ]]; then
        func_log "Directory $BACKUPDIRTODAY not available, please check"
	exit 1
fi
###############################################################################
# Setup cleanup of old backups
DELOLDERTHAN=$(date --date "-$RETENTION Days" +%s);
DELOLDERDIRS=$(ls -gGl $BACKUPDIR| grep ^d| tr -s [:blank:] " " |cut -d' ' -f 7);
for DELOLDERDIR in $DELOLDERDIRS; do
	if [[ $DELOLDERDIR -lt $DELOLDERTHAN ]]; then
		func_log "Deleting $BACKUPDIR/$DELOLDERDIR";
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
func_log "Backup starting"
###############################################################################
# Perform the backup
# Switch to /ffp
cd /ffp
# Create tar file
tar $EXCLUDELIST $TARVERBOSE -pzcf $BACKUPDIRTODAY/fun_plug.tgz *
if [[ $? -ne 0 ]]; then
	func_log "Backup failed, please check"
	exit 1
else
	func_log "Backup successful"
fi
###############################################################################
# Create md5sum for later consistency check
md5sum $BACKUPDIRTODAY/fun_plug.tgz > $BACKUPDIRTODAY/fun_plug.tgz.md5
###############################################################################
chmod -R $BACKUPCHMOD $BACKUPDIR
chown -R $BACKUPCHOWN $BACKUPDIR
###############################################################################
func_log "Backup finished"
#!/ffp/bin/sh
#
#****h* uwscripts/uwsiteloader
# NAME
#  UW Site Loader
# SYNOPSIS
#  Downloads a definition file from wolf-u.li and presents the data to the user
# AUTHOR
#  * Uli Wolf (UW) <m@il.wolf-u.li>
# HISTORY
#  * (YYYY-MM-DD - Author: Changes)
#  * 2012-03-21 - UW: Initial Version
################################################################################
# SOURCE
################################################################################
# Temporary files
TMPFILE1=$(mktemp)
TMPFILE2=$(mktemp)
TMPFILE3=$(mktemp)
TMPFILE4=$(mktemp)
################################################################################
# Variable definitions
FFPSITES_FILE=/ffp/etc/funpkg/sites
################################################################################
# Functions
function func_exit {
	echo $2
	exit $1
}
################################################################################
dialog --title " Information " --backtitle " UW Site Loader " --yesno "\nThis script will download the current definition file which contains all possible sites for ffp packages. Continue?" 0 0
if [[ $? -ne 0 ]]; then
	clear
	echo "Exiting"
	exit 1
fi
################################################################################
# Information for own sites
dialog --title " Information " --backtitle " UW Site Loader " --msgbox "If you want to add your own site in this tool, please send me a message to:\n<ffp@wolf-u.li>\nI will add it as quickly as possible." 10 50
################################################################################
# Download the definition-file
dialog --title " Information " --backtitle " UW Site Loader " --infobox "Downloading definitions\nPlease wait" 10 40
curl -L https://wolf-u.li/u/439 -o $TMPFILE1
if [[ $? -ne 0 ]]; then
	dialog --title " Error " --backtitle " UW Site Loader " --msgbox "Downloading definitions\nFAILED, please check your internet connection!" 10 40
	clear
	echo "Please check your internet connection, cannot proceed!"
	exit 1
fi
dialog --title " Information " --backtitle " UW Site Loader " --infobox "Downloading definitions\nCompleted - Processing" 10 40
################################################################################
# Process the definition file and present the data to the user for selection
# Determine FFP_ARCH
export $(cat /ffp/etc/ffp-version|grep FFP_ARCH)
clear
for SITEDEFINITION in $(cat $TMPFILE1)
do
	SITE_ARCH=$(echo $SITEDEFINITION|cut -d"#" -f1)
	if [[ $SITE_ARCH = $FFP_ARCH ]]; then
		SITE_MAINT=$(echo $SITEDEFINITION|cut -d"#" -f2)
		SITE_SHORTCODE=$(echo $SITEDEFINITION|cut -d"#" -f3)
		SITE_URL=$(echo $SITEDEFINITION|cut -d"#" -f4)
		echo "${SITE_ARCH}#${SITE_MAINT}#${SITE_SHORTCODE}#${SITE_URL}" >> $TMPFILE2
		ON_OFF="off"
		if [[ $(grep -c "$SITE_URL" $FFPSITES_FILE) -gt 0 ]]; then
			ON_OFF="on"
		fi
		echo "'${SITE_MAINT}' '${SITE_URL}' $ON_OFF 'Packages of ${SITE_MAINT} (Found under ${SITE_URL})'" >> $TMPFILE3
	fi
done
################################################################################
# Display the menu to the user
xargs dialog --separate-output --title " Choose sites " --backtitle " UW Site Loader " --item-help --checklist "" 0 0 0 <$TMPFILE3 2>$TMPFILE4

# Check if the user did abort the dialog
if [[ $? -eq 0 ]]; then
	# Process the selection
	# Make a Backup
	[[ -f ${FFPSITES_FILE} ]] && mv ${FFPSITES_FILE} ${FFPSITES_FILE}.bak
	# Iterate through the Definition-File
	for SITEDEFINITION in $(cat $TMPFILE2)
	do
		# Iterate through the selection from the menu
		for SITESELECTION in $(cat $TMPFILE4)
		do
			# Check if a line in the definition matches the selection
			if [[ $(echo $SITEDEFINITION|grep -c $SITESELECTION) -gt 0 ]]; then
				SITE_MAINT=$(echo $SITEDEFINITION|cut -d"#" -f2)
				SITE_SHORTCODE=$(echo $SITEDEFINITION|cut -d"#" -f3)
				SITE_URL=$(echo $SITEDEFINITION|cut -d"#" -f4)
				echo -e "${SITE_SHORTCODE}\t${SITE_URL}" >> ${FFPSITES_FILE}
			fi
		done
	done
	dialog --title " Information " --backtitle " UW Site Loader " --msgbox "Package List was updated with the sites from the following maintainers:\n\n$(cat $TMPFILE4)" 10 50
	################################################################################
	# Update Package lists
	dialog --title " Information " --backtitle " UW Site Loader " --yesno "\nDo you want to run 'slacker -U' to download the latest package lists?" 0 0
	RC=$?
	clear
	if [[ $RC -eq 0 ]]; then
		/ffp/bin/slacker -U
	fi
else
	dialog --title " Error " --backtitle " UW Site Loader " --msgbox "Selection aborted, program exits without modifications to ${FFPSITES_FILE}" 10 50
	clear
fi
################################################################################
# Remove temporary stuff
rm $TMPFILE1
rm $TMPFILE2
rm $TMPFILE3
rm $TMPFILE4

################################################################################
# Exit
echo "Thanks for using UW Site Loader!"
exit 0
#****

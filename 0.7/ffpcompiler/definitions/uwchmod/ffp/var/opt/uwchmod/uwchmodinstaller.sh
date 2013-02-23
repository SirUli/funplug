#!/bin/sh
# Author: Uli Wolf <ffp@wolf-u.li>
# This is a extension of a script by KyleK (http://forum.dsmg600.info/viewtopic.php?pid=44533#p44533)

# Init variables
V_SOURCEDIR=/ffp/var/opt/uwchmod
V_TARGETDIR=/usr/local/config
V_INITFILE=$V_TARGETDIR/rc.init.sh

if [[ -d $V_TARGETDIR ]]; then
	# Copy
	cp -f $V_SOURCEDIR/uwchmod.sh $V_TARGETDIR/ 
	chmod +x $V_TARGETDIR/uwchmod.sh

	# Copy
	cp $V_SOURCEDIR/uwchmodinitializer.sh $V_TARGETDIR/
	# Mark executable
	chmod +x $V_TARGETDIR/uwchmodinitializer.sh

	# Remove older installations of this script
	sed -i '/^### UWCHMOD BEGIN ###/,/^### UWCHMOD END ###/d' $V_INITFILE

	# Now add the new one
	/bin/echo "### UWCHMOD BEGIN ###" >> $V_INITFILE
	echo "if [[ -x $V_TARGETDIR/uwchmodinitializer.sh ]]; then" >> $V_INITFILE
	echo "    $V_TARGETDIR/uwchmodinitializer.sh" >> $V_INITFILE
	echo "fi" >> $V_INITFILE
	/bin/echo "### UWCHMOD END ###" >> $V_INITFILE

	if [[ -x /usr/local/config/uwchmodinitializer.sh ]]; then
		/usr/local/config/uwchmodinitializer.sh
	fi
else
	echo "This seems not to be a problematic device"
fi
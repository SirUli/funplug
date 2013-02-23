#!/bin/sh
# Author: Uli Wolf <ffp@wolf-u.li>
# This is a extension of a script by KyleK (http://forum.dsmg600.info/viewtopic.php?pid=44533#p44533)

# Replaces /bin/chmod with a custom script that has only one purpose:
# If any process tries to execute a chmod 777, it will be skipped

if [ -x /usr/local/config/uwchmod.sh ]; then
	if [ -x /bin/chmod ]; then
		rm /bin/chmod
	fi
	ln -s /usr/local/config/uwchmod.sh /bin/chmod
fi
#!/bin/sh
# Author: Uli Wolf <ffp@wolf-u.li>
# This is a extension of a script by KyleK (http://forum.dsmg600.info/viewtopic.php?pid=44533#p44533)

# Init variables
V_ARGUMENTS="$@"
V_PROBLEMATICSTATEMENT=0
V_STARTDIR=/mnt

# First check for the chmod
for V_CHMODVARTEST in $V_ARGUMENTS; do
        if [[ $V_CHMODVARTEST = '777' ]]; then
                # Could be a problem, lets check further
		# Get the path
		V_ARGUMENTS_PATH=$(echo $V_ARGUMENTS|awk '{for(i=1;i<=NF;i++)if($i ~/\//) print $i}')
		# If this is empty, this is not from the firmware, can be skipped
		if [[ "${V_ARGUMENTS_PATH}test" != "test" ]]; then
			# Remove last slash
			V_ARGUMENTS_PATH=${V_ARGUMENTS_PATH%/*}
			# Determine possible paths
			for V_DIRECTORY in $(find $V_STARTDIR -maxdepth 2 -type d -name "USB*" -o -name "HD*"); do
				if [[ $V_DIRECTORY = $V_ARGUMENTS_PATH ]]; then
					V_PROBLEMATICSTATEMENT=1
					break
				fi
			done
		fi
        fi
done

if [[ $V_PROBLEMATICSTATEMENT -ne 1 ]]; then
	# Just handover to busybox
	/bin/busybox chmod $V_ARGUMENTS
fi


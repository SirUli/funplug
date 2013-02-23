# Execute installation

echo "Running installer for UWCHMOD"
V_INSTFILE=/ffp/var/opt/uwchmod/uwchmodinstaller.sh
echo "Checking for correct installation"
if [[ -f $V_INSTFILE ]]; then
	echo "Seems to be good, executing installer"
	chmod +x $V_INSTFILE
	$V_INSTFILE
	echo "Done."
else
	echo "Seems like the installation didn't work"
	echo "Aborting"
fi
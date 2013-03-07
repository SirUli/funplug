# Fix the examples folder
find /ffp/etc/examples/ffpbackup/ -type f -name '*.new' -print0| while read -d $'\0' f; do mv "$f" "${f%.new}"; done
# Fix permissions
chmod a+x /ffp/var/opt/ffpbackup/ffpbackup.sh
# Create a link for direct execution
ln -snf /ffp/var/opt/ffpbackup/ffpbackup.sh /ffp/sbin/ffpbackup.sh
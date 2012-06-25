#!/ffp/bin/sh

# THANKS: KyleK

# PROVIDES: svnserve

. /ffp/etc/ffp.subr

REPOSITORY="/mnt/HD/HD_a2/svn/"

name="svnserve"
command="/ffp/bin/$name"
svnserve_flags="-d -r ${REPOSITORY}"

required_dirs=${REPOSITORY}
run_rc_command "$1"
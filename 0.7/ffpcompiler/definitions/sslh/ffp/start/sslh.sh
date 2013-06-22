#!/ffp/bin/sh
#
# SSLH startup script
#
# History :
# 10/02/2013, V1.0 - Creation by N. Bernaerts (http://bernaerts.dyndns.org/dns325/71-funplug07/273-dns325-ffp7-sslh-https-ssh-openvpn)
# 15/04/2013, V2.0 - Now handles restart

# PROVIDE: sslh
# REQUIRE: LOGIN

. /ffp/etc/ffp.subr

name="sslh"
start_cmd="sslh_start"
stop_cmd="sslh_stop"
restart_cmd="sslh_restart"

# --------------------------------------------
# Beginning of Configuration

# New port for DNS-325 web administration
SSL_PORT=444

# List of protocols to handle (address:port)
# Leave empty if not used
SRV_SSH="192.168.x.x:22"
SRV_SSL="192.168.x.x:443"
SRV_OPENVPN="192.168.x.x:1194"
SRV_TINC=""

# End of configuration
# --------------------------------------------

# set process PID
SSLH_PID="/var/run/sslh.pid"

# get DNS-325 ethernet IP
ETH_IP=`ifconfig | grep "inet" | grep -v "127.0.0.1" | sed 's/^.*addr:\([0-9\.]*\).*$/\1/g'`
echo "SSLH will listen on interface $ETH_IP, port 443"

# add PID to SSLH command
SSLH_COMMAND="--pidfile $SSLH_PID"

# add listening port to SSLH command
SSLH_COMMAND="$SSLH_COMMAND --listen $ETH_IP:443"

# if needed, add SSH server to SSLH command
if [ ! -z $SRV_SSH ]; then SSLH_COMMAND="$SSLH_COMMAND --ssh $SRV_SSH"; fi

# if needed, add SSL server to SSLH command
if [ ! -z $SRV_SSL ]; then SSLH_COMMAND="$SSLH_COMMAND --ssl $SRV_SSL"; fi

# if needed, add TINC server to SSLH command
if [ ! -z $SRV_TINC ]; then SSLH_COMMAND="$SSLH_COMMAND --tinc $SRV_TINC"; fi

# if needed, add OpenVPN server to SSLH command
if [ ! -z $SRV_OPENVPN ]; then SSLH_COMMAND="$SSLH_COMMAND --openvpn $SRV_OPENVPN"; fi

sslh_start()
{
  # change administration interface default https port to 444
  sed -i 's/:443/:'$SSL_PORT'/g' /etc/lighttpd/lighttpd.conf

  # kill administration interface web server (it will restart after few seconds)
  killall lighttpd

  # start sslh, listening on default https port 443
  sslh $SSLH_COMMAND
}

sslh_stop()
{
  # kill running instance from PID
  kill `cat $SRV_PID`

  # delete PID file
  rm $SSLH_PID

  # change administration interface default https port back to 443
  sed -i 's/:'$SSL_PORT'/:443/g' /etc/lighttpd/lighttpd.conf

  # kill administration interface web server (it will restart after few seconds)
  killall lighttpd
}

sslh_restart()
{
  # kill running instance from PID
  kill `cat $SRV_PID`

  # delete PID file
  rm $SSLH_PID

  # start sslh, listening on default https port 443
  sslh $SSLH_COMMAND
}

# run the command given as parameter
run_rc_command "$1"
#!/bin/sh
PATH=/usr/bin:/bin:/usr/sbin:/sbin
# Converts Fahrenheit to Celcius
f2c() {
  /bin/echo $(( (($1 - 32) * 10 + 9) / 18 ))
}
# Determine if its a DNS-320/325 or a former one
/ffp/bin/which fancontrol >> /dev/null
if [[ $? -eq 0 ]]; then
	# This is a DNS-323 or alike
	BINARYNAME=fancontrol
else
	/ffp/bin/which fan_control >> /dev/null
	if [[ $? -eq 0 ]]; then
		# This is a DNS-320/325 or alike
		BINARYNAME=fan_control
	fi
fi

# Kill the old fan controller
PID=$(/bin/pidof $BINARYNAME)
if [ -n "$PID" ]; then
   /bin/kill -9 $PID
fi
## Settings for the Temperatures
# Temperatures are in celcius - convert if necessary using f2c function
# Example: "TSTOP=$(f2c 90)" will convert 90° Fahrenheit to Celcius
# Fan stops below TSTOP
TSTOP=32
# Fan is set to low below TLOW and higher than TSTOP
TLOW=40
# NAS shutdown at that temperature
TSHUTDOWN=60
## Stop Fan if HDDs are stopped (1) or ignore Fan (0)
# This won't work on the DNS-320/DNS-325, so please leave it on 0 on them!
WATCHHDD=0
## Check if WATCHHDD is set to 1. If yes, then first check for that
if [ $WATCHHDD -eq 1 ]; then
        # Just using the dns323-tools from:
        # http://www.inreto.de/dns323/utils/
        HD=`/tmp/dns323-spindown | grep -i -c ACTIVE`
        if [ $HD -ne 1 ]; then
                # There is no HDD active, stop the fan
                /usr/sbin/fanspeed s &> /dev/null
                # Now stop, there is no need to check anything else
                exit 0;
        fi
        # There is obviously a disk active, so go on
fi
## Find out current temperature
T=`/usr/sbin/temperature g 0`
T=${T##*=}
C=`/usr/sbin/temperature g 0 | /bin/grep -i -c Fahrenheit`
## Convert to Fahrenheit if output is in Celcius
if [ $C -gt 0 ]; then
    T=$(f2c $T)
fi
## Calculate the correct Temperature
# Set high as standard. In case of failure (whyever this may happen)
# this script will change the cooler to "high"
NEWVAL="h"
if [ $T -lt $TLOW ]; then
        NEWVAL="l"
fi
if [ $T -lt $TSTOP ]; then
        NEWVAL="s"
fi
if [ $T -gt $TSHUTDOWN ]; then
        # NAS is overheated, initiate shutdown
        /bin/touch /tmp/shutdown
else
        # Set fan to new speed
        /usr/sbin/fanspeed $NEWVAL &> /dev/null
fi

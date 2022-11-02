#!/bin/bash
#
# changelog
# 20181220 - gev - change to 14 days, email function to notify itsupport

# specify notification days in seconds
seconds=1209600 #864000 seconds is 10 days
crtlocation="***"
date=`openssl x509 -in $crtlocation -enddate | grep ""notAfter"" | awk -F'=' '{print $2}'`

crtdate=$(date -d "$date" +%s)
cdate=$(date +%s)

MAILTO=***@***.com
HOSTNAME=`hostname`

if ! openssl x509 -checkend $seconds -in $crtlocation ; then
    if (( $crtdate > $cdate))  ; then
        expire="will expires in less than 14 days"
    else
        expire="expired"
    fi
    echo -e "WARNING - Certificate $expire at $date" | mail -s "Server Cert $expire at $date on $HOSTNAME" ${MAILTO} &
    result="WARNING - Certificate $expire at $date"
    /usr/sbin/slack-notify.sh "-t Certificate $expire" "-b $result" -s DOWN  "-c ***"
fi

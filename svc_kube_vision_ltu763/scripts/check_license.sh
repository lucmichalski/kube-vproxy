#!/bin/bash

##############################
#
# LTU Technologies - www.ltutech.com
# JuLien42
#
# check the expiration date of the license
#
# ./check_license_date <license file> [warning] [error]
#
#
# exemple in /etc/nagios/nrpe.cfg:
#   command[check_license]=/usr/lib/nagios/plugins/check_license_date /opt/ltuengine/config/license.lic
#
#
#############################

function usage() {
        echo "$0 <license file> [warning] [error]"
        exit 3
}

function invalidLicense() {
        echo "UNKNOWN - invalid license file"
        exit 3
}

function isNum() {
	[ "$(echo $1 | grep "^[ [:digit:] ]*$")" ] && echo 1 || echo 0
}

if [ "$#" -lt 1 ] || [ "$#" -gt 3 ]; then
	usage
fi 

lFile=$1
warning=$([ "$#" -gt 1 ] && echo $2 || echo $((60*60*24*10)))
critical=$([ "$#" -gt 2 ] && echo $3 || echo $((60*60*24*2)))

[ ! -f $lFile ] && invalidLicense
expirationDate=$(date -d "$(cat $lFile  | grep 'Expiration' | cut -d ':' -f2)" "+%s")
diffDate=$(($expirationDate - $(date "+%s")))
[ $(isNum "$expirationDate") -eq 0 ] && invalidLicense

message="certificat expiration: $diffDate cert: $lFile | diff=$diffDate"

if [ "$diffDate" -lt "$critical" ]; then
	echo "CRITICAL - $message"
	exit 2
fi

if [ "$diffDate" -lt "$warning" ]; then
        echo "WARNING - $message"
	exit 1
fi

echo "OK - $message"
exit 0

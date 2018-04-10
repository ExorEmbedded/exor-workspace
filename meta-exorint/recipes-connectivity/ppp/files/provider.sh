#!/bin/sh

COM_DEVICE=`/usr/bin/modem com`
[ $? -ne 0 ] && exit 1

cat << EOF
# example configuration for a dialup connection authenticated with PAP or CHAP
#
# This is the default configuration used by pon(1) and poff(1).
# See the manual page pppd(8) for information on all the options.

# MUST CHANGE: replace myusername@realm with the PPP login name given to
# your by your provider.
# There should be a matching entry with the password in /etc/ppp/pap-secrets
# and/or /etc/ppp/chap-secrets.
#user "myusername@realm"

# MUST CHANGE: replace ******** with the phone number of your provider.
# The /etc/chatscripts/pap chat script may be modified to change the
# modem initialization string.
#connect "/usr/sbin/chat -v -f /etc/chatscripts/pap -T ********"
connect "/usr/sbin/chat -v -f /etc/chatscripts/gprs"

# Serial device to which the modem is connected.
${COM_DEVICE}
# Speed of the serial line.
3000000

# Assumes that your IP address is allocated dynamically by the ISP.
noipdefault
# Try to get the name server addresses from the ISP.
usepeerdns
# Don't set default route (done in ppp-up.d/05addgw)
nodefaultroute

# Makes pppd "dial again" when the connection is lost.
persist
# No limit on retries (signal may be poor)
maxfail 0

# Do not ask the remote to authenticate.
noauth

# extras
debug
ktune
nodeflate
EOF

AUTH_TYPE=`sys_params services/mobile/auth/type 2>/dev/null`
AUTH_USER=`sys_params services/mobile/auth/user 2>/dev/null`
case "${AUTH_TYPE}" in
    1|2) # PAP, CHAP
        [ -z ${AUTH_USER} ] || echo "user ${AUTH_USER}"
        ;;
    *)
        ;;
esac

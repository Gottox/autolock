#!/bin/sh
set -e

if [ "$1" = "install" ]; then
	self=$(which $0)
	printf "Bluetooth address of the device: "
	read -r addr
	echo "* * * * * root $self $addr >/dev/null 2>&1" > /etc/cron.d/autolock
	exit 0
elif [ $# != 1 ]; then
	echo "Usage: $0 BTADDR | install"
	exit 1
fi
addr=$1

cleanup() {
	rm /run/autolock/was_connected
	exit 0
}

# Only continue if bluetooth is enabled
rfkill list bluetooth -o SOFT | grep -q unblocked || cleanup

# Only continue if Session is not locked
loginctl show-session 1 | grep -q LockedHint=yes && cleanup

if l2ping -c 1 -t 1 "$addr"; then
	mkdir -p /run/autolock
	touch /run/autolock/was_connected
elif [ -e /run/autolock/was_connected ]; then
	loginctl lock-sessions
	cleanup
fi

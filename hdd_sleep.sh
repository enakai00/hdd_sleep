#!/bin/bash -x

DISK=sdb	# Target disk
IDLE=10		# Spindown after 10 minutes idle

logger -t hdd_sleep.sh "daemon started."

spinup=1
state=$(grep " $DISK " /proc/diskstats)

while [[ true ]]; do
	new_state=$(grep " $DISK " /proc/diskstats)
	if [[ "$new_state" != "$state" ]]; then # HDD was accessed 
		state=$new_state
		count=0
		if [[ $spinup -eq 0 ]]; then
			logger -t hdd_sleep.sh "spinup /dev/$DISK"
			spinup=1
		fi
	else # No HDD access
		if [[ $spinup -eq 1 ]]; then
			count=$(( count + 1 ))
			if [[ $count -eq $IDLE ]]; then
				logger -t hdd_sleep.sh "spindown /dev/$DISK"
				sync
				sleep 1
				sdparm --command=stop /dev/$DISK
				state=$(grep " $DISK " /proc/diskstats)
				spinup=0
				count=0
			fi
		fi
	fi
	sleep 60
done
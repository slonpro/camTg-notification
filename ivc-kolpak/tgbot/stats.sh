#!/bin/bash

filename="/tmp/cpu_status.png"

info=$(echo -e && \
	echo -e "STATION ULLI VHF AIRBAND/ADSB v1 RockPiS (ULLI, SAINT-PETERSBURG, RUSSIA) STATUS" && \
	echo -e && \
	uname -n -s -r && \
        uptime && \
        cat /sys/block/mmcblk0/stat | awk '{printf "Uptime read: %.3fMiB (%.1f%% I/Os merged) written: %.3f MiB (%.1f%% I/Os merged)\n", $3*512/1048576, $2/$1*100, $7*512/1048576, $6/$5*100}' && \
        echo -e && \
        free -h && \
        echo -e && \
        lsusb | grep -v Linux && \
        echo -e && \
        df -h | grep "4.4G\|Used\|/tmp" && \
        echo -e && \
	ip -s addr show dev eth0 | grep -v "link\|preferred" && \
	ip -s addr show dev tap0 | grep -v "link\|preferred" && \
	iwconfig wlan0 | grep -i "quality\|Rate\|Frequency\|ESSID" && \
	ip -s addr show dev wlan0 | grep -v "link\|preferred" && \
	echo -e && \
	service rtlairband status | grep "rtlairband.service\|Active:" && \
        service icecast2 status | grep "Active:\|icecast2.service" && \
	echo -e)

#echo "$info"

#exit 0

#         python3 /etc/avia-stuff/sensors/sensors.py && \

echo "$info" | \
	sed 's/\t/     /g' | \
        convert -background '#76608A' \
        -font DejaVu-Sans-Mono \
        -fill white \
        -pointsize 8 \
        label:@- \
        $filename

tgbot.sh "status" --senddoc $filename

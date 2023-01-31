#!/bin/bash

############################################################
# IVC KOLPAK PROJECT
# (c) 2018-2019 Flangeneer
# Any questions ask in telegram group: @ivckolpak
# Saint-Petersburg, 2018-2019
############################################################

# Script executes telegram bot accoding to channel

channel=$1

timeout -k 10 300s estgb --path /etc/ivc-kolpak/channels/$channel/ \
	--force-remove \
	--weakconfig \
	--comment "$4" \
	--escape-seq \
	--daemon \
	--fileconfigs "$2" "$3" &

exit 0
#         --proxy socks5://172.24.1.1:9050 \

#!/bin/sh

cd /home/root/lws

IP=`cat ../lws/js/websocket_demo.js |grep 'ws://' | awk -F '//' '{print $2}' | awk -F ':' '{print $1}'`
while [ 1 -eq 1 ]; do
	ifconfig eth0:0 ${IP} || true
	if [ 0 -ne `ifconfig | grep ${IP} | wc -l` ]; then
		break
	fi
	sleep 0.5
done

killall lws-minimal-ws-server-threads || true
sleep 0.5
apps/lws-minimal-ws-server-threads
cd -
exit 0

#!/bin/sh

cd /home/root/Head_count

while [ 1 -eq 1 ]; do
	killall Head_count_cam || true
	./Head_count_cam
	sleep 3
done

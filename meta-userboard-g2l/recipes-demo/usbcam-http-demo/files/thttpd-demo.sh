#!/bin/sh -e

cd /home/root/usbcam-http-demo

PID_FILE=/tmp/thttpd-demo.pid
(cat ${PID_FILE} | xargs kill) || true
thttpd -d /var/demo -p 30000 -i ${PID_FILE}
while [ 1 -eq 1 ]; do
	if [ 0 -ne `v4l2-ctl --list-devices | grep usb | wc -l` ]; then
		ifconfig eth0:0 192.168.1.111
		killall sample_app_usbcam_http || true
		./sample_app_usbcam_http || true
	fi
	sleep 1
done

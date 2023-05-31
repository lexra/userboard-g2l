#!/bin/sh

PID_FILE=/run/thttpd-tvm.pid

cd /home/root/tvm
(while [ 1 -eq 1 ]; do ifconfig eth0 up; ifconfig eth0:0 192.168.1.111 netmask 255.255.255.0; sleep 180; done) &

(cat ${PID_FILE} | xargs kill) || true
thttpd -d /var/tvm -p 40000 -i ${PID_FILE}

export PRODUCT=V2L
while [ 1 -eq 1 ]; do
	sleep 1
	if [ 0 -ne `v4l2-ctl --list-devices | grep usb | wc -l` ]; then
		./tutorial_app

		killall sample_app_drpai_tvm_usbcam_http || true
		ifconfig eth0 up; ifconfig eth0:0 192.168.1.111 netmask 255.255.255.0
		./sample_app_drpai_tvm_usbcam_http
	fi
done

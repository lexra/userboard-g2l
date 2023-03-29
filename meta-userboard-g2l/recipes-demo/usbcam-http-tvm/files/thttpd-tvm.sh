#!/bin/sh -e

export PRODUCT=V2L
PID_FILE=/run/thttpd-tvm.pid

cd /home/root/tvm
(cat ${PID_FILE} | xargs kill) || true
thttpd -d /var/tvm -p 40000 -i ${PID_FILE}
while [ 1 -eq 1 ]; do
	sleep 1
	if [ 0 -ne `v4l2-ctl --list-devices | grep usb | wc -l` ]; then
		ifconfig eth0 up; ifconfig eth0:0 192.168.1.111 || true
		killall sample_app_drpai_tvm_usbcam_http || true
		./sample_app_drpai_tvm_usbcam_http || true
	fi
done

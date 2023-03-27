#!/bin/sh -e

PID_FILE=/run/thttpd-tvm.pid

cd /home/root/tvm
#ln -sf preprocess_tvm_v2l preprocess_tvm_v2ma

(cat ${PID_FILE} | xargs kill) || true
thttpd -d /var/tvm -p 40000 -i ${PID_FILE}

export PRODUCT=V2L
while [ 1 -eq 1 ]; do
	if [ 0 -ne `v4l2-ctl --list-devices | grep usb | wc -l` ]; then
		ifconfig eth0:0 192.168.1.111
		killall sample_app_drpai_tvm_usbcam_http || true
		./sample_app_drpai_tvm_usbcam_http
	fi
	sleep 1
done

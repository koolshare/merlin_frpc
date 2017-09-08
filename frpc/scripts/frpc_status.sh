#! /bin/sh

frpc_status=`ps | grep -w frpc | grep -cv grep`
frpc_pid=`ps | grep -w frpc | grep -v grep | awk '{print $1}' | xargs`
frpc_version=`/koolshare/bin/frpc -v`
if [ "$frpc_status" == "1" ];then
	echo frpc  $frpc_version  进程运行正常！（PID：$frpc_pid） > /tmp/.frpc.log
else
	echo frpc  $frpc_version 【警告】：进程未运行！ > /tmp/.frpc.log
fi
echo XU6J03M6 >> /tmp/.frpc.log
sleep 2
rm -rf /tmp/.frpc.log
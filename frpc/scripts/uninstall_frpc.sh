#!/bin/sh
eval `dbus export frpc_`
source /koolshare/scripts/base.sh
MODULE=frpc
/koolshare/scripts/config-frpc.sh stop
rm -f /koolshare/init.d/S98frpc.sh
rm -f /koolshare/bin/frpc
rm -f /koolshare/res/frpc-menu.js
rm -f /koolshare/res/icon-frpc.png
rm -f /koolshare/res/frpc_check.html
rm -f /koolshare/res/frpc_stcp_conf.html
rm -f /koolshare/res/frpc.css
rm -f /koolshare/scripts/config-frpc.sh
rm -f /koolshare/scripts/frpc_status.sh
rm -f /koolshare/webs/Module_frpc.asp
rm -f /koolshare/configs/frpc.ini
rm -f /tmp/.frpc.ini
rm -f /tmp/.frpc_stcp.ini
rm -fr /tmp/frpc*
if [ "${frpc_common_ddns}" == "1" ]; then
    nvram set ddns_enable_x=0
	nvram commit
fi
values=`dbus list frpc | cut -d "=" -f 1`

for value in $values
do
dbus remove $value 
done
dbus remove __event__onwanstart_frpc
dbus remove __event__onnatstart_frpc
cru d frpc_monitor
rm -f /koolshare/scripts/uninstall_frpc.sh

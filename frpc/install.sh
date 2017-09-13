#!/bin/sh

MODULE=frpc
VERSION="2.0.9"
cd /
rm -f /koolshare/init.d/S98frpc.sh
cp -f /tmp/$MODULE/bin/* /koolshare/bin/
cp -f /tmp/$MODULE/scripts/* /koolshare/scripts/
cp -f /tmp/$MODULE/res/* /koolshare/res/
cp -f /tmp/$MODULE/webs/* /koolshare/webs/
cp -f /tmp/$MODULE/init.d/* /koolshare/init.d/
rm -fr /tmp/frp* >/dev/null 2>&1
killall ${MODULE}
chmod +x /koolshare/bin/frpc
chmod +x /koolshare/scripts/config-frpc.sh
chmod +x /koolshare/scripts/frpc_status.sh
chmod +x /koolshare/init.d/S98frpc.sh
sleep 1
dbus set ${MODULE}_version="${VERSION}"
dbus set frpc_client_version=`/koolshare/bin/frpc --version`
dbus set frpc_common_cron_hour_min="hour"
dbus set frpc_common_cron_time="1"
ddns_set=`dbus get frpc_common_ddns`
if [ "$ddns_set" == "" ]; then
    dbus set frpc_common_ddns="2"
fi
dbus set softcenter_module_frpc_install=1
dbus set softcenter_module_frpc_name=${MODULE}
dbus set softcenter_module_frpc_title="Frpc内网穿透"
dbus set softcenter_module_frpc_description="内网穿透利器，谁用谁知道。"
dbus set softcenter_module_frpc_version="${VERSION}"
en=`dbus get ${MODULE}_enable`
if [ "$en" == "1" ]; then
    sh /koolshare/scripts/config-frpc.sh
fi

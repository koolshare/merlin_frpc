#!/bin/sh

MODULE=frpc
VERSION="2.1.14"
cd /tmp
rm -f /koolshare/init.d/S98frpc.sh
if [ ! -x /koolshare/bin/base64_encode ]; then
    cp -f /tmp/frpc/bin/base64_encode /koolshare/bin/base64_encode
    chmod +x /koolshare/bin/base64_encode
    [ ! -L /koolshare/bin/base64_decode ] && ln -sf /koolshare/bin/base64_encode /koolshare/bin/base64_decode
fi
cp -f /tmp/${MODULE}/bin/frpc /koolshare/bin/frpc
cp -f /tmp/${MODULE}/scripts/* /koolshare/scripts/
cp -f /tmp/${MODULE}/res/* /koolshare/res/
cp -f /tmp/${MODULE}/webs/* /koolshare/webs/
cp -f /tmp/${MODULE}/init.d/* /koolshare/init.d/
[ ! -d /koolshare/res/layer ] && ( mkdir -p /koolshare/res/layer/; cp -rf /tmp/frpc/res/layer/* /koolshare/res/layer/ )
rm -fr /tmp/frp* >/dev/null 2>&1
killall ${MODULE}
chmod +x /koolshare/bin/frpc
chmod +x /koolshare/scripts/config-frpc.sh
chmod +x /koolshare/scripts/frpc_status.sh
chmod +x /koolshare/scripts/uninstall_frpc.sh
chmod +x /koolshare/init.d/S98frpc.sh
sleep 1
dbus set frpc_client_version=`/koolshare/bin/frpc --version`
#if [ "`dbus get frpc_version`"x = "2.1.4"x  ]; then
#    dbus set frpc_customize_conf="1"
#fi
if [ "`dbus get frpc_common_ddns`"x = ""x ] && [ "`dbus get frpc_ddns`"x = ""x ]; then
    dbus set frpc_common_ddns="2"
elif [ "`dbus get frpc_common_ddns`"x = "1"x ] || [ "`dbus get frpc_ddns`"x = "1"x ]; then
    dbus set frpc_domain=`nvram get ddns_hostname_x`
    dbus set frpc_common_ddns="1"
    dbus remove frpc_ddns
elif [ "`dbus get frpc_ddns`"x = "2"x ]; then
    dbus set frpc_common_ddns="2"
    dbus remove frpc_ddns
fi
if [ "`dbus get frpc_cron_hour_min`"x != ""x ] && [ "`dbus get frpc_cron_time`"x != ""x ]; then
    dbus set frpc_common_cron_hour_min="`dbus get frpc_cron_hour_min`"
    dbus set frpc_common_cron_time="`dbus get frpc_cron_time`"
    dbus remove frpc_cron_hour_min
    dbus remove frpc_cron_time
elif [ "`dbus get frpc_cron_hour_min`"x != ""x ] && [ "`dbus get frpc_cron_time`"x != ""x ]; then
    dbus set frpc_common_cron_hour_min="hour"
    dbus set frpc_common_cron_time="1"
fi
dbus set softcenter_module_frpc_install=1
dbus set softcenter_module_frpc_name=${MODULE}
dbus set softcenter_module_frpc_title="Frpc内网穿透"
dbus set softcenter_module_frpc_description="内网穿透利器，谁用谁知道。"
dbus set softcenter_module_frpc_version="${VERSION}"
dbus set ${MODULE}_version="${VERSION}"
rm -fr /tmp/frp* >/dev/null 2>&1
en=`dbus get frpc_enable`
if [ "${en}"x = "1"x ]; then
    sh /koolshare/scripts/config-frpc.sh
fi

#!/bin/sh

MODULE=frpc
VERSION="2.1.4"
cd /
rm -f /koolshare/init.d/S98frpc.sh
if [[ ! -x /koolshare/bin/base64_encode ]]; then
    cp -f /tmp/frpc/bin/base64_encode /koolshare/bin/base64_encode
    chmod +x /koolshare/bin/base64_encode
    [ ! -L /koolshare/bin/base64_decode ] && ln -sf /koolshare/bin/base64_encode /koolshare/bin/base64_decode
fi
cp -f /tmp/$MODULE/bin/frpc /koolshare/bin/frpc
cp -f /tmp/$MODULE/scripts/* /koolshare/scripts/
cp -f /tmp/$MODULE/res/* /koolshare/res/
cp -f /tmp/$MODULE/webs/* /koolshare/webs/
cp -f /tmp/$MODULE/init.d/* /koolshare/init.d/
rm -fr /koolshare/res/frpc-menu.js /koolshare/res/frpc_stcp_conf.html >/dev/null 2>&1
killall ${MODULE}
chmod +x /koolshare/bin/frpc
chmod +x /koolshare/scripts/config-frpc.sh
chmod +x /koolshare/scripts/frpc_status.sh
chmod +x /koolshare/scripts/uninstall_frpc.sh
chmod +x /koolshare/init.d/S98frpc.sh
sleep 1
_config=`dbus get frpc_config`
if [ "${_config}"x = ""x ]; then
    echo "dbus set frpc_enable=`dbus get frpc_enable`" > /tmp/frp_old.sh
    echo "dbus set frpc_ddns=`dbus get frpc_common_ddns`" >> /tmp/frp_old.sh
    echo "dbus set frpc_cron_time=`dbus get frpc_common_cron_time`" >> /tmp/frp_old.sh
    echo "dbus set frpc_cron_hour_min=`dbus get frpc_common_cron_hour_min`" >> /tmp/frp_old.sh
    echo "dbus set frpc_domain=`nvram get ddns_hostname_x`" >> /tmp/frp_old.sh
    if [ -f /koolshare/configs/frpc.ini ]; then
        echo "dbus set frpc_config=`cat /koolshare/configs/frpc.ini | base64_encode`" >> /tmp/frp_old.sh
    fi
    dbus set frpc_cron_hour_min="hour"
    dbus set frpc_cron_time="1"
    values=`dbus list frpc | cut -d "=" -f 1`
    for value in $values
    do
    dbus remove $value 
    done
    /bin/sh /tmp/frp_old.sh
    rm -f /tmp/frp_old.sh
fi
dbus set ${MODULE}_version="${VERSION}"
dbus set frpc_client_version=`/koolshare/bin/frpc --version`
ddns_set=`dbus get frpc_ddns`
if [ "$ddns_set" == "" ]; then
    dbus set frpc_ddns="2"
fi
dbus set softcenter_module_frpc_install=1
dbus set softcenter_module_frpc_name=${MODULE}
dbus set softcenter_module_frpc_title="Frpc内网穿透"
dbus set softcenter_module_frpc_description="内网穿透利器，谁用谁知道。"
dbus set softcenter_module_frpc_version="${VERSION}"
cd /tmp/
rm -fr /tmp/frp* >/dev/null 2>&1
en=`dbus get ${MODULE}_enable`
if [ "$en"x = "1"x ]; then
    sh /koolshare/scripts/config-frpc.sh
fi

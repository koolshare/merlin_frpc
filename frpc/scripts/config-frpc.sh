#!/bin/sh

eval `dbus export frpc_`
source /koolshare/scripts/base.sh
NAME=frpc
BIN=/koolshare/bin/frpc
INI_FILE=/tmp/.frpc.ini
PID_FILE=/var/run/frpc.pid
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

fun_ntp_sync(){
    ntp_server=`nvram get ntp_server0`
    start_time="`date +%Y%m%d`"
    ntpclient -h ${ntp_server} -i3 -l -s > /dev/null 2>&1
    if [ "${start_time}"x = "`date +%Y%m%d`"x ]; then  
        ntpclient -h ntp1.aliyun.com -i3 -l -s > /dev/null 2>&1 
    fi
}
fun_start_stop(){
    dbus set frpc_client_version=`${BIN} --version`
    if [ "${frpc_enable}"x = "1"x ];then
        killall frpc || true
        _frpc_config=`dbus get frpc_config | base64_decode` || "未发现配置文件"
        cat > ${INI_FILE}<<-EOF
${_frpc_config}
EOF
        echo -n "starting ${NAME}..."
        export GOGC=40
        start-stop-daemon -S -q -b -m -p ${PID_FILE} -x ${BIN} -- -c ${INI_FILE}
        echo " done"
    else
        killall frpc || true
    fi
}
fun_nat_start(){
    if [ "${frpc_enable}"x = "1"x ];then
        echo_date 添加nat-start触发事件...
        dbus set __event__onnatstart_frpc="/koolshare/scripts/config-frpc.sh"
    else
        echo_date 删除nat-start触发...
        dbus remove __event__onnatstart_frpc
    fi
}
fun_crontab(){
    if [ "${frpc_enable}"x = "1"x ];then
        echo -n "setting ${NAME} crontab..."
        if [ "${frpc_cron_time}"x = "0"x ]; then
            cru d frpc_monitor
        else
            if [ "${frpc_cron_hour_min}"x = "min"x ]; then
                cru a frpc_monitor "*/"${frpc_cron_time}" * * * * /bin/sh /koolshare/scripts/config-frpc.sh"
            elif [ "${frpc_cron_hour_min}"x = "hour"x ]; then
                cru a frpc_monitor "0 */"${frpc_cron_time}" * * * /bin/sh /koolshare/scripts/config-frpc.sh"
            fi
        fi
        echo " done"
    else
        cru d frpc_monitor
    fi
}
fun_ddns_stop(){
    nvram set ddns_enable_x=0
    nvram commit
}
fun_ddns_start(){
    if [ "${frpc_enable}"x = "1"x ];then
        # ddns setting
        if [[ "${frpc_ddns}" == "1" ]] && [[ "${frpc_domain}" != "" ]]; then
            nvram set ddns_enable_x=1
            nvram set ddns_hostname_x=${frpc_domain}
            ddns_custom_updated 1
            nvram commit
        elif [[ "${frpc_ddns}" == "0" ]]; then
            fun_ddns_stop
        fi
    else
        fun_ddns_stop
    fi
}

case $ACTION in
start)
    fun_ntp_sync
    fun_start_stop
    fun_nat_start
    fun_crontab
    fun_ddns_start
    ;;
*)
    fun_ntp_sync
    fun_start_stop
    fun_nat_start
    fun_crontab
    fun_ddns_start
    ;;
esac

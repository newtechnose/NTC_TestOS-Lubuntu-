#!/bin/bash

# ==============================
# 設定
# ==============================

NICS=(enp1s0 enp2s0)

TARGETS_enp1s0="192.168.1.1 192.168.1.2 192.168.1.3"
TARGETS_enp2s0="172.16.1.2 172.16.1.3 172.16.1.4"
TARGETS_eth2=""
TARGETS_eth3=""
TARGETS_eth4=""
TARGETS_eth5=""
TARGETS_eth6=""
TARGETS_eth7=""
TARGETS_eth8=""
TARGETS_eth9=""

LOGFILE="/home/testos/log/ping_monitor.log"
TIMEOUT_LIMIT=60

get_speed() {
    speed=$(ethtool "$1" 2>/dev/null | awk -F': ' '/Speed/ {print $2}')
    [ -z "$speed" ] && echo "Unknown" || echo "$speed"
}

trap "echo -e '\nStopped by user at $(date)' >> $LOGFILE; exit 0" SIGINT

echo "===== Ping Monitor Start: $(date) =====" | tee -a $LOGFILE

declare -A LAST_OK
declare -A DOWN_FLAG

for nic in "${NICS[@]}"; do
    targets_var="TARGETS_${nic}"
    targets="${!targets_var}"
    for ip in $targets; do
        LAST_OK["$nic,$ip"]=$(date +%s)
        DOWN_FLAG["$nic,$ip"]=0
    done
done

while true
do
    current_time=$(date +%s)
    ERROR_FLAG=0

    for nic in "${NICS[@]}"; do
        targets_var="TARGETS_${nic}"
        targets="${!targets_var}"

        for ip in $targets; do

            if ping -I "$nic" -c 1 -W 1 "$ip" > /dev/null 2>&1
            then
                LAST_OK["$nic,$ip"]=$current_time
                echo "$(date) OK: $nic -> $ip"

            else
                last_time=${LAST_OK["$nic,$ip"]}
                diff=$((current_time - last_time))

                echo "$(date) DOWN: $nic -> $ip  (${diff}s / ${TIMEOUT_LIMIT}s)"

                if [ $diff -ge $TIMEOUT_LIMIT ]; then
                    SPEED=$(get_speed "$nic")
                    echo "$(date) ERROR: NIC=$nic ($SPEED) TARGET=$ip unreachable for ${TIMEOUT_LIMIT} seconds" | tee -a $LOGFILE
                    ERROR_FLAG=1
                fi
            fi

        done
    done

    if [ $ERROR_FLAG -eq 1 ]; then
        exit 1
    fi

    sleep 1
done

#!/bin/bash

# ダイアログを表示してIPを標準の既定値に設定するか確認
if zenity --question --text="BMCのIPアドレス、サブネットマスク、ゲートウェイを標準の既定値に設定しますか？"; then

    # 標準の既定値
    DEFAULT_BMC_IP="192.168.1.2"
    DEFAULT_SUBNET_MASK="255.255.255.0"
    DEFAULT_GATEWAY="0.0.0.0"

    # IPMI Toolを使用してBMCの設定を変更
    cd /home/testos/
    echo "Failoverをセットします。"
    sudo ./IPMICFG-Linux.x86_64 -raw 0x30 0x70 0x0c 1 0
    sleep 2
    echo "Failoverを完了しました。"
    sleep 1
    echo "DHCPをOFFにします。"
    sudo ./IPMICFG-Linux.x86_64 -dhcp off
    sleep 2
    echo "DHCPをOFFに設定しました。"
    sleep 1
    echo "BMC IPをセットします。"
    sudo ./IPMICFG-Linux.x86_64 -m $DEFAULT_BMC_IP
    sleep 2
    echo "BMC IPを$DEFAULT_BMC_IPにセットしました。"
    sleep 1
    echo "サブネットマスクをセットします。"
    sudo ./IPMICFG-Linux.x86_64 -k $DEFAULT_SUBNET_MASK
    sleep 2
    echo "サブネットマスクを$DEFAULT_SUBNET_MASKにセットしました。"
    sleep 1
    echo "ゲートウェイをセットします。"
    sudo ./IPMICFG-Linux.x86_64 -g $DEFAULT_GATEWAY
    sleep 2
    echo "ゲートウェイを$DEFAULT_GATEWAYにセットしました。"
    sleep 1

    # 完了メッセージの表示
    zenity --info --text="BMCのIPアドレスは\n$DEFAULT_BMC_IP\nサブネットマスクは\n$DEFAULT_SUBNET_MASK\nゲートウェイは\n$DEFAULT_GATEWAY\nに設定されました。"
else
    # キャンセル時のメッセージを表示
    zenity --info --text="設定をキャンセルしました。"
fi


# ダイアログを表示してパスワードを標準の既定値に設定するか確認
if zenity --question --text="IPMIのadminパスワードを「$PASSWORD」に変更しますか？"; then

    # 標準の既定値
    PASSWORD="ArcADMIN1"

    # IPMI Toolを使用してBMCの設定を変更
    cd /home/testos
    sudo ./IPMICFG-Linux.x86_64 -user setpwd 2 $PASSWORD

    # 完了メッセージの表示
    zenity --info --text="IPMIログインパスワードは、「$PASSWORD」に設定されました。"

else
    # キャンセル時のメッセージを表示
    zenity --info --text="設定をキャンセルしました。"
fi




#!/bin/bash

# ダイアログを表示してIPを標準の既定値に設定するか確認
if zenity --question --text="BMCのIPアドレス、サブネットマスク、ゲートウェイを標準の既定値に設定しますか？"; then

    # 標準の既定値
    DEFAULT_BMC_IP="192.168.1.2"
    DEFAULT_SUBNET_MASK="255.255.255.0"
    DEFAULT_GATEWAY="0.0.0.0"

    # IPMI Toolを使用してBMCの設定を変更
    sudo ipmitool lan set 1 ipsrc static
    sudo ipmitool lan set 1 ipaddr $DEFAULT_BMC_IP
    sudo ipmitool lan set 1 netmask $DEFAULT_SUBNET_MASK
    sudo ipmitool lan set 1 defgw ipaddr $DEFAULT_GATEWAY

    # 完了メッセージの表示
    zenity --info --text="BMCのIPアドレスは\n$DEFAULT_BMC_IP\nサブネットマスクは\n$DEFAULT_SUBNET_MASK\nゲートウェイは\n$DEFAULT_GATEWAY\nに設定されました。"
else
    # キャンセル時のメッセージを表示
    zenity --info --text="設定をキャンセルしました。"
fi


# ダイアログを表示してパスワードを標準の既定値に設定するか確認
if zenity --question --text="IPMIのadminパスワードを「ADMINntc1」に変更しますか？"; then

    # 標準の既定値
    PASSWORD="ADMINntc1"

    # IPMI Toolを使用してBMCの設定を変更
    sudo ipmitool user set password 2 $PASSWORD

    # 完了メッセージの表示
    zenity --info --text="IPMIログインパスワードは、「ADMINntc1」に設定されました。"

else
    # キャンセル時のメッセージを表示
    zenity --info --text="設定をキャンセルしました。"
fi




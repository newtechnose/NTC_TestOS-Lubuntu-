#!/bin/bash

# ステータスファイルのパス
STATUS_FILE="/home/testos/Status/status.txt"

# ステータスファイルの中身を読み取る
if [ -f "$STATUS_FILE" ]; then
    STATUS=$(cat "$STATUS_FILE")
else
    zenity --error --text="ステータスファイルが見つかりません。"
    exit 1
fi

# ステータスに基づいて処理を分岐
if [ -z "$STATUS" ]; then
    zenity --info --text="NTC Productよりタスクを実行してください。"
elif [ "$STATUS" -ge 1 ] && [ "$STATUS" -le 2 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-1U_Season1.sh
elif [ "$STATUS" -ge 3 ] && [ "$STATUS" -le 5 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-2U_Season1.sh
elif [ "$STATUS" -ge 6 ] && [ "$STATUS" -le 8 ]; then
    /home/testos/shell/Product_shell/Nrec4000.sh
elif [ "$STATUS" -ge 9 ] && [ "$STATUS" -le 11 ]; then
    /home/testos/shell/Product_shell/Nrec8000.sh
elif [ "$STATUS" -ge 12 ] && [ "$STATUS" -le 14 ]; then
    /home/testos/shell/Product_shell/cloudy.sh
elif [ "$STATUS" -ge 15 ] && [ "$STATUS" -le 17 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-1U_Season2.sh
elif [ "$STATUS" -ge 18 ] && [ "$STATUS" -le 20 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-2U_Season2.sh
elif [ "$STATUS" -ge 21 ] && [ "$STATUS" -le 23 ]; then
    /home/testos/shell/Product_shell/ai_server_AMD.sh
elif [ "$STATUS" -ge 24 ] && [ "$STATUS" -le 26 ]; then
    /home/testos/shell/Product_shell/Nrec6000.sh
elif [ "$STATUS" -ge 27 ] && [ "$STATUS" -le 29 ]; then
    /home/testos/shell/Product_shell/TXPMedical.sh
elif [ "$STATUS" -ge 30 ] && [ "$STATUS" -le 32 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-1U_AllFlash.sh
elif [ "$STATUS" -ge 33 ] && [ "$STATUS" -le 35 ]; then
    /home/testos/shell/Product_shell/SmartNAS1000-2U_AllFlash.sh
elif [ "$STATUS" -ge 36 ] && [ "$STATUS" -le 38 ]; then
    /home/testos/shell/Product_shell/TXPMedical-2U.sh
else
    zenity --error --text="無効なステータスです: $STATUS"
    exit 1
fi


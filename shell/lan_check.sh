#!/bin/bash

CHOICE=$(zenity --list \
    --title="LAN Check" \
    --text="実行するチェックを選んでください" \
    --radiolist \
    --column="選択" --column="項目" \
    TRUE "簡易LAN疎通チェック" \
    FALSE "各速度LAN疎通チェック" \
    --height=300 --width=400)

case "$CHOICE" in
    "簡易LAN疎通チェック")
        bash /home/testos/shell/lan_speed_test_easy.sh
        ;;
    "各速度LAN疎通チェック")
        bash /home/testos/shell/lan_speed_test.sh
        ;;
    *)
        zenity --warning --text="キャンセルされました。"
        ;;
esac

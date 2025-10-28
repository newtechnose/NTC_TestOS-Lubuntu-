#!/bin/bash

# 出荷日の設定
SHIP_DATE=$(zenity --calendar --date-format="%Y/%m/%d" --title="出荷日選択" --text="出荷日を入力してください。")

one_month_later=$(date -d "$SHIP_DATE +1 month" +%Y/%m/%d)

cd /opt/MegaRAID/storcli

# 指定されたコマンドを実行する
qterminal -e "bash -c 'sudo ./storcli64 /c0 set patrolread delay=720 && zenity --info --width 800 --title='Success' --text='Patrol Readの間隔設定が完了しました。\n次にPatrol Readの設定を行います。' && sudo ./storcli64 /c0 set patrolread mode=auto starttime=$one_month_later 12 && zenity --info --width 800 --title='Success' --text='設定が完了しました。\nターミナルで実行結果を確認してください。\nEnterキーを押して終了します。' ; read -p 'Please Enter''"






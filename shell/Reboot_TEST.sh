#!/bin/bash

# reboot_tool.conf ファイルのパス
conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"

# zenity を使用して [Count Cur] の値を入力させる
count_cur=$(zenity --entry --text="初期値を入力してください。" --title="[Count Cur]" --width=800)
# キャンセルが押された場合は終了
[ $? -ne 0 ] && exit 1

# zenity を使用して [Count Limit] の値を入力させる
count_limit=$(zenity --entry --text="リブート回数を入力してください。" --title="[Count Limit]" --width=800)
# キャンセルが押された場合は終了
[ $? -ne 0 ] && exit 1

# [Command1] と [Command2] の値
command1="shutdown -r +2"
command2="NONE"

# reboot_tool.conf ファイルに書き込み
echo "[Count Cur]" > "$conf_file"
echo "$count_cur" >> "$conf_file"
echo "[Count Limit]" >> "$conf_file"
echo "$count_limit" >> "$conf_file"
echo "[Command1]" >> "$conf_file"
echo "$command1" >> "$conf_file"
echo "[Command2]" >> "$conf_file"
echo "$command2" >> "$conf_file"

# 確認のために [Count Limit] 入力後にファイルの中身を表示
zenity --text-info --title="reboot_tool.conf の内容" --filename="$conf_file" --width=800 --height=400
# キャンセルが押された場合は終了
[ $? -ne 0 ] && exit 1

# 確認メッセージを表示し、"OK" ボタンが押された場合に /usr/sbin/reboot_tool を実行
zenity --question --text="Rebootテストを開始します。「はい」を押すと2分後に開始します。\n\n※この時点でreboot_tool.confが変更済み、キャンセルした場合でも再起動するとリブートテストが実行されます。" --title="Confirmation"
[ $? -eq 0 ] && qterminal -e "bash -c '/usr/sbin/reboot_tool'"

sudo systemctl enable run_reboot_status.service

/home/testos/shell/Run_Reboot_Status.sh

# 最後に Enter キーを待つ
read -p 'Press Enter to close.'


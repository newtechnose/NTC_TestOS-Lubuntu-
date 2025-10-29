#!/bin/bash

# ドライブの選択をZenityで取得
selected_drive=$(zenity --entry --text "対応ドライブを入力してください。（例：sda, sdb など）" --entry-text "")

# ドライブが選択されなかった場合は終了
if [ -z "$selected_drive" ]; then
  zenity --error --text "ドライブが選択されませんでした。スクリプトを終了します。"
  exit 1
fi

# 処理選択メニューを表示
action=$(zenity --list --radiolist \
  --title="処理選択" \
  --text="実行する操作を選択してください。" \
  --column="選択" --column="操作内容" \
  TRUE "①Meister-SのStatusを見る" \
  FALSE "②Meister-Sのバージョンを見る" \
  FALSE "③パトロールリードを実行する" \
  FALSE "④Meister-Sのログを取得する" \
  --height=400 --width=400)

# 選択に応じた処理
if [ "$action" == "①Meister-SのStatusを見る" ]; then
  # Meister-SのStatusを見る
  qterminal -e "bash -c '
    DRIVE=${selected_drive}
    sudo /usr/local/MirrorMonitor/nu_disp -t /dev/\${DRIVE} --show-info-all
    read -p \"Press Enter to exit...\"
  '"

elif [ "$action" == "②Meister-Sのバージョンを見る" ]; then
  # Meister-Sのバージョンを見る
  qterminal -e "bash -c '
    DRIVE=${selected_drive}
    sudo /usr/local/MirrorMonitor/nu_disp -t /dev/\${DRIVE} --show-info-all | grep -i -E \"FPGA Revision|RAID FirmWare\"
    read -p \"Press Enter to exit...\"
  '"

elif [ "$action" == "③パトロールリードを実行する" ]; then
  # パトロールリードを実行
  qterminal -e "bash -c '
    DRIVE=${selected_drive}
    echo \"パトロールリードを開始します...\"
    sudo /usr/local/MirrorMonitor/nu_pr -t /dev/\${DRIVE} start
    sleep 10

    echo \"パトロールリードの進捗を確認中です...\"
    while true; do
        OUTPUT=\$(sudo /usr/local/MirrorMonitor/nu_disp -t /dev/\${DRIVE} --show-info-all | grep -i PATROL)
        clear
        echo \"\${OUTPUT}\"

        if echo \"\${OUTPUT}\" | grep -q \"RAID Patrol Read Status: PATROL SUCCESS\"; then
            echo \"パトロールリードが正常に完了しました。\"
            break
        fi

        echo \"パトロールリード進行中...次の確認まで10分待機します。\"
        sleep 600
    done

    echo \"Meister-Sのパトロールリードが完了しました。\"
    read -p \"Press Enter to exit...\"
  '"

  zenity --info --text "Meister-Sのパトロールリードが完了しました。" --title "完了通知"

elif [ "$action" == "④Meister-Sのログを取得する" ]; then
  # 保存するファイル名をZenityで取得
  log_filename=$(zenity --entry --text "ログを保存するファイル名を入力してください。（例：meister_log.bin）" --entry-text "meister_log.bin")

  # ファイル名が入力されなかった場合は終了
  if [ -z "$log_filename" ]; then
    zenity --error --text "ファイル名が入力されませんでした。スクリプトを終了します。"
    exit 1
  fi

  # ログ取得処理を実行
  qterminal -e "bash -c '
    DRIVE=${selected_drive}
    LOGFILE=${log_filename}

    echo \"Meister-Sのログを取得中...\"
    sudo /usr/local/MirrorMonitor/nu_getlog -t /dev/\${DRIVE} -f /home/testos/Meister-S_Log/\${LOGFILE}
    echo \"Meister-Sのログ取得が完了しました。\"
    sudo chmod 777 /home/testos/Meister-S_Log/\${LOGFILE}
    read -p \"Press Enter to exit...\"
  '"

  # ログ取得完了の通知をZenityで表示
  zenity --info --text "Meister-Sのログを取得しました。\n保存先: /home/testos/Meister-S_Log/$log_filename" --title "ログ取得完了"

else
  # 選択されなかった場合
  zenity --error --text "操作が選択されませんでした。スクリプトを終了します。"
  exit 1
fi

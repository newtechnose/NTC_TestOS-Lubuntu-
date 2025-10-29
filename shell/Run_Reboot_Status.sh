#!/bin/bash

sleep 2

# reboot_tool.conf のパス
CONFIG_FILE="/opt/NTC/reboot_tool/reboot_tool.conf"

# Count Cur と Count Limit を取得する関数
get_counts() {
    count_cur=$(grep -A 1 "\[Count Cur\]" "$CONFIG_FILE" | tail -n 1 | tr -d ' ')
    count_limit=$(grep -A 1 "\[Count Limit\]" "$CONFIG_FILE" | tail -n 1 | tr -d ' ')
}

# Count Cur を更新する関数
update_count_cur() {
    sed -i "/\[Count Cur\]/!b;n;c$count_cur" "$CONFIG_FILE"
}

# Count Cur が Count Limit を超えるまでループ
while true; do
    get_counts

    if [[ "$count_cur" -le "$count_limit" ]]; then
        echo "Pythonスクリプトを実行します。"
        python3 /home/testos/shell/reboot_text.py &  # Pythonスクリプトをバックグラウンドで実行
        wait $!  # Pythonスクリプトの終了を待機
    elif [[ "$count_cur" -eq "$((count_limit + 1))" ]]; then
        echo "[Count Cur] が [Count Limit] を超えました。終了スクリプトを実行します。"
        python3 /home/testos/shell/reboot_finish.py &  # reboot_finish.py を実行
        wait $!  # Pythonスクリプトの終了を待機
        count_cur=$((count_cur + 1))  # Count Cur を+1
        update_count_cur  # 設定ファイルを更新
        systemctl --user disable run_reboot_status.service
    elif [[ "$count_cur" -ge "$((count_limit + 2))" ]]; then
        echo "[Count Cur] が [Count Limit] を2以上超えています。スクリプトの実行を停止します。"
        break  # ループを抜ける
    fi

    # 1秒間の待機（必要に応じて変更）
    sleep 1
done


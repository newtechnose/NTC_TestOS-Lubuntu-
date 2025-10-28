#!/bin/bash

sleep 2

# reboot_tool.conf のパス
CONFIG_FILE="/opt/NTC/reboot_tool/reboot_tool.conf"

# Count Cur と Count Limit を取得する関数
get_counts() {
    count_cur=$(grep -A 1 "\[Count Cur\]" "$CONFIG_FILE" | tail -n 1 | tr -d ' ')
    count_limit=$(grep -A 1 "\[Count Limit\]" "$CONFIG_FILE" | tail -n 1 | tr -d ' ')
}

# Count Cur が Count Limit を超えるまでループ
while true; do
    get_counts

    if [[ "$count_cur" -le "$count_limit" ]]; then
        echo "Pythonスクリプトを実行します。"
        python3 /home/testos/shell/reboot_text.py &  # Pythonスクリプトをバックグラウンドで実行
        wait $!  # Pythonスクリプトの終了を待機
    else
        echo "[Count Cur] が [Count Limit] を超えました。スクリプトの実行を停止します。"
        break  # ループを抜ける
    fi

    # 1秒間の待機（必要に応じて変更）
    sleep 1
done


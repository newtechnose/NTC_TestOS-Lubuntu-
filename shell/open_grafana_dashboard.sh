#!/bin/bash

# Grafana ダッシュボードのURL設定
GPU_DASHBOARD="http://localhost:3000/d/Oxed_c6Wz/nvidia-dcgm-exporter-dashboard?orgId=1&from=now-1h&to=now&timezone=browser&var-instance=localhost:9400&var-gpu=$__all&refresh=5s"
CPU_MEM_DASHBOARD="http://localhost:3000/d/rYdddlPWk/node-exporter-full?orgId=1&from=now-1h&to=now&timezone=browser&var-ds_prometheus=cf2itk8xpfgu8f&var-job=node-exporter&var-nodename=TestOS&var-node=localhost:9100&refresh=1m"

# Zenity で複数選択ダイアログ
CHOICES=$(zenity --list \
    --title="Grafana Dashboard Selection" \
    --text="開きたいダッシュボードを選択してください（複数選択可）" \
    --checklist \
    --column="選択" --column="ダッシュボード" \
    TRUE "GPU使用状況監視" \
    TRUE "CPU/メモリ使用状況監視" \
    --width=400 --height=400)

# 選択なしの場合は終了
if [ -z "$CHOICES" ]; then
    exit 0
fi

# Zenity は複数選択時に '|' で区切って返す
IFS="|" read -r -a CHOICE_ARRAY <<< "$CHOICES"

# 選択された項目に応じてブラウザで開く
for CHOICE in "${CHOICE_ARRAY[@]}"; do
    case $CHOICE in
        "GPU使用状況監視")
            xdg-open "$GPU_DASHBOARD" &
            ;;
        "CPU/メモリ使用状況監視")
            xdg-open "$CPU_MEM_DASHBOARD" &
            ;;
    esac
done

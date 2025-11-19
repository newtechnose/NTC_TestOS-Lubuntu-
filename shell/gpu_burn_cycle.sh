#!/bin/bash
set -e

# ================================================
# GPU負荷テストスクリプト（Zenity GUI + キャンセル即停止 + 固定Docker名）
# 休憩時間は秒単位で入力
# ================================================

LOG_DIR="/home/testos/gpu-burn/gpu_logs"
mkdir -p "$LOG_DIR"

# ==============================
# 終了処理関数
# ==============================
cleanup() {
    echo "Stopping GPU-Burn and nvidia-smi..."
    [[ -n "$NVSMI_PID" ]] && kill -TERM "$NVSMI_PID" 2>/dev/null || true
    [[ -n "$CONTAINER_ID" ]] && docker kill "$CONTAINER_ID" 2>/dev/null || true
    exit 1
}

trap cleanup INT TERM

# ==============================
# Zenityでユーザー入力
# ==============================

zenity --info --width 600 --title="GPU負荷テスト開始" \
  --text="GPU負荷試験ツール gpu_burn を起動します。\nウィンドウのOKを押して設定を入力してください"

# ログ削除確認
zenity --question --title="確認" --text="最初にログを削除して開始しますか？"
[ $? -eq 0 ] && rm -rf "$LOG_DIR" && mkdir -p "$LOG_DIR" || exit 0

# サイクル回数
NUM_CYCLES=$(zenity --entry --title="サイクル回数" --text="サイクルを入力してください（例：5）")
[ -z "$NUM_CYCLES" ] && cleanup

# GPU-burn 実行時間
GPU_BURN_TIME=$(zenity --entry --title="GPU-burn実行時間" --text="GPU-burnの実行時間(秒)")
[ -z "$GPU_BURN_TIME" ] && cleanup

# 休憩時間（秒で入力）
BREAK_TIME=$(zenity --entry --title="休憩時間" --text="休憩時間を秒単位で入力してください（例: 50）")
[ -z "$BREAK_TIME" ] && cleanup
BREAK_SECONDS="$BREAK_TIME"

# nvidia-smi 取得間隔
NVSMI_TIME=$(zenity --entry --title="nvidia-smi間隔" --text="nvidia-smi取得間隔(秒)")
[ -z "$NVSMI_TIME" ] && cleanup

# =======================================
# サイクル開始
# =======================================
(
for ((i=1;i<=NUM_CYCLES;i++)); do
    echo $(( (i-1)*100/NUM_CYCLES ))
    echo "# Cycle $i 開始..."

    mkdir -p "$LOG_DIR/cycle_$i"

    # nvidia-smi バックグラウンド
    nvidia-smi -l "$NVSMI_TIME" > "$LOG_DIR/cycle_$i/nvidia-smi_log.txt" &
    NVSMI_PID=$!

    # Docker 実行（固定Name）
    CONTAINER_NAME="gpu_burn"
    # もし既存コンテナがあれば強制停止
    docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME\$" && docker kill "$CONTAINER_NAME" >/dev/null 2>&1
    CONTAINER_ID=$(docker run -d --rm --gpus all --name "$CONTAINER_NAME" --init gpu_burn "$GPU_BURN_TIME")
    echo "$CONTAINER_ID" > "$LOG_DIR/cycle_$i/container_id.txt"

    # GPU-Burn 終了まで秒ごとに待機して進捗更新
    for ((s=1;s<=GPU_BURN_TIME;s++)); do
        sleep 1
        PROGRESS=$(( (i-1)*100/NUM_CYCLES + s*100/(GPU_BURN_TIME*NUM_CYCLES) ))
        [ $PROGRESS -gt 100 ] && PROGRESS=100
        echo "$PROGRESS"
        echo "# Cycle $i 実行中 ($s/$GPU_BURN_TIME 秒)"
    done

    # コンテナ終了待ち
    docker wait "$CONTAINER_ID" >/dev/null

    # nvidia-smi 停止
    [[ -n "$NVSMI_PID" ]] && kill -TERM "$NVSMI_PID"

    echo "# Cycle $i 完了"

    # 休憩時間を進捗付きで表示
    if [ $i -lt $NUM_CYCLES ]; then
        (
        SECONDS_WAIT=0
        while [ $SECONDS_WAIT -lt $BREAK_SECONDS ]; do
            sleep 1
            SECONDS_WAIT=$((SECONDS_WAIT+1))
            PERCENT=$((SECONDS_WAIT*100/BREAK_SECONDS))
            echo "$PERCENT"
            echo "# Cycle $i 休憩中 ($SECONDS_WAIT/$BREAK_SECONDS 秒)"
        done
        ) | zenity --progress --title="休憩中" --text="Cycle $i 休憩中..." --percentage=0 --auto-close --cancel-label="終了"

        # キャンセル判定
        [ $? -ne 0 ] && cleanup
    fi

done
) | zenity --progress --title="GPU-burn 実行中" --text="サイクルを実行中..." \
    --percentage=0 --auto-close --cancel-label="終了"

# Zenityで「終了」ボタン押された場合
[ $? -ne 0 ] && cleanup

# 完了メッセージ
zenity --info --width 600 --title="完了" \
  --text="GPU負荷テストが終了しました。\nログは $LOG_DIR に保存されています。"

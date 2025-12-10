#!/bin/bash
set -e

# ================================================
# GPU-Burn 単発実行スクリプト（ログ保存完全版）
# ================================================

LOG_DIR="/home/testos/gpu-burn/gpu_logs"
mkdir -p "$LOG_DIR"

# ==============================
# 終了処理関数
# ==============================
cleanup() {
    echo "Stopping GPU-Burn and nvidia-smi and log capture..."

    [[ -n "$LOG_PID" ]] && kill -TERM "$LOG_PID" 2>/dev/null || true
    [[ -n "$NVSMI_PID" ]] && kill -TERM "$NVSMI_PID" 2>/dev/null || true

    [[ -n "$CONTAINER_ID" ]] && docker kill "$CONTAINER_ID" 2>/dev/null || true

    exit 1
}

trap cleanup INT TERM

# ==============================
# Zenityでユーザー入力
# ==============================

zenity --info --width=600 --title="GPU負荷テスト開始" \
  --text="GPU負荷試験ツール gpu_burn を起動します。\nOK を押して設定を入力してください。"

# ログ削除確認
zenity --question --title="確認" --text="最初にログを削除して開始しますか？"
[ $? -eq 0 ] && rm -rf "$LOG_DIR" && mkdir -p "$LOG_DIR" || exit 0

# GPU-burn 実行時間
GPU_BURN_TIME=$(zenity --entry --title="GPU-burn実行時間" --text="GPU-burnの実行時間(秒)")
[ -z "$GPU_BURN_TIME" ] && cleanup

# nvidia-smi 取得間隔
NVSMI_TIME=$(zenity --entry --title="nvidia-smi間隔" --text="nvidia-smi取得間隔(秒)")
[ -z "$NVSMI_TIME" ] && cleanup

# =======================================
# GPU-Burn 実行
# =======================================
(
# nvidia-smi バックグラウンドログ
nvidia-smi -l "$NVSMI_TIME" > "$LOG_DIR/nvidia-smi_log.txt" &
NVSMI_PID=$!

# Docker コンテナ名固定
CONTAINER_NAME="gpu_burn"

# 既存コンテナ停止
docker ps --format '{{.Names}}' | grep -q "^$CONTAINER_NAME\$" && docker kill "$CONTAINER_NAME" >/dev/null 2>&1

# GPU-Burn コンテナ起動
CONTAINER_ID=$(docker run -d --rm --gpus all --name "$CONTAINER_NAME" --init gpu_burn "$GPU_BURN_TIME")
echo "$CONTAINER_ID" > "$LOG_DIR/container_id.txt"

# ★ GPU-Burn の標準出力を保存 ★
docker logs -f "$CONTAINER_ID" > "$LOG_DIR/gpu-burn_output.txt" 2>&1 &
LOG_PID=$!

# プログレス更新ループ
for ((s=1;s<=GPU_BURN_TIME;s++)); do
    sleep 1
    PROGRESS=$(( s*100/GPU_BURN_TIME ))
    [ $PROGRESS -gt 100 ] && PROGRESS=100
    echo "$PROGRESS"
    echo "# GPU-Burn 実行中 ($s / $GPU_BURN_TIME 秒)"
done

# コンテナ終了待ち
docker wait "$CONTAINER_ID" >/dev/null

# nvidia-smi 終了
[[ -n "$NVSMI_PID" ]] && kill -TERM "$NVSMI_PID"

# GPU-Burn ログ取得停止
[[ -n "$LOG_PID" ]] && kill -TERM "$LOG_PID"

) | zenity --progress --title="GPU-burn 実行中" --text="GPU-Burn 実行中..." \
    --percentage=0 --auto-close --cancel-label="終了"

# Zenity「終了」ボタン
[ $? -ne 0 ] && cleanup

# 完了メッセージ
zenity --info --width 600 --title="完了" \
  --text="GPU負荷テストが終了しました。\nログは $LOG_DIR に保存されています。"

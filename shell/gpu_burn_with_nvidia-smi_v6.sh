#!/bin/bash
set -e

# 終了処理関数
cleanup() {
    echo "Received Ctrl + C. Cleaning up..."
    
    # nvidia-smiを終了
    if [ -n "$NVSMI_PID" ]; then
        echo "Killing nvidia-smi (PID: $NVSMI_PID)..."
        kill -9 "$NVSMI_PID"
    fi
    
    # GPU-burnを終了
    if [ -n "$GPU_BURN_PID" ]; then
        echo "Killing GPU-burn (PID: $GPU_BURN_PID)..."
        kill -9 "$GPU_BURN_PID"
    fi
    
    exit 1
}

# 最初にログを削除するかどうか尋ねる
zenity --question --title="Confirmation" --text="最初にログを削除しプログラムを実行します。\n※いいえにするとプログラムを終了します。"
response=$?

if [ $response -eq 0 ]; then
    # ユーザーが「はい」を選択した場合はログディレクトリを削除
    rm -rf "/home/testos/gpu-burn/gpu_logs"
fi

# サイクルの回数を入力
NUM_CYCLES=$(zenity --entry --title="Input" --text="サイクルを入力してください（例：5）")
if [ -z "$NUM_CYCLES" ]; then
    cleanup
fi

# GPU-burnの実行時間を入力
GPU_BURN_TIME=$(zenity --entry --title="Input" --text="GPU-burnの実行時間を入力してください (in seconds)")
if [ -z "$GPU_BURN_TIME" ]; then
    cleanup
fi

# 休憩時間を入力
BREAK_TIME=$(zenity --entry --title="Input" --text="休憩時間を入力してください (例：50s、1h...)")
if [ -z "$BREAK_TIME" ]; then
    cleanup
fi

# nvidia-smiの取得時間を入力
NVSMI_TIME=$(zenity --entry --title="Input" --text="nvidia-smiを何秒ごとに取得するか入力してください (in seconds)")
if [ -z "$NVSMI_TIME" ]; then
    cleanup
fi

# 終了処理を登録
trap cleanup INT

for ((i=1; i<=NUM_CYCLES; i++))
do
    # gpu_logsディレクトリを再作成
    mkdir -p "/home/testos/gpu-burn/gpu_logs/cycle_$i"

    echo "Starting cycle $i..."

    # GPU-burnを実行
    cd /home/testos/gpu-burn
    /home/testos/gpu-burn/gpu_burn "$GPU_BURN_TIME" > "/home/testos/gpu-burn/gpu_logs/cycle_$i/gpu_burn_output.txt" 2>&1 &
    GPU_BURN_PID=$!
    echo "GPU-burn PID: $GPU_BURN_PID"

    # nvidia-smiの情報を取得してログに保存
    nvidia-smi -l "$NVSMI_TIME" > "/home/testos/gpu-burn/gpu_logs/cycle_$i/nvidia-smi_log.txt" &
    NVSMI_PID=$!
    echo "nvidia-smi PID: $NVSMI_PID"

    # GPU-burnの実行が終了するまで待機
    wait "$GPU_BURN_PID"

    echo "Cycle $i complete."

    # nvidia-smiを終了
    if [ -n "$NVSMI_PID" ]; then
        echo "Killing nvidia-smi (PID: $NVSMI_PID)..."
        kill -9 "$NVSMI_PID"
    fi

    # 休憩時間 (最後のサイクルでなければ)
    if [ $i -lt "$NUM_CYCLES" ]; then
        sleep "$BREAK_TIME"
    fi
done

# 正常終了時の終了処理
cleanup


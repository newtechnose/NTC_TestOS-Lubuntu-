#!/bin/bash
set -euo pipefail

###############################################
# Burn-cycle.sh（cycle別ログ & 判定 完成版）
###############################################

LOG_GPU_DIR="/home/testos/gpu-burn/gpu_logs"
LOG_CPU_DIR="/home/testos/V4/burnintest/logs"

mkdir -p "$LOG_GPU_DIR" "$LOG_CPU_DIR"

###############################################
# 初期確認
###############################################
zenity --question --title="確認" --text="最初にログを削除して開始しますか？"
[ $? -eq 0 ] || exit 0
rm -rf "$LOG_GPU_DIR" "$LOG_CPU_DIR"
mkdir -p "$LOG_GPU_DIR" "$LOG_CPU_DIR"

NUM_CYCLES=$(zenity --entry --title="サイクル回数" --text="サイクル数を入力")
GPU_BURN_TIME=$(zenity --entry --title="GPU-burn実行時間" --text="GPU-burn 実行時間(秒)")
BREAK_SECONDS=$(zenity --entry --title="休憩時間" --text="休憩時間(秒)")
NVSMI_TIME=$(zenity --entry --title="nvidia-smi間隔" --text="nvidia-smi 取得間隔(秒)")

for v in NUM_CYCLES GPU_BURN_TIME BREAK_SECONDS NVSMI_TIME; do
    [[ -z "${!v}" ]] && zenity --error --text="入力が不足しています" && exit 1
done

###############################################
# cleanup
###############################################
cleanup() {
    echo "=== cleanup ==="

    pkill -f bit_cmd_line_x64 2>/dev/null || true
    docker kill gpu_burn 2>/dev/null || true
    docker rm -f gpu_burn 2>/dev/null || true
    pkill -f "nvidia-smi -l" 2>/dev/null || true

    exit 1
}
trap cleanup INT TERM

###############################################
# Cycle ループ
###############################################
for ((i=1;i<=NUM_CYCLES;i++)); do
    echo "=== Cycle $i start ==="

    CYCLE_GPU_LOG_DIR="${LOG_GPU_DIR}/cycle_${i}"
    CYCLE_CPU_LOG_DIR="${LOG_CPU_DIR}/cycle_${i}"
    mkdir -p "$CYCLE_GPU_LOG_DIR" "$CYCLE_CPU_LOG_DIR"

    ###########################################
    # nvidia-smi
    ###########################################
    nvidia-smi -l "$NVSMI_TIME" \
        > "${CYCLE_GPU_LOG_DIR}/nvidia-smi.log" 2>&1 &
    NVSMI_PID=$!

    ###########################################
    # GPU-burn
    ###########################################
    docker rm -f gpu_burn 2>/dev/null || true
    CONTAINER_ID=$(docker run -d --rm --gpus all --name gpu_burn --init gpu_burn "$GPU_BURN_TIME")
    echo "$CONTAINER_ID" > "${CYCLE_GPU_LOG_DIR}/container_id.txt"

    docker logs -f gpu_burn \
        > "${CYCLE_GPU_LOG_DIR}/gpu-burn.log" 2>&1 &
    GPU_LOG_PID=$!

    ###########################################
    # BurnInTest
    ###########################################
    rm -f /home/testos/V4/burnintest/logs/BiTLog*.log

    cd /home/testos/V4/burnintest/64bit
    gnome-terminal -- bash -c \
        "sudo ./bit_cmd_line_x64 -C /home/testos/BurnInTest_cfg/5min.cfg" &
    BIT_PID=$!
    echo "$BIT_PID" > "${CYCLE_CPU_LOG_DIR}/burnintest_pid.txt"

    ###########################################
    # GPU-burn 進捗
    ###########################################
    (
        for ((t=1;t<=GPU_BURN_TIME;t++)); do
            sleep 1
            echo $((t*100/GPU_BURN_TIME))
            echo "# Cycle $i 実行中 ($t/$GPU_BURN_TIME 秒)"
        done
    ) | zenity --progress \
        --title="Cycle $i 実行中" \
        --cancel-label="停止" \
        --auto-close

    ###########################################
    # 終了処理
    ###########################################
    docker wait "$CONTAINER_ID" >/dev/null 2>&1 || true

    pkill -f bit_cmd_line_x64 2>/dev/null || true
    kill "$NVSMI_PID" "$GPU_LOG_PID" 2>/dev/null || true
    pkill -f "nvidia-smi -l" 2>/dev/null || true

    mv /home/testos/V4/burnintest/logs/BiTLog*.log \
       "$CYCLE_CPU_LOG_DIR/" 2>/dev/null || true

    ###########################################
    # 休憩
    ###########################################
    if (( i < NUM_CYCLES )); then
        (
            for ((r=1;r<=BREAK_SECONDS;r++)); do
                sleep 1
                echo $((r*100/BREAK_SECONDS))
                echo "# 休憩中 ($r/$BREAK_SECONDS 秒)"
            done
        ) | zenity --progress \
            --title="休憩中" \
            --cancel-label="停止" \
            --auto-close
    fi

done

###############################################
# BurnInTest 判定（cycle別）
###############################################
bit_result="合格"
for d in "${LOG_CPU_DIR}"/cycle_*; do
    log=$(ls "$d"/BiTLog*.log 2>/dev/null | head -n 1)
    [[ -z "$log" ]] && bit_result="不合格" && break

    grep -q "Errors:[[:space:]]*[1-9]" "$log" && bit_result="不合格" && break

    last=$(grep "TEST RUN" "$log" | tail -n 1)
    [[ "$last" != *"PASSED"* ]] && bit_result="不合格" && break
done

###############################################
# GPU-burn 判定（cycle別）
###############################################
gpu_result="合格"
for d in "${LOG_GPU_DIR}"/cycle_*; do
    grep -q "NG" "$d/gpu-burn.log" && gpu_result="不合格" && break
done

###############################################
# 総合判定
###############################################
if [[ "$bit_result" == "合格" && "$gpu_result" == "合格" ]]; then
    zenity --info --title="最終結果" \
        --text="<span font_desc='Sans 40' background='#00FF00'><b>PASSED</b></span>" \
        --no-wrap
else
    zenity --error --title="最終結果" \
        --text="<span font_desc='Sans 40' background='#FF0000'><b>FAILED</b></span>" \
        --no-wrap
fi

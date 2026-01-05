#!/bin/bash
set -euo pipefail

###############################################
# Burn-cycle.sh — 日時指定・cycle別ログ・判定 完全版
###############################################

###############################################
# ログ・パス定義
###############################################
LOG_GPU_DIR="/home/testos/gpu-burn/gpu_logs"
LOG_CPU_DIR="/home/testos/V4/burnintest/logs"
BIT_CFG_DIR="/home/testos/BurnInTest_cfg"

mkdir -p "$LOG_GPU_DIR" "$LOG_CPU_DIR"

###############################################
# 開始日・開始時刻選択
###############################################
DATE_SELECTED=$(zenity --calendar \
    --title="開始日を選択してください" \
    --text="テストを開始する日付を指定してください" \
    --date-format="%Y-%m-%d" \
    --width=400)

[[ -z "${DATE_SELECTED:-}" ]] && zenity --error --text="日付が選択されませんでした。" && exit 1

TIME_SELECTED=$(zenity --entry \
    --title="開始時刻の指定" \
    --text="開始する時刻を入力してください（例：14:30）" \
    --width=300)

[[ -z "${TIME_SELECTED:-}" ]] && zenity --error --text="時刻が入力されませんでした。" && exit 1

if [[ ! "${TIME_SELECTED}" =~ ^([01]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
    zenity --error --text="時刻は HH:MM 形式で入力してください。"
    exit 1
fi

TARGET_SEC=$(date -d "${DATE_SELECTED} ${TIME_SELECTED}" +%s)
NOW_SEC=$(date +%s)

if (( TARGET_SEC <= NOW_SEC )); then
    TARGET_SEC=$(date -d "tomorrow ${TIME_SELECTED}" +%s)
fi

WAIT_SEC=$((TARGET_SEC - NOW_SEC))

###############################################
# 開始待機バー（キャンセル検知付き）
###############################################
if (( WAIT_SEC > 0 )); then
    (
        for ((s=0; s<=WAIT_SEC; s++)); do
            sleep 1
            echo $(( s * 100 / WAIT_SEC ))
            echo "# テスト開始まであと $((WAIT_SEC - s)) 秒"
        done
    ) | zenity --progress \
        --title="開始待機中" \
        --percentage=0 \
        --auto-close \
        --cancel-label="中止"

    ZEN_EXIT=${PIPESTATUS[1]}
    [[ "$ZEN_EXIT" -ne 0 ]] && echo "開始待機キャンセル" && exit 1
fi

###############################################
# 入力
###############################################
zenity --question --title="確認" --text="ログを削除してテストを開始しますか？"
[ $? -eq 0 ] || exit 0
rm -rf "$LOG_GPU_DIR" "$LOG_CPU_DIR"
mkdir -p "$LOG_GPU_DIR" "$LOG_CPU_DIR"

NUM_CYCLES=$(zenity --entry --title="サイクル回数" --text="サイクル数を入力")
BREAK_SECONDS=$(zenity --entry --title="休憩時間" --text="休憩時間(秒)")
NVSMI_TIME=$(zenity --entry --title="nvidia-smi間隔" --text="nvidia-smi 取得間隔(秒)")

GPU_TIME_LABEL=$(zenity --list \
    --title="GPU 実行時間選択" \
    --column="選択" \
    5min 60min 120min 180min 1440min)

for v in NUM_CYCLES BREAK_SECONDS NVSMI_TIME GPU_TIME_LABEL; do
    [[ -z "${!v:-}" ]] && zenity --error --text="入力が不足しています" && exit 1
done

###############################################
# GPU時間 → 秒 / cfg
###############################################
case "$GPU_TIME_LABEL" in
    5min)    GPU_BURN_TIME=300 ;;
    60min)   GPU_BURN_TIME=3600 ;;
    120min)  GPU_BURN_TIME=7200 ;;
    180min)  GPU_BURN_TIME=10800 ;;
    1440min) GPU_BURN_TIME=86400 ;;
    *) zenity --error --text="無効な時間選択" && exit 1 ;;
esac

BIT_CFG="${BIT_CFG_DIR}/${GPU_TIME_LABEL}.cfg"
[[ ! -f "$BIT_CFG" ]] && zenity --error --text="cfg が存在しません\n$BIT_CFG" && exit 1

###############################################
# cleanup / trap
###############################################
cleanup() {
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
    CYCLE_GPU_LOG_DIR="${LOG_GPU_DIR}/cycle_${i}"
    CYCLE_CPU_LOG_DIR="${LOG_CPU_DIR}/cycle_${i}"
    mkdir -p "$CYCLE_GPU_LOG_DIR" "$CYCLE_CPU_LOG_DIR"

    nvidia-smi -l "$NVSMI_TIME" > "$CYCLE_GPU_LOG_DIR/nvidia-smi.log" 2>&1 &
    NVSMI_PID=$!

    docker rm -f gpu_burn 2>/dev/null || true
    CONTAINER_ID=$(docker run -d --rm --gpus all --name gpu_burn --init gpu_burn "$GPU_BURN_TIME")
    docker logs -f gpu_burn > "$CYCLE_GPU_LOG_DIR/gpu-burn.log" 2>&1 &
    GPU_LOG_PID=$!

    rm -f /home/testos/V4/burnintest/logs/BiTLog*.log
    cd /home/testos/V4/burnintest/64bit
    gnome-terminal -- bash -c "sudo ./bit_cmd_line_x64 -C $BIT_CFG" &

    (
        for ((t=1;t<=GPU_BURN_TIME;t++)); do
            sleep 1
            echo $((t*100/GPU_BURN_TIME))
            echo "# Cycle $i 実行中"
        done
    ) | zenity --progress --title="Cycle $i 実行中" --auto-close --cancel-label="停止" || cleanup

    docker wait "$CONTAINER_ID" >/dev/null 2>&1 || true
    pkill -f bit_cmd_line_x64
    kill "$NVSMI_PID" "$GPU_LOG_PID" 2>/dev/null || true
    mv /home/testos/V4/burnintest/logs/BiTLog*.log "$CYCLE_CPU_LOG_DIR/" 2>/dev/null || true

    (( i < NUM_CYCLES )) && sleep "$BREAK_SECONDS"
done

###############################################
# 判定
###############################################
bit_result="合格"
for d in "$LOG_CPU_DIR"/cycle_*; do
    log=$(ls "$d"/BiTLog*.log 2>/dev/null | head -n 1)
    grep -q "Errors:[[:space:]]*[1-9]" "$log" && bit_result="不合格"
    grep "TEST RUN" "$log" | tail -n 1 | grep -q PASSED || bit_result="不合格"
done

gpu_result="合格"
for d in "$LOG_GPU_DIR"/cycle_*; do
    grep -q "NG" "$d/gpu-burn.log" && gpu_result="不合格"
done

###############################################
# 最終結果
###############################################
if [[ "$bit_result" == "合格" && "$gpu_result" == "合格" ]]; then
    zenity --info --text="<span font_desc='Sans 40' background='#00FF00'><b>PASSED</b></span>" --no-wrap
else
    zenity --error --text="<span font_desc='Sans 40' background='#FF0000'><b>FAILED</b></span>" --no-wrap
fi

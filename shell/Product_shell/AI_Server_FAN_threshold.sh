#!/bin/bash

sudo sleep 2

# ====== FAN Threshold Setting Script ======

# FAN リスト
FANS=("SYS_FAN1" "SYS_FAN2" "SYS_FAN3" "SYS_FAN4" "SYS_FAN7" "SYS_FAN8")

# ===== 1. メインメニュー =====
choice=$(zenity --list \
    --title="FAN しきい値メニュー" \
    --text="FAN のしきい値設定を選択してください。" \
    --column="選択肢" \
    "しきい値の設定を行う" \
    "デフォルト値に設定する" \
    --width=500 --height=300)

if [ -z "$choice" ]; then
    exit 0
fi

# ===== 2. FAN 選択（チェックボックス） =====
fan_selection=$(zenity --list \
    --title="FAN 選択" \
    --text="しきい値を変更する FAN を選んでください（複数選択可）" \
    --checklist \
    --column="選択" --column="FAN 名" \
    TRUE "SYS_FAN1" \
    TRUE "SYS_FAN2" \
    TRUE "SYS_FAN3" \
    TRUE "SYS_FAN4" \
    TRUE "SYS_FAN7" \
    TRUE "SYS_FAN8" \
    --separator=" " \
    --width=450 --height=600)

if [ -z "$fan_selection" ]; then
    zenity --warning --text="FAN が選択されていません。" --width=250
    exit 0
fi

selected_fans=($fan_selection)

# ================================
# しきい値の設定
# ================================
if [ "$choice" = "しきい値の設定を行う" ]; then

    # LCR（Lower Critical）
    lcr=$(zenity --entry \
        --title="LCR 設定" \
        --text="Lower Critical を入力してください（例：1200）")
    [[ -z "$lcr" ]] && exit 0

    # LNC（Lower Non-Critical）
    lnc=$(zenity --entry \
        --title="LNC 設定" \
        --text="Lower Non-Critical を入力してください（例：1500）")
    [[ -z "$lnc" ]] && exit 0

    # LNR は設定不可 → 0 固定
    lnr=0

    for fan in "${selected_fans[@]}"; do
        sudo ipmitool sensor thresh "$fan" lower "$lnr" "$lcr" "$lnc"
    done

    zenity --info --text="選択された FAN のしきい値を設定しました。\nLNR=0 / LCR=$lcr / LNC=$lnc" --width=320
    exit 0
fi

# ================================
# デフォルト値に戻す
# ================================
if [ "$choice" = "デフォルト値に設定する" ]; then

    default_lnr=0
    default_lcr=1200
    default_lnc=1500

    for fan in "${selected_fans[@]}"; do
        sudo ipmitool sensor thresh "$fan" lower "$default_lnr" "$default_lcr" "$default_lnc"
    done

    zenity --info --text="選択された FAN をデフォルト値に戻しました。\nLNR=0 / LCR=1200 / LNC=1500" --width=330
    exit 0
fi

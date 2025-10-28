#!/bin/bash

# RAIDカードの選択（ウィンドウサイズを大きく設定）
RAID_CARD=$(zenity --list --title="RAIDカードの選択" \
    --column="RAIDカード" \
    --height=400 --width=500 \
    "CloudyⅤシリーズ（AOC-SAS3908）" \
    "CloudyⅣ-Entryシリーズ（MegaRAID9361-4i）" \
    "SmartNAS1000シリーズ（MegaRAID9361-8i）" \
    "Nrecシリーズ（MegaRAID9361-8i）"\
    "MegaRAID9580-8i8e")

# RAIDカードが選択されたかチェック
if [ $? -ne 0 ]; then
    zenity --error --text="RAIDカードが選択されませんでした。"
    exit 1
fi

# RAIDカードに対応するファイルパスの記録
case $RAID_CARD in
    "CloudyⅤシリーズ（AOC-SAS3908）")
        FILE_PATH="/home/testos/RAIDcard_FW/CloudyⅤ/5.310.02-4101.3908/STG_AOC-S3908L-H8IR-3908-BRCM-UNUSED_20241217_52.31.0-5830_STDsp.rom"
        CARD_NAM="SAS3908"
        ;;
    "CloudyⅣ-Entryシリーズ（MegaRAID9361-4i）")
        FILE_PATH="/home/testos/RAIDcard_FW/CloudyⅣ-Entry/24.21.0-0148/MR_4MB.rom"
        CARD_NAM="AVAGOMegaRAIDSAS9361-4i"
        ;;
    "SmartNAS1000シリーズ（MegaRAID9361-8i）")
        FILE_PATH="/home/testos/RAIDcard_FW/SmartNAS1000/24.21.0-0159/MR_4MB.rom"
        CARD_NAM="AVAGOMegaRAIDSAS9361-8i"
        ;;
    "Nrecシリーズ（MegaRAID9361-8i）")
        FILE_PATH="/home/testos/RAIDcard_FW/Nrec/24.21.0-0159/MR_4MB.rom"
        CARD_NAM="AVAGOMegaRAIDSAS9361-8i"
        ;;
    "MegaRAID9580-8i8e")
        sudo /home/testos/shell/9580-8i8e.sh
        exit 1
esac

# Zenityで選択結果を表示
zenity --info --title="選択結果" --width=400 --height=200 \
    --text="選択されたRAIDカード: $RAID_CARD\n記録されたファイルパス: $FILE_PATH"

# RAIDカードのIDを判別する
controller_list=$(
  sudo /opt/MegaRAID/storcli/storcli64 show | \
  awk -v model="$CARD_NAM" '
    BEGIN {found=0}
    /^-+$/ { 
      if (++found == 2) next  # 表の下線の2本目を超えたらデータ行
    }
    found == 2 && $2 == model {
      print $1
    }
  '
)

echo "Matching controller(s): $controller_list"

if [ -z "$controller_list" ]; then
  echo "$CARD_NAM コントローラが見つかりません。"
  read -n 1 -s -r -p "何かキーを押すと終了します..."
  exit 1
fi

for ctl in $controller_list; do
  echo "=== コントローラ $ctl を確認中 ==="

# RAIDカードのFW更新を行うか尋ねる
zenity --question --text="RAIDカードのFWを更新しますか？" --width=300
if [ $? -eq 0 ]; then
    # タスク1: RAIDカードのFW更新
    cd /opt/MegaRAID/storcli
    sudo ./storcli64 /c$ctl download file="$FILE_PATH"
    zenity --info --text="RAIDカードのFW更新が完了しました。" --width=300
fi

# RAIDカードのFactory Defaultを行うか尋ねる
zenity --question --text="RAIDカードをFactory Defaultに設定しますか？" --width=300
if [ $? -eq 0 ]; then
    # タスク2: RAIDカードのFactory Default
    sudo ./storcli64 /c$ctl set factory defaults
    zenity --info --text="RAIDカードのFactory Defaultの処理をしました。" --width=300

    # 再起動が必要なことを知らせ、再起動を行うか確認
    zenity --question --text="処理を完了させるには、rebootが必要です。rebootしますか？" --width=300
    if [ $? -eq 0 ]; then
        sudo reboot
    fi
fi
done

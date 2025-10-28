#!/bin/bash

STORCLI="/opt/MegaRAID/storcli/storcli64"
FW_DIR="/home/testos/RAIDcard_FW/MegaRAID9580-8i8e"
FW_FILE="$FW_DIR/9580-8i8e_NOPAD.rom"
PSOC_FILE="$FW_DIR/pblp_catalog.signed.rom"

TARGET_FW_VER="52.32.0-5980"
TARGET_PSOC_VER="0x001F"

reboot_needed=0

# storcli存在チェック
if [ ! -x "$STORCLI" ]; then
  echo "storcli が見つかりません: $STORCLI"
  exit 1
fi

# ファイル存在確認
for f in "$FW_FILE" "$PSOC_FILE"; do
  if [ ! -f "$f" ]; then
    echo "ファイルが見つかりません: $f"
    exit 1
  fi
done

# MegaRAID9580-8i8e を持つコントローラの一覧取得
controller_list=$(sudo $STORCLI show | awk '/MegaRAID9580-8i8e/ {print $1}')
if [ -z "$controller_list" ]; then
  echo "MegaRAID 9580-8i8e コントローラが見つかりません。"
  exit 1
fi

for ctl in $controller_list; do
  echo "=== コントローラ $ctl を確認中 ==="

  # 現在のFWバージョン取得
  current_fw=$(sudo $STORCLI /c$ctl show all | grep -i "Firmware Package Build" | awk -F= '{gsub(/^[ \t]+/, "", $2); print $2}')
  echo "現在のFirmware Package Buildバージョン: $current_fw"

  # FWバージョン比較・更新
  if [ "$current_fw" == "$TARGET_FW_VER" ]; then
    echo "FWは最新バージョンです。更新をスキップします。"
  else
    echo "=== FWを更新します ==="
    sudo $STORCLI /c$ctl download file="$FW_FILE"
    if [ $? -ne 0 ]; then
      echo "FW更新失敗。PSOC更新をスキップします。"
      continue
    fi
    reboot_needed=1
  fi

  # 再起動確認
  if [ "$reboot_needed" -eq 1 ]; then
    echo -n "FW更新が行われました。一度シャットダウンしますか？ [Y/N]: "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      echo "シャットダウンします..."
      sudo shutdown -h now
    else
      echo "シャットダウンはスキップされました。"
    fi
  fi


  # 現在のPSOCバージョン取得
  current_psoc=$(sudo $STORCLI /c$ctl show all | grep -i "PSOC FW Version" | awk -F= '{gsub(/^[ \t]+/, "", $2); print $2}')
  echo "現在のPSOCバージョン: $current_psoc"

  # PSOCバージョン比較・更新
  if [ "$current_psoc" == "$TARGET_PSOC_VER" ]; then
    echo "PSOCは最新バージョンです。更新をスキップします。"
  else
    echo "=== PSOCを更新します ==="
    sudo $STORCLI /c$ctl download file="$PSOC_FILE"
    if [ $? -eq 0 ]; then
      echo "PSOC更新成功"
      reboot_needed=2
    else
      echo "PSOC更新失敗"
    fi
  fi

  echo "------------------------------"
done

# 再起動確認
if [ "$reboot_needed" -eq 2 ]; then
  echo -n "FW更新が行われました。一度シャットダウンしますか？ [Y/N]: "
  read -r answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "シャットダウンします..."
    sudo shutdown -h now
  else
    echo "シャットダウンはスキップされました。"
  fi
fi

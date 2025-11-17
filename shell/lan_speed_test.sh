#!/bin/bash
# ==========================================
# X550 マルチギガ対応 LAN速度テスト（メインUI）
# 各速度設定スクリプトを呼び出す
# ==========================================

BASE_DIR="/home/testos/shell/"  # ← 各LAN設定シェルを置くディレクトリ

# LANケーブル接続メッセージ
if command -v zenity >/dev/null 2>&1; then
    zenity --info --text="LANポートにケーブルを接続してください。"
else
    echo "LANポートにケーブルを接続してください。"
fi

sleep 1

# 速度選択
if command -v zenity >/dev/null 2>&1; then
    SPEED=$(zenity --list \
      --title="LAN速度テスト" \
      --text="テストするリンク速度を選択してください。" \
      --column="速度モード" \
      "100 (100Mb/s)" \
      "1000 (1GbE)" \
      "2500 (2.5GbE)" \
      "5000 (5GbE)" \
      "10000 (10GbE)" \
      "Auto (オートネゴ)" \
      --height=300 --width=350)
else
    echo "テストするリンク速度を入力してください（100 / 1000 / 2500 / 5000 / 10000 / Auto）："
    read SPEED
fi

if [ -z "$SPEED" ]; then
    exit 0
fi

# 速度に応じたシェルを選択
case "$SPEED" in
  "100"|"100 (100Mb/s)")     SCRIPT="$BASE_DIR/LAN_100M.sh" ;;
  "1000"|"1000 (1GbE)")      SCRIPT="$BASE_DIR/LAN_1GbE.sh" ;;
  "2500"|"2500 (2.5GbE)")    SCRIPT="$BASE_DIR/LAN_2.5GbE.sh" ;;
  "5000"|"5000 (5GbE)")      SCRIPT="$BASE_DIR/LAN_5GbE.sh" ;;
  "10000"|"10000 (10GbE)")   SCRIPT="$BASE_DIR/LAN_10GbE.sh" ;;
  "Auto"|"Auto (オートネゴ)") SCRIPT="$BASE_DIR/LAN_Auto.sh" ;;
  *) SCRIPT="" ;;
esac

if [ ! -f "$SCRIPT" ]; then
    zenity --error --text="対象スクリプトが見つかりません。\n$SCRIPT"
    exit 1
fi

# 実行
chmod +x "$SCRIPT"
$SCRIPT


#!/bin/bash

# 最初にLANポートへのケーブル接続を促すメッセージ
zenity --info --text="LANポートにケーブルを接続してください。"

sleep 2

# 有効なネットワークインターフェースを自動検出
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(en|eth)')

# 結果を保持するための変数
RESULT=""

# 各インターフェースに対して接続状態とスピードを確認
for INTERFACE in $INTERFACES; do
  # IPv4アドレスがあるか確認
  if /sbin/ifconfig $INTERFACE | grep -q "inet "; then
    STATUS="接続されています"
  else
    STATUS="接続されていません"
  fi

  # リンクスピードを取得
  SPEED=$(ethtool $INTERFACE | grep "Speed")

  # リンクスピードが取得できたら、LANに接続しているとみなす
  if [ -n "$SPEED" ]; then
    STATUS="接続されています"
  fi

  # 結果に追加
  RESULT+="LANポート ($INTERFACE) は $STATUS。\nリンクスピード: $SPEED\n\n"
done

# 結果を表示
if [ -n "$RESULT" ]; then
  zenity --info --text="$RESULT" --width=400 --height=200
else
  zenity --error --text="LANポートが接続されていません。"
fi


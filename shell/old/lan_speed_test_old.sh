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
  if /sbin/ifconfig $INTERFACE | grep -q "inet "; then
    # リンクスピードを取得
    SPEED=$(ethtool $INTERFACE | grep "Speed")
    # 結果に追加
    RESULT+="LANポート ($INTERFACE) に接続されました。\nリンクスピード: $SPEED\n\n"
  else
    # 接続されていない場合のメッセージ
    RESULT+="LANポート ($INTERFACE) は接続されていません。\n\n"
  fi
done

# 結果を表示
if [ -n "$RESULT" ]; then
  zenity --info --text="$RESULT"
else
  zenity --error --text="LANポートが接続されていません。"
fi



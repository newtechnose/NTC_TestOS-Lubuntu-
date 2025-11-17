#!/bin/bash
# ==========================================
# X550 1GbE 設定スクリプト（修正版）
# ==========================================

RESULT=""
SPEED="1GbE"

INTERFACES=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(en|eth)')
if [ -z "$INTERFACES" ]; then
    echo "LANポートが見つかりません。"
    exit 1
fi

for IFACE in $INTERFACES; do
    echo "=== $IFACE を $SPEED に設定中 ==="

    # advertise + autoneg ON → down/up
    sudo ethtool -s "$IFACE" advertise 0x020 autoneg on
   # sudo ip link set "$IFACE" down
   # sleep 3
   # sudo ip link set "$IFACE" up
    sleep 10

    # リンク再確認
    sudo ethtool -r "$IFACE"
    sleep 10
    LINK_INFO=$(sudo ethtool "$IFACE" | grep -E 'Speed|Duplex|Link detected|Auto-negotiation')
    echo -e "$LINK_INFO"

    RESULT+="LANポート: $IFACE\n設定: $SPEED\n$LINK_INFO\n\n"
done

# 結果表示
if echo "$RESULT" | grep -q "yes"; then
    if command -v zenity >/dev/null 2>&1; then
        zenity --info --title="テスト結果" --text="✅ テスト結果：\n\n$RESULT"
    else
        echo -e "✅ テスト結果：\n\n$RESULT"
    fi
else
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --title="テスト結果" --text="❌ すべてのポートでリンクアップしませんでした。\n\n$RESULT"
    else
        echo -e "❌ すべてのポートでリンクアップしませんでした。\n\n$RESULT"
    fi
fi


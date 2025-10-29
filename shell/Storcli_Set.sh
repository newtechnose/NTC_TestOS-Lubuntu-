#!/bin/bash

# 最初にsudoのパスワードを要求
sudo sleep 2

# Zenityで選択肢を提示し、複数選択を許可
options=$(zenity --width 500 --height 600 --list --checklist \
    --title="Storcli設定を選択" \
    --text="設定を選んでください" \
    --column="選択" --column="設定項目" \
    TRUE "PatrolReadの設定" \
    TRUE "ConsistencyCheckの設定" \
    TRUE "Copybackの設定" \
    TRUE "BatteryWarningの「OFF」設定"\
    FALSE "BatteryWarningの「ON」設定"\
    FALSE "Card Alarm無効の設定" )

# ユーザーがキャンセルした場合
if [ $? -ne 0 ]; then
    zenity --error --text="設定が選択されませんでした。"
    exit 1
fi

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
        CARD_NAM="SAS3908"
        ;;
    "CloudyⅣ-Entryシリーズ（MegaRAID9361-4i）")
        CARD_NAM="AVAGOMegaRAIDSAS9361-4i"
        ;;
    "SmartNAS1000シリーズ（MegaRAID9361-8i）")
        CARD_NAM="AVAGOMegaRAIDSAS9361-8i"
        ;;
    "Nrecシリーズ（MegaRAID9361-8i）")
        CARD_NAM="AVAGOMegaRAIDSAS9361-8i"
        ;;
    "MegaRAID9580-8i8e")
        CARD_NAM="MegaRAID9580-8i8e"
        ;;
esac

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

ctl=$controller_list


# 出荷日フラグ
need_ship_date=false

# 結果を保存する変数
result_summary="Storcli設定結果:\n\n"

# PatrolReadまたはConsistencyCheckが選択されたかどうかを確認
IFS="|"  # 選択肢が"|"で区切られているため
for option in $options; do
    if [[ "$option" == "PatrolReadの設定" || "$option" == "ConsistencyCheckの設定" ]]; then
        need_ship_date=true
        break
    fi
done

# 出荷日が必要な場合は設定前に入力を促す
if [ "$need_ship_date" = true ]; then
    SHIP_DATE=$(zenity --calendar --date-format="%Y/%m/%d" \
        --title="出荷日選択" \
        --text="出荷日を入力してください。")

    # キャンセルされた場合
    if [ $? -ne 0 ]; then
        zenity --error --text="出荷日が入力されませんでした。"
        exit 1
    fi

    echo "選択された出荷日は $SHIP_DATE です。"
fi

# 選択されたオプションに基づいて処理を実行
for option in $options; do
    case $option in
        "PatrolReadの設定")
            # PatrolRead設定のシェルコマンドを実行（出荷日を使って）
            one_month_later=$(date -d "$SHIP_DATE +1 month" +%Y/%m/%d)
            cd /opt/MegaRAID/storcli
            echo "Patrol Readの間隔設定を開始します..."
            patrolread_output=$(sudo ./storcli64 /c$ctl set patrolread delay=720 2>&1)
            sleep 3
            echo "Patrol Readの間隔設定を完了しました。"
            result_summary+="PatrolReadの間隔設定結果:\n$patrolread_output\n\n"

            sleep 2
            echo "Patrol Readの自動開始設定を行います。"
            patrolread_mode_output=$(sudo ./storcli64 /c$ctl set patrolread mode=auto starttime="$one_month_later" 00 2>&1)
            sleep 3
            result_summary+="PatrolReadの自動開始設定結果:\n$patrolread_mode_output\n\n"
            echo "Patrol Readの自動開始設定を完了しました。"
            sleep 2
            ;;
        "ConsistencyCheckの設定")
            # Consistency Check設定のシェルコマンドを実行（出荷日を使って）
            ten_year_later=$(date -d "$SHIP_DATE +10 year" +%Y/%m/%d)
            cd /opt/MegaRAID/storcli
            echo "Consistency Checkの設定を行います。"
            cc_output=$(sudo ./storcli64 /c$ctl set cc=seq starttime=$ten_year_later 00  2>&1)
            sleep 3
            echo "Consistency Checkの設定を完了しました。"
            result_summary+="ConsistencyCheckの設定結果:\n$cc_output\n\n"
            sleep 2
            ;;
        "Copybackの設定")
            # Copyback設定のシェルコマンドを実行
            cd /opt/MegaRAID/storcli
            echo "Copybackの設定を行います。"
            copyback_output=$(sudo ./storcli64 /c$ctl set copyback=off type=all 2>&1)
	    sleep 3
	    echo "Copybackの設定を完了しました。"
            result_summary+="Copybackの設定結果:\n$copyback_output\n\n"
	    sleep 2
            ;;
        "BatteryWarningの「OFF」設定")
            # Battery Warning設定のシェルコマンドを実行
            cd /opt/MegaRAID/storcli
            echo "Battery Warningの「OFF」設定を行います。"
            battery_warning_output=$(sudo ./storcli64 /c$ctl set batterywarning=off 2>&1)
	    sleep 3
	    echo "Battery Warningの「OFF」設定を完了しました。"
            result_summary+="BatteryWarningの設定結果:\n$battery_warning_output\n\n"
	    sleep 2
	    echo "Battery Warningの「OFF」設定を確認します。"
	    battery_warning_status=$(sudo ./storcli64 /c$ctl show batterywarning 2>&1)
	    sleep 3
	    result_summary+="BatteryWarningの確認結果:\n$battery_warning_status\n\n"
	    sleep 2
	    echo "Battery Warningの「OFF」設定の確認が完了しました。"
            ;;
        "BatteryWarningの「ON」設定")
            # Battery Warning設定のシェルコマンドを実行
            cd /opt/MegaRAID/storcli
            echo "Battery Warningの「ON」設定を行います。"
            battery_warning_output=$(sudo ./storcli64 /c$ctl set batterywarning=on 2>&1)
	    sleep 3
	    echo "Battery Warningの「ON」設定を完了しました。"
            result_summary+="BatteryWarningの設定結果:\n$battery_warning_output\n\n"
	    sleep 2
	    echo "Battery Warningの「ON」設定を確認します。"
	    battery_warning_status=$(sudo ./storcli64 /c$ctl show batterywarning 2>&1)
	    sleep 3
	    result_summary+="BatteryWarningの確認結果:\n$battery_warning_status\n\n"
	    sleep 2
	    echo "Battery Warningの「ON」設定の確認が完了しました。"
            ;;
        "Card Alarm無効の設定")
            # Alar無効設定のシェルコマンドを実行
            cd /opt/MegaRAID/storcli
            echo "CardのAlarmを無効にする設定を行います。"
            cardalarm_output=$(sudo ./storcli64 /c$ctl set alarm=off 2>&1)
	    sleep 3
	    echo "CardのAlarm無効化の設定を完了しました。"
            result_summary+="Card Alarm無効の設定結果:\n$cardalarm_output\n\n"
	    sleep 2
        echo "Card Alarm無効の設定を確認します。"
	    cardalarm_status=$(sudo ./storcli64 /c$ctl show alarm 2>&1)
	    sleep 3
	    result_summary+="CardのAlarm無効化の設定の確認結果:\n$cardalarm_status\n\n"
	    sleep 2
	    echo "CardのAlarm無効化の設定の確認が完了しました。"
        sleep 2
        echo "RAIDカードのブザーが無効になっているか確認します"
        sleep 2
        echo "Slot1,Slot2でRAID0を組んで、故意的にdegreedにします。"
        sleep 2
        zenity --question \
               --title="RAID0構築の確認" \
               --text="RAID0を組みます。\nSlot1, Slot2に試験用Diskを搭載してください。\n続行しますか？" \
               --ok-label="はい" \
               --cancel-label="いいえ"

        if [ $? -eq 0 ]; then
            echo "ユーザーが「はい」を選択しました。次の処理に進みます。"
            # 次の処理をここに記述
            # storcli 出力取得（テキスト形式）
            cd /opt/MegaRAID/storcli
            DRIVE_INFO=$(sudo ./storcli64 /c$ctl /eall /sall show)
            EID=$(echo "$DRIVE_INFO" | awk '/UGood/ {print $1}' | cut -d: -f1 | sort | uniq -c | awk '$1 >= 2 {print $2}' | head -n 1)
            # 見つからない場合
            if [[ -z "$EID" ]]; then
                echo "❌ Slot0とSlot1を持つEIDが見つかりません。"
                exit 1
            fi
            echo "✅ EID=$EID を検出しました"

            echo "RAID0構築を構築します。"
            sleep 2
            sudo ./storcli64 /c$ctl add vd type=raid0 drives=$EID:0,$EID:1
            sleep 5
            echo "Slot0のDiskをオフラインにします。"
            sleep 2
            sudo ./storcli64 /c$ctl /e$EID /s0 set offline

            # ブザー確認ダイアログを表示
            RESPONSE=$(zenity --list \
                --title="LSAのブザー確認" \
                --text="LSAのブザーは鳴っていますか？" \
                --radiolist \
                --column="選択" --column="状態" \
                FALSE "ブザーが鳴っている" \
                TRUE "ブザーが鳴っていない" \
                --height=200 --width=400)

            # 選択内容に応じた処理
            if [[ "$RESPONSE" == "ブザーが鳴っていない" ]]; then
                zenity --info --title="確認結果" --text="✅ ブザーの無効化が確認されました。"
            elif [[ "$RESPONSE" == "ブザーが鳴っている" ]]; then
                zenity --error --title="確認結果" --text="❌ ブザーが無効化されていません。\n設定を見直してください。"
            else
                echo "キャンセルされました。"
            fi

            sleep 3
            # RAID0のVD削除
            echo "RAID0の構成情報を削除します。"
            sudo ./storcli64 /c$ctl /v0 delete
            sleep 3
            echo "RAID0の構成情報を削除しました。"
            sleep 3


        else
            echo "ユーザーが「いいえ」を選択しました。処理を中断します。"
            sleep 3
        fi
            ;;
        *)
            echo "不明なオプションが選択されました。"
            ;;
    esac
done

# 最後にすべての結果をまとめてZenityで表示
echo -e "$result_summary" | zenity --text-info --width=800 --height=600 --title="Storcli設定結果" 

# 完了メッセージをZenityで表示
zenity --info --text="Storcli設定が完了しました。"


#!/bin/bash

sudo sleep 2

# status.txtのパス
STATUS_FILE="/home/testos/Status/status.txt"

# status.txtが存在しなければファイルを作成し、初期カウントを0とする
if [ ! -f "$STATUS_FILE" ]; then
    echo "18" > "$STATUS_FILE"
    chmod 777 "$STATUS_FILE"
fi

# status.txtからカウントを読み込む
count=$(cat "$STATUS_FILE")



# 特定のカウント値で特定のコマンドを実行する
#TARGET_COUNT=
if [ -z "$count" ]; then
	sleep 3
	
	if zenity --question --title="statusファイルの初期化確認" --text="前回の製品テストシステムログを削除します。よろしいでしょうか？"; then
	    # ユーザーが「はい」を選択した場合、ファイルを初期値に戻す
	    echo "18" > "$STATUS_FILE"
	    zenity --info --text="Statusフォルダが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="拒否しました。"
	    exit 1
	fi
	
	rm -rf /home/testos/Status/*
	echo "18" > "$STATUS_FILE"
	chmod 777 "$STATUS_FILE"
	# status.txtからカウントを読み込む
	count=$(cat "$STATUS_FILE")
fi



# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=18
if [ "$count" -eq "$TARGET_COUNT" ]; then
	sudo sleep 3
	# テストをはじめから開始するかユーザーに尋ねる
	if zenity --question --title="statusファイルの初期化確認" --text="SmartNAS1000-2Uの製品テストをはじめから始めますか？"; then
	    # ユーザーが「はい」を選択した場合、ファイルを初期値に戻す
	    echo "18" > "$STATUS_FILE"
	    zenity --info --text="ファイルが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="テストを拒否しました。"
	    exit 1
	fi
fi


# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=18
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第18群コマンドを実行します。"


	# タスク0: 各種初期設定
	# Zenityを使ってシリアル番号を入力させる
	SERIAL=$(zenity --entry --title="シリアル番号入力" --text="フォルダを作成するためのNTC製品シリアル番号を入力してください")

	# シリアル番号が入力されていない場合やキャンセルされた場合の処理
	if [ -z "$SERIAL" ]; then
	    zenity --error --text="シリアル番号が入力されていません。"
	    exit 1
	fi

	# フォルダを作成する
	mkdir -p "/home/testos/Desktop/Result/$SERIAL"
	mkdir -p "/home/testos/Desktop/Result/$SERIAL/Log"
#	mkdir -p "/home/testos/Desktop/Result/$SERIAL/burnintest"

	chmod 777 "/home/testos/Desktop/Result/$SERIAL"

	# 出荷日の設定
	SHIP_DATE=$(zenity --calendar --date-format="%Y/%m/%d" --title="出荷日選択" --text="出荷日を入力してください。")

	one_month_later=$(date -d "$SHIP_DATE +1 month" +%Y/%m/%d)
	ten_year_later=$(date -d "$SHIP_DATE +10 year" +%Y/%m/%d)


	# RAIDを組むかどうかをユーザーに確認する
	zenity --question --title="RAIDの組み立て" --text="RAIDを組みますか？"
	# ユーザーの回答を変数に保存します
	response=$?
	# RAIDを組む場合は 1、組まない場合は 0 を保存します
	if [ $response -eq 0 ]; then
	    setup_raid=1
	else
	    setup_raid=0
	fi

	# RAIDを組む場合にのみ Diskの本数とRAIDレベルを入力させます
	if [ $setup_raid -eq 1 ]; then
	    while true; do
	        # Diskの本数を zenity を使用して入力させます
	        drive_count=$(zenity --entry --title="Diskの本数入力" --text="ディスクの本数（2～8）を入力してください")

	        # 入力がキャンセルされた場合はスクリプトを終了します
	        if [ $? -ne 0 ]; then
	            exit 1
	        fi

	        # 入力された Disk の本数を確認します（2～8本であるかチェック）
	        if [[ "$drive_count" -ge 2 && "$drive_count" -le 8 ]]; then
	            break
	        else
	            zenity --error --title="エラー" --text="サポート外の本数です。2～8本の間で入力してください。"
	        fi
	    done

	    while true; do
	        # ディスク本数に応じてサポートされるRAIDレベルを設定
	        case $drive_count in
	            2)
	                valid_raid_levels="0 1"
	                ;;
	            3)
	                valid_raid_levels="0 1 5"
	                ;;
	            4)
	                valid_raid_levels="0 1 5 6 10"
	                ;;
	            5)
	                valid_raid_levels="0 1 5 6 10"
	                ;;
	            6)
	                valid_raid_levels="0 1 5 6 10 50"
	                ;;
	            7)
	                valid_raid_levels="0 1 5 6 10 50"
	                ;;
	            8)
	                valid_raid_levels="0 1 5 6 10 50 60"
	                ;;
	        esac

	        # RAID レベルを zenity を使用して入力させます
	        raid_level=$(zenity --entry --title="RAIDレベル入力" --text="サポートされているRAIDレベルは $valid_raid_levels です。RAID レベルを入力してください")

	        # 入力がキャンセルされた場合はスクリプトを終了します
	        if [ $? -ne 0 ]; then
	            exit 1
	        fi

	        # RAIDレベルがサポートされているかチェック
	        if echo "$valid_raid_levels" | grep -wq "$raid_level"; then
	            break
	        else
	            zenity --error --title="エラー" --text="サポートされていないRAIDレベルです。$valid_raid_levels のいずれかを入力してください。"
	        fi
	    done
	    # raidを追加
	    raid_level="raid$raid_level"


	    # RAID レベルと Disk の本数に応じてディスク情報を指定します
	    # Disk8本の時
	    if [ "$drive_count" -eq 8 ]; then
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6,252:7"
	    # RAID0 構成
	    if [ "$raid_level" == "raid0" ]; then
	        raid_options=("RAID0 でDisk0〜7構成" \
	                      "RAID0 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID0 でDisk0〜5構成，Disk6,7をホットスペア" \
	                      "RAID0 でDisk0〜4構成，Disk5,6,7をホットスペア" \
	                      "RAID0 でDisk0〜3構成，Disk4,5,6,7をホットスペア" \
	                      "RAID0 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア" \
	                      "RAID0 でDisk0〜1構成，Disk2,3,4,5,6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID0 でDisk0〜7構成") raid_type_id=1 ;;
	        "RAID0 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=2 ;;
	        "RAID0 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=3 ;;
	        "RAID0 でDisk0〜4構成，Disk5,6,7をホットスペア") raid_type_id=4 ;;
	        "RAID0 でDisk0〜3構成，Disk4,5,6,7をホットスペア") raid_type_id=5 ;;
	        "RAID0 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア") raid_type_id=6 ;;
	        "RAID0 でDisk0〜1構成，Disk2,3,4,5,6,7をホットスペア") raid_type_id=7 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID1 構成
	    elif [ "$raid_level" == "raid1" ]; then
	        raid_options=("RAID1 でDisk0〜7構成" \
	                      "RAID1 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID1 でDisk0〜5構成，Disk6,7をホットスペア" \
	                      "RAID1 でDisk0〜4構成，Disk5,6,7をホットスペア" \
	                      "RAID1 でDisk0〜3構成，Disk4,5,6,7をホットスペア" \
	                      "RAID1 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア" \
	                      "RAID1 でDisk0〜1構成，Disk2,3,4,5,6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID1 でDisk0〜7構成") raid_type_id=8 ;;
	        "RAID1 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=9 ;;
	        "RAID1 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=10 ;;
	        "RAID1 でDisk0〜4構成，Disk5,6,7をホットスペア") raid_type_id=11 ;;
	        "RAID1 でDisk0〜3構成，Disk4,5,6,7をホットスペア") raid_type_id=12 ;;
	        "RAID1 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア") raid_type_id=13 ;;
	        "RAID1 でDisk0〜1構成，Disk2,3,4,5,6,7をホットスペア") raid_type_id=14 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID5 構成
	    elif [ "$raid_level" == "raid5" ]; then
	        raid_options=("RAID5 でDisk0〜7構成" \
	                      "RAID5 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID5 でDisk0〜5構成，Disk6,7をホットスペア" \
	                      "RAID5 でDisk0〜4構成，Disk5,6,7をホットスペア" \
	                      "RAID5 でDisk0〜3構成，Disk4,5,6,7をホットスペア" \
	                      "RAID5 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID5 でDisk0〜7構成") raid_type_id=15 ;;
	        "RAID5 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=16 ;;
	        "RAID5 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=17 ;;
	        "RAID5 でDisk0〜4構成，Disk5,6,7をホットスペア") raid_type_id=18 ;;
	        "RAID5 でDisk0〜3構成，Disk4,5,6,7をホットスペア") raid_type_id=19 ;;
	        "RAID5 でDisk0〜2構成，Disk3,4,5,6,7をホットスペア") raid_type_id=20 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	      # RAID6 構成
	    elif [ "$raid_level" == "raid6" ]; then
	        raid_options=("RAID6 でDisk0〜7構成" \
	                      "RAID6 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID6 でDisk0〜5構成，Disk6,7をホットスペア" \
	                      "RAID6 でDisk0〜4構成，Disk5,6,7をホットスペア" \
	                      "RAID6 でDisk0〜3構成，Disk4,5,6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID6 でDisk0〜7構成") raid_type_id=21 ;;
	        "RAID6 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=22 ;;
	        "RAID6 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=23 ;;
	        "RAID6 でDisk0〜4構成，Disk5,6,7をホットスペア") raid_type_id=24 ;;
	        "RAID6 でDisk0〜3構成，Disk4,5,6,7をホットスペア") raid_type_id=25 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID10 構成
	    elif [ "$raid_level" == "raid10" ]; then
	        raid_options=("RAID10 でDisk0〜7構成" \
	                      "RAID10 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID10 でDisk0〜5構成，Disk6,7をホットスペア" \
	                      "RAID10 でDisk0〜4構成，Disk5,6,7をホットスペア" \
	                      "RAID10 でDisk0〜3構成，Disk4,5,6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID10 でDisk0〜7構成") raid_type_id=26 ;;
	        "RAID10 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=27 ;;
	        "RAID10 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=28 ;;
	        "RAID10 でDisk0〜4構成，Disk5,6,7をホットスペア") raid_type_id=29 ;;
	        "RAID10 でDisk0〜3構成，Disk4,5,6,7をホットスペア") raid_type_id=30 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID50 構成
	    elif [ "$raid_level" == "raid50" ]; then
	        raid_options=("RAID50 でDisk0〜7構成" \
	                      "RAID50 でDisk0〜6構成，Disk7をホットスペア" \
	                      "RAID50 でDisk0〜5構成，Disk6,7をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID50 でDisk0〜7構成") raid_type_id=31 ;;
	        "RAID50 でDisk0〜6構成，Disk7をホットスペア") raid_type_id=32 ;;
	        "RAID50 でDisk0〜5構成，Disk6,7をホットスペア") raid_type_id=33 ;; 
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID60 構成
	    elif [ "$raid_level" == "raid60" ]; then
	        raid_options=("RAID60 でDisk0〜7構成")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID60 でDisk0〜7構成") raid_type_id=34 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    fi
	fi  
	    # Disk7本の時
	    if [ "$drive_count" -eq 7 ]; then
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	    # RAID0 構成
	    if [ "$raid_level" == "raid0" ]; then
	        raid_options=("RAID0 でDisk0〜6構成" \
	                      "RAID0 でDisk0〜5構成，Disk6をホットスペア" \
	                      "RAID0 でDisk0〜4構成，Disk5,6をホットスペア" \
	                      "RAID0 でDisk0〜3構成，Disk4,5,6をホットスペア" \
	                      "RAID0 でDisk0〜2構成，Disk3,4,5,6をホットスペア" \
	                      "RAID0 でDisk0〜1構成，Disk2,3,4,5,6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID0 でDisk0〜6構成") raid_type_id=35 ;;
	        "RAID0 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=36 ;;
	        "RAID0 でDisk0〜4構成，Disk5,6をホットスペア") raid_type_id=37 ;;
	        "RAID0 でDisk0〜3構成，Disk4,5,6をホットスペア") raid_type_id=38 ;;
	        "RAID0 でDisk0〜2構成，Disk3,4,5,6をホットスペア") raid_type_id=39 ;;
	        "RAID0 でDisk0〜1構成，Disk2,3,4,5,6をホットスペア") raid_type_id=40 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID1 構成
	    elif [ "$raid_level" == "raid1" ]; then
	        raid_options=("RAID1 でDisk0〜6構成" \
	                      "RAID1 でDisk0〜5構成，Disk6をホットスペア" \
	                      "RAID1 でDisk0〜4構成，Disk5,6をホットスペア" \
	                      "RAID1 でDisk0〜3構成，Disk4,5,6をホットスペア" \
	                      "RAID1 でDisk0〜2構成，Disk3,4,5,6をホットスペア" \
	                      "RAID1 でDisk0〜1構成，Disk2,3,4,5,6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID1 でDisk0〜6構成") raid_type_id=41 ;;
	        "RAID1 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=42 ;;
	        "RAID1 でDisk0〜4構成，Disk5,6をホットスペア") raid_type_id=43 ;;
	        "RAID1 でDisk0〜3構成，Disk4,5,6をホットスペア") raid_type_id=44 ;;
	        "RAID1 でDisk0〜2構成，Disk3,4,5,6をホットスペア") raid_type_id=45 ;;
	        "RAID1 でDisk0〜1構成，Disk2,3,4,5,6をホットスペア") raid_type_id=46 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID5 構成
	    elif [ "$raid_level" == "raid5" ]; then
	        raid_options=("RAID5 でDisk0〜6構成" \
	                      "RAID5 でDisk0〜5構成，Disk6をホットスペア" \
	                      "RAID5 でDisk0〜4構成，Disk5,6をホットスペア" \
	                      "RAID5 でDisk0〜3構成，Disk4,5,6をホットスペア" \
	                      "RAID5 でDisk0〜2構成，Disk3,4,5,6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID5 でDisk0〜6構成") raid_type_id=47 ;;
	        "RAID5 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=48 ;;
	        "RAID5 でDisk0〜4構成，Disk5,6をホットスペア") raid_type_id=49 ;;
	        "RAID5 でDisk0〜3構成，Disk4,5,6をホットスペア") raid_type_id=50 ;;
	        "RAID5 でDisk0〜2構成，Disk3,4,5,6をホットスペア") raid_type_id=51 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	      # RAID6 構成
	    elif [ "$raid_level" == "raid6" ]; then
	        raid_options=("RAID6 でDisk0〜6構成" \
	                      "RAID6 でDisk0〜5構成，Disk6をホットスペア" \
	                      "RAID6 でDisk0〜4構成，Disk5,6をホットスペア" \
	                      "RAID6 でDisk0〜3構成，Disk4,5,6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID6 でDisk0〜6構成") raid_type_id=52 ;;
	        "RAID6 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=53 ;;
	        "RAID6 でDisk0〜4構成，Disk5,6をホットスペア") raid_type_id=54 ;;
	        "RAID6 でDisk0〜3構成，Disk4,5,6をホットスペア") raid_type_id=55 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID10 構成
	    elif [ "$raid_level" == "raid10" ]; then
	        raid_options=("RAID10 でDisk0〜6構成" \
	                      "RAID10 でDisk0〜5構成，Disk6をホットスペア" \
	                      "RAID10 でDisk0〜4構成，Disk5,6をホットスペア" \
	                      "RAID10 でDisk0〜3構成，Disk4,5,6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID10 でDisk0〜6構成") raid_type_id=56 ;;
	        "RAID10 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=57 ;;
	        "RAID10 でDisk0〜4構成，Disk5,6をホットスペア") raid_type_id=58 ;;
	        "RAID10 でDisk0〜3構成，Disk4,5,6をホットスペア") raid_type_id=59 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID50 構成
	    elif [ "$raid_level" == "raid50" ]; then
	        raid_options=("RAID50 でDisk0〜6構成" \
	                      "RAID50 でDisk0〜5構成，Disk6をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID50 でDisk0〜6構成") raid_type_id=60 ;;
	        "RAID50 でDisk0〜5構成，Disk6をホットスペア") raid_type_id=61 ;; 
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    fi
	fi 	        
	    # Disk6本の時
	    if [ "$drive_count" -eq 6 ]; then
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    # RAID0 構成
	    if [ "$raid_level" == "raid0" ]; then
	        raid_options=("RAID0 でDisk0〜5構成" \
	                      "RAID0 でDisk0〜4構成，Disk5をホットスペア" \
	                      "RAID0 でDisk0〜3構成，Disk4,5をホットスペア" \
	                      "RAID0 でDisk0〜2構成，Disk3,4,5をホットスペア" \
	                      "RAID0 でDisk0〜1構成，Disk2,3,4,5をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID0 でDisk0〜5構成") raid_type_id=62 ;;
	        "RAID0 でDisk0〜4構成，Disk5をホットスペア") raid_type_id=63 ;;
	        "RAID0 でDisk0〜3構成，Disk4,5をホットスペア") raid_type_id=64 ;;
	        "RAID0 でDisk0〜2構成，Disk3,4,5をホットスペア") raid_type_id=65 ;;
	        "RAID0 でDisk0〜1構成，Disk2,3,4,5をホットスペア") raid_type_id=66 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID1 構成
	    elif [ "$raid_level" == "raid1" ]; then
	        raid_options=("RAID1 でDisk0〜5構成" \
	                      "RAID1 でDisk0〜4構成，Disk5をホットスペア" \
	                      "RAID1 でDisk0〜3構成，Disk4,5をホットスペア" \
	                      "RAID1 でDisk0〜2構成，Disk3,4,5をホットスペア" \
	                      "RAID1 でDisk0〜1構成，Disk2,3,4,5をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID1 でDisk0〜5構成") raid_type_id=67 ;;
	        "RAID1 でDisk0〜4構成，Disk5をホットスペア") raid_type_id=68 ;;
	        "RAID1 でDisk0〜3構成，Disk4,5をホットスペア") raid_type_id=69 ;;
	        "RAID1 でDisk0〜2構成，Disk3,4,5をホットスペア") raid_type_id=70 ;;
	        "RAID1 でDisk0〜1構成，Disk2,3,4,5をホットスペア") raid_type_id=71 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID5 構成
	    elif [ "$raid_level" == "raid5" ]; then
	        raid_options=("RAID5 でDisk0〜5構成" \
	                      "RAID5 でDisk0〜4構成，Disk5をホットスペア" \
	                      "RAID5 でDisk0〜3構成，Disk4,5をホットスペア" \
	                      "RAID5 でDisk0〜2構成，Disk3,4,5をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID5 でDisk0〜5構成") raid_type_id=72 ;;
	        "RAID5 でDisk0〜4構成，Disk5をホットスペア") raid_type_id=73 ;;
	        "RAID5 でDisk0〜3構成，Disk4,5をホットスペア") raid_type_id=74 ;;
	        "RAID5 でDisk0〜2構成，Disk3,4,5をホットスペア") raid_type_id=75 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	      # RAID6 構成
	    elif [ "$raid_level" == "raid6" ]; then
	        raid_options=("RAID6 でDisk0〜5構成" \
	                      "RAID6 でDisk0〜4構成，Disk5をホットスペア" \
	                      "RAID6 でDisk0〜3構成，Disk4,5をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID6 でDisk0〜5構成") raid_type_id=76 ;;
	        "RAID6 でDisk0〜4構成，Disk5をホットスペア") raid_type_id=77 ;;
	        "RAID6 でDisk0〜3構成，Disk4,5をホットスペア") raid_type_id=78 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID10 構成
	    elif [ "$raid_level" == "raid10" ]; then
	        raid_options=("RAID10 でDisk0〜5構成" \
	                      "RAID10 でDisk0〜4構成，Disk5をホットスペア" \
	                      "RAID10 でDisk0〜3構成，Disk4,5をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID10 でDisk0〜5構成") raid_type_id=79 ;;
	        "RAID10 でDisk0〜4構成，Disk5をホットスペア") raid_type_id=80 ;;
	        "RAID10 でDisk0〜3構成，Disk4,5をホットスペア") raid_type_id=81 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID50 構成
	    elif [ "$raid_level" == "raid50" ]; then
	        raid_options=("RAID50 でDisk0〜5構成")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID50 でDisk0〜5構成") raid_type_id=82 ;; 
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    fi
	fi 
	    # Disk5本の時
	    if [ "$drive_count" -eq 5 ]; then
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    # RAID0 構成
	    if [ "$raid_level" == "raid0" ]; then
	        raid_options=("RAID0 でDisk0〜4構成" \
	                      "RAID0 でDisk0〜3構成，Disk4をホットスペア" \
	                      "RAID0 でDisk0〜2構成，Disk3,4をホットスペア" \
	                      "RAID0 でDisk0〜1構成，Disk2,3,4をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID0 でDisk0〜4構成") raid_type_id=83 ;;
	        "RAID0 でDisk0〜3構成，Disk4をホットスペア") raid_type_id=84 ;;
	        "RAID0 でDisk0〜2構成，Disk3,4をホットスペア") raid_type_id=85 ;;
	        "RAID0 でDisk0〜1構成，Disk2,3,4をホットスペア") raid_type_id=86 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID1 構成
	    elif [ "$raid_level" == "raid1" ]; then
	        raid_options=("RAID1 でDisk0〜4構成" \
	                      "RAID1 でDisk0〜3構成，Disk4をホットスペア" \
	                      "RAID1 でDisk0〜2構成，Disk3,4をホットスペア" \
	                      "RAID1 でDisk0〜1構成，Disk2,3,4をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID1 でDisk0〜4構成") raid_type_id=87 ;;
	        "RAID1 でDisk0〜3構成，Disk4をホットスペア") raid_type_id=88 ;;
	        "RAID1 でDisk0〜2構成，Disk3,4をホットスペア") raid_type_id=89 ;;
	        "RAID1 でDisk0〜1構成，Disk2,3,4をホットスペア") raid_type_id=90 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID5 構成
	    elif [ "$raid_level" == "raid5" ]; then
	        raid_options=("RAID5 でDisk0〜4構成" \
	                      "RAID5 でDisk0〜3構成，Disk4をホットスペア" \
	                      "RAID5 でDisk0〜2構成，Disk3,4をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID5 でDisk0〜4構成") raid_type_id=91 ;;
	        "RAID5 でDisk0〜3構成，Disk4をホットスペア") raid_type_id=92 ;;
	        "RAID5 でDisk0〜2構成，Disk3,4をホットスペア") raid_type_id=93;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	      # RAID6 構成
	    elif [ "$raid_level" == "raid6" ]; then
	        raid_options=("RAID6 でDisk0〜4構成" \
	                      "RAID6 でDisk0〜3構成，Disk4をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID6 でDisk0〜4構成") raid_type_id=94 ;;
	        "RAID6 でDisk0〜3構成，Disk4をホットスペア") raid_type_id=95 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    # RAID10 構成
	    elif [ "$raid_level" == "raid10" ]; then
	        raid_options=("RAID10 でDisk0〜4構成" \
	                      "RAID10 でDisk0〜3構成，Disk4をホットスペア")
	        raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
	        case "$raid_selection" in
	        "RAID10 でDisk0〜4構成") raid_type_id=96 ;;
	        "RAID10 でDisk0〜3構成，Disk4をホットスペア") raid_type_id=97 ;;
	        *) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
	        exit 1 ;;
	        esac
	    fi
	fi 	
        
	    # Disk4本の時
	    if [ "$drive_count" -eq 4 ]; then
	        drive_list="252:0,252:1,252:2,252:3"
		if [ "$raid_level" == "raid0" ]; then
			raid_options=("RAID0 でDisk0〜3構成" "RAID0 でDisk0〜2構成，Disk3をホットスペア" "RAID0 でDisk0〜1構成，Disk2,3をホットスペア")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID0 でDisk0〜3構成") raid_type_id=98 ;;
			"RAID0 でDisk0〜2構成，Disk3をホットスペア") raid_type_id=99 ;;
			"RAID0 でDisk0〜1構成，Disk2,3をホットスペア") raid_type_id=100 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid1" ]; then
			raid_options=("RAID1 でDisk0〜3構成" "RAID1 でDisk0〜2構成，Disk3をホットスペア" "RAID1 でDisk0〜1構成，Disk2,3をホットスペア")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID1 でDisk0〜3構成") raid_type_id=101 ;;
			"RAID1 でDisk0〜2構成，Disk3をホットスペア") raid_type_id=102 ;;
			"RAID1 でDisk0〜1構成，Disk2,3をホットスペア") raid_type_id=103 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid5" ]; then
			raid_options=("RAID5 でDisk0〜3構成" "RAID5 でDisk0〜2構成，Disk3をホットスペア")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID5 でDisk0〜3構成") raid_type_id=104 ;;
			"RAID5 でDisk0〜2構成，Disk3をホットスペア") raid_type_id=105 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid6" ]; then
			raid_options=("RAID6 でDisk0〜Disk3構成")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID6 でDisk0〜Disk3構成") raid_type_id=106 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid10" ]; then
			raid_options=("RAID10 でDisk0〜Disk3構成")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID10 でDisk0〜Disk3構成") raid_type_id=107 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		fi	        
	     fi
	     # Disk3本の時
	    if [ "$drive_count" -eq 3 ]; then
	        drive_list="252:0,252:1,252:2"
		if [ "$raid_level" == "raid0" ]; then
			raid_options=("RAID0 でDisk0〜2構成" "RAID0 でDisk0〜1構成，Disk2をホットスペア")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID0 でDisk0〜2構成") raid_type_id=108 ;;
			"RAID0 でDisk0〜1構成，Disk2をホットスペア") raid_type_id=109 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid1" ]; then
			raid_options=("RAID1 でDisk0〜2構成" "RAID1 でDisk0〜1構成，Disk2をホットスペア")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID1 でDisk0〜2構成") raid_type_id=110 ;;
			"RAID1 でDisk0〜1構成，Disk2をホットスペア") raid_type_id=111 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid5" ]; then
			raid_options=("RAID5 でDisk0〜2構成")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID5 でDisk0〜2構成") raid_type_id=112 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		fi	        
	     fi
	    # Disk2本の時
	    if [ "$drive_count" -eq 2 ]; then
	        drive_list="252:0,252:1"
		if [ "$raid_level" == "raid0" ]; then
			raid_options=("RAID0 でDisk0〜1構成")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID0 でDisk0〜1構成") raid_type_id=113 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac
		elif [ "$raid_level" == "raid1" ]; then
			raid_options=("RAID1 でDisk0〜1構成")
			raid_selection=$(zenity --width=400 --height=400 --list --title="RAID構成選択" --text="RAID構成を選択してください" --column="オプション" "${raid_options[@]}")
			case "$raid_selection" in
			"RAID1 でDisk0〜1構成") raid_type_id=114 ;;
			*) zenity --error --text="無効な選択がされました。スクリプトを終了します。"
			exit 1 ;;
			esac	        
	     fi
	fi

	# 結果の表示
	echo "選択されたRAIDタイプID: $raid_type_id" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/raid_type.txt


	# RAIDタイプIDの説明を追加
	case "$raid_type_id" in
	1) raid_description="RAID0: Disk0〜7構成"
	   has_hotspare=false
	   ;;
	2) raid_description="RAID0: Disk0〜6構成, Disk7ホットスペア" 
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	   en="252"
	   hotspare_slot="7"
	   ;;
	3) raid_description="RAID0: Disk0〜5構成, Disk6,7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	   en="252"
	   hotspare_slot="6,7"
	   ;;
	4) raid_description="RAID0: Disk0〜4構成, Disk5,6,7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2,252:3,252:4"
	   en="252"
	   hotspare_slot="5,6,7" 
	   ;;
	5) raid_description="RAID0: Disk0〜3構成, Disk4,5,6,7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2,252:3"
	   en="252"
	   hotspare_slot="4,5,6,7" 
	   ;;
	6) raid_description="RAID0: Disk0〜2構成, Disk3,4,5,6,7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2"
	   en="252"
	   hotspare_slot="3,4,5,6,7" 
	   ;;
	7) raid_description="RAID0: Disk0〜1構成, Disk2,3,4,5,6,7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1"
	   en="252"
	   hotspare_slot="2,3,4,5,6,7" 
	   ;;
	8) raid_description="RAID1: Disk0〜7構成"
	   has_hotspare=false
	   ;;
	9) raid_description="RAID1: Disk0〜6構成, Disk7ホットスペア"
	   has_hotspare=true
	   drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	   en="252"
	   hotspare_slot="7"
	   ;;
	10) raid_description="RAID1: Disk0〜5構成, Disk6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6,7"
	    ;;
	11) raid_description="RAID1: Disk0〜4構成, Disk5,6,7ホットスペア" 
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6,7"
	    ;;
	12) raid_description="RAID1: Disk0〜3構成, Disk4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6,7"
	    ;;
	13) raid_description="RAID1: Disk0〜2構成, Disk3,4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5,6,7"
	    ;;
	14) raid_description="RAID1: Disk0〜1構成, Disk2,3,4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4,5,6,7"
	    ;;
	15) raid_description="RAID5: Disk0〜7構成"
	    has_hotspare=false
	    ;;
	16) raid_description="RAID5: Disk0〜6構成, Disk7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	    en="252"
	    hotspare_slot="7"
	    ;;
	17) raid_description="RAID5: Disk0〜5構成, Disk6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6,7"
	    ;;
	18) raid_description="RAID5: Disk0〜4構成, Disk5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6,7"
	    ;;
	19) raid_description="RAID5: Disk0〜3構成, Disk4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6,7"
	    ;;
	20) raid_description="RAID5: Disk0〜2構成, Disk3,4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5,6,7"
	    ;;
	21) raid_description="RAID6: Disk0〜7構成"
	    has_hotspare=false
	    ;;
	22) raid_description="RAID6: Disk0〜6構成, Disk7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	    en="252"
	    hotspare_slot="7"
	    ;;
	23) raid_description="RAID6: Disk0〜5構成, Disk6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6,7"
	    ;;
	24) raid_description="RAID6: Disk0〜4構成, Disk5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6,7"
	    ;;
	25) raid_description="RAID6: Disk0〜3構成, Disk4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6,7"
	    ;;
	26) raid_description="RAID10: Disk0〜7構成"
	    has_hotspare=false
	    ;;
	27) raid_description="RAID10: Disk0〜6構成, Disk7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	    en="252"
	    hotspare_slot="7"
	    ;;
	28) raid_description="RAID10: Disk0〜5構成, Disk6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6,7"
	    ;;
	29) raid_description="RAID10: Disk0〜4構成, Disk5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6,7"
	    ;;
	30) raid_description="RAID10: Disk0〜3構成, Disk4,5,6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6,7"
	    ;;
	31) raid_description="RAID50: Disk0〜7構成"
	    has_hotspare=false
	    ;;
	32) raid_description="RAID50: Disk0〜6構成, Disk7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
	    en="252"
	    hotspare_slot="7"
	    ;;
	33) raid_description="RAID50: Disk0〜5構成, Disk6,7ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6,7"
	    ;;
	34) raid_description="RAID60: Disk0〜7構成"
	    has_hotspare=false
	    ;;
	35) raid_description="RAID0: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	36) raid_description="RAID0: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	37) raid_description="RAID0: Disk0〜4構成, Disk5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6"
	    ;;
	38) raid_description="RAID0: Disk0〜3構成, Disk4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6"
	    ;;
	39) raid_description="RAID0: Disk0〜2構成, Disk3,4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5,6"
	    ;;
	40) raid_description="RAID0: Disk0〜1構成, Disk2,3,4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4,5,6"
	    ;;
	41) raid_description="RAID1: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	42) raid_description="RAID1: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	43) raid_description="RAID1: Disk0〜4構成, Disk5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6"
	    ;;
	44) raid_description="RAID1: Disk0〜3構成, Disk4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6"
	    ;;
	45) raid_description="RAID1: Disk0〜2構成, Disk3,4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5,6"
	    ;;
	46) raid_description="RAID1: Disk0〜1構成, Disk2,3,4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4,5,6"
	    ;;
	47) raid_description="RAID5: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	48) raid_description="RAID5: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	49) raid_description="RAID5: Disk0〜4構成, Disk5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6"
	    ;;
	50) raid_description="RAID5: Disk0〜3構成, Disk4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6"
	    ;;
	51) raid_description="RAID5: Disk0〜2構成, Disk3,4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5,6"
	    ;;
	52) raid_description="RAID6: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	53) raid_description="RAID6: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	54) raid_description="RAID6: Disk0〜4構成, Disk5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6"
	    ;;
	55) raid_description="RAID6: Disk0〜3構成, Disk4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6"
	    ;;
	56) raid_description="RAID10: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	57) raid_description="RAID10: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	58) raid_description="RAID10: Disk0〜4構成, Disk5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5,6"
	    ;;
	59) raid_description="RAID10: Disk0〜3構成, Disk4,5,6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5,6"
	    ;;
	60) raid_description="RAID50: Disk0〜6構成"
	    has_hotspare=false
	    ;;
	61) raid_description="RAID50: Disk0〜5構成, Disk6ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4,252:5"
	    en="252"
	    hotspare_slot="6"
	    ;;
	62) raid_description="RAID0: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	63) raid_description="RAID0: Disk0〜4構成, Disk5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5"
	    ;;
	64) raid_description="RAID0: Disk0〜3構成, Disk4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5"
	    ;;
	65) raid_description="RAID0: Disk0〜2構成, Disk3,4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5"
	    ;;
	66) raid_description="RAID0: Disk0〜1構成, Disk2,3,4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4,5"
	    ;;
	67) raid_description="RAID1: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	68) raid_description="RAID1: Disk0〜4構成, Disk5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5"
	    ;;
	69) raid_description="RAID1: Disk0〜3構成, Disk4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5"
	    ;;
	70) raid_description="RAID1: Disk0〜2構成, Disk3,4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5"
	    ;;
	71) raid_description="RAID1: Disk0〜1構成, Disk2,3,4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4,5"
	    ;;
	72) raid_description="RAID5: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	73) raid_description="RAID5: Disk0〜4構成, Disk5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5"
	    ;;
	74) raid_description="RAID5: Disk0〜3構成, Disk4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5"
	    ;;
	75) raid_description="RAID5: Disk0〜2構成, Disk3,4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4,5"
	    ;;
	76) raid_description="RAID6: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	77) raid_description="RAID6: Disk0〜4構成, Disk5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5"
	    ;;
	78) raid_description="RAID6: Disk0〜3構成, Disk4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5"
	    ;;
	79) raid_description="RAID10: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	80) raid_description="RAID10: Disk0〜4構成, Disk5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3,252:4"
	    en="252"
	    hotspare_slot="5"
	    ;;
	81) raid_description="RAID10: Disk0〜3構成, Disk4,5ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4,5"
	    ;;
	82) raid_description="RAID50: Disk0〜5構成"
	    has_hotspare=false
	    ;;
	83) raid_description="RAID0: Disk0〜4構成"
	    has_hotspare=false
	    ;;
	84) raid_description="RAID0: Disk0〜3構成, Disk4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4"
	    ;;
	85) raid_description="RAID0: Disk0〜2構成, Disk3,4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4"
	    ;;
	86) raid_description="RAID0: Disk0〜1構成, Disk2,3,4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4"
	    ;;
	87) raid_description="RAID1: Disk0〜4構成"
	    has_hotspare=false
	    ;;
	88) raid_description="RAID1: Disk0〜3構成, Disk4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4"
	    ;;
	89) raid_description="RAID1: Disk0〜2構成, Disk3,4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4"
	    ;;
	90) raid_description="RAID1: Disk0〜1構成, Disk2,3,4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1"
	    en="252"
	    hotspare_slot="2,3,4"
	    ;;
	91) raid_description="RAID5: Disk0〜4構成"
	    has_hotspare=false
	    ;;
	92) raid_description="RAID5: Disk0〜3構成, Disk4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4"
	    ;;
	93) raid_description="RAID5: Disk0〜2構成, Disk3,4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3,4"
	    ;;
	94) raid_description="RAID6: Disk0〜4構成"
	    has_hotspare=false
	    ;;
	95) raid_description="RAID6: Disk0〜3構成, Disk4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4"
	    ;;
	96) raid_description="RAID10: Disk0〜4構成"
	    has_hotspare=false
	    ;;
	97) raid_description="RAID10: Disk0〜3構成, Disk4ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2,252:3"
	    en="252"
	    hotspare_slot="4"
	    ;;
	98) raid_description="RAID0: Disk0〜3構成"
	    has_hotspare=false
	    ;;
	99) raid_description="RAID0: Disk0〜2構成，Disk3ホットスペア"
	    has_hotspare=true
	    drive_list="252:0,252:1,252:2"
	    en="252"
	    hotspare_slot="3"
	    ;;
	100) raid_description="RAID0: Disk0〜1構成，Disk2,3ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1"
	     en="252"
	     hotspare_slot="2,3"
	     ;;
	101) raid_description="RAID1: Disk0〜3構成"
	     has_hotspare=false
	     ;;
	102) raid_description="RAID1: Disk0〜2構成，Disk3ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1,252:2"
	     en="252"
	     hotspare_slot="3"
	     ;;
	103) raid_description="RAID1: Disk0〜1構成，Disk2,3ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1"
	     en="252"
	     hotspare_slot="2,3"
	     ;;
	104) raid_description="RAID5: Disk0〜3構成"
	     has_hotspare=false
	     ;;
	105) raid_description="RAID5: Disk0〜2構成，Disk3ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1,252:2"
	     en="252"
	     hotspare_slot="3"
	     ;;
	106) raid_description="RAID6: Disk0〜Disk3構成"
	     has_hotspare=false
	     ;;
	107) raid_description="RAID10: Disk0〜Disk3構成"
	     has_hotspare=false
	     ;;
	108) raid_description="RAID0: Disk0〜2構成"
	     has_hotspare=false
	     ;;
	109) raid_description="RAID0: Disk0〜1構成，Disk2ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1"
	     en="252"
	     hotspare_slot="2"
	     ;;
	110) raid_description="RAID1: Disk0〜2構成"
	     has_hotspare=false
	     ;;
	111) raid_description="RAID1: Disk0〜1構成，Disk2ホットスペア"
	     has_hotspare=true
	     drive_list="252:0,252:1"
	     en="252"
	     hotspare_slot="2"
	     ;;
	112) raid_description="RAID5: Disk0〜2構成"
	     has_hotspare=false
	     ;;
	113) raid_description="RAID0: Disk0〜1構成"
	     has_hotspare=false
	     ;;
	114) raid_description="RAID1: Disk0〜1構成"
	     has_hotspare=false
	     ;;
	*) raid_description="不明なRAID構成" ;;
	esac

	fi

	figlet "SmartNAS1000 TEST START"

	# カウントを1増やす
	((count++))
	# 更新したカウントをstatus.txtに書き込む
	echo "$count" > "$STATUS_FILE"
	# シリアル番号をserial.txtに書き込む
	SERIAL_FILE="/home/testos/Status/serial.txt"
	touch "$SERIAL_FILE"
	echo "$SERIAL" > "$SERIAL_FILE"
	# 出荷関係の書き込み
	SHIP_DATE_FILE="/home/testos/Status/ship_date.txt"
	touch "$SHIP_DATE_FILE"
	echo "$SHIP_DATE" > "$SHIP_DATE_FILE"
	ONE_MONTH_LATER_FILE="/home/testos/Status/one_month_later.txt"
	touch "$ONE_MONTH_LATER_FILE"
	echo "$one_month_later" > "$ONE_MONTH_LATER_FILE"
	TEN_YEAR_LATER_FILE="/home/testos/Status/ten_year_later.txt"
	touch "$TEN_YEAR_LATER_FILE"
	echo "$ten_year_later" > "$TEN_YEAR_LATER_FILE"	
	# RAID関係の書き込み
	SETUP_RAID_FILE="/home/testos/Status/setup_raid.txt"
	touch "$SETUP_RAID_FILE"
	echo "$setup_raid" > "$SETUP_RAID_FILE"	
	RAID_LEVEL_FILE="/home/testos/Status/raid_level.txt"
	touch "$RAID_LEVEL_FILE"
	echo "$raid_level" > "$RAID_LEVEL_FILE"	
	DRIVE_COUNT_FILE="/home/testos/Status/drive_count.txt"
	touch "$DRIVE_COUNT_FILE"
	echo "$drive_count" > "$DRIVE_COUNT_FILE"
	DRIVE_LIST_FILE="/home/testos/Status/drive_list.txt"
	touch "$DRIVE_LIST_FILE"
	echo "$drive_list" > "$DRIVE_LIST_FILE"	
	RAID_TYPE_ID_FILE="/home/testos/Status/raid_type_id.txt"
	touch "$RAID_TYPE_ID_FILE"
	echo "$raid_type_id" > "$RAID_TYPE_ID_FILE"
	sleep 5

fi


# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=19
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第19群コマンドを実行します。"
    
	# ファイルパスの定義
	SERIAL_FILE="/home/testos/Status/serial.txt"
	SHIP_DATE_FILE="/home/testos/Status/ship_date.txt"
	ONE_MONTH_LATER_FILE="/home/testos/Status/one_month_later.txt"
	TEN_YEAR_LATER_FILE="/home/testos/Status/ten_year_later.txt"
	SETUP_RAID_FILE="/home/testos/Status/setup_raid.txt"
	RAID_LEVEL_FILE="/home/testos/Status/raid_level.txt"
	DRIVE_COUNT_FILE="/home/testos/Status/drive_count.txt"
	DRIVE_LIST_FILE="/home/testos/Status/drive_list.txt"
	RAID_TYPE_ID_FILE="/home/testos/Status/raid_type_id.txt"
	# 各ファイルから値を読み込む
	SERIAL=$(cat "$SERIAL_FILE")
	one_month_later=$(cat "$ONE_MONTH_LATER_FILE")
	ten_year_later=$(cat "$TEN_YEAR_LATER_FILE")
	setup_raid=$(cat "$SETUP_RAID_FILE")
	raid_level=$(cat "$RAID_LEVEL_FILE")
	drive_count=$(cat "$DRIVE_COUNT_FILE")
	drive_list=$(cat "$DRIVE_LIST_FILE")
	raid_type_id=$(cat "$RAID_TYPE_ID_FILE")

	#Resultファイルの初期作成
	touch /home/testos/Desktop/Result/$SERIAL/result.txt 
	# テキストファイルの保存場所
	txt_file="/home/testos/Desktop/Result/$SERIAL/result.txt"

	# ヘッダーをテキストファイルに出力
	printf "| %-30s | %-6s | %-50s |\n" "項目" "結果" "備考" >> "$txt_file"
	echo -e "|-----------------------------|-----|--------------------------------------------------|" >> "$txt_file"


	# タスク1: FWバージョンアップの確認
	# ディレクトリの移動
	cd /opt/MegaRAID/storcli
	# 正しいRAIDカードFWのバージョン
	expected_fw_version="4.680.00-8577"
	
	# storcliでRAIDカードのFWバージョンを取得
	fw_version=$(sudo ./storcli64 /c0 show | grep "FW Version" | awk '{print $4}')

	# バージョン判定とチェックマークの設定
	if [ "$fw_version" == "$expected_fw_version" ]; then
	  result="合格"  # 合格
	else
	  result="不合格"  # 不合格
	fi

	# RAIDカードFWの結果をテキストファイルに書き込み
	printf "| %-30s | %-6s | %-50s |\n" "RAIDカードFW" "$result" "$fw_version" >> "$txt_file"


	# タスク2: RAID構成VD作成
	# RAIDを組む場合にのみ RAID を構築します
	if [ $setup_raid -eq 1 ]; then
	# ディレクトリの移動
	cd /opt/MegaRAID/storcli
	# 仮想ディスクを作成する処理
	function create_virtual_disk {
		local vd_name=$1
		local size=$2
		local log_file=$3	
		sudo ./storcli64 /c0 add vd type=$raid_level size=$size name=$vd_name drives=$drive_list strip=64 awb cached ra pdcache=on | tee -a "/home/testos/Desktop/Result/$SERIAL/Log/$log_file"
		sleep 1

		# Status判定
		if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/$log_file"; then
			result="合格"
		else
			result="不合格"
		fi

		# 結果をログに出力
		printf "| %-30s | %-6s | %-50s |\n" "$vd_name作成" "$result" "$raid_description" >> "$txt_file"
	}

	# VD0を作成 (全容量)
	create_virtual_disk "VD0" "all" "1_RAID_VD0.txt"
	echo "RAIDでVD0(全容量)が構成されました。" | tee -a "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"
	echo -e "\n\n\n\n\n"

	# ホットスペアがある場合の処理
	if [ "$has_hotspare" = true ]; then
		sudo ./storcli64 /c0 /e$en /s$hotspare_slot add hotsparedrive | tee -a "/home/testos/Desktop/Result/$SERIAL/Log/2_RAID_Hotspare.txt"
		sleep 1

		# Status判定
		if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/2_RAID_Hotspare.txt"; then
			result="合格"
		else
			result="不合格"
		fi

		# 結果をログに出力
		printf "| %-30s | %-6s | %-50s |\n" "ホットスペア作成" "$result" "$raid_description" >> "$txt_file"
		echo "Slot $hotspare_slot にホットスペアが構成されました。" | tee -a "/home/testos/Desktop/Result/$SERIAL/Log/2_RAID_Hotspare.txt"
		echo -e "\n\n\n\n\n"
	fi
	# タスク3: VDのInitialization
	sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_VD0_init.txt
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/3_VD0_init.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"

	sleep 120

	while true; do
	    output=$(sudo ./storcli64 /c0 /v0 show init)
	    echo "$output"
	    if echo "$output" | grep -q "Not in progress"; then
	        break
	    fi
	    sleep 1800
	done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_VD0_init.txt
	sleep 60

	
	
	# タスク4: RAIDカードの設定
	# ディレクトリの移動
	cd /opt/MegaRAID/storcli
	echo "Patrol Readの間隔設定を開始します..." | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	# Patrolreadコマンドを実行する
	sudo ./storcli64 /c0 set patrolread delay=720 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	echo "Patrol Readの間隔設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	sleep 5
	echo "Patrol Readの自動開始設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	sudo ./storcli64 /c0 set patrolread mode=auto starttime=$one_month_later 00 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	echo "Patrol Readの自動開始設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt
	echo -e "\n\n\n\n\n"
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_Storcli_Patrolread.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "PatrolRead設定" "$result" "$one_month_later" >> "$txt_file"



	echo "Consistency Checkの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_Storcli_ConsistencyCheck.txt
	sudo ./storcli64 /c0 set cc=seq starttime=$ten_year_later 00 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_Storcli_ConsistencyCheck.txt
	echo "Consistency Checkの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_Storcli_ConsistencyCheck.txt
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/5_Storcli_ConsistencyCheck.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ConsistencyCheck設定" "$result" "$ten_year_later ※LSAでScheduleを Weekly ⇒ Monthly に変更すること" >> "$txt_file"
	       

	echo "Copybackの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/6_Storcli_CopyBack.txt
	sudo ./storcli64 /c0 set copyback=off type=all | tee -a /home/testos/Desktop/Result/$SERIAL/Log/6_Storcli_CopyBack.txt
	echo "Copybackの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/6_Storcli_CopyBack.txt
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/6_Storcli_CopyBack.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "CopyBack設定" "$result" "Copy Back ALL" >> "$txt_file"


	echo "Battery Warningの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/7_Storcli_BatteryWarning.txt
	sudo ./storcli64 /c0 set batterywarning=off | tee -a /home/testos/Desktop/Result/$SERIAL/Log/7_Storcli_BatteryWarning.txt
	echo "Battery Warningの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/7_Storcli_BatteryWarning.txt


	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/7_Storcli_BatteryWarning.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "BatteryWarning設定" "$result" "BatteryWarning OFF" >> "$txt_file"


	fi

	# タスク5: BurnInTest
	echo "BurnInTestを開始します。"
	sleep 5
	cd /home/testos/V4/burnintest/64bit
	sudo ./bit_cmd_line_x64 -C /home/testos/BurnInTest_cfg/Nrec4000_8000.cfg
	sleep 3
	echo "BurnInTestを完了しました。" 
	sleep 3
	
	sudo mv /home/testos/Desktop/Result/BiTLog2.log /home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_Result.log 
	log_file="/home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_Result.log"

	# テスト結果を格納するための配列
	declare -a test_results

	# 結果セクションを抽出
	results_section=$(grep -E 'CPU - Maths|Memory \(RAM\)|Disk: /dev/sdb |Disk: /dev/sdc ' "$log_file" )

	# 各行を変数に格納
	while IFS= read -r line; do
	    test_results+=("$line")
	done <<< "$results_section"

	# 各テスト結果を個別の変数に保存
	cpu_maths=$(echo "${test_results[0]}")
	memory_ram=$(echo "${test_results[1]}")
	disk_sdb=$(echo "${test_results[2]}")
#	disk_sdc=$(echo "${test_results[3]}")

	# 最後の行を取得
	last_line=$(grep "TEST RUN" "$log_file" | tail -n 1)

	# 結果を判定
	if [[ "$last_line" == *"PASSED"* ]]; then
	    result="合格"
	elif [[ "$last_line" == *"FAILED"* ]]; then
	    result="不合格"
	else
	    result="結果が不明です"
	fi

	# さらに項目を追加する場合は、同様の処理を続ける
	printf "| %-30s | %-6s | %-50s |\n" "BurnInTest" "$result" "BurnInTest_Result" >> "$txt_file"
	printf "| %-30s | %-6s | %-50s |\n" "cpu_maths" " " "$cpu_maths" >> "$txt_file"
	printf "| %-30s | %-6s | %-50s |\n" "memory_ram" " " "$memory_ram" >> "$txt_file"
	printf "| %-30s | %-6s | %-50s |\n" "disk_sdb" " " "$disk_sdb" >> "$txt_file"
#	printf "| %-30s | %-6s | %-50s |\n" "disk_sdc" " " "$disk_sdc" >> "$txt_file"
	
	# タスク6: HDDアクセステスト
	# hdparmの実行と結果の保存
	hdparm_sdb=$(sudo hdparm -ft /dev/sdb | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_hdparm_sdb.txt)

	# 結果から速度を抽出（数値のみを取り出す）
	speed=$(echo "$hdparm_sdb" | grep -oP '\d+(\.\d+)?(?= MB/sec)' | head -n 1)

	# 速度が300.00 MB/sec以上かどうかのチェック
	if (( $(echo "$speed >= 300.00" | bc -l) )); then
	    result="合格"
	else
	    result="不合格"
	fi
	# さらに項目を追加する場合は、同様の処理を続ける
	printf "| %-30s | %-6s | %-50s MB/sec |\n" "VD0のHDDアクセステスト" "$result" "$speed" >> "$txt_file"

	sleep 3

	sleep 10
	
	
	
	# タスク7: Rebootテスト
	# reboot_tool.conf ファイルのパス
	conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"
	
	count_cur=0
	count_limit=100
	# [Command1] と [Command2] の値
	command1="shutdown -r +2"
	command2="NONE"
	
	# reboot_tool.conf ファイルに書き込み
	echo "[Count Cur]" > "$conf_file"
	echo "$count_cur" >> "$conf_file"
	echo "[Count Limit]" >> "$conf_file"
	echo "$count_limit" >> "$conf_file"
	echo "[Command1]" >> "$conf_file"
	echo "$command1" >> "$conf_file"
	echo "[Command2]" >> "$conf_file"
	echo "$command2" >> "$conf_file"
	

	# カウントを1増やす
	((count++))
	# 更新したカウントをstatus.txtに書き込む
	echo "$count" > "$STATUS_FILE"
	
	/usr/sbin/reboot_tool
	
	sleep 130
	
	
fi



	
# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=20
if [ "$count" -eq "$TARGET_COUNT" ]; then
	sleep 3
	# ファイルパスの定義
	SERIAL_FILE="/home/testos/Status/serial.txt"
	SHIP_DATE_FILE="/home/testos/Status/ship_date.txt"
	ONE_MONTH_LATER_FILE="/home/testos/Status/one_month_later.txt"
	TEN_YEAR_LATER_FILE="/home/testos/Status/ten_year_later.txt"
	SETUP_RAID_FILE="/home/testos/Status/setup_raid.txt"
	RAID_LEVEL_FILE="/home/testos/Status/raid_level.txt"
	DRIVE_COUNT_FILE="/home/testos/Status/drive_count.txt"
	DRIVE_LIST_FILE="/home/testos/Status/drive_list.txt"
	RAID_TYPE_ID_FILE="/home/testos/Status/raid_type_id.txt"

	# 各ファイルから値を読み込む
	SERIAL=$(cat "$SERIAL_FILE")
	one_month_later=$(cat "$ONE_MONTH_LATER_FILE")
	ten_year_later=$(cat "$TEN_YEAR_LATER_FILE")
	setup_raid=$(cat "$SETUP_RAID_FILE")
	raid_level=$(cat "$RAID_LEVEL_FILE")
	drive_count=$(cat "$DRIVE_COUNT_FILE")
	drive_list=$(cat "$DRIVE_LIST_FILE")
	raid_type_id=$(cat "$RAID_TYPE_ID_FILE")
	
	# テキストファイルの保存場所
	txt_file="/home/testos/Desktop/Result/$SERIAL/result.txt"
	


	# reboot_tool.conf ファイルのパス
	conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"

	# [Count Cur]と[Count Limit]の値を取得
	COUNT_CUR=$(grep -A 1 "\[Count Cur\]" "$conf_file" | tail -n 1)
	COUNT_LIMIT=$(grep -A 1 "\[Count Limit\]" "$conf_file" | tail -n 1)

	# 合否判定
	if [ "$COUNT_CUR" -gt "$COUNT_LIMIT" ]; then
	    result="合格"
	else
	    result="不合格"
	fi

	# さらに項目を追加する場合は、同様の処理を続ける
	printf "| %-30s | %-6s | %-50s 回 |\n" "Rebootテスト" "$result" "$COUNT_LIMIT" >> "$txt_file"


	# 最後にテーブルの終わりを出力したい場合に使う（必要に応じて）
	 echo -e "|---------------------------|----|----------------------------------------------|" >> "$txt_file"


	#完了通知
	python3 /home/testos/shell/Product_shell/smartnas_finish.py
	# status.txtに書き込む
	echo "" > "$STATUS_FILE"
	exit 1

fi


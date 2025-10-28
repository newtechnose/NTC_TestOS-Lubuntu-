#!/bin/bash

sudo sleep 2

# status.txtのパス
STATUS_FILE="/home/testos/Status/status.txt"

# status.txtが存在しなければファイルを作成し、初期カウントを0とする
if [ ! -f "$STATUS_FILE" ]; then
    echo "12" > "$STATUS_FILE"
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
	    echo "12" > "$STATUS_FILE"
	    zenity --info --text="Statusフォルダが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="拒否しました。"
	    exit 1
	fi
	
	rm -rf /home/testos/Status/*
	echo "12" > "$STATUS_FILE"
	chmod 777 "$STATUS_FILE"
	# status.txtからカウントを読み込む
	count=$(cat "$STATUS_FILE")
fi



# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=12
if [ "$count" -eq "$TARGET_COUNT" ]; then
	sudo sleep 3
	# テストをはじめから開始するかユーザーに尋ねる
	if zenity --question --title="statusファイルの初期化確認" --text="Cloudyの製品テストをはじめから始めますか？"; then
	    # ユーザーが「はい」を選択した場合、ファイルを初期値に戻す
	    echo "12" > "$STATUS_FILE"
	    zenity --info --text="ファイルが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="テストを拒否しました。"
	    exit 1
	fi
fi


# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=12
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第12群コマンドを実行します。"


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
	# RAID構成を選択してください
	raid_choice=$(zenity --width=800 --height=800 --list --title="RAID構成の選択" \
	    --text="構成するRAID構成を選択してください" \
	    --radiolist \
	    --column "選択" --column "RAID構成" \
	    TRUE "① CloudyⅤ-1U 3.5インチBay 標準構成(Disk0 ～ Disk3でRAID6構成)" \
	    FALSE "② CloudyⅤ-1U 2.5インチBay 標準構成(Disk0 ～ Disk7でRAID6構成)" \
	    FALSE "③ CloudyⅤ-2U 3.5インチBay 標準構成(Disk0 ～ Disk10でRAID6構成、ホットスペアDisk11)" \
	    FALSE "④ CloudyⅤ-2U 2.5インチBay サーバ構成(Disk0 ～ Disk22でRAID6構成、ホットスペアDisk23)" \
	    FALSE "⑤ CloudyⅤ-2U 2.5インチBay 映像構成(Disk0 ～ Disk23でRAID6構成)" \
	    FALSE "⑥ CloudyⅤ-4U 3.5インチBay 標準構成(Disk0 ～ Disk31でRAID6構成、ホットスペアDisk32～35)" \
	    FALSE "⑦ その他のユーザー指定構成")

	# ユーザーの選択を変数に保存し、選択に応じて処理を行います
	case "$raid_choice" in
	    "① CloudyⅤ-1U 3.5インチBay 標準構成(Disk0 ～ Disk3でRAID6構成)")
	        echo "RAID6構成を選択しました。Disk0 ～ Disk3でRAID6を組みます。"
	        # RAID5構成の処理を追加
	        raid_type_id=1
	        ;;
	    "② CloudyⅤ-1U 2.5インチBay 標準構成(Disk0 ～ Disk7でRAID6構成)")
	        echo "RAID6構成を選択しました。Disk0 ～ Disk7でRAID6を組みます。"
	        # RAID6構成の処理を追加
	        raid_type_id=2
	        ;;
	    "③ CloudyⅤ-2U 3.5インチBay 標準構成(Disk0 ～ Disk10でRAID6構成、ホットスペアDisk11)")
	        echo "RAID6構成（ホットスペア付き）を選択しました。Disk0 ～ Disk10でRAID6を組み、Disk11をホットスペアにします。"
	        # RAID6+ホットスペア構成の処理を追加
	        raid_type_id=3
	        ;;
	    "④ CloudyⅤ-2U 2.5インチBay サーバ構成(Disk0 ～ Disk22でRAID6構成、ホットスペアDisk23)")
	        echo "サーバ構成を選択しました。Disk0 ～ Disk22でRAID6を組み、Disk23をホットスペアにします。"
	        # サーバ構成の処理を追加
	        raid_type_id=4
	        ;;
	    "⑤ CloudyⅤ-2U 2.5インチBay 映像構成(Disk0 ～ Disk23でRAID6構成)")
	        echo "映像構成を選択しました。Disk0 ～ Disk23でRAID6を組みます。"
	        # 映像構成の処理を追加
	        raid_type_id=5
	        ;;
	    "⑥ CloudyⅤ-4U 3.5インチBay 標準構成(Disk0 ～ Disk31でRAID6構成、ホットスペアDisk32～35)")
	        echo "4U標準構成を選択しました。Disk0 ～ Disk31でRAID6を組み、Disk32 ～ Disk35をホットスペアにします。"
	        # 4U標準構成の処理を追加
	        raid_type_id=6
	        ;;
	    "⑦ その他のユーザー指定構成")
	        echo "ユーザー指定構成を選択しました。"
	        # RAIDを事前に組んでいるか確認
		if zenity --question --title="RAID構成済みか確認" --text="既にLSAでRAIDを構成しておりますか？ ※VD0のみのとき使用可能です。VD２つ以上は「いいえ」を選択して手動でどうぞ!"; then
	    	# ユーザーが「はい」を選択した場合、
	    	# ユーザー指定構成の処理を追加
	        raid_type_id=7
		else
	    	# ユーザーが「いいえ」を選択した場合、強制終了
	    	zenity --error --text="ユーザー指定のRAID構成の場合はLSAでRAIDを組んでから、この自動プログラムを実行してください。"
	    	exit 1
		fi
	       ;;
	    *)
	        echo "RAID構成が選択されませんでした。"
	        ;;
	esac
#	fi

	# 結果の表示
	echo "選択されたRAIDタイプID: $raid_type_id" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/raid_type.txt


	# RAIDタイプIDの説明を追加
	case "$raid_type_id" in
	1) raid_description="CloudyⅤ-1U 3.5インチBay 標準構成(Disk0 ～ Disk3でRAID6構成)" ;;
	2) raid_description="CloudyⅤ-1U 2.5インチBay 標準構成(Disk0 ～ Disk7でRAID6構成)" ;;
	3) raid_description="CloudyⅤ-2U 3.5インチBay 標準構成(Disk0 ～ Disk10でRAID6構成、ホットスペアDisk11)" ;;
	4) raid_description="CloudyⅤ-2U 2.5インチBay サーバ構成(Disk0 ～ Disk22でRAID6構成、ホットスペアDisk23)" ;;
	5) raid_description="CloudyⅤ-2U 2.5インチBay 映像構成(Disk0 ～ Disk23でRAID6構成)" ;;
	6) raid_description="CloudyⅤ-4U 3.5インチBay 標準構成(Disk0 ～ Disk31でRAID6構成、ホットスペアDisk32～35)" ;;
	7) raid_description="ユーザー指定構成を選択しました。" ;;
	*) raid_description="不明なRAID構成" ;;
	esac

	fi
	
	figlet "Cloudy TEST START"

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
TARGET_COUNT=13
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第13群コマンドを実行します。"
    
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
	case $raid_type_id in
	1)
		# RAID type 1の設定
		# 最初のVD0を作成（サイズ200GB）
		sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=252:0,252:1,252:2,252:3 strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 10
		# size=allでVD1を作成
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD1 drives=252:0,252:1,252:2,252:3 strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt
		sleep 10
		# VD ID 239を削除
		sudo ./storcli64 /c0 /v239 del force
		sleep 10
		# 2回目のVD0を作成（サイズ200GB）
		sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=252:0,252:1,252:2,252:3 strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 10
		# 条件が満たされるまでループ
		while true; do
		    # VDリストの確認
		    output=$(sudo ./storcli64 /c1 /vall show)
		    # 条件に合致するVDのIDを取得
		    id=$(echo "$output" | grep -Eo '0/[0-9]+ RAID6.*(GB|TB).*VD0' | grep -Eo '0/[0-9]+' | cut -d'/' -f2)
		    # 条件に合致するVDのIDとサイズがあるか確認
		    if echo "$output" | grep -q '0/237 RAID6.*GB.*VD0'; then
		        echo "VD ID TBサイズが確認されました。"
		        break
		    elif [ -n "$id" ]; then
		        echo "条件に合致しないため、VDを再作成します..."
		        # 特定したVD IDを削除
		        sudo ./storcli64 /c1/v"$id" del force
		        sleep 30
		        # VDを作成（size=200GB）
		        sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=252:0,252:1,252:2,252:3 strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		        sleep 10
		    fi
		    # 少し待機してから再試行
		    sleep 5
		done
		echo "指定条件を満たしたため、スクリプトを終了します。"
		
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(200GB)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD1作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD1(残りの容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	2)
		# RAID type 2の設定
		drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6"
		en="252"
		hotspare_slot="7"
		
		# 最初のVD0を作成（サイズ200GB）
		sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 10
		# size=allでVD1を作成
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD1 drives=$drive_list strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt
		sleep 10
		# VD ID 239を削除
		sudo ./storcli64 /c0 /v239 del force
		sleep 10
		# 2回目のVD0を作成（サイズ200GB）
		sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 10
		# 条件が満たされるまでループ
		while true; do
		    # VDリストの確認
		    output=$(sudo ./storcli64 /c1 /vall show)
		    # 条件に合致するVDのIDを取得
		    id=$(echo "$output" | grep -Eo '0/[0-9]+ RAID6.*(GB|TB).*VD0' | grep -Eo '0/[0-9]+' | cut -d'/' -f2)
		    # 条件に合致するVDのIDとサイズがあるか確認
		    if echo "$output" | grep -q '0/237 RAID6.*GB.*VD0'; then
		        echo "VD ID TBサイズが確認されました。"
		        break
		    elif [ -n "$id" ]; then
		        echo "条件に合致しないため、VDを再作成します..."
		        # 特定したVD IDを削除
		        sudo ./storcli64 /c1/v"$id" del force
		        sleep 30
		        # VDを作成（size=200GB）
		        sudo ./storcli64 /c0 add vd type=raid6 size=200GB name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		        sleep 10
		    fi
		    # 少し待機してから再試行
		    sleep 5
		done
		echo "指定条件を満たしたため、スクリプトを終了します。"
		
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(200GB)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD1作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD1(残りの容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/2_RAID_VD1.txt
		echo -e "\n\n\n\n\n"
		
		# ホットスペアの設定
		sudo ./storcli64 /c0 /e$en /s$hotspare_slot add hotsparedrive | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ホットスペア作成" "$result" "$raid_description" >> "$txt_file"
		echo "Slot 7にホットスペアが構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	3)
		# RAID type 3の設定
		drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6,252:7,252:8,252:9,252:10"
		en="252"
		hotspare_slot="11"
		
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(全容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		
		# ホットスペアの設定
		sudo ./storcli64 /c0 /e$en /s$hotspare_slot add hotsparedrive | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ホットスペア作成" "$result" "$raid_description" >> "$txt_file"
		echo "Slot 11にホットスペアが構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	4)
		# RAID type 4の設定
		drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6,252:7,252:8,252:9,252:10,252:11,252:12,252:13,252:14,252:15,252:16,252:17,252:18,252:19,252:20,252:21,252:22"
		en="252"
		hotspare_slot="23"
		
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-18s | %-6s | %-26s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(全容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		
		# ホットスペアの設定
		sudo ./storcli64 /c0 /e$en /s$hotspare_slot add hotsparedrive | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ホットスペア作成" "$result" "$raid_description" >> "$txt_file"
		echo "Slot 23にホットスペアが構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	5)
		# RAID type 5の設定	
		drive_list="252:0,252:1,252:2,252:3,252:4,252:5,252:6,252:7,252:8,252:9,252:10,252:11,252:12,252:13,252:14,252:15,252:16,252:17,252:18,252:19,252:20,252:21,252:22,252:23"	
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(全容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	6)
		# RAID type 6の設定
		drive_list="252:0-31"	
		en="252"
		hotspare_slot="32,33,34,35"
		sudo ./storcli64 /c0 add vd type=raid6 size=all name=VD0 drives=$drive_list strip=64 awb ra pdcache=on | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "VD0作成" "$result" "$raid_description" >> "$txt_file"
		echo "RAID6でVD0(全容量)が構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		
		# ホットスペアの設定
		sudo ./storcli64 /c0 /e$en /s$hotspare_slot add hotsparedrive | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		sleep 1
	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ホットスペア作成" "$result" "$raid_description" >> "$txt_file"

		echo "Slot 32,33,34,35にホットスペアが構成されました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/3_RAID_Hotspare.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	7)
		# RAID type 7の設定	

		printf "| %-30s | %-6s | %-50s |\n" "VD作成" "(手動)" "$raid_description" >> "$txt_file"
		echo "RAIDが構成されおります。LSAでユーザー指定のRAID構成を行っているか確認してください。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_RAID_VD0.txt
		echo -e "\n\n\n\n\n"
		sleep 1
		;;
	esac
	# タスク3: VDのInitialization
	case $raid_type_id in
	1)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sudo ./storcli64 /c0/v1 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
	        	# Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt"; then
		            	result="合格"
		        else
		            	result="不合格"
		        fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD1初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 5
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 120

		while true; do
	    	output=$(sudo ./storcli64 /c0 /v1 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt
		sleep 60
		;;
	2)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sudo ./storcli64 /c0/v1 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
	        	# Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt"; then
		            	result="合格"
		        else
		            	result="不合格"
		        fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD1初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 5
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 120

		while true; do
	    	output=$(sudo ./storcli64 /c0 /v1 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/5_VD1_init.txt
		sleep 60
		;;
	3)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 60
		;;
	4)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 60
		;;
	5)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 60
		;;
	6)
		sudo ./storcli64 /c0/v0 start init full force | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
	        	# Status判定
		       	 if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt"; then
		         	result="合格"
			 else
		            	result="不合格"
		         fi
			# さらに項目を追加する場合は、同様の処理を続ける
			printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "$result" "INIT Operation" >> "$txt_file"
		sleep 60
		while true; do
	    	output=$(sudo ./storcli64 /c0 /v0 show init)
	    	echo "$output"
	    	if echo "$output" | grep -q "Not in progress"; then
	        	break
	    	fi
	    	sleep 1800
		done | tee -a /home/testos/Desktop/Result/$SERIAL/Log/4_VD0_init.txt
		sleep 60
		;;
	7)
		printf "| %-30s | %-6s | %-50s |\n" "VD0初期化" "(手動)" "手動でLSAで行っているか確認してください" >> "$txt_file"
		sleep 60
		;;
	esac
		
	# タスク4: RAIDカードの設定
	# ディレクトリの移動
	cd /opt/MegaRAID/storcli
	echo "Patrol Readの間隔設定を開始します..." | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	# Patrolreadコマンドを実行する
	sudo ./storcli64 /c0 set patrolread delay=720 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	echo "Patrol Readの間隔設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	sleep 5
	echo "Patrol Readの自動開始設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	sudo ./storcli64 /c0 set patrolread mode=auto starttime=$one_month_later 00 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	echo "Patrol Readの自動開始設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt
	echo -e "\n\n\n\n\n"
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/8_Storcli_Patrolread.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "PatrolRead設定" "$result" "$one_month_later" >> "$txt_file"



	echo "Consistency Checkの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/9_Storcli_ConsistencyCheck.txt
	sudo ./storcli64 /c0 set cc=seq starttime=$ten_year_later 00 | tee -a /home/testos/Desktop/Result/$SERIAL/Log/9_Storcli_ConsistencyCheck.txt
	echo "Consistency Checkの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/9_Storcli_ConsistencyCheck.txt
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/9_Storcli_ConsistencyCheck.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "ConsistencyCheck設定" "$result" "$ten_year_later ※LSAでScheduleを Weekly ⇒ Monthly に変更すること" >> "$txt_file"
	       

	echo "Copybackの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/10_Storcli_CopyBack.txt
	sudo ./storcli64 /c0 set copyback=off type=all | tee -a /home/testos/Desktop/Result/$SERIAL/Log/10_Storcli_CopyBack.txt
	echo "Copybackの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/10_Storcli_CopyBack.txt
	sleep 5

	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/10_Storcli_CopyBack.txt"; then
		            result="合格"
		        else
		            result="不合格"
		        fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s |\n" "CopyBack設定" "$result" "Copy Back ALL" >> "$txt_file"


	echo "Battery Warningの設定を行います。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/11_Storcli_BatteryWarning.txt
	sudo ./storcli64 /c0 set batterywarning=off | tee -a /home/testos/Desktop/Result/$SERIAL/Log/11_Storcli_BatteryWarning.txt
	echo "Battery Warningの設定を完了しました。" | tee -a /home/testos/Desktop/Result/$SERIAL/Log/11_Storcli_BatteryWarning.txt


	        # Status判定
		        if grep -q "Status = Success" "/home/testos/Desktop/Result/$SERIAL/Log/11_Storcli_BatteryWarning.txt"; then
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
	case $raid_type_id in
	1|2)
		sudo ./bit_cmd_line_x64 -C /home/testos/BurnInTest_cfg/Cloudy1U.cfg
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
		disk_sdc=$(echo "${test_results[3]}")

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
		printf "| %-30s | %-6s | %-50s |\n" "disk_sdc" " " "$disk_sdc" >> "$txt_file"
		;;
	3|4|5|6|7)
		sudo ./bit_cmd_line_x64 -C /home/testos/V4/burnintest/Cloudy2U4U.cfg
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
#		disk_sdb=$(echo "${test_results[2]}")
		disk_sdc=$(echo "${test_results[3]}")

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
#		printf "| %-30s | %-6s | %-50s |\n" "disk_sdb" " " "$disk_sdb" >> "$txt_file"
		printf "| %-30s | %-6s | %-50s |\n" "disk_sdc" " " "$disk_sdc" >> "$txt_file"
		;;
	esac
	
	
	
	# タスク6: HDDアクセステスト
	# hdparmの実行と結果の保存
	case $raid_type_id in
	1|2)
		hdparm_sdb=$(sudo hdparm -ft /dev/sdb | tee -a /home/testos/Desktop/Result/$SERIAL/Log/6_hdparm_sdb.txt)

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

		hdparm_sdc=$(sudo hdparm -ft /dev/sdc | tee -a /home/testos/Desktop/Result/$SERIAL/Log/7_hdparm_sdc.txt)

		# 結果から速度を抽出（数値のみを取り出す）
		speed=$(echo "$hdparm_sdc" | grep -oP '\d+(\.\d+)?(?= MB/sec)' | head -n 1)

		# 速度が300.00 MB/sec以上かどうかのチェック
		if (( $(echo "$speed >= 300.00" | bc -l) )); then
		    result="合格"
		else
		    result="不合格"
		fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s MB/sec |\n" "VD1のHDDアクセステスト" "$result" "$speed" >> "$txt_file"

		sleep 10
		;;
	3|4|5|6|7)
		hdparm_sdc=$(sudo hdparm -ft /dev/sdc | tee -a /home/testos/Desktop/Result/$SERIAL/Log/7_hdparm_sdc.txt)

		# 結果から速度を抽出（数値のみを取り出す）
		speed=$(echo "$hdparm_sdc" | grep -oP '\d+(\.\d+)?(?= MB/sec)' | head -n 1)

		# 速度が300.00 MB/sec以上かどうかのチェック
		if (( $(echo "$speed >= 300.00" | bc -l) )); then
		    result="合格"
		else
		    result="不合格"
		fi
		# さらに項目を追加する場合は、同様の処理を続ける
		printf "| %-30s | %-6s | %-50s MB/sec |\n" "VD0のHDDアクセステスト" "$result" "$speed" >> "$txt_file"

		sleep 10
		;;
	esac	
	
	
	# タスク7: Rebootテスト
	
	# reboot_tool.conf ファイルのパス
#	conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"
	
#	count_cur=0
#	count_limit=100
	# [Command1] と [Command2] の値
#	command1="shutdown -r +2"
#	command2="NONE"
	
	# reboot_tool.conf ファイルに書き込み
#	echo "[Count Cur]" > "$conf_file"
#	echo "$count_cur" >> "$conf_file"
#	echo "[Count Limit]" >> "$conf_file"
#	echo "$count_limit" >> "$conf_file"
#	echo "[Command1]" >> "$conf_file"
#	echo "$command1" >> "$conf_file"
#	echo "[Command2]" >> "$conf_file"
#	echo "$command2" >> "$conf_file"
	

	# カウントを1増やす
	((count++))
	# 更新したカウントをstatus.txtに書き込む
	echo "$count" > "$STATUS_FILE"
	
#	/usr/sbin/reboot_tool
	
	sleep 130
	
	
fi



	
# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=14
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
#	conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"

	# [Count Cur]と[Count Limit]の値を取得
#	COUNT_CUR=$(grep -A 1 "\[Count Cur\]" "$conf_file" | tail -n 1)
#	COUNT_LIMIT=$(grep -A 1 "\[Count Limit\]" "$conf_file" | tail -n 1)

	# 合否判定
#	if [ "$COUNT_CUR" -gt "$COUNT_LIMIT" ]; then
#	    result="合格"
#	else
#	    result="不合格"
#	fi

	# さらに項目を追加する場合は、同様の処理を続ける
#	printf "| %-30s | %-6s | %-50s 回 |\n" "Rebootテスト" "$result" "$COUNT_LIMIT" >> "$txt_file"


	# 最後にテーブルの終わりを出力したい場合に使う（必要に応じて）
	 echo -e "|---------------------------|----|-----------------------------------------------|" >> "$txt_file"


	#完了通知
	python3 /home/testos/shell/Product_shell/cloudy_finish.py
	# status.txtに書き込む
	echo "" > "$STATUS_FILE"
	exit 1

fi


#!/bin/bash

sudo sleep 2

# status.txtのパス
STATUS_FILE="/home/testos/Status/status.txt"

# status.txtが存在しなければファイルを作成し、初期カウントを0とする
if [ ! -f "$STATUS_FILE" ]; then
    echo "27" > "$STATUS_FILE"
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
	    echo "27" > "$STATUS_FILE"
	    zenity --info --text="Statusフォルダが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="拒否しました。"
	    exit 1
	fi
	
	rm -rf /home/testos/Status/*
	echo "27" > "$STATUS_FILE"
	chmod 777 "$STATUS_FILE"
	# status.txtからカウントを読み込む
	count=$(cat "$STATUS_FILE")
fi



# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=27
if [ "$count" -eq "$TARGET_COUNT" ]; then
	sudo sleep 3
	# テストをはじめから開始するかユーザーに尋ねる
	if zenity --question --title="statusファイルの初期化確認" --text="TXPMedicalの製品テストをはじめから始めますか？"; then
	    # ユーザーが「はい」を選択した場合、ファイルを初期値に戻す
	    echo "27" > "$STATUS_FILE"
	    zenity --info --text="ファイルが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="テストを拒否しました。"
	    exit 1
	fi
fi


# 特定のカウント値で特定のコマンドを実行する
TARGET_COUNT=27
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第27群コマンドを実行します。"


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

	
	figlet "TXPMedical TEST START"

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
TARGET_COUNT=28
if [ "$count" -eq "$TARGET_COUNT" ]; then
    echo "カウントが ${TARGET_COUNT} に達しました。第28群コマンドを実行します。"
    
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


	# タスク1: BurnInTest(Kite SSD)
	echo "BurnInTest(Kite SSD)を開始します。"
	sleep 5
	cd /home/testos/V4/burnintest/64bit
	sudo ./bit_cmd_line_x64 -C /home/testos/V4/burnintest/TXPMedical_SSD.cfg
	sleep 3
	echo "BurnInTest(Kite SSD)を完了しました。" 
	sleep 3
	
	sudo mv /home/testos/Desktop/Result/BiTLog2.log /home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_SSDonly_Result.log 
	log_file="/home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_SSDonly_Result.log"

	# テスト結果を格納するための配列
	declare -a test_results

	# 結果セクションを抽出
	results_section=$(grep -E 'Disk: /dev/sda ' "$log_file" )

	# 各行を変数に格納
	while IFS= read -r line; do
	    test_results+=("$line")
	done <<< "$results_section"

	# 各テスト結果を個別の変数に保存
#	cpu_maths=$(echo "${test_results[0]}")
#	memory_ram=$(echo "${test_results[1]}")
	disk_sda=$(echo "${test_results[0]}")


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
	printf "| %-30s | %-6s | %-50s |\n" "BurnInTest" "$result" "BurnInTest_SSDonly_Result" >> "$txt_file"
#	printf "| %-30s | %-6s | %-50s |\n" "cpu_maths" " " "$cpu_maths" >> "$txt_file"
#	printf "| %-30s | %-6s | %-50s |\n" "memory_ram" " " "$memory_ram" >> "$txt_file"
	printf "| %-30s | %-6s | %-50s |\n" "disk_sda" " " "$disk_sda" >> "$txt_file"

	
	
	# タスク2: BurnInTest
	echo "BurnInTestを開始します。"
	sleep 5
	cd /home/testos/V4/burnintest/64bit
	sudo ./bit_cmd_line_x64 -C /home/testos/BurnInTest_cfg/TXPMedical.cfg
	sleep 3
	echo "BurnInTestを完了しました。" 
	sleep 3
	
	sudo mv /home/testos/Desktop/Result/BiTLog2.log /home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_Result.log 
	log_file="/home/testos/Desktop/Result/$SERIAL/Log/BurnInTest_Result.log"

	# テスト結果を格納するための配列
	declare -a test_results

	# 結果セクションを抽出
	results_section=$(grep -E 'CPU - Maths|Memory \(RAM\)|Disk: /dev/sdb ' "$log_file" )

	# 各行を変数に格納
	while IFS= read -r line; do
	    test_results+=("$line")
	done <<< "$results_section"

	# 各テスト結果を個別の変数に保存
	cpu_maths=$(echo "${test_results[0]}")
	memory_ram=$(echo "${test_results[1]}")
	disk_sdb=$(echo "${test_results[2]}")


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

	
		


	
	# タスク3: HDDアクセステスト
	# hdparmの実行と結果の保存
	hdparm_sda=$(sudo hdparm -ft /dev/sda | tee -a /home/testos/Desktop/Result/$SERIAL/Log/1_hdparm_sda.txt)

	# 結果から速度を抽出（数値のみを取り出す）
	speed=$(echo "$hdparm_sda" | grep -oP '\d+(\.\d+)?(?= MB/sec)' | head -n 1)

	# 速度が200.00 MB/sec以上かどうかのチェック
	if (( $(echo "$speed >= 200.00" | bc -l) )); then
	    result="合格"
	else
	    result="不合格"
	fi
	# さらに項目を追加する場合は、同様の処理を続ける
	printf "| %-30s | %-6s | %-50s MB/sec |\n" "SSDアクセステスト" "$result" "$speed" >> "$txt_file"


	sleep 10
	
	
	
	# タスク4: Rebootテスト
	
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
TARGET_COUNT=29
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
	 echo -e "|---------------------------|----|-----------------------------------------------|" >> "$txt_file"


	#完了通知
	python3 /home/testos/shell/Product_shell/TXPMedical_finish.py
	# status.txtに書き込む
	echo "" > "$STATUS_FILE"
	exit 1

fi


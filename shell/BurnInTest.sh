MODE=$(zenity --list \
    --title="BurnInTest 起動モード選択" \
    --column="起動モード" \
    "GUIで実行" \
    "エージング24時間" \
    "エージング24時間（Cloudy 1U）")

[ $? -ne 0 ] && exit 1

case "$MODE" in
    "GUIで実行")
        cd /home/testos/V4/burnintest
        qterminal -e "bash -c 'sudo ./burnintest.sh'"
        ;;


    "エージング24時間")
        cd /home/testos/V4/burnintest/64bit
        sudo ./bit_cmd_line_x64 -C /home/testos/BurnInTest_cfg/24h.cfg
        sleep 3
        echo "BurnInTestが24時間を完了しました。"
        sleep 3

        sudo mv /home/testos/V4/burnintest/logs/BiTLog2.log /home/testos/V4/burnintest/logs/BurnInTest_24h_Result.log
        log_file="/home/testos/V4/burnintest/logs/BurnInTest_24h_Result.log"

        # テスト結果を格納するための配列
        declare -a test_results

        # 結果セクションを抽出
        results_section=$(grep -E 'Disk: /dev/sda ' "$log_file" )

        # 各行を変数に格納
        while IFS= read -r line; do
	        test_results+=("$line")
        done <<< "$results_section"


        # 各テスト結果を個別の変数に保存
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

        # ===== 判定処理 =====
        if [[ "$result" == "合格"  ]]; then
            # 合格の場合
            zenity --info \
            --title="システム負荷テスト結果" \
            --width=400 --height=200 \
            --ok-label="閉じる" \
            --text="<span font_desc='Sans 40' foreground='black' background='#00FF00'><b>PASSED</b></span>" \
            --no-wrap
        else
            # 不合格の場合
            zenity --error \
            --title="システム負荷テスト結果" \
            --width=400 --height=200 \
            --ok-label="閉じる" \
            --text="<span font_desc='Sans 40' foreground='black' background='#FF0000'><b>FAILED</b></span>" \
            --no-wrap
        fi

        zenity --info --text="システム負荷テストが完了しました。\n「FAILED」の場合は/home/testos/V4/burnintest/logsの中を参照してください。" --width=600 --height=200
        ;;


    "エージング24時間（Cloudy 1U）")
        # sudo fdisk -l を実行し、ディスク型式がMRから始まるデバイスの/dev/sd〇を特定
        declare -A mr_disks
        current_dev=""
        index=1
        while read -r line; do
        if [[ $line =~ ^ディスク\ (/dev/sd[a-z]+): ]]; then
            current_dev=${BASH_REMATCH[1]}
        elif [[ $line =~ Disk\ model:\ (MR|SAS) ]]; then
            if [[ -n $current_dev ]]; then
                mr_disks[$current_dev]="MR Disk Found"
                eval "Disk_fdisk${index}=$current_dev"
                ((index++))
            fi
        fi
        done < <(sudo fdisk -l)

        # アルファベット順で最も若いDisk_fdiskを取得
        smallest_disk=$(printf "%s\n" ${!mr_disks[@]} | sort | head -n 1)

        # /dev/sdX → sdX
        disk_name=$(basename "$smallest_disk")

        # cfgファイル名生成
        CFG_FILE="${disk_name}_1440min.cfg"

        echo "使用ディスク: $smallest_disk"
        echo "選択CFG: $CFG_FILE"

        CFG_DIR="/home/testos/BurnInTest_cfg"

        if [ ! -f "$CFG_DIR/$CFG_FILE" ]; then
            echo "ERROR: CFGファイルが存在しません: $CFG_DIR/$CFG_FILE"
            exit 1
        fi

        cd /home/testos/V4/burnintest/64bit
        sudo ./bit_cmd_line_x64 -C "$CFG_DIR/$CFG_FILE"
        sleep 3
        echo "BurnInTestが24時間を完了しました。"
        sleep 3

        sudo mv /home/testos/V4/burnintest/logs/BiTLog2.log /home/testos/V4/burnintest/logs/BurnInTest_24h(CL1)_Result.log
        log_file="/home/testos/V4/burnintest/logs/BurnInTest_24h(CL1)_Result.log"

        # テスト結果を格納するための配列
        declare -a test_results

        # 結果セクションを抽出
        results_section=$(grep -E 'Disk: /dev/sda ' "$log_file" )

        # 各行を変数に格納
        while IFS= read -r line; do
	        test_results+=("$line")
        done <<< "$results_section"


        # 各テスト結果を個別の変数に保存
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

        # ===== 判定処理 =====
        if [[ "$result" == "合格"  ]]; then
            # 合格の場合
            zenity --info \
            --title="システム負荷テスト結果" \
            --width=400 --height=200 \
            --ok-label="閉じる" \
            --text="<span font_desc='Sans 40' foreground='black' background='#00FF00'><b>PASSED</b></span>" \
            --no-wrap
        else
            # 不合格の場合
            zenity --error \
            --title="システム負荷テスト結果" \
            --width=400 --height=200 \
            --ok-label="閉じる" \
            --text="<span font_desc='Sans 40' foreground='black' background='#FF0000'><b>FAILED</b></span>" \
            --no-wrap
        fi

        zenity --info --text="システム負荷テストが完了しました。\n「FAILED」の場合は/home/testos/V4/burnintest/logsの中を参照してください。" --width=600 --height=200
        ;;
esac


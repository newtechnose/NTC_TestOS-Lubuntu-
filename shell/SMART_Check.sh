#!/bin/bash

cd /opt/MegaRAID/storcli/

# storcli64コマンドを実行し、DIDのリストを取得
did_list=( $(sudo ./storcli64 /c0 /eall /sall show J | jq -r '."Controllers"[0]."Response Data"."Drive Information"[]["DID"]') )

# 取得したDIDの値をSlot0_DID, Slot1_DID, ... の変数に代入
i=0
for did in "${did_list[@]}"; do
    eval "Slot${i}_DID=$did"
    ((i++))
done

# sudo fdisk -l を実行し、ディスク型式がMRから始まるデバイスの/dev/sd〇を特定
declare -A mr_disks
current_dev=""
index=1
while read -r line; do
    if [[ $line =~ ^ディスク\ (/dev/sd[a-z]+): ]]; then
        current_dev=${BASH_REMATCH[1]}
    elif [[ $line =~ ディスク型式:\ (MR|SAS) ]]; then
        if [[ -n $current_dev ]]; then
            mr_disks[$current_dev]="MR Disk Found"
            eval "Disk_fdisk${index}=$current_dev"
            ((index++))
        fi
    fi
done < <(sudo fdisk -l)

# アルファベット順で最も若いDisk_fdiskを取得
smallest_disk=$(printf "%s\n" ${!mr_disks[@]} | sort | head -n 1)

# Zenityを使用してフォルダ名を取得
dir_name=$(zenity --entry --title="フォルダ名入力" --text="保存するフォルダ名を入力してください")
if [[ -z "$dir_name" ]]; then
    echo "フォルダ名が入力されませんでした。処理を中断します。"
    exit 1
fi

# フォルダ作成
data_dir="/home/testos/SMART_inport/$dir_name"
mkdir -p "$data_dir"

echo "Executing smartctl for each Slot_DID with the first Disk_fdisk and saving output to $data_dir:"
for ((j=0; j<i; j++)); do
    eval "current_did=\$Slot${j}_DID"
    if [[ -n "$current_did" ]]; then
        output_file="$data_dir/SMART_Slot${j}_DID${current_did}.txt"
        sudo smartctl -a -d megaraid,$current_did $smallest_disk > "$output_file"
    fi
done

echo "SMART data saved in $data_dir"

# 各SMARTデータファイルを解析し、Device Modelを判定
wd_count=0
seagate_count=0
phison_count=0
for file in "$data_dir"/*.txt; do
    if [[ -f "$file" ]]; then
        device_model=$(grep -i "Device Model:" "$file" | awk -F": " '{print $2}')
        if [[ "$device_model" =~ "WDC  WUH722020BLE6L4" ]]; then
            ((wd_count++))
        elif [[ "$device_model" =~ "ST2000NM000B"|"ST4000NM024B"|"ST8000NM017B"|"ST16000NM000J"|"ST20000NM004E" ]]; then
            ((seagate_count++))
        elif [[ "$device_model" =~ "PHSSS01T9ECTJ-IA-NE1100" ]]; then
            ((phison_count++)) 
        fi
    fi
done

# Zenity の表示（1回のみ）
if [[ $wd_count -gt 0 && $seagate_count -eq 0 && $phison_count -eq 0 ]]; then
    zenity --info --title="S.M.A.R.T 判定" --text="WD HDD ${wd_count}本でS.M.A.R.T情報を判定します"
elif [[ $seagate_count -gt 0 && $wd_count -eq 0 && $phison_count -eq 0 ]]; then
    zenity --info --title="S.M.A.R.T 判定" --text="Seagate HDD ${seagate_count}本でS.M.A.R.T情報を判定します"
elif [[ $phison_count -gt 0 && $seagate_count -eq 0 && $wd_count -eq 0 ]]; then
    zenity --info --title="S.M.A.R.T 判定" --text="phison SSD ${phison_count}本でS.M.A.R.T情報を判定します"
else
    zenity --error --title="エラー" --text="対応していないHDD・SSDモデルが含まれています。"
    exit 1
fi

# Seagate HDD の S.M.A.R.T 判定
RESULT_FILE="$data_dir/result.txt"
> "$RESULT_FILE"

ALL_PASS=true

for file in "$data_dir"/*.txt; do
    if [[ -f "$file" ]]; then
        device_model=$(grep -i "Device Model:" "$file" | awk -F": " '{print $2}')
        if [[ "$device_model" =~ "ST2000NM000B"|"ST4000NM024B"|"ST8000NM017B"|"ST16000NM000J"|"ST20000NM004E" ]]; then
        SLOT_ID=$(echo "$file" | sed -E 's/.*SMART_Slot([0-9]+)_DID([0-9]+).txt/\1/')
        DID_ID=$(echo "$file" | sed -E 's/.*SMART_Slot([0-9]+)_DID([0-9]+).txt/\2/')

        echo "Checking Slot${SLOT_ID} DID${DID_ID}..." | tee -a "$RESULT_FILE"

        # 各SMART値を数値として取得（10進数指定）
        WORST_1=$((10#$(awk '$1 == "1" {print $5}' "$file")))
        WORST_5=$((10#$(awk '$1 == "5" {print $5}' "$file")))
        RAW_5=$((10#$(awk '$1 == "5" {print $10}' "$file")))
        WORST_7=$((10#$(awk '$1 == "7" {print $5}' "$file")))
        WORST_10=$((10#$(awk '$1 == "10" {print $5}' "$file")))
        RAW_10=$((10#$(awk '$1 == "10" {print $10}' "$file")))
        WORST_18=$((10#$(awk '$1 == "18" {print $5}' "$file")))
        WORST_187=$((10#$(awk '$1 == "187" {print $5}' "$file")))
        RAW_187=$((10#$(awk '$1 == "187" {print $10}' "$file")))
        VALUE_188=$((10#$(awk '$1 == "188" {print $4}' "$file")))
        WORST_190=$((10#$(awk '$1 == "190" {print $5}' "$file")))
        WORST_197=$((10#$(awk '$1 == "197" {print $5}' "$file")))
        RAW_197=$((10#$(awk '$1 == "197" {print $10}' "$file")))
        WORST_198=$((10#$(awk '$1 == "198" {print $5}' "$file")))
        RAW_198=$((10#$(awk '$1 == "198" {print $10}' "$file")))

        # 判定条件
        if [[ "$WORST_1" -ge 47 ]] &&
           [[ "$WORST_5" -eq 100 && "$RAW_5" -eq 0 ]] &&
           [[ "$WORST_7" -ge 47 ]] &&
           [[ "$WORST_10" -eq 100 && "$RAW_10" -eq 0 ]] &&
           [[ "$WORST_18" -eq 100 ]] &&
           [[ "$WORST_187" -eq 100 && "$RAW_187" -eq 0 ]] &&
           [[ "$VALUE_188" -eq 100 ]] &&
           [[ "$WORST_190" -ge 41 ]] &&
           [[ "$WORST_197" -eq 100 && "$RAW_197" -eq 0 ]] &&
           [[ "$WORST_198" -eq 100 && "$RAW_198" -eq 0 ]]; then

            echo "Slot${SLOT_ID} DID${DID_ID}: 合格" | tee -a "$RESULT_FILE"
        else
            echo "Slot${SLOT_ID} DID${DID_ID}: 不合格" | tee -a "$RESULT_FILE"
            ALL_PASS=false
        fi
        fi
    fi
done

# WD HDD の S.M.A.R.T 判定
for file in "$data_dir"/*.txt; do
    if [[ -f "$file" ]]; then
        device_model=$(grep -i "Device Model:" "$file" | awk -F": " '{print $2}')
        if [[ "$device_model" =~ "WDC  WUH722020BLE6L4" ]]; then
            echo "Checking WD HDD: $device_model..." | tee -a "$RESULT_FILE"

            # 各SMART値を数値として取得（10進数指定）
            WORST_1=$((10#$(awk '$1 == "1" {print $5}' "$file")))
            WORST_5=$((10#$(awk '$1 == "5" {print $5}' "$file")))
            RAW_5=$((10#$(awk '$1 == "5" {print $10}' "$file")))
            WORST_7=$((10#$(awk '$1 == "7" {print $5}' "$file")))
            WORST_10=$((10#$(awk '$1 == "10" {print $5}' "$file")))
            RAW_10=$((10#$(awk '$1 == "10" {print $10}' "$file")))
            WORST_22=$((10#$(awk '$1 == "22" {print $5}' "$file")))
            WORST_196=$((10#$(awk '$1 == "196" {print $5}' "$file")))
            RAW_196=$((10#$(awk '$1 == "196" {print $10}' "$file")))
            WORST_197=$((10#$(awk '$1 == "197" {print $5}' "$file")))
            RAW_197=$((10#$(awk '$1 == "197" {print $10}' "$file")))

            # 判定条件（WD HDD）
            if [[ "$WORST_1" -eq 100 ]] &&
               [[ "$WORST_5" -eq 100 && "$RAW_5" -eq 0 ]] &&
               [[ "$WORST_7" -eq 100 && "$RAW_7" -eq 0 ]] &&
               [[ "$WORST_10" -eq 100 && "$RAW_10" -eq 0 ]] &&
               [[ "$WORST_22" -eq 100 ]] &&
               [[ "$WORST_196" -eq 100 && "$RAW_196" -eq 0 ]] &&
               [[ "$WORST_197" -eq 100 && "$RAW_197" -eq 0 ]]; then
                echo "WD HDD: 合格" | tee -a "$RESULT_FILE"
            else
                echo "WD HDD: 不合格" | tee -a "$RESULT_FILE"
                ALL_PASS=false
            fi
        fi
    fi
done

# phison SSD の S.M.A.R.T 判定（Slot/DID付き）
for file in "$data_dir"/*.txt; do
    if [[ -f "$file" ]]; then
        device_model=$(grep -i "Device Model:" "$file" | awk -F": " '{print $2}')
        if [[ "$device_model" =~ "PHSSS01T9ECTJ-IA-NE1100" ]]; then
            # ファイル名から Slot と DID を取得
            SLOT_ID=$(echo "$file" | sed -E 's/.*SMART_Slot([0-9]+)_DID([0-9]+).txt/\1/')
            DID_ID=$(echo "$file" | sed -E 's/.*SMART_Slot([0-9]+)_DID([0-9]+).txt/\2/')

            echo "Checking Slot${SLOT_ID} DID${DID_ID}..." | tee -a "$RESULT_FILE"

            # SMART値の取得
            VALUE_1=$(awk '$1=="1" && $2=="Raw_Read_Error_Rate"{print $4}' "$file")
            WORST_1=$(awk '$1=="1" && $2=="Raw_Read_Error_Rate"{print $5}' "$file")
            RAW_1=$(awk '$1=="1" && $2=="Raw_Read_Error_Rate"{print $NF}' "$file")

            RAW_168=$(awk '$1=="168"{print $NF}' "$file")

            VALUE_170=$(awk '$1=="170"{print $4}' "$file")
            WORST_170=$(awk '$1=="170"{print $5}' "$file")

            VALUE_218=$(awk '$1=="218"{print $4}' "$file")
            WORST_218=$(awk '$1=="218"{print $5}' "$file")

            RAW_231=$(awk '$1=="231"{print $NF}' "$file")

            # 判定条件
            if [[ "$VALUE_1" -eq 100 && "$WORST_1" -eq 100 && "$RAW_1" -eq 0 ]] &&
               [[ "$RAW_168" -eq 0 ]] &&
               [[ "$VALUE_170" -eq 100 && "$WORST_170" -eq 100 ]] &&
               [[ "$VALUE_218" -eq 100 && "$WORST_218" -eq 100 ]] &&
               [[ "$RAW_231" -ge 99 ]]; then
                echo "Slot${SLOT_ID} DID${DID_ID}: 合格" | tee -a "$RESULT_FILE"
            else
                echo "Slot${SLOT_ID} DID${DID_ID}: 不合格" | tee -a "$RESULT_FILE"
                ALL_PASS=false
            fi
        fi
    fi
done




# 判定結果
if [[ "$ALL_PASS" == true ]]; then
    zenity --info --title="S.M.A.R.T 判定結果" --text="すべてのディスクは合格しました。"
else
    zenity --error --title="S.M.A.R.T 判定結果" --text="いくつかのディスクが不合格でした。"
fi


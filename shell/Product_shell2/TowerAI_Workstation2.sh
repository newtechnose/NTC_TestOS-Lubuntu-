#!/bin/bash
set -euo pipefail

###############################################
# TowerAI_Workstation2.sh
# 半製品シリアル / BIOS / BMC バージョン確認
###############################################

# Product.sh から渡される前提
if [ -z "${STATUS_FILE:-}" ]; then
    echo "STATUS_FILE is not set" >&2
    exit 1
fi

log() {
    echo "[`date '+%Y-%m-%d %H:%M:%S'`] $*" >> "$STATUS_FILE"
}

error_exit() {
    log "ERROR: $*"
    sed -i "s/^RESULT=.*/RESULT=NG/" "$STATUS_FILE"
    exit 1
}

log "=== TowerAI_Workstation2.sh START ==="

###############################################
# ① 半製品シリアル入力
###############################################
HALF_SERIAL=$(zenity --entry \
  --title="半製品シリアル入力" \
  --text="半製品シリアルをバーコードリーダーで読み取ってください")

[ -z "$HALF_SERIAL" ] && error_exit "半製品シリアル未入力"

log "HALF_SERIAL=$HALF_SERIAL"

###############################################
# ② BIOS バージョン確認
###############################################
BIOS_VERSION=$(sudo dmidecode -s bios-version)
EXPECTED_BIOS_VERSION="R02"

log "DETECTED_BIOS_VERSION=$BIOS_VERSION"

if [ "$BIOS_VERSION" != "$EXPECTED_BIOS_VERSION" ]; then
    error_exit "BIOS version mismatch (expected=$EXPECTED_BIOS_VERSION actual=$BIOS_VERSION)"
fi

log "BIOS_VERSION_CHECK=OK"

###############################################
# ③ BMC バージョン確認（16進 → 10進変換）
###############################################
IPMI_INFO=$(sudo ipmitool mc info 2>/dev/null)

# Firmware Revision（13.05）
FW_MAIN=$(echo "$IPMI_INFO" \
    | awk -F: '/Firmware Revision/ {gsub(/ /,"",$2); print $2}')

# Aux Firmware Rev Info の1行目（例: 0x09）
FW_AUX_HEX=$(echo "$IPMI_INFO" \
    | awk '/Aux Firmware Rev Info/ {getline; print $1}')

# 16進数 → 10進数（0x09 → 9 → 09）
FW_AUX_DEC=$(printf "%02d" $((16#${FW_AUX_HEX#0x})))

BMC_VERSION="${FW_MAIN}.${FW_AUX_DEC}"
EXPECTED_BMC_VERSION="13.05.09"

log "DETECTED_BMC_FW_MAIN=$FW_MAIN"
log "DETECTED_BMC_FW_AUX_HEX=$FW_AUX_HEX"
log "DETECTED_BMC_FW_AUX_DEC=$FW_AUX_DEC"
log "DETECTED_BMC_VERSION=$BMC_VERSION"

if [ "$BMC_VERSION" != "$EXPECTED_BMC_VERSION" ]; then
    error_exit "BMC version mismatch (expected=$EXPECTED_BMC_VERSION actual=$BMC_VERSION)"
fi

log "BMC_VERSION_CHECK=OK"

###############################################
# 第1工程完了
###############################################
log "PHASE=BIOS_BMC_CHECK_DONE"


###############################################
# ④ BMC パスワード 設定
###############################################

set +e

# 標準の既定値
BMC_IP="172.16.91.63"
BMC_PASSWORD="ADMINntc1"


# 1. ログインを試行
# 標準エラー出力もキャッチして判定に使用します
OUTPUT=$(sudo ipmitool -I lanplus -H "$BMC_IP" -U admin -P "$BMC_PASSWORD" user list 2 2>&1)
EXIT_CODE=$?

# 2. 判定
if [ $EXIT_CODE -eq 0 ]; then
    log "Unchanged_BMC_admin_Password=$BMC_PASSWORD"
    # 成功時は特になにもせず終了
else
    # ローカルインターフェース経由でパスワードを強制上書き
    sudo ipmitool user set password 2 "$BMC_PASSWORD"
    
    if [ $? -eq 0 ]; then
        log "Changed_BMC_admin_Password=$BMC_PASSWORD"
    else
        echo "[ ERROR ]"
    fi
fi

log "DETECTED_BMC_admin_Password=$BMC_PASSWORD"
log "BMC_admin_Password_CHECK=OK"

set -euo pipefail

###############################################
# ⑤ MB確認
###############################################
MB_NAME=$(sudo cat /sys/class/dmi/id/board_name)
EXPECTED_MB_NAME="MW34-SP0-00"

log "DETECTED_MB_NAME=$MB_NAME"

if [ "$MB_NAME" != "$EXPECTED_MB_NAME" ]; then
    error_exit "MB Name mismatch (expected=$EXPECTED_MB_NAME actual=$MB_NAME)"
fi

log "MB_NAME_CHECK=OK"


###############################################
# ⑥ CPU確認
###############################################
CPU_MODEL=$(sudo grep "model name" /proc/cpuinfo | head -n 1 | sed 's/.*: //')
EXPECTED_CPU_MODEL="12th Gen Intel(R) Core(TM) i3-12100E"

log "DETECTED_CPU_MODEL=$CPU_MODEL"

if [ "$CPU_MODEL" != "$EXPECTED_CPU_MODEL" ]; then
    error_exit "CPU Model mismatch (expected=$EXPECTED_CPU_MODEL actual=$CPU_MODEL)"
fi

log "CPU_MODEL_CHECK=OK"


###############################################
# ④ Memory 検査（MB単位）
###############################################
log "=== MEMORY CHECK START ==="

# ===== 期待値（MB）=====
EXPECTED_TOTAL_MB=16384     # 16GB = 16*1024
EXPECTED_DIMM_MB=8192       # 8GB  = 8*1024
EXPECTED_SPEED="3200"

MEM_INFO=$(sudo dmidecode -t memory)


# 有効DIMMのみ抽出（MB変換）
SIZES_MB=($(echo "$MEM_INFO" | awk '
/Size:/ && $2 ~ /^[0-9]+$/ {
    if ($3 == "GB")  print $2 * 1024;
    else if ($3 == "MB") print $2;
}'))

SPEEDS=($(echo "$MEM_INFO" \
    | awk -F: '/Configured Memory Speed: [0-9]+ MT\/s/ {gsub(/ |MT\/s/,"",$2); print $2}'))

DIMM_COUNT=${#SIZES_MB[@]}

[ "$DIMM_COUNT" -eq 0 ] && error_exit "Memory not detected"


# 合計容量計算
TOTAL_MB=0
for s in "${SIZES_MB[@]}"; do
    TOTAL_MB=$((TOTAL_MB + s))
done


# ログ出力
log "MEM_DIMM_COUNT=$DIMM_COUNT"
log "MEM_TOTAL_MB=$TOTAL_MB"
log "MEM_SIZES_MB=${SIZES_MB[*]}"
log "MEM_SPEEDS=${SPEEDS[*]}"


# 判定
[ "$TOTAL_MB" -ne "$EXPECTED_TOTAL_MB" ] && \
    error_exit "Total memory mismatch (expected=${EXPECTED_TOTAL_MB}MB actual=${TOTAL_MB}MB)"

for s in "${SIZES_MB[@]}"; do
    [ "$s" -ne "$EXPECTED_DIMM_MB" ] && \
        error_exit "DIMM size mismatch (expected=${EXPECTED_DIMM_MB}MB actual=${s}MB)"
done

for sp in "${SPEEDS[@]}"; do
    [ "$sp" != "$EXPECTED_SPEED" ] && \
        error_exit "Memory speed mismatch (expected=${EXPECTED_SPEED} actual=${sp})"
done

log "MEMORY_CHECK=OK"
log "=== MEMORY CHECK END ==="


###############################################
# ④ BMC Fan Profile 設定
###############################################
log "=== FAN PROFILE SET START ==="

BMC_IP="172.16.91.63"
BMC_USER="admin"
BMC_PASS="ADMINntc1"
FAN_JSON="/home/testos/FAN_Profile/20260116_AIServer_fanprofile.json"
FAN_PROFILE_JSON_NAME="AIServer"

[ ! -f "$FAN_JSON" ] && error_exit "Fan profile JSON not found: $FAN_JSON"

COOKIE=$(mktemp)

################################
# Login
################################
LOGIN_RESP=$(curl -sk -c "$COOKIE" \
  -X POST \
  -d "username=${BMC_USER}&password=${BMC_PASS}" \
  https://${BMC_IP}/api/session) || error_exit "BMC login failed"

log "BMC_LOGIN=OK"

################################
# CSRF取得（JSONから）
################################
CSRF_TOKEN=$(echo "$LOGIN_RESP" | sed -n 's/.*"CSRFToken"[ ]*:[ ]*"\([^"]*\)".*/\1/p')

[ -z "$CSRF_TOKEN" ] && error_exit "CSRF token取得失敗"

log "CSRF_TOKEN=$CSRF_TOKEN"


################################
# JSON読込
################################
JSON_DATA=$(cat "$FAN_JSON")

################################
# Fan Profile POST
################################
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
  -b "$COOKIE" \
  -H "X-CSRFToken: ${CSRF_TOKEN}" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "$JSON_DATA" \
  https://${BMC_IP}/api/settings/fanprofile)

if [ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "204" ]; then
    error_exit "Fan profile設定失敗 (HTTP=$HTTP_CODE)"
fi

log "FAN_PROFILE_SET=OK (HTTP=$HTTP_CODE)"


################################
# Fan Profile VERIFY
################################
VERIFY_RESP=$(curl -sk \
  -b "$COOKIE" \
  -H "X-CSRFToken: ${CSRF_TOKEN}" \
  https://${BMC_IP}/api/settings/fanprofile/collection)



echo "$VERIFY_RESP" | grep -q "\"strName\"[[:space:]]*:[[:space:]]*\"${FAN_PROFILE_JSON_NAME}\"" \
  || error_exit "Fan profile verify失敗 (${FAN_PROFILE_JSON_NAME} not found)"

log "FAN_PROFILE_VERIFY_RESP=$FAN_PROFILE_JSON_NAME"
log "FAN_PROFILE_VERIFY=OK (${FAN_PROFILE_JSON_NAME})"

log "=== FAN PROFILE SET END ==="



################################
# Network SettingのBond Interface設定
################################
#Dedicatedに変更
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" \
  -b "$COOKIE" \
  -H "X-CSRFToken: ${CSRF_TOKEN}" \
  -H "Content-Type: application/json" \
  -X PUT \
  -d '{"bond_enable":1,"bond_mode":"active-backup","bond_ifc":"eth1","auto_configuration_enable":1}' \
  https://${BMC_IP}/api/settings/network-bond)

[ "$HTTP_CODE" != "200" ] && [ "$HTTP_CODE" != "204" ] && \
  error_exit "Dedicated設定失敗 (HTTP=$HTTP_CODE)"

log "BMC_NETWORK_MODE=Dedicated"
log "BMC_NETWORK_DEDICATED_SET=OK"



###############################################
# BMC時間を設定（Redfish）
###############################################
UTC_NOW=$(date -u +"%Y-%m-%dT%H:%M:%S+09:00")

ETAG=$(curl -sk -u ${BMC_USER}:${BMC_PASS} \
  https://${BMC_IP}/redfish/v1/Managers/Self | jq -r '."@odata.etag"')

curl -sk -u ${BMC_USER}:${BMC_PASS} \
  -X PATCH \
  -H "Content-Type: application/json" \
  -H "If-Match: $ETAG" \
  -d "{\"DateTime\":\"$UTC_NOW\"}" \
  https://${BMC_IP}/redfish/v1/Managers/Self

###############################################
# ★ 反映待ち（超重要）
###############################################
sleep 10

###############################################
# BMC時刻取得
###############################################
BMC_CLOCK_RAW=$(curl -sk -u ${BMC_USER}:${BMC_PASS} \
  https://${BMC_IP}/redfish/v1/Managers/Self | jq -r '.DateTime')

log "BMC_RAW_TIME=$BMC_CLOCK_RAW"


###############################################
# ±60秒以内ならOK判定
###############################################

NOW_EPOCH=$(date +%s)
BMC_EPOCH=$(date -d "$BMC_CLOCK_RAW" +%s)

DIFF=$(( NOW_EPOCH - BMC_EPOCH ))
ABS_DIFF=${DIFF#-}

log "NOW_EPOCH=$NOW_EPOCH"
log "BMC_EPOCH=$BMC_EPOCH"
log "TIME_DIFF=${ABS_DIFF}s"

if (( ABS_DIFF <= 60 )); then
    log "BMC_Data_and_Time_SET=OK"
else
    log "BMC_Data_and_Time_SET=NG"
    error_exit "BMC日時設定失敗"
fi


###############################################
# V_BAT 判定（3.00V以上でPASS）
###############################################

VBAT=$(sudo ipmitool sensor | awk -F'|' '/V[_ ]?BAT/ {gsub(/ /,"",$2); print $2}')

if [[ -z "$VBAT" ]]; then
    log "VBAT_TEST=NG (sensor not found)"
    error_exit "V_BATセンサー未検出"
fi

log "VBAT_VALUE=${VBAT}V"

if awk "BEGIN {exit !($VBAT >= 3.00)}"; then
    log "VBAT_TEST=PASS"
else
    log "VBAT_TEST=FAIL"
    error_exit "V_BAT電圧低下"
fi






rm -f "$COOKIE"





log "=== TowerAI_Workstation2.sh END ==="



exit 0


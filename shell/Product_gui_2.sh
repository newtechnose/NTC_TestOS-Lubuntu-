#!/bin/bash
set -euo pipefail


###############################################
# Product.sh（reboot耐性版）
###############################################

STATUS_DIR="/home/testos/Status"
STATUS_FILE="/home/testos/Status/status.txt"

###############################################
# ① 自動テスト開始確認
###############################################
zenity --question \
  --title="自動テストツール" \
  --text="自動テストツールを開始しますか？"

[ $? -ne 0 ] && exit 0


###############################################
# ② 前回ログ削除の確認
###############################################
if zenity --question --title="statusファイルの初期化確認" --text="前回の製品テストシステムログを削除します。よろしいでしょうか？"; then
	    # ユーザーが「はい」を選択した場合、ファイルを初期値に戻す
      # 初期化の処理
      rm -rf /home/testos/Status/*
      echo "" > "$STATUS_FILE"
	    zenity --info --text="Statusフォルダが初期値に戻されました。"
	else
	    # ユーザーが「いいえ」を選択した場合、何もしない
	    zenity --error --text="拒否しました。"
	    exit 1
fi

###############################################
# ③ 実行担当者入力
###############################################
OPERATOR=$(zenity --entry \
  --title="実行担当者の入力" \
  --text="実行担当者をバーコードリーダーで読み取ってください")

[ -z "$OPERATOR" ] && zenity --error --text="担当者未入力" && exit 1

###############################################
# ④ 製品型番入力
###############################################
PRODUCT_MODEL=$(zenity --entry \
  --title="試験製品の入力" \
  --text="製品チェックシートに記載のバーコードを読み取ってください")

[ -z "$PRODUCT_MODEL" ] && zenity --error --text="型番未入力" && exit 1

###############################################
# ⑤ 型番とスクリプト対応
###############################################
declare -A PRODUCT_SCRIPTS=(
    ["NAISNP4A1L256G"]="/home/testos/shell/Product_shell2/TowerAI_Workstation2.sh"
)

if [ -z "${PRODUCT_SCRIPTS[$PRODUCT_MODEL]+_}" ]; then
    zenity --error \
      --title="未対応型番" \
      --text="この型番は自動検査ツールが用意されていません。\n\n型番：$PRODUCT_MODEL"
    exit 1
fi

SCRIPT_PATH="${PRODUCT_SCRIPTS[$PRODUCT_MODEL]}"


###############################################
# 出荷日の設定
###############################################
	SHIP_DATE=$(zenity --calendar --date-format="%Y/%m/%d" --title="出荷日選択" --text="出荷日を入力してください。")

	#one_month_later=$(date -d "$SHIP_DATE +1 month" +%Y/%m/%d)
	#ten_year_later=$(date -d "$SHIP_DATE +10 year" +%Y/%m/%d)



###############################################
# ステータスファイル作成
###############################################
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
RUN_ID=$(date +"%Y%m%d_%H%M%S")
STATUS_FILE="$STATUS_DIR/${PRODUCT_MODEL}_${RUN_ID}.status"
export STATUS_FILE

cat <<EOF > "$STATUS_FILE"
START_TIME=$START_TIME
OPERATOR=$OPERATOR
PRODUCT_MODEL=$PRODUCT_MODEL
SHIP_DATE=$SHIP_DATE
SCRIPT_PATH=$SCRIPT_PATH
RESULT=RUNNING
EOF

###############################################
# 実行内容表示
###############################################
zenity --info \
  --width=600 \
  --title="試験内容確認" \
  --text="以下の内容で試験を開始します。\n\n\
実行担当者：$OPERATOR\n\
製品型番：$PRODUCT_MODEL\n\
出荷日：$SHIP_DATE\n\
ステータス保存先：$STATUS_FILE"


###############################################
# 各部品シリアル取得（重複チェック・連番表示版）
###############################################
SERIAL_LIST=()

while true; do
  # 入力ダイアログを表示
  PARTS_SERIAL_INPUT=$(zenity --entry \
    --title="パーツシリアルスキャン" \
    --text="各パーツのバーコードをスキャンしてください。\n（終了する場合は 'end' と入力、もしくはキャンセル）" \
    --entry-text="")

  # 終了条件
  if [[ $? -ne 0 ]] || [[ "$PARTS_SERIAL_INPUT" == "end" ]] || [[ -z "$PARTS_SERIAL_INPUT" ]]; then
    break
  fi

  # 重複チェック
  DUPLICATE=false
  for s in "${SERIAL_LIST[@]}"; do
    if [[ "$s" == "$PARTS_SERIAL_INPUT" ]]; then
      DUPLICATE=true
      break
    fi
  done

  if $DUPLICATE; then
    zenity --warning \
      --title="重複エラー" \
      --text="シリアル [$PARTS_SERIAL_INPUT] は既にスキャン済みです。" \
      --timeout=5
    continue 
  fi

  SERIAL_LIST+=("$PARTS_SERIAL_INPUT")
done

# --- 結果の整形処理 ---
if [ ${#SERIAL_LIST[@]} -eq 0 ]; then
  zenity --info --text="入力されたシリアル番号はありません。"
else
  # 番号付きの文字列を作成
  SERIAL_LIST_RESULT=""
  INDEX=1
  
  # 丸数字（①〜）を付与するループ
  for s in "${SERIAL_LIST[@]}"; do
    # 1-20番くらいまでは丸数字、それ以降は (21) のような形式にするのが一般的です
    # ここではシンプルな 1. 2. 形式、または直接丸数字を指定できます
    if [ $INDEX -le 20 ]; then
      # Unicodeの丸数字（①〜⑳）を利用
      CIRCLE_NUM=$(printf "\\U$(printf '%x' $((0x245F + INDEX)))")
      SERIAL_LIST_RESULT+="${CIRCLE_NUM} ${s}\n"
    else
      SERIAL_LIST_RESULT+="${INDEX}. ${s}\n"
    fi
    ((INDEX++))
  done

  zenity --info --title="スキャン完了" --width=600 --text="以下のシリアルを取得しました：\n\n$SERIAL_LIST_RESULT"
fi


###############################################
# シリアル保存
###############################################
SERIAL_FILE="/tmp/parts_serial_list.txt"
printf "%s\n" "${SERIAL_LIST[@]}" > "$SERIAL_FILE"



###############################################
# ⑤ 型番.sh 実行
###############################################
if bash "$SCRIPT_PATH"; then
    RESULT="OK"
else
    RESULT="NG"
fi

###############################################
# 結果保存（rebootがなければここまで来る）
###############################################
END_TIME=$(date +"%Y-%m-%d %H:%M:%S")

sed -i \
  -e "s/^RESULT=.*/RESULT=$RESULT/" \
  "$STATUS_FILE"

echo "END_TIME=$END_TIME" >> "$STATUS_FILE"

zenity --info \
  --title="試験完了" \
  --text="試験が完了しました。\n\n結果：$RESULT"

exit 0
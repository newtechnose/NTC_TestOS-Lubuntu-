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
SCRIPT_PATH=$SCRIPT_PATH
RESULT=RUNNING
EOF

###############################################
# 実行内容表示
###############################################
zenity --info \
  --title="試験内容確認" \
  --text="以下の内容で試験を開始します。\n\n\
実行担当者：$OPERATOR\n\
製品型番：$PRODUCT_MODEL\n\
ステータス保存先：$STATUS_FILE"

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
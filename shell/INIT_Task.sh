#!/bin/bash

# Statusファイルのパス
STATUS_FILE="/home/testos/Status/status.txt"

# Zenityで確認ダイアログを表示
zenity --question --text="製品自動プログラムタスクを初期化してよろしいですか？"

# ユーザーがOKを選択した場合
if [ $? = 0 ]; then
    echo "初期化を開始します。"
    
    # 初期化の処理
    rm -rf /home/testos/Status/*
    echo "" > "$STATUS_FILE"
    chmod 777 "$STATUS_FILE"
    
    echo "初期化が完了しました。"
    # エンターを押すまで待機
    read -p "エンターキーを押して続行してください..."
else
    echo "初期化をキャンセルしました。"
    # エンターを押すまで待機
    read -p "エンターキーを押して続行してください..."
fi


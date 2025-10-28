#!/bin/bash

# 削除確認ダイアログ
zenity --question --text="Resultフォルダ内の内容を削除しますか？※Logが全て削除されます" --title="フォルダ削除確認"

# Zenityの戻り値を確認
if [ $? -eq 0 ]; then
    # "はい"を選択した場合
    rm -rf /home/testos/Desktop/Result/*
    zenity --info --text="Resultフォルダ内を削除しました。" --title="削除完了"
else
    # "いいえ"を選択した場合
    zenity --info --text="操作をキャンセルしました。" --title="キャンセル"
fi


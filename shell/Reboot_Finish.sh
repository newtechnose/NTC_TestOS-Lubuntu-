#!/bin/bash

# ファイルパス
conf_file="/opt/NTC/reboot_tool/reboot_tool.conf"

# 新しい内容
new_content="[Count Cur]
2
[Count Limit]
0
[Command1]
shutdown -r +2
[Command2]
NONE"

# ファイルが存在するか確認
if [ -e "$conf_file" ]; then
    # 変更を行う前に確認メッセージを表示
    zenity --question --text="リブートテストを終了しますか？" --ok-label="はい" --cancel-label="いいえ"

    case $? in
        0)
            # ファイルの内容を削除
            echo -n > "$conf_file"
            
            # 新しい内容をファイルに書き込み
            echo "$new_content" > "$conf_file"
            
            # 変更内容をzenityで表示
            zenity --info --text="reboot_tool.conf の内容が変更されました。\n\nあと1回再起動し、リブートテストを終了します。\n\n新しい内容:\n$new_content"
            ;;
        1)
            # ユーザーが変更をキャンセルした場合のメッセージ
            zenity --info --text="キャンセルされました。"
            ;;
    esac
else
    # ファイルが存在しない場合の処理
    zenity --error --text="エラー: $conf_file が見つかりません。"
fi


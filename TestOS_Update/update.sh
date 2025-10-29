#!/bin/bash

# 作業用ディレクトリ
WORKDIR="/home/testos/TestOS_update"
CLONEDIR="/home/testos/NTC_TestOS"
VERSION_FILE_CURRENT="/home/testos/TestOS_Version/version.txt"
VERSION_FILE_NEW="$CLONEDIR/TestOS_Version/version.txt"

# 今のバージョンを取得
if [[ ! -f "$VERSION_FILE_CURRENT" ]]; then
    zenity --error --text="現在のバージョンファイルが見つかりません：$VERSION_FILE_CURRENT"
    exit 1
fi
CURRENT_VER=$(cat "$VERSION_FILE_CURRENT" | tr -d ' \n')

# NTC_TestOSフォルダを削除
sudo rm -rf /home/testos/NTC_TestOS

# Gitから新しいバージョンを取得
git clone https://newtechnose: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@github.com/newtechnose/NTC_TestOS-Lubuntu-.git "$CLONEDIR"
sudo chmod 777 $CLONEDIR
if [[ $? -ne 0 ]]; then
    zenity --error --text="Gitリポジトリのクローンに失敗しました。"
    exit 1
fi

# 新しいバージョンを取得
if [[ ! -f "$VERSION_FILE_NEW" ]]; then
    zenity --error --text="新しいバージョンファイルが見つかりません：$VERSION_FILE_NEW"
    exit 1
fi
NEW_VER=$(cat "$VERSION_FILE_NEW" | tr -d ' \n')

# バージョン比較（セマンティックバージョン対応）
if [[ "$(printf '%s\n' "$NEW_VER" "$CURRENT_VER" | sort -V | head -n1)" != "$NEW_VER" ]]; then
    zenity --question --title="アップデート確認" \
           --text="更新が必要です。\n\n現在のVersion：$CURRENT_VER\n新しいVersion：$NEW_VER\n\n更新しますか？"

    if [[ $? -ne 0 ]]; then
        zenity --info --text="更新はキャンセルされました。"
        exit 0
    fi

    # ==== 更新処理開始 ====
    echo "更新を実行します..."

    # Desktop の中身をコピー（上書き）＋ chmod +x
    if [[ -d "$CLONEDIR/Desktop" ]]; then
        sudo rm -rf /home/testos/Desktop/*
        sudo cp -r "$CLONEDIR/Desktop/"* /home/testos/Desktop/
        sudo chmod +x /home/testos/Desktop/* 2>/dev/null
        sudo chmod 777 /home/testos/Desktop/Result
    fi

    # Pictures の中身をコピー（上書き）＋ chmod 777
    if [[ -d "$CLONEDIR/Pictures" ]]; then
        sudo rm -rf /home/testos/Pictures/*
        sudo cp -r "$CLONEDIR/Pictures/"* /home/testos/Pictures/
        sudo chmod -R 777 /home/testos/Pictures/*
    fi

    # RAIDcard_FW の中身をコピー（上書き）
    if [[ -d "$CLONEDIR/RAIDcard_FW" ]]; then
        sudo rm -rf /home/testos/RAIDcard_FW/*
        sudo cp -r "$CLONEDIR/RAIDcard_FW/"* /home/testos/RAIDcard_FW/
    fi

    # TestOS_Version の中身をコピー（上書き）＋ chmod 777
    if [[ -d "$CLONEDIR/TestOS_Version" ]]; then
        sudo rm -rf /home/testos/TestOS_Version/*
        sudo cp -r "$CLONEDIR/TestOS_Version/"* /home/testos/TestOS_Version/
        sudo chmod -R 777 /home/testos/TestOS_Version/*
    fi

    # shell の中身をコピー（上書き）＋ chmod 777
    if [[ -d "$CLONEDIR/shell" ]]; then
        sudo rm -rf /home/testos/shell/*
        sudo cp -r "$CLONEDIR/shell/"* /home/testos/shell/
        sudo chmod -R 777 /home/testos/shell/*
    fi

    # BurnInTest_cfg の中身をコピー（上書き）＋ chmod 777
    if [[ -d "$CLONEDIR/BurnInTest_cfg" ]]; then
        sudo rm -rf /home/testos/BurnInTest_cfg/*
        cp -r "$CLONEDIR/BurnInTest_cfg/"* /home/testos/BurnInTest_cfg/
    fi

    # バージョンに対応した壁紙を設定
    WALLPAPER_PATH="/home/testos/Pictures/TestOS_${NEW_VER}.png"

    if [[ -f "$WALLPAPER_PATH" ]]; then
        pcmanfm-qt --set-wallpaper "$WALLPAPER_PATH"
    else
        echo "壁紙ファイルが見つかりません：$WALLPAPER_PATH"
    fi

    zenity --info --text="更新が完了しました。"

    # ==== 再起動確認 ====
    zenity --question --title="再起動の確認" \
           --text="システムを再起動しますか？"
    if [[ $? -eq 0 ]]; then
        sudo reboot
    else
        zenity --info --text="再起動はキャンセルされました。"
    fi
else
    zenity --info --text="更新する内容はありません。現在のVersion：$CURRENT_VER"
    exit 0
fi

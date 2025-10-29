#!/bin/bash

# ステータスを確認
status=$(/etc/init.d/LsiSASH status)

# サービスが停止している場合、開始する
#if [[ "$status" == *"LSI Storage Authority is stopped"* ]]; then
#    echo "LSI Storage Authority is stopped. Starting service..."
#    gnome-terminal --wait -- /bin/bash -c "sudo /etc/init.d/LsiSASH start"
#else
#    echo "LSI Storage Authority is running."
#fi

     qterminal -e "bash -c 'sudo /etc/init.d/LsiSASH restart'"


# 開くURLを指定
target_url="http://localhost:2463"

# FirefoxでURLを開く
firefox "$target_url"


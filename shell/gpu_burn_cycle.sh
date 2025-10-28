#!/bin/bash

# スクリプトのあるディレクトリに移動
cd /home/testos/shell

# zenityでメッセージを表示
zenity --info --width 800 --title="gpu_burn_cycle" --text="GPU負荷試験用ツール gpu_burnを起動します。\nウィンドウのOKを押して、各設定値を入力しテストが完了するまで待ってください。"

# スクリプトの実行結果をターミナルに表示
qterminal -e "bash -c '/home/testos/shell/gpu_burn_with_nvidia-smi_v6.sh'"
# スクリプトの結果によってzenityでメッセージを表示
zenity --info --width 800 --title='Infomation' --text='GPU負荷テストが終了しました\n結果はログファイルをご確認ください。\n※ログファイルの場所：/home/testos/gpu-burn/gpu_logs'

#read -p 'Press Enter to close.'


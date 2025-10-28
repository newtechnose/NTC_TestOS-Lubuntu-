#!/bin/bash

# 初期情報取得前にメッセージを表示
zenity --info --text="初期情報を取得します。まだUSBを挿さないでください"

# 初期のデバイスリストを取得
initial_devices=$(lsblk -o NAME,TRAN | grep usb)

# USB挿入待ちのメッセージを表示（OKを押してからUSBを挿してください）
zenity --info --text="OKを押してから、USBを挿してください"

# USBメモリが挿入されるまで待機
while true; do
    current_devices=$(lsblk -o NAME,TRAN | grep usb)

    if [ "$current_devices" != "$initial_devices" ]; then
        # USBメモリが認識された場合
	device=$(lsusb | grep -i 'Alcor Micro Corp\|ASolid USB_0114\|I-O Data Device')

        if [ -n "$device" ]; then
            # USBデバイスのバス情報を取得
            bus=$(echo "$device" | awk '{print $2}')
            dev=$(echo "$device" | awk '{print $4}' | sed 's/://')

            # デバイスの速度（USB2.0かUSB3.0か）を確認
            speed=$(lsusb -v -s $bus:$dev | grep -i 'bcdUSB' | awk '{print $2}')

            if [[ "$speed" == "2.00" ]]; then
                zenity --info --text="USB 2.0 メモリが挿入されました！"
            elif [[ "$speed" == "3.20" ]]; then
                zenity --info --text="USB 3.0 メモリが挿入されました！"
            elif [[ "$speed" == "3.10" ]]; then
                zenity --info --text="USB 3.0 メモリが挿入されました！"
            else
                zenity --info --text="USBメモリが挿入されました（バージョン不明）"
            fi
        else
            zenity --info --text="USBメモリが認識されましたが、詳細情報を取得できません。"
        fi
        break
    fi

    # 1秒ごとに確認
    sleep 1
done

# USBを安全に取り外すようメッセージを表示
zenity --info --text="USBを取り外してください。安全に取り外せます。"


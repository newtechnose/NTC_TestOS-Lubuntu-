#!/bin/bash

/home/testos/LCD_BMP_FONT_SAMPLE_0.12/bin/ezio_g500_api -d /dev/ttyS1 -b 115200 -G 1 /home/testos/LCD_BMP_FONT_SAMPLE_0.12/beta.bmp

#echo 'LCD表示実行しました。Enterキーを押してください'
#read
#exit 0

#gnome-terminal --command "dialog --title 'LCD Display' --msgbox 'LCD表示にドット抜けが無いか確認してください。' 19 73"

zenity --info --width 800 --title="LCD表示テスト" --text="LCD表示にドット抜けが無いか確認してください。"

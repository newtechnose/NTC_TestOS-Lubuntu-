#!/bin/bash

zenity --info --width 800 --title="LCD操作テスト" --text="LCDのボタン操作のテストをします。
OKを押したら、LCDのボタンを順番に押し、画面の表示が切り替わることを確認してください。"

/home/testos/LCD_BMP_FONT_SAMPLE_0.12/bin/ezio_g500_api -d /dev/ttyS1 -b 115200 -t


#!/bin/bash

file_path="/opt/NTC/reboot_tool/reboot_tool.conf"

if [ ! -f "$file_path" ]; then
    zenity --error --text="ファイルが見つかりません: $file_path"
    exit 1
fi

zenity --text-info --filename="$file_path"

exit 0


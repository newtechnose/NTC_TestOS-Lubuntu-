zenity --info --width 800 --title="COMポートテスト" --text="製品とテスト用PCをRS232Cケーブルで接続し、minicomが起動したら互いに入力した文字が出力されているか確認してください。\n\n終了するときはCtrl + a を押して x を押すと終了する画面が出てくるので、Enterキーを押し、終了してください。\n※ウィンドウの✕ボタンでは終了しないでください。"
gnome-terminal -- bash -c "minicom; bash"

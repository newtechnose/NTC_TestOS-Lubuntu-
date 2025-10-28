#!/usr/bin/env python3

import subprocess
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk
import sys

# CloudyⅤを実行する関数
def run_cloudy_v():
    # 「NTC版」か「Arcserve版」を選択させる新しいウィンドウを表示
    select_cloudy_v_version()

# NTC版を実行する関数
def run_ntc():
    subprocess.run(["/home/testos/shell/IPMI_Supericro.sh"])
    messagebox.showinfo("完了", "NTC版の処理を終了します")
    root.quit()
    sys.exit()

# Arcserve版を実行する関数
def run_arcserve():
    subprocess.run(["/home/testos/shell/IPMI_Arcserve.sh"])
    messagebox.showinfo("完了", "Arcserve版の処理を終了します")
    root.quit()
    sys.exit()

# SmartNAS1000を実行する関数
def run_smartnas1000():
    subprocess.run(["/home/testos/shell/IPMI_Gigabyte.sh"])
    messagebox.showinfo("完了", "SmartNAS1000の処理を終了します")
    root.quit()
    sys.exit()

# その他を実行する関数
def run_others():
    subprocess.run(["/home/testos/shell/IPMI_Gigabyte.sh"])
    messagebox.showinfo("完了", "その他の処理を終了します")
    root.quit()
    sys.exit()

# CloudyⅤのバージョン選択用の新しいウィンドウを作成
def select_cloudy_v_version():
    # メインウィンドウを非表示にする
    root.withdraw()

    # 新しいウィンドウを作成
    new_window = tk.Toplevel(root)
    new_window.title("CloudyⅤ バージョン選択")
    new_window.geometry("600x400")

    # 画像の読み込み
    ntc_image_path = "/home/testos/Pictures/Icon/NTC_Cloudy.png"
    arcserve_image_path = "/home/testos/Pictures/Icon/Arc1U.png"

    ntc_image = Image.open(ntc_image_path)
    arcserve_image = Image.open(arcserve_image_path)

    ntc_image = ntc_image.resize((200, 200))  # 画像サイズを調整
    arcserve_image = arcserve_image.resize((200, 200))

    ntc_img = ImageTk.PhotoImage(ntc_image)
    arcserve_img = ImageTk.PhotoImage(arcserve_image)

    # フレームの作成（画像とラベルを一緒に配置するため）
    frame_ntc = tk.Frame(new_window)
    frame_ntc.pack(side="left", padx=20, pady=20)

    frame_arcserve = tk.Frame(new_window)
    frame_arcserve.pack(side="right", padx=20, pady=20)

    # ボタンとして画像を表示し、クリックで実行
    button_ntc = tk.Button(frame_ntc, image=ntc_img, command=run_ntc)
    button_ntc.pack()

    button_arcserve = tk.Button(frame_arcserve, image=arcserve_img, command=run_arcserve)
    button_arcserve.pack()

    # 画像の下にテキストラベルを追加
    label_ntc = tk.Label(frame_ntc, text="NTC版", font=("Arial", 12))
    label_ntc.pack()

    label_arcserve = tk.Label(frame_arcserve, text="Arcserve版", font=("Arial", 12))
    label_arcserve.pack()

    # ウィンドウを閉じたときの処理
    new_window.protocol("WM_DELETE_WINDOW", lambda: (new_window.destroy(), root.destroy()))

    # メインループを持たせるため、画像参照の保持が必要
    new_window.mainloop()

# メインウィンドウの作成
root = tk.Tk()
root.title("IPMI設定 実行選択")
root.geometry("800x400")

# 画像の読み込み
image1_path = "/home/testos/Pictures/Icon/Cloudy2U.png"
image2_path = "/home/testos/Pictures/Icon/SmartNAS.png"
image3_path = "/home/testos/Pictures/Icon/server.png"  # その他の画像

image1 = Image.open(image1_path)
image2 = Image.open(image2_path)
image3 = Image.open(image3_path)

# 画像サイズを調整（すべて均等に200x200に）
image1 = image1.resize((200, 200))
image2 = image2.resize((200, 200))
image3 = image3.resize((200, 200))

# 画像をTkinterが扱える形式に変換
img1 = ImageTk.PhotoImage(image1)
img2 = ImageTk.PhotoImage(image2)
img3 = ImageTk.PhotoImage(image3)

# グリッドレイアウトを使って均等に配置
frame = tk.Frame(root)
frame.grid(row=0, column=0, padx=20, pady=20)

# ボタンとして画像を表示し、クリックで実行
button1 = tk.Button(frame, image=img1, command=run_cloudy_v)
button1.grid(row=0, column=0, padx=20, pady=20)

button2 = tk.Button(frame, image=img2, command=run_smartnas1000)
button2.grid(row=0, column=1, padx=20, pady=20)

button3 = tk.Button(frame, image=img3, command=run_others)
button3.grid(row=0, column=2, padx=20, pady=20)

# 画像の下にテキストラベルを追加
label1 = tk.Label(frame, text="CloudyⅤ", font=("Arial", 12))
label1.grid(row=1, column=0)

label2 = tk.Label(frame, text="SmartNAS1000", font=("Arial", 12))
label2.grid(row=1, column=1)

label3 = tk.Label(frame, text="その他", font=("Arial", 12))
label3.grid(row=1, column=2)

# ウィンドウを閉じたときの処理
root.protocol("WM_DELETE_WINDOW", lambda: (root.quit(), sys.exit()))

# ウィンドウの表示
root.mainloop()


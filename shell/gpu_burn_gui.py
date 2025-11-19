#!/usr/bin/env python3

import subprocess
import tkinter as tk
from tkinter import messagebox
from PIL import Image, ImageTk

# 通常のGPU-Burnを実行する関数
def run_gpu_burn():
    # シェルスクリプト実行
    subprocess.run(["/home/testos/shell/gpu_burn.sh"])
    # 念のため残っているコンテナを強制終了
    subprocess.run(["docker", "kill", "gpu_burn"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    messagebox.showinfo("完了", "通常のGPU-Burnを実行しました")
    root.quit()

# GPU-Burnサイクルを実行する関数
def run_gpu_burn_cycle():
    # シェルスクリプト実行
    subprocess.run(["/home/testos/shell/gpu_burn_cycle.sh"])
    # 念のため残っているコンテナを強制終了
    subprocess.run(["docker", "kill", "gpu_burn"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    messagebox.showinfo("完了", "GPU-Burnサイクルを実行しました")
    root.quit()

# ---------------------------
# メインウィンドウの作成
# ---------------------------
root = tk.Tk()
root.title("GPU-Burn 実行選択")
root.geometry("600x400")

# 画像のパス
image1_path = "/home/testos/Pictures/Icon/gpu-burn2.png"
image2_path = "/home/testos/Pictures/Icon/gpu-burn-cycle.png"

# 画像読み込み＆サイズ調整
image1 = Image.open(image1_path).resize((200, 200))
image2 = Image.open(image2_path).resize((200, 200))

img1 = ImageTk.PhotoImage(image1)
img2 = ImageTk.PhotoImage(image2)

# フレーム作成
frame1 = tk.Frame(root)
frame1.pack(side="left", padx=20, pady=20)

frame2 = tk.Frame(root)
frame2.pack(side="right", padx=20, pady=20)

# ボタンとして画像を配置
button1 = tk.Button(frame1, image=img1, command=run_gpu_burn)
button1.pack()

button2 = tk.Button(frame2, image=img2, command=run_gpu_burn_cycle)
button2.pack()

# 画像の下にラベルを追加
label1 = tk.Label(frame1, text="通常のGPU-Burn", font=("Arial", 12))
label1.pack()

label2 = tk.Label(frame2, text="GPU-Burnサイクル", font=("Arial", 12))
label2.pack()

# ウィンドウ表示
root.mainloop()
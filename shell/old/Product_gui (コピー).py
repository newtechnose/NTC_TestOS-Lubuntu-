import tkinter as tk
from tkinter import messagebox
from PIL import ImageTk, Image
import os

class ImageSelector:
    def __init__(self, root):
        self.root = root
        self.root.title("画像選択")
        self.root.geometry("600x400")

        # CloudyとSmartNAS1000の画像ファイルパス
        self.cloudy_image_path = "/home/testos/Pictures/Icon/NTC_Cloudy.png"
        self.smartnas_image_path = "/home/testos/Pictures/Icon/SmartNAS_1U2U.png"

        # SmartNAS1000-1Uと2Uの画像ファイルパス
        self.smartnas_1u_image_path = "/home/testos/Pictures/Icon/SmartNAS-1U.png"
        self.smartnas_2u_image_path = "/home/testos/Pictures/Icon/SmartNAS.png"

        # シェルスクリプトのパス
        self.ssd_none_smartnas_1u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-1U_Season1.sh"
        self.ssd_with_smartnas_1u_sh = "./run_with_ssd_smartnas_1u.sh"
        self.ssd_none_smartnas_2u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-2U_Season1.sh"
        self.ssd_with_smartnas_2u_sh = "./run_with_ssd_smartnas_2u.sh"

        # SSDあり・なしのフラグを管理
        self.ssd_with = False

        # 1段階目の画像と選択肢を表示
        self.display_first_selection()

    def display_first_selection(self):
        self.clear_window()

        # Frameを使ってCloudyとSmartNAS1000をそれぞれ別のコンテナに配置
        frame1 = tk.Frame(self.root)
        frame1.pack(side="left", padx=10, pady=10)

        frame2 = tk.Frame(self.root)
        frame2.pack(side="right", padx=10, pady=10)

        # Cloudyの画像を表示
        cloudy_img = Image.open(self.cloudy_image_path)
        cloudy_img = cloudy_img.resize((250, 250), Image.Resampling.LANCZOS)
        cloudy_photo = ImageTk.PhotoImage(cloudy_img)

        cloudy_button = tk.Button(frame1, image=cloudy_photo, command=self.cloudy_selected)
        cloudy_button.image = cloudy_photo
        cloudy_button.pack()

        # Cloudyのラベルを追加
        cloudy_label = tk.Label(frame1, text="Cloudy")
        cloudy_label.pack()

        # SmartNAS1000の画像を表示
        smartnas_img = Image.open(self.smartnas_image_path)
        smartnas_img = smartnas_img.resize((250, 250), Image.Resampling.LANCZOS)
        smartnas_photo = ImageTk.PhotoImage(smartnas_img)

        smartnas_button = tk.Button(frame2, image=smartnas_photo, command=self.smartnas_selected)
        smartnas_button.image = smartnas_photo
        smartnas_button.pack()

        # SmartNAS1000のラベルを追加
        smartnas_label = tk.Label(frame2, text="SmartNAS1000")
        smartnas_label.pack()

    def cloudy_selected(self):
        messagebox.showinfo("選択", "Cloudyが選ばれました")
        self.root.destroy()  # ウィンドウを完全に閉じる

    def smartnas_selected(self):
        messagebox.showinfo("選択", "SmartNAS1000が選ばれました")
        self.display_ssd_selection()

    def display_ssd_selection(self):
        self.clear_window()

        label = tk.Label(self.root, text="①SSDなしモデル ②SSDありモデル")
        label.pack()

        # SSDなしモデルのボタン
        btn1 = tk.Button(self.root, text="SSDなしモデル", command=self.ssd_none_selected)
        btn1.pack(pady=10)

        # SSDありモデルのボタン
        btn2 = tk.Button(self.root, text="SSDありモデル", command=self.ssd_with_selected)
        btn2.pack(pady=10)

    def ssd_none_selected(self):
        messagebox.showinfo("選択", "SSDなしモデルが選ばれました")
        self.ssd_with = False
        self.display_smartnas_model_selection()

    def ssd_with_selected(self):
        messagebox.showinfo("選択", "SSDありモデルが選ばれました")
        self.ssd_with = True
        self.display_smartnas_model_selection()

    def display_smartnas_model_selection(self):
        self.clear_window()

        label = tk.Label(self.root, text="①SmartNAS1000-1U ②SmartNAS1000-2U")
        label.pack()

        # Frameを使って1Uと2Uをそれぞれ別のコンテナに配置
        frame1 = tk.Frame(self.root)
        frame1.pack(side="left", padx=10, pady=10)

        frame2 = tk.Frame(self.root)
        frame2.pack(side="right", padx=10, pady=10)

        # SmartNAS1000-1Uの画像を表示
        smartnas_1u_img = Image.open(self.smartnas_1u_image_path)
        smartnas_1u_img = smartnas_1u_img.resize((250, 250), Image.Resampling.LANCZOS)
        smartnas_1u_photo = ImageTk.PhotoImage(smartnas_1u_img)

        smartnas_1u_button = tk.Button(frame1, image=smartnas_1u_photo, command=self.smartnas_1u_selected)
        smartnas_1u_button.image = smartnas_1u_photo
        smartnas_1u_button.pack()

        # SmartNAS1000-1Uのラベルを追加
        smartnas_1u_label = tk.Label(frame1, text="SmartNAS1000-1U")
        smartnas_1u_label.pack()

        # SmartNAS1000-2Uの画像を表示
        smartnas_2u_img = Image.open(self.smartnas_2u_image_path)
        smartnas_2u_img = smartnas_2u_img.resize((250, 250), Image.Resampling.LANCZOS)
        smartnas_2u_photo = ImageTk.PhotoImage(smartnas_2u_img)

        smartnas_2u_button = tk.Button(frame2, image=smartnas_2u_photo, command=self.smartnas_2u_selected)
        smartnas_2u_button.image = smartnas_2u_photo
        smartnas_2u_button.pack()

        # SmartNAS1000-2Uのラベルを追加
        smartnas_2u_label = tk.Label(frame2, text="SmartNAS1000-2U")
        smartnas_2u_label.pack()

    def smartnas_1u_selected(self):
        messagebox.showinfo("選択", "SmartNAS1000-1Uが選ばれました")
        self.execute_script(self.ssd_with_smartnas_1u_sh if self.ssd_with else self.ssd_none_smartnas_1u_sh)

    def smartnas_2u_selected(self):
        messagebox.showinfo("選択", "SmartNAS1000-2Uが選ばれました")
        self.execute_script(self.ssd_with_smartnas_2u_sh if self.ssd_with else self.ssd_none_smartnas_2u_sh)

    def execute_script(self, script_path):
        self.clear_window()  # ウィジェットを消去して画像を消す
        messagebox.showinfo("実行中", f"スクリプト {script_path} を実行します")
        os.system(script_path)
        self.root.destroy()  # ウィンドウを完全に閉じる

    def clear_window(self):
        # 画面上のウィジェットをクリア
        for widget in self.root.winfo_children():
            widget.destroy()

# メインウィンドウを作成
root = tk.Tk()
app = ImageSelector(root)
root.mainloop()


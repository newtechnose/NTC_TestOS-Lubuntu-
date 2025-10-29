import tkinter as tk
from tkinter import messagebox
from PIL import ImageTk, Image
import os

class ImageSelector:
    def __init__(self, root):
        self.root = root
        self.root.title("画像選択")
        self.root.geometry("1200x400")  # ウィンドウサイズを変更

        # CloudyとSmartNAS1000の画像ファイルパス
        self.cloudy_image_path = "/home/testos/Pictures/Icon/NTC_Cloudy.png"
        self.smartnas_image_path = "/home/testos/Pictures/Icon/SmartNAS_1U2U.png"
        self.nrec_image_path = "/home/testos/Pictures/Icon/Nrec_4000_6000_8000.png"
        self.ai_server_image_path = "/home/testos/Pictures/Icon/AIServer.png"  # AIサーバ(AMD)の画像

        # SmartNAS1000-1Uと2Uの画像ファイルパス
        self.smartnas_1u_image_path = "/home/testos/Pictures/Icon/SmartNAS-1U.png"
        self.smartnas_2u_image_path = "/home/testos/Pictures/Icon/SmartNAS.png"

        # Nrecシリーズの画像ファイルパス
        self.nrec4000_image_path = "/home/testos/Pictures/Icon/Nrec4000.png"
        self.nrec6000_image_path = "/home/testos/Pictures/Icon/Nrec6000.png"
        self.nrec8000_image_path = "/home/testos/Pictures/Icon/Nrec8000.png"

        # シェルスクリプトのパス
        self.ssd_none_smartnas_1u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-1U_Season1.sh"
        self.ssd_with_smartnas_1u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-1U_Season2.sh"
        self.ssd_none_smartnas_2u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-2U_Season1.sh"
        self.ssd_with_smartnas_2u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-2U_Season2.sh"
        self.nrec4000_sh = "/home/testos/shell/Product_shell/Nrec4000.sh"
        self.nrec6000_sh = "/home/testos/shell/Product_shell/Nrec6000.sh"
        self.nrec8000_sh = "/home/testos/shell/Product_shell/Nrec8000.sh"
        self.cloudy_sh = "/home/testos/shell/Product_shell/cloudy.sh"  # Cloudyのシェルを追加
        self.ai_server_sh = "/home/testos/shell/Product_shell/ai_server_AMD.sh"  # AIサーバ(AMD)のスクリプト
        self.txp_medical_sh = "/home/testos/shell/Product_shell/TXPMedical.sh"  # TXPMedicalのシェル
        self.txp_medical_2u_sh = "/home/testos/shell/Product_shell/TXPMedical-2U.sh"  # TXPMedical-2Uのシェル
        self.all_flash_smartnas_1u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-1U_AllFlash.sh"  # オールフラッシュSartNAS1000-1Uのシェル
        self.all_flash_smartnas_2u_sh = "/home/testos/shell/Product_shell/SmartNAS1000-2U_AllFlash.sh"  # オールフラッシュSartNAS1000-2Uのシェル

        # SSDあり・なしのフラグを管理
        self.ssd_with = False
        
        # TXPのフラグを管理
        self.TXP = False

        # オールフラッシュのフラグを管理
        self.all_flash = False

        # 1段階目の画像と選択肢を表示
        self.display_first_selection()

    def display_first_selection(self):
        self.clear_window()

        # キャンバスとスクロールバーを追加
        canvas = tk.Canvas(self.root, width=900, height=350)
        scrollbar = tk.Scrollbar(self.root, orient="horizontal", command=canvas.xview)
        scrollable_frame = tk.Frame(canvas)

        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(xscrollcommand=scrollbar.set)

        canvas.pack(side="top", fill="both", expand=True)
        scrollbar.pack(side="bottom", fill="x")

        # 製品画像をフレームに配置
        self.add_product(scrollable_frame, self.cloudy_image_path, "Cloudy", self.cloudy_selected)
        self.add_product(scrollable_frame, self.smartnas_image_path, "SmartNAS1000", self.smartnas_selected)
        self.add_product(scrollable_frame, self.nrec_image_path, "Nrecシリーズ", self.nrec_selected)
        self.add_product(scrollable_frame, self.ai_server_image_path, "AIサーバ(AMD)", self.ai_server_selected)

    def add_product(self, frame, image_path, label_text, command):
        product_frame = tk.Frame(frame)
        product_frame.pack(side="left", padx=10, pady=10)

        img = Image.open(image_path)
        img = img.resize((250, 250), Image.Resampling.LANCZOS)
        photo = ImageTk.PhotoImage(img)

        button = tk.Button(product_frame, image=photo, command=command)
        button.image = photo
        button.pack()

        label = tk.Label(product_frame, text=label_text)
        label.pack()

    def cloudy_selected(self):
        messagebox.showinfo("選択", "Cloudyが選ばれました")
        self.execute_script(self.cloudy_sh)  # Cloudyのシェルを実行

    def smartnas_selected(self):
        messagebox.showinfo("選択", "SmartNAS1000が選ばれました")
        self.display_ssd_selection()

    def nrec_selected(self):
        messagebox.showinfo("選択", "Nrecシリーズが選ばれました")
        self.display_nrec_selection()

    def ai_server_selected(self):
        messagebox.showinfo("選択", "AIサーバ(AMD)が選ばれました")
        self.execute_script(self.ai_server_sh)

    def display_ssd_selection(self):
        self.clear_window()

        label = tk.Label(self.root, text="①M.2 SSDなしモデル ②M.2 SSDありモデル ③TXPMedicalモデル ④オールフラッシュ(M.2 SSDあり)モデル")
        label.pack()

        # SSDなしモデルのボタン
        btn1 = tk.Button(self.root, text="M.2 SSDなしモデル", command=self.ssd_none_selected)
        btn1.pack(pady=10)

        # SSDありモデルのボタン
        btn2 = tk.Button(self.root, text="M.2 SSDありモデル", command=self.ssd_with_selected)
        btn2.pack(pady=10)

        # TXPMedicalモデルのボタン
        btn3 = tk.Button(self.root, text="TXPMedicalモデル", command=self.txp_medical_selected)
        btn3.pack(pady=10)
        
        # オールフラッシュモデルのボタン
        btn3 = tk.Button(self.root, text="オールフラッシュ(M.2 SSDあり)モデル", command=self.allflash_selected)
        btn3.pack(pady=10)

    def ssd_none_selected(self):
        messagebox.showinfo("選択", "M.2 SSDなしモデルが選ばれました")
        self.ssd_with = False
        self.display_smartnas_model_selection()

    def ssd_with_selected(self):
        messagebox.showinfo("選択", "M.2 SSDありモデルが選ばれました")
        self.ssd_with = True
        self.display_smartnas_model_selection()

    def txp_medical_selected(self):
        messagebox.showinfo("選択", "TXPMedicalモデルが選ばれました")
        self.ssd_with = False
        self.all_flash = False
        self.TXP = True
        self.display_smartnas_model_selection()
#        self.execute_script(self.txp_medical_sh)  # TXPMedicalのシェルを実行
        
    def allflash_selected(self):
        messagebox.showinfo("選択", "オールフラッシュ(M.2 SSDあり)モデルが選ばれました")
        self.ssd_with = True
        self.all_flash = True
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
        if self.all_flash:
            self.execute_script(self.all_flash_smartnas_1u_sh)
        elif self.TXP:
            self.execute_script(self.txp_medical_sh)        
        else:
            self.execute_script(self.ssd_with_smartnas_1u_sh if self.ssd_with else self.ssd_none_smartnas_1u_sh)

    def smartnas_2u_selected(self):
        messagebox.showinfo("選択", "SmartNAS1000-2Uが選ばれました")
        if self.all_flash:
            self.execute_script(self.all_flash_smartnas_2u_sh)
        elif self.TXP:
            self.execute_script(self.txp_medical_2u_sh) 
        else:
            self.execute_script(self.ssd_with_smartnas_2u_sh if self.ssd_with else self.ssd_none_smartnas_2u_sh)

    def display_nrec_selection(self):
        self.clear_window()

        label = tk.Label(self.root, text="Nrecシリーズを選択してください")
        label.pack()

        # Frameを使ってNrec4000、Nrec6000、Nrec8000をそれぞれ別のコンテナに配置
        frame = tk.Frame(self.root)
        frame.pack(pady=10)

        # Nrec4000の画像を表示
        nrec4000_img = Image.open(self.nrec4000_image_path)
        nrec4000_img = nrec4000_img.resize((250, 250), Image.Resampling.LANCZOS)
        nrec4000_photo = ImageTk.PhotoImage(nrec4000_img)

        nrec4000_button = tk.Button(frame, image=nrec4000_photo, command=self.nrec4000_selected)
        nrec4000_button.image = nrec4000_photo
        nrec4000_button.grid(row=0, column=0, padx=10)

        # Nrec4000のラベルを追加
        nrec4000_label = tk.Label(frame, text="Nrec4000")
        nrec4000_label.grid(row=1, column=0)

        # Nrec6000の画像を表示
        nrec6000_img = Image.open(self.nrec6000_image_path)
        nrec6000_img = nrec6000_img.resize((250, 250), Image.Resampling.LANCZOS)
        nrec6000_photo = ImageTk.PhotoImage(nrec6000_img)

        nrec6000_button = tk.Button(frame, image=nrec6000_photo, command=self.nrec6000_selected)
        nrec6000_button.image = nrec6000_photo
        nrec6000_button.grid(row=0, column=1, padx=10)

        # Nrec6000のラベルを追加
        nrec6000_label = tk.Label(frame, text="Nrec6000")
        nrec6000_label.grid(row=1, column=1)

        # Nrec8000の画像を表示
        nrec8000_img = Image.open(self.nrec8000_image_path)
        nrec8000_img = nrec8000_img.resize((250, 250), Image.Resampling.LANCZOS)
        nrec8000_photo = ImageTk.PhotoImage(nrec8000_img)

        nrec8000_button = tk.Button(frame, image=nrec8000_photo, command=self.nrec8000_selected)
        nrec8000_button.image = nrec8000_photo
        nrec8000_button.grid(row=0, column=2, padx=10)

        # Nrec8000のラベルを追加
        nrec8000_label = tk.Label(frame, text="Nrec8000")
        nrec8000_label.grid(row=1, column=2)

    def nrec4000_selected(self):
        messagebox.showinfo("選択", "Nrec4000が選ばれました")
        self.execute_script(self.nrec4000_sh)

    def nrec6000_selected(self):
        messagebox.showinfo("選択", "Nrec6000が選ばれました")
        self.execute_script(self.nrec6000_sh)

    def nrec8000_selected(self):
        messagebox.showinfo("選択", "Nrec8000が選ばれました")
        self.execute_script(self.nrec8000_sh)


    def execute_script(self, script_path):
        os.system(script_path)  # シェルスクリプトを実行

    def clear_window(self):
        # 現在のウィンドウをクリア
        for widget in self.root.winfo_children():
            widget.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = ImageSelector(root)
    root.mainloop()


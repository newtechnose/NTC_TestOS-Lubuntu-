import tkinter as tk  # tkinterモジュールのインポート
from PIL import Image, ImageTk  # Pillowライブラリのインポート

class CompletionApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Reboot Status Completed')
        self.geometry('1200x600')  # ウィンドウサイズを1200x600に設定
        self.configure(bg='lightgreen')  # 背景色を黄緑色に設定

        # キャンバスを作成
        self.canvas = tk.Canvas(self, width=1200, height=600, bg='lightgreen', highlightthickness=0)
        self.canvas.pack()

        # チェックマーク画像を追加
        self.check_image = Image.open("/home/testos/Pictures/Icon/CheckMark.png")  # チェックマークの画像ファイル
        self.check_image = self.check_image.resize((200, 200), Image.Resampling.LANCZOS)  # サイズ調整
        self.check_photo = ImageTk.PhotoImage(self.check_image)
        self.canvas.create_image(600, 300, image=self.check_photo)

        # テキストの追加
        self.canvas.create_text(600, 450, text="Reboot試験が終了しました。", font=('Helvetica', 32), fill='white')

        # OKボタンを追加して配置
        ok_button = tk.Button(self, text="OK", font=('Helvetica', 16), command=self.close_window)
        ok_button.place(x=550, y=500)  # OKボタンをウィンドウの中央下部に配置

    def close_window(self):
        """ウィンドウを閉じる処理"""
        self.destroy()

if __name__ == '__main__':
    app = CompletionApp()
    app.mainloop()


import tkinter as tk
from math import cos, sin, radians

class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title('Reboot Status')
        self.geometry('1200x600')  # ウィンドウサイズを1200x600に設定
        self.configure(bg='blue')  # 背景色を青に設定

        self.canvas = tk.Canvas(self, width=1160, height=600, bg='blue', highlightthickness=0)
        self.canvas.pack(pady=20)

        self.num_circles = 6  # 円の数を6に設定
        self.circles = []
        self.angle = 0  # 初期角度

        # 6つの円を配置
        for i in range(self.num_circles):
            x, y = self.calculate_position(i * (360 / self.num_circles))
            circle = self.canvas.create_oval(x-30, y-30, x+30, y+30, fill='white', outline='white')
            self.circles.append(circle)

        # テキストの追加
        self.status_text = self.canvas.create_text(600, 500, text="Reboot試験中", font=('Helvetica', 16), fill='white')
        self.value_text = self.canvas.create_text(600, 550, text="", font=('Helvetica', 16), fill='white')

        self.animate_circles()
        self.update_status()

    def calculate_position(self, offset):
        """角度から円の位置を計算する"""
        angle_rad = radians(self.angle + offset)
        x = 600 + 150 * cos(angle_rad)
        y = 280 + 150 * sin(angle_rad)
        return x, y

    def animate_circles(self):
        """すべての円を動かして再描画する"""
        for i, circle in enumerate(self.circles):
            x, y = self.calculate_position(i * (360 / self.num_circles))
            self.canvas.coords(circle, x-30, y-30, x+30, y+30)
        
        self.angle = (self.angle + 3) % 360  # 角度を更新
        self.after(10, self.animate_circles)  # 10ミリ秒後に再度実行

    def update_status(self):
        """reboot_tool.confから値を読み取り、表示を更新する"""
        try:
            with open("/opt/NTC/reboot_tool/reboot_tool.conf", "r") as file:
                count_cur = count_limit = None
                for line in file:
                    if "[Count Cur]" in line:
                        count_cur = int(next(file).strip())
                    if "[Count Limit]" in line:
                        count_limit = int(next(file).strip())
                
                if count_cur is not None and count_limit is not None:
                    display_value = f"{count_cur} / {count_limit} 回目"
                else:
                    display_value = "Invalid value"
                    
                self.canvas.itemconfig(self.value_text, text=display_value)  # テキストを更新
        except FileNotFoundError:
            self.canvas.itemconfig(self.value_text, text="ファイルが見つかりません")
        except Exception as e:
            self.canvas.itemconfig(self.value_text, text=f"エラー: {str(e)}")

        self.after(1000, self.update_status)  # 1秒後に再度実行

if __name__ == '__main__':
    app = App()
    app.mainloop()


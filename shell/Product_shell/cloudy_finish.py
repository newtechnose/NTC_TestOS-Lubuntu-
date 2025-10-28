import tkinter as tk
from PIL import Image, ImageTk

def update_image(frame):
    try:
        # GIF画像の指定フレームに移動
        bg_image.seek(frame)
        photo = ImageTk.PhotoImage(bg_image)
        background_label.config(image=photo)
        background_label.image = photo
        root.after(100, update_image, (frame + 1) % bg_image.n_frames)
    except EOFError:
        # 最終フレームに達したら終了
        return

def main():
    global root, bg_image, background_label
    root = tk.Tk()
    root.title("作業完了通知")

    # 画像ファイルのパスを設定
    image_path = "/home/testos/Pictures/image/cloudy_kun.gif"

    # 画像を読み込み
    bg_image = Image.open(image_path)

    # ウィンドウサイズを画像のサイズに設定
    root.geometry(f"{bg_image.width}x{bg_image.height}")

    # 画像を背景に持つラベルを作成
    photo = ImageTk.PhotoImage(bg_image)
    background_label = tk.Label(root, image=photo)
    background_label.place(x=0, y=0, relwidth=1, relheight=1)

    # テキストラベル
    label = tk.Label(root, text="Cloudyの設定・テストがすべて完了しました", font=('Helvetica', 19, 'bold'), fg="blue", bg="white")
    label.pack(padx=10, pady=170)

    # OKボタン
    button = tk.Button(root, text="OK", command=root.destroy, font=('Helvetica', 12))
    button.pack(pady=1)

    # GIFをアップデート
    update_image(0)

    root.mainloop()

if __name__ == "__main__":
    main()


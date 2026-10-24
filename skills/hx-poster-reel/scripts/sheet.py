import os, sys, json
from PIL import Image, ImageDraw
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
shots = json.load(open(os.path.join(ROOT, "build/shots.json")))
a, z = int(sys.argv[1]), int(sys.argv[2]); out = sys.argv[3]
sel = shots[a:z]; cols = 10; tw, th = 216, 270
sheet = Image.new("RGB", (cols * tw, ((len(sel) + cols - 1) // cols) * th), (40, 40, 40))
for i, s in enumerate(sel):
    p = os.path.join(ROOT, "build/posters", s["id"], "000.jpg")
    im = Image.open(p).convert("RGB").resize((tw - 4, th - 4), Image.LANCZOS)
    ImageDraw.Draw(im).text((3, 3), s["id"], fill=(255, 255, 0))
    sheet.paste(im, ((i % cols) * tw + 2, (i // cols) * th + 2))
sheet.save(out, quality=88)

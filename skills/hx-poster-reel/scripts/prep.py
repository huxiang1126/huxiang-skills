#!/usr/bin/env python3
"""Derived images for the posters: the textured-glass versions (and the same crop without the glass, so the
glass -> clear pair lines up exactly), and a paper noise tile for the dark mirror posters.
Usage: python tools/prep.py name:fx:fy [...]      (fx, fy = crop position as fractions, like CSS object-position)"""
import os, sys
import numpy as np
import cv2

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
W, H = 1080, 1350
FX = os.path.join(ROOT, "img/fx")
os.makedirs(FX, exist_ok=True)


def cover(img, fx, fy, z=1.0):
    h, w = img.shape[:2]
    s = max(W / w, H / h) * z
    r = cv2.resize(img, (round(w * s), round(h * s)), interpolation=cv2.INTER_AREA)
    x0 = int((r.shape[1] - W) * fx)
    y0 = int((r.shape[0] - H) * fy)
    return r[y0:y0 + H, x0:x0 + W]


def glass(img, cell=21.0):
    """a pane of moulded glass: a diagonal grid of small lenses, each showing an inverted, shrunken patch of a
    softened picture, with a bright spot and dark rim per lens"""
    h, w = img.shape[:2]
    soft = cv2.GaussianBlur(img, (0, 0), 3.2).astype(np.float32)
    yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
    a = np.pi / 4                                  # the grid runs on the diagonal, like the reference
    u0 = (xx * np.cos(a) + yy * np.sin(a)) / cell
    v0 = (-xx * np.sin(a) + yy * np.cos(a)) / cell
    fu, fv = u0 - np.floor(u0) - 0.5, v0 - np.floor(v0) - 0.5          # -0.5..0.5 inside each lens
    cu, cv_ = np.floor(u0) + 0.5, np.floor(v0) + 0.5
    k = -0.75                                      # inverted and shrunk
    su, sv = (cu + fu * k) * cell, (cv_ + fv * k) * cell
    sx = su * np.cos(a) - sv * np.sin(a)
    sy = su * np.sin(a) + sv * np.cos(a)
    out = cv2.remap(soft, sx.astype(np.float32), sy.astype(np.float32), cv2.INTER_LINEAR, borderMode=cv2.BORDER_REFLECT)
    r2 = np.clip((fu * fu + fv * fv) / 0.25, 0, 1)
    rim = 1 - 0.30 * r2 ** 2
    spot = np.exp(-(((fu + 0.14) ** 2 + (fv + 0.14) ** 2) / 0.008))
    out = out * rim[..., None] + 46 * spot[..., None]
    return np.clip(out, 0, 255).astype(np.uint8)


if __name__ == "__main__":
    rng = np.random.default_rng(3)
    n = rng.normal(128, 38, (540, 540)).astype(np.float32)
    n = cv2.GaussianBlur(n, (0, 0), 0.8)
    cv2.imwrite(os.path.join(FX, "noise.png"), np.clip(n, 0, 255).astype(np.uint8))
    for arg in sys.argv[1:]:
        name, fx, fy, z = (arg.split(":") + ["1"])[:4]
        src = cv2.imread(os.path.join(ROOT, "img", name + ".jpg"))
        c = cover(src, float(fx), float(fy), float(z))
        cv2.imwrite(os.path.join(FX, f"clear_{name}.jpg"), c, [cv2.IMWRITE_JPEG_QUALITY, 93])
        cv2.imwrite(os.path.join(FX, f"glass_{name}.jpg"), glass(c), [cv2.IMWRITE_JPEG_QUALITY, 93])
        print(name)

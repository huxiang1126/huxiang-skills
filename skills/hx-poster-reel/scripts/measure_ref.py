#!/usr/bin/env python3
"""Measure a reference reel before copying anything from it.

Writes ref_frames.jpg (every frame, or one per cut for long clips) and prints the cut list with each shot's length,
plus the frame rate and the shortest/longest/median shot. Run it first: ON FOOT's reference looked like a 20 s video, and turned out to be 19 posters at 0.2 s each (a 3.8 s GIF).

Usage: python measure_ref.py reference.mp4 [out_dir]
"""
import os, subprocess, sys
import numpy as np
import cv2

src = sys.argv[1]
out = sys.argv[2] if len(sys.argv) > 2 else "."
cap = cv2.VideoCapture(src)
fps = cap.get(cv2.CAP_PROP_FPS) or 30
frames, cuts, prev = [], [0.0], None
i = 0
while True:
    ok, f = cap.read()
    if not ok:
        break
    small = cv2.resize(cv2.cvtColor(f, cv2.COLOR_BGR2GRAY), (90, 160)).astype(np.float32)
    if prev is not None and np.abs(small - prev).mean() > 18:
        cuts.append(i / fps)
    prev = small
    frames.append(f)
    i += 1
dur = i / fps
shots = np.diff(cuts + [dur])
print(f"{src}: {dur:.2f} s, {fps:.2f} fps, {i} frames, {len(cuts)} shots")
print(f"shot length: min {shots.min():.3f}  median {np.median(shots):.3f}  max {shots.max():.3f} s")
for k, (t, d) in enumerate(zip(cuts, shots)):
    print(f"  shot {k + 1:3d}  at {t:7.3f} s  for {d:.3f} s")
# one tile per shot (its middle frame)
tiles = []
for t, d in zip(cuts, shots):
    f = frames[min(len(frames) - 1, int((t + d / 2) * fps))]
    h = 300
    tiles.append(cv2.resize(f, (int(f.shape[1] * h / f.shape[0]), h)))
cols = 6
w = max(t.shape[1] for t in tiles)
rows = [tiles[r:r + cols] for r in range(0, len(tiles), cols)]
sheet = np.vstack([np.hstack([cv2.copyMakeBorder(t, 0, 0, 0, w - t.shape[1], cv2.BORDER_CONSTANT) for t in row] +
                             [np.zeros((300, w, 3), np.uint8)] * (cols - len(row))) for row in rows])
os.makedirs(out, exist_ok=True)
cv2.imwrite(os.path.join(out, "ref_frames.jpg"), sheet)
print("wrote", os.path.join(out, "ref_frames.jpg"))

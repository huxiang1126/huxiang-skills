#!/usr/bin/env python3
"""Joins the rendered posters (build/posters) into the master on the song, 1080x1350 30 fps.
Audio: the user's 140 BPM track from 11.877 s to its last hit, plus a real camera shutter on each look's headline
poster, on each glass -> clear, and on the sign-off.   Run:  python tools/assemble.py  -> renders/OnFoot_master.mp4
                                                              python tools/assemble.py frames t ... -> build/chk.jpg"""
import json, os, subprocess, sys
import numpy as np
import cv2
import soundfile as sf
import librosa

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
E = json.load(open(os.path.join(ROOT, "build/edl.json")))
FPS, TOTAL = E["FPS"], E["TOTAL"]
W, H = 1080, 1350
NF = round(TOTAL * FPS)
SR = 44100
SHUTTER = "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Screen Capture.aif"

_cache = {}


def poster(sid, k):
    p = os.path.join(ROOT, "build/posters", sid, f"{k:03d}.jpg")
    if p not in _cache:
        if len(_cache) > 60:
            _cache.clear()
        _cache[p] = cv2.imread(p)
    return _cache[p]


def frame(i):
    for e in E["edl"]:
        if e["f0"] <= i < e["f1"]:
            k = min(i - e["f0"], len(os.listdir(os.path.join(ROOT, "build/posters", e["id"]))) - 2) if e["anim"] else 0
            return poster(e["id"], max(0, k))
    return poster(E["edl"][-1]["id"], 0)


def mix():
    N = int(TOTAL * SR)
    song, _ = librosa.load(E["SONG"], sr=SR, mono=False, offset=E["S0"])
    song = np.stack([song, song]) if song.ndim == 1 else song
    song = song * (0.9 / np.abs(song).max())
    out = np.zeros((2, N), np.float32)
    L = min(N, song.shape[1])
    out[:, :L] = song[:, :L]
    sh, _ = librosa.load(SHUTTER, sr=SR, mono=True)
    i0 = int(np.argmax(np.abs(sh) > 0.03 * np.abs(sh).max()))
    sh = sh[max(0, i0 - 20):]
    sh = sh / np.abs(sh).max()
    for t in E["shutters"] + [E["HIT"]]:
        a = int(t * SR)
        g = 0.45 if abs(t - E["HIT"]) < 0.01 else 0.32
        n = min(len(sh), N - a)
        out[:, a:a + n] += sh[:n] * g
    pk = np.abs(out).max()
    if pk > 0.97:
        out *= 0.97 / pk
    fo = int(0.4 * SR)
    out[:, -fo:] *= np.linspace(1, 0, fo) ** 1.5
    return out


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "frames":
        ts = [float(x) for x in sys.argv[2:]]
        tiles = [cv2.resize(frame(round(t * FPS)), (216, 270)) for t in ts]
        for im, t in zip(tiles, ts):
            cv2.putText(im, f"{t:.2f}", (4, 16), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 255), 1)
        while len(tiles) % 8:
            tiles.append(np.zeros_like(tiles[0]))
        cv2.imwrite(os.path.join(ROOT, "build/chk.jpg"), np.vstack([np.hstack(tiles[r * 8:(r + 1) * 8]) for r in range(len(tiles) // 8)]))
        sys.exit()
    wav = os.path.join(ROOT, "build/mix.wav")
    sf.write(wav, mix().T, SR, subtype="PCM_16")
    out = os.path.join(ROOT, "renders/OnFoot_master.mp4")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    enc = subprocess.Popen(["ffmpeg", "-loglevel", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{W}x{H}", "-r", str(FPS), "-i", "-",
                            "-i", wav, "-map", "0:v", "-map", "1:a", "-c:v", "libx264", "-crf", "15", "-preset", "medium", "-pix_fmt", "yuv420p",
                            "-c:a", "aac", "-b:a", "256k", "-shortest", "-movflags", "+faststart", out], stdin=subprocess.PIPE)
    for i in range(NF):
        enc.stdin.write(np.ascontiguousarray(frame(i)).tobytes())
    enc.stdin.close()
    enc.wait()
    print(out)

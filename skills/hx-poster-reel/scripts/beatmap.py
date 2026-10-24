#!/usr/bin/env python3
"""Map a track before cutting to it: tempo, beat length, the drop, and per beat how busy the hi-hats are and whether a
heavy bass hit (808 / kick) lands on it. That map decides where posters hold and where they flicker.

ON FOOT's track: 140 BPM (0.4287 s a beat, so half a beat is 0.21 s, one poster), drop at 15.307 s, and in every 16-beat
phrase the heavy hits fell on beats 0, 5, 8, 11 and 15. Holds went there, eighth notes in between, sixteenths on 13-15.

Usage: python beatmap.py song.wav [drop_seconds]
"""
import sys
import numpy as np
import librosa
from scipy.signal import butter, sosfiltfilt

path = sys.argv[1]
y, sr = librosa.load(path, sr=44100, mono=True)
tempo, beats = librosa.beat.beat_track(y=y, sr=sr)
bpm = float(np.atleast_1d(tempo)[0])
beat = 60.0 / bpm
lo = sosfiltfilt(butter(4, 120 / (sr / 2), output="sos"), y)
hi = sosfiltfilt(butter(4, 6000 / (sr / 2), btype="high", output="sos"), y)
if len(sys.argv) > 2:
    drop = float(sys.argv[2])
else:   # the first big rise in sub-bass energy
    e = np.convolve(lo ** 2, np.ones(2205) / 2205, "same")[::441]
    drop = float(np.argmax(e > 0.35 * e.max()) * 0.01)
env = librosa.onset.onset_strength(y=hi, sr=sr, hop_length=128)
t = librosa.frames_to_time(np.arange(len(env)), sr=sr, hop_length=128)
pk = t[librosa.util.peak_pick(env, pre_max=3, post_max=3, pre_avg=10, post_avg=10, delta=0.6, wait=6)]
loE = np.convolve(lo ** 2, np.ones(441) / 441, "same")[::441]
print(f"{path}: {len(y) / sr:.1f} s, {bpm:.1f} BPM, beat {beat:.4f} s, half beat {beat / 2:.3f} s, drop ~{drop:.3f} s")
print("per beat from the drop:  n:hats  B = heavy bass hit, b = lighter")
line, mb = "", loE.max()
for n in range(-8, int((len(y) / sr - drop) / beat)):
    s = drop + n * beat
    if s < 0:
        continue
    c = int(((pk >= s) & (pk < s + beat)).sum())
    bass = loE[int(s / 0.01):int((s + beat) / 0.01)].max() if s + beat < len(y) / sr else 0
    line += f"{n:4d}:{c}{'B' if bass > 0.5 * mb else ('b' if bass > 0.2 * mb else ' ')} "
    if (n + 9) % 8 == 7:
        print(line); line = ""
print(line)

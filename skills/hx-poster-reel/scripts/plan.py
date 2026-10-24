#!/usr/bin/env python3
"""ON FOOT — a rapid poster reel after @47thegreat_'s BECOMING, 4:5, cut to the user's 140 BPM hip-hop track
(assets/song.wav).

Timing: the video starts two bars before the drop (song 11.877 s), so the drop lands at 3.43 s. Four 16-beat
phrases follow, one per look, then a 4-beat tail and the sign-off after the song's last hit.
Inside each phrase the 808 hits fall on beats 0, 5, 8, 11 and 15: those get held posters, the hi-hat runs in
between get a new poster every eighth note, and beats 13-15 flicker on the sixteenths.

Writes build/shots.json (what to render) and build/edl.json (which frame shows what)."""
import json, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FPS = 30
BEAT = 0.4287
V0 = 8 * BEAT                     # the drop
SONG = os.path.join(ROOT, "assets/song.wav")      # your track; re-measure BEAT and the drop with beatmap.py
DROP_SONG = 15.307                # the drop in the song (seconds), from beatmap.py
S0 = DROP_SONG - 8 * BEAT         # song time at video t = 0
HIT = V0 + 68 * BEAT              # the song's last hit
TOTAL = round(HIT + 1.75, 3)


def b(n):
    return V0 + n * BEAT


P1 = ("Out by ten. Coffee in one hand, the tram bell somewhere behind. The jacket stays on until the sun reaches "
      "the crossing, then the knit comes off and ends up round the waist. Nothing planned. Everything worn.")
P2 = ("Four looks, one city, no set. Between traffic lights, on the tram line, at the crossing, by the harbour. "
      "Whoever walks past, walks past. Hong Kong moves fast, so the clothes have to walk: wide legs that swing, a "
      "jacket you can carry, a bag that stays on the shoulder when the light turns green.")
P3A = "Every frame happens on the street, between one green light and the next."
P3B = ("Nobody stops the traffic. Nobody holds the tram. The pictures are what the walk leaves behind: a coffee, "
       "a crossing, a jacket catching the sun.")

LOOKS = {
    "A": dict(
        t=dict(n="01", lk="LIGHT DENIM", lkzh="盘扣短夹克", h1="TRAM", h2="LINE", ht1="LIGHT", ht2="DENIM",
               s1="Ten a.m.,", s2="Central.", m1="WALK", m2="DON'T POSE", p1="ON", p2b="FOOT", bf1="SHORT", bf2="BLACK",
               script="Des Voeux", detail="FROG BUTTONS",
               rows=["A SHORT BLACK JACKET WITH FROG BUTTONS", "LIGHT WIDE-LEG DENIM", "A WHITE TEE AND A BURGUNDY SHOULDER BAG"],
               w3="TRAM BELL,\nGREEN LIGHT,\nGO.", itemsEn="FROG-BUTTON\nSHORT JACKET\nWHITE TEE\nLIGHT WIDE-LEG DENIM\nBURGUNDY SHOULDER BAG",
               itemsZh="盘扣短夹克 · 白T · 浅蓝阔腿牛仔 · 酒红肩包", itemsShort="SHORT JACKET\nLIGHT DENIM"),
        c=dict(bg="#1f3fe0", fg="#f4f1ea", pn="#f1ece4", ink="#121212", ac="#0d2350", on="#f1ece4", neon="#e4f21d", neonInk="#0d2350",
               navy="#0d2350", navyInk="#e4f21d", blue="#2047e8", g1="#1f3fe0", g2="#9cc0ff"),
        pool=["A_s26", "A_s29", "A_g22", "A_s27", "A_g31", "A_g12", "A_s28", "A_g32", "A_g11", "A_g33", "A_g13", "A_g21", "A_g23"],
        cuts=["A_s29", "A_g21", "A_s27"], detail=("A_g23", "50% 45%", 1.35), glass=("A_s26", 0.5, 0.22)),
    "B": dict(
        t=dict(n="02", lk="SUEDE & RED", lkzh="麂皮夹克", h1="SUEDE", h2="& SUN", ht1="COFFEE", ht2="FIRST",
               s1="Coffee first,", s2="then the tram.", m1="RED,", m2="TIED", p1="RED", p2b="KNIT", bf1="TIED", bf2="LOOSE",
               script="Suede.", detail="RED KNIT, TIED",
               rows=["A SUEDE JACKET OVER A GREY CARDIGAN", "WHITE WIDE-LEG TROUSERS", "A RED KNIT TIED AT THE WAIST"],
               w3="SUN ON\nTHE SUEDE,\nKNIT ROUND\nTHE WAIST.", itemsEn="SUEDE JACKET\nGREY CARDIGAN\nWHITE WIDE-LEG\nTROUSERS\nRED KNIT, TIED",
               itemsZh="麂皮夹克 · 灰开衫 · 白色阔腿裤 · 红毛衣系腰", itemsShort="SUEDE JACKET\nRED KNIT, TIED"),
        c=dict(bg="#d7392b", fg="#f6efe6", pn="#f3e7d8", ink="#2a1710", ac="#b5532a", on="#fbf3ea", neon="#ffd23f", neonInk="#3a1d10",
               navy="#3a1d10", navyInk="#ff6b4a", blue="#2047e8", g1="#d7392b", g2="#f2a07b"),
        pool=["B_s30", "B_n02", "B_g11", "B_s34", "B_h11", "B_n_walker", "B_g22", "B_s31", "B_h21", "B_n_coffee1", "B_g12", "B_h23",
              "B_s35", "B_g32", "B_n_corner", "B_h31", "B_g33", "B_h13", "B_g21", "B_g23", "B_h22", "B_g13", "B_g31"],
        cuts=["B_s34", "B_s30", "B_s30"], detail=("B_h32", "50% 50%", 1.15), glass=("B_n_walker", 0.5, 0.2)),
    "C": dict(
        t=dict(n="03", lk="SOFT CHECK", lkzh="细格立领夹克", h1="SOFT", h2="CHECK", ht1="STAND", ht2="COLLAR",
               s1="Sun on", s2="the crossing.", m1="SLOW", m2="WALK", p1="MID", p2b="DAY", bf1="HIGH", bf2="NOON",
               script="Midday.", detail="STAND COLLAR",
               rows=["A CHECK JACKET WITH A STAND COLLAR", "WHITE WIDE-LEG TROUSERS", "A FLUFFY CHAIN BAG AND PLATFORM LOAFERS"],
               w3="HALF PAST\nTWELVE,\nSTILL\nWALKING.", itemsEn="CHECK STAND-\nCOLLAR JACKET\nWHITE WIDE-LEG\nTROUSERS\nFLUFFY CHAIN BAG\nPLATFORM LOAFERS",
               itemsZh="细格立领夹克 · 白色阔腿裤 · 毛绒链条包 · 厚底乐福", itemsShort="CHECK JACKET\nWHITE TROUSERS"),
        c=dict(bg="#f2c230", fg="#161410", pn="#efe6d6", ink="#1d1a14", ac="#6b6a3c", on="#f5efe2", neon="#e2f200", neonInk="#1d1a14",
               navy="#24251c", navyInk="#f2c230", blue="#2047e8", g1="#c9b48f", g2="#f2c230"),
        pool=["C_s38", "C_s37", "C_steps", "C_s36", "C_tram", "C_s39", "C_legs", "C_rail", "C_collar"],
        cuts=["C_s38", "C_s36", "C_s36"], detail=("C_collar", "50% 25%", 1.25), glass=("C_s37", 0.5, 0.25)),
    "D": dict(
        t=dict(n="04", lk="ALL RED", lkzh="红色针织开衫", h1="RED", h2="CAP", ht1="ALL", ht2="RED",
               s1="Wherever", s2="the tram goes.", m1="KINGSTON", m2="STREET", p1="RED", p2b="KNIT", bf1="LAST", bf2="LIGHT",
               script="Kingston St.", detail="RIBBED CUFFS",
               rows=["A RED KNIT CARDIGAN AND THE CAP TO MATCH", "STRIPED WIDE-LEG TROUSERS", "A BLACK TOTE ON THE SHOULDER"],
               w3="RED CAP,\nRED KNIT,\nGREEN\nLIGHT.", itemsEn="RED KNIT CARDIGAN\nMATCHING CAP\nSTRIPED WIDE-LEG\nTROUSERS\nBLACK TOTE",
               itemsZh="红色针织开衫 · 同色棒球帽 · 条纹阔腿裤 · 黑色托特", itemsShort="RED CARDIGAN\nRED CAP"),
        c=dict(bg="#1e5b3a", fg="#f6efe6", pn="#f1e5dc", ink="#1b1b1b", ac="#c8231f", on="#f6efe6", neon="#f6d0c2", neonInk="#7a0f0c",
               navy="#123d27", navyInk="#ff5a4e", blue="#2047e8", g1="#7b4dff", g2="#e85cc8"),
        pool=["D_s40", "D_n_walk", "D_front", "D_s41", "D_stop", "D_back", "D_legs", "D_fruit", "D_cuff"],
        cuts=["D_s40", "D_s41", "D_front"], detail=("D_cuff", "80% 45%", 1.2), glass=("D_s41", 0.5, 0.22)),
}
for L in LOOKS.values():
    L["t"].update(p=P1, p2=P2, p3a=P3A, p3b=P3B)

SEGS = []        # (t0, t1, spec, (z0, z1) or None)


def seg(n0, n1, spec, zz=None):
    SEGS.append((b(n0), b(n1), spec, zz))


class Pool:
    def __init__(self, names):
        self.n, self.i = names, 0

    def __call__(self):
        v = self.n[self.i % len(self.n)]
        self.i += 1
        return v


def spec(tpl, L, **kw):
    s = dict(tpl=tpl, t=dict(LOOKS[L]["t"]), c=dict(LOOKS[L]["c"]))
    t = s["t"]
    if tpl in ("headtop",):
        t.update(h1=t["ht1"], h2=t["ht2"])
    if tpl in ("profile",):
        t.update(h1=t["p1"], h2=t["p2b"])
    if tpl in ("bluefield",):
        t.update(h1=t["bf1"], h2=t["bf2"])
    s.update(kw)
    return s


ORDER = "ABCD"
POOLS = {k: Pool(LOOKS[k]["pool"]) for k in ORDER}

# ---- intro: two bars before the drop, no hi-hats yet: slower, one poster a beat, then faster into the drop
seg(-8, -6, spec("cover", "B", cut="B_s34", t=dict(LOOKS["B"]["t"], h1="ON", h2="FOOT", tr="FOUR LOOKS\nONE CITY",
                                                     side="Four looks,\none city,\nno set."), c=dict(LOOKS["A"]["c"]), cx=600, ch=1200), (1.0, 1.035))
seg(-6, -5, spec("glass", "C", fx="C_s37", t=dict(LOOKS["C"]["t"], s1="Ten a.m.,", s2="Central.")))
seg(-5, -4, spec("clear", "C", fx="C_s37", t=dict(LOOKS["C"]["t"], s1="Ten a.m.,", s2="Central.")), (1.0, 1.03))
seg(-4, -3, spec("split", "D", img="D_s41", img2="D_front"), (1.0, 1.03))
seg(-3, -2, spec("half", "A", img="A_s26"), (1.0, 1.03))
seg(-2, -1.5, spec("navy", "B", img="B_n02", img2="B_h32"))
seg(-1.5, -1, spec("profile", "C", img="C_s39", t=dict(LOOKS["C"]["t"], h1="HONG", h2="KONG")))
for k, L in enumerate(ORDER):
    seg(-1 + k * 0.25, -1 + (k + 1) * 0.25, spec("rows", L, img=LOOKS[L]["pool"][0]))

# ---- one phrase per look
EIGHTHS_A = ["split", "half", "neon", "navy", "rows", "headtop"]
EIGHTHS_B = ["profile", "blackpage", "white", "bluefield"]
for k, L in enumerate(ORDER):
    n0 = 16 * k
    P = POOLS[L]
    cuts = LOOKS[L]["cuts"]
    hero = "cover" if L in "AC" else "web"
    seg(n0, n0 + 2, spec(hero, L, cut=cuts[0], cx=540 if hero == "cover" else 790), (1.0, 1.035))
    for i, tpl in enumerate(EIGHTHS_A):
        seg(n0 + 2 + i * 0.5, n0 + 2.5 + i * 0.5, spec(tpl, L, img=P(), img2=P(), img3=P()))
    di, dp, dz = LOOKS[L]["detail"]
    seg(n0 + 5, n0 + 6, spec("logo", L, img=di, pos=dp), (dz, dz * 1.06))
    for i, tpl in enumerate(EIGHTHS_B):
        seg(n0 + 6 + i * 0.5, n0 + 6.5 + i * 0.5, spec(tpl, L, img=P()))
    g = LOOKS[L]["glass"][0]
    seg(n0 + 8, n0 + 9, spec("glass", L, fx=g))
    seg(n0 + 9, n0 + 10, spec("clear", L, fx=g), (1.0, 1.03))
    seg(n0 + 10, n0 + 10.5, spec("half", L, img=P(), c=dict(LOOKS[L]["c"], ac=LOOKS[L]["c"]["navy"], on=LOOKS[L]["c"]["navyInk"])))
    seg(n0 + 10.5, n0 + 11, spec("split", L, img=P(), img2=P()))
    seg(n0 + 11, n0 + 12, spec("mirror", L, cut=cuts[2]), (1.0, 1.03))
    seg(n0 + 12, n0 + 13, spec("items", L, img=P()), (1.0, 1.03))
    for i in range(8):
        seg(n0 + 13 + i * 0.25, n0 + 13.25 + i * 0.25, spec("burst", L, img=P(), k=i + 1))
    if L != "D":                                   # beat 15: a look at the next look, in its colours
        N = ORDER[k + 1]
        seg(n0 + 15, n0 + 16, spec("gradient", N, cut=LOOKS[N]["cuts"][1]), (1.0, 1.03))
    else:
        seg(n0 + 15, n0 + 16, spec("massive", "D", imgs=["A_s26", "B_s30", "C_s38", "D_s40"],
                                   t=dict(LOOKS["D"]["t"], big="ON FOOT", p2s="Light denim. Suede and a red knit. A soft check. All red.")), (1.0, 1.02))

# ---- tail: the four looks together, then the sign-off after the last hit
seg(64, 68, spec("lineup", "A", cuts=["A_s27", "B_s30", "C_s38", "D_s40"], names=[LOOKS[k]["t"]["lkzh"] for k in ORDER],
                 c=dict(LOOKS["A"]["c"], bg="#f1ece4", fg="#121212")), (1.0, 1.0))
SEGS.append((HIT, TOTAL, spec("sign", "A"), None))

if __name__ == "__main__":
    shots, edl = [], []
    for i, (t0, t1, s, zz) in enumerate(SEGS):
        f0, f1 = round(t0 * FPS), round(t1 * FPS)
        sid = f"{i:03d}_{s['tpl']}"
        nf = max(1, f1 - f0)
        zs = [round(zz[0] + (zz[1] - zz[0]) * (1 - (1 - j / max(1, nf - 1)) ** 2), 4) for j in range(nf)] if zz and zz != (1.0, 1.0) else [s.get("z", 1)]
        shots.append(dict(id=sid, spec=s, zs=zs))
        edl.append(dict(f0=f0, f1=f1, id=sid, anim=len(zs) > 1))
    os.makedirs(os.path.join(ROOT, "build"), exist_ok=True)
    json.dump(shots, open(os.path.join(ROOT, "build/shots.json"), "w"), ensure_ascii=False)
    json.dump(dict(edl=edl, FPS=FPS, TOTAL=TOTAL, S0=S0, HIT=HIT, SONG=SONG, BEAT=BEAT, V0=V0,
                   shutters=[b(16 * k) for k in range(4)] + [b(16 * k + 9) for k in range(4)] + [b(-5)]),
              open(os.path.join(ROOT, "build/edl.json"), "w"))
    print(f"{len(SEGS)} posters, {sum(len(s['zs']) for s in shots)} renders, total {TOTAL}s, drop {V0:.3f}s, hit {HIT:.3f}s")
    gaps = [(round(a[1], 3), round(c[0], 3)) for a, c in zip(SEGS, SEGS[1:]) if abs(a[1] - c[0]) > 1e-6]
    print("gaps", gaps)

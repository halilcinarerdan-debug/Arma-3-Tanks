#!/usr/bin/env python3
"""
Oyun içi ekran görüntüsü DEĞİL: SQF'teki U-birim koordinatlarını ve gerçek PNG dokularını kullanan önizleme.
Arma'daki ctrlSetTextColor gibi dokuyu renkle çarpar. Kullanım: python3 tools/preview.py <çıktı klasörü>
"""
import sys, os, math
import numpy as np
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, os.path.dirname(__file__))
from labels import L as LABELS, LANGS, text as _ltext

OUTDIR = sys.argv[1] if len(sys.argv) > 1 else "."
LANG = sys.argv[2] if len(sys.argv) > 2 else "ru"          # tr | en | ru | de
DIRT = float(sys.argv[3]) if len(sys.argv) > 3 else 0.6      # kir katmanı opaklığı (CBA ayarı karşılığı)
def lbl(key): return _ltext(key, LANG)
DATA = os.path.join(os.path.dirname(__file__), "..", "addons", "tankui", "data")
W, H = 1920, 1080
SX, SY, SW, SH = W * 0.2, H * 0.08, W * 0.6, H * 0.84
sx, sy, sw, sh = SX + SW * 0.115, SY + SH * 0.07, SW * 0.845, SH * 0.86
u = sh / 17
bx, by = sx + 0.8 * u, sy + 0.4 * u
FONT = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"
_cache = {}

PAL = ""      # "leo" = Leopard 2 iç mekan paleti (kit.sqf _pal ile aynı)
def tex(name):
    if name not in _cache:
        _cache[name] = Image.open(os.path.join(DATA, name + "_ca.png")).convert("RGBA")
    return _cache[name]

def circle(size=128):
    im = Image.new("RGBA", (size * 3, size * 3), (0, 0, 0, 0))
    ImageDraw.Draw(im).ellipse([0, 0, size * 3 - 1, size * 3 - 1], fill=(255, 255, 255, 255))
    return im.resize((size, size), Image.LANCZOS)
DOT = circle()
RECT = Image.new("RGBA", (8, 8), (255, 255, 255, 255))

class Scene:
    def __init__(self):
        self.im = Image.new("RGBA", (W, H), (43, 47, 42, 255))
    def U(self, ox): return bx + ox * u
    def V(self, oy): return by + oy * u
    def paste(self, img, cx, cy, w, h, tint=(1, 1, 1, 1), ang=0):
        img = img.resize((max(1, int(round(w))), max(1, int(round(h)))), Image.LANCZOS)
        a = np.asarray(img).astype(np.float32)
        a[..., 0] *= tint[0]; a[..., 1] *= tint[1]; a[..., 2] *= tint[2]; a[..., 3] *= tint[3] if len(tint) > 3 else 1
        img = Image.fromarray(a.astype(np.uint8), "RGBA")
        if ang:
            img = img.rotate(-ang, expand=True, resample=Image.BICUBIC)
        self.im.alpha_composite(img, (int(round(cx - img.size[0] / 2)), int(round(cy - img.size[1] / 2))))
    def spr(self, name, ox, oy, wU, hU, tint=(1, 1, 1, 1), fb=None):
        self.paste(DOT if name == "@dot" else (RECT if name == "@rect" else tex(name)), self.U(ox), self.V(oy), wU * u, hU * u, tint)
    def rect(self, ox, oy, wU, hU, col): self.paste(RECT, self.U(ox), self.V(oy), wU * u, hU * u, col)
    def box(self, ox, oy, wU, hU, col): self.rect(ox + wU / 2, oy + hU / 2, wU, hU, col)
    def bar(self, bx_, by_, length, thick, ang, tint, name="needle"):   # placeRect: pivot merkezli kare
        self.paste(tex(name), bx_, by_, 2 * length, 2 * length, tint, ang)
    def txt(self, ox, oy, wU, hU, t, col=(0.84, 0.86, 0.8, 1), style=2, size=0.46):
        t = str(t)
        f = ImageFont.truetype(FONT, int(u * size * 1.0))
        d = ImageDraw.Draw(self.im)
        x = self.U(ox); y = self.V(oy)
        bb = d.textbbox((0, 0), t, font=f, anchor="ls")
        tw = bb[2] - bb[0]
        px = {0: x, 1: x + wU * u - tw, 2: x - tw / 2}[style]
        d.text((px, y), t, font=f, fill=tuple(int(c * 255) for c in col[:3]), anchor="lm")

dim = (0.62, 0.78, 0.58, 1)
GREEN = (0.25, 0.95, 0.35, 1); AMBER = (1, 0.72, 0.15, 1); RED = (0.95, 0.2, 0.15, 1)

def frame(S, active, labels):
    labels = [(lbl({2: "SCR_STATION", 0: "SCR_AMMO", 1: "SCR_STATUS"}[tab]), tab) for _, tab in labels]
    sc = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    S.paste(RECT, sx + sw / 2, sy + sh / 2, sw, sh, (0.012, 0.018, 0.014, 1))
    S.paste(tex("housing_" + PAL if PAL else "housing"), SX + SW / 2, SY + SH / 2, SW, SH)
    d = ImageDraw.Draw(S.im)
    f = ImageFont.truetype(FONT, int(H * 0.011 * 1.1))
    for i, (name, tab) in enumerate(labels):
        x0, y0 = SX + SW * 0.022, SY + SH * (0.20 + 0.12 * i)
        col = (36, 77, 33) if tab == active else (18, 20, 15)
        d.rounded_rectangle([x0, y0, x0 + SW * 0.076, y0 + SH * 0.075], radius=10, fill=col)
        d.text((x0 + SW * 0.038, y0 + SH * 0.0375), name, font=f, fill=(235, 240, 235) if PAL else (158, 199, 148), anchor="mm")
    x0, y0 = SX + SW * 0.022, SY + SH * 0.80
    d.rounded_rectangle([x0, y0, x0 + SW * 0.076, y0 + SH * 0.075], radius=10, fill=(18, 20, 15))
    d.text((x0 + SW * 0.038, y0 + SH * 0.0375), lbl("CLOSE"), font=f, fill=(235, 240, 235) if PAL else (158, 199, 148), anchor="mm")

def header(S, left, right):
    w = sw / u - 1.6
    ac = (0.9, 0.92, 0.9, 1) if PAL else dim
    S.txt(0, 0.45, w * 0.6, 0.7, left, ac, 0)
    S.txt(w * 0.6, 0.45, w * 0.4, 0.7, right, ac, 1)
    S.rect(w / 2, 1.1, w, 0.05, (0.55, 0.57, 0.55, 1) if PAL else (0.35, 0.45, 0.33, 1))

def lamp(S, ox, oy, name, col, on, pw=3.4):
    S.spr("label", ox, oy, pw, 0.95)
    S.txt(ox - 0.5, oy, pw - 1.2, 0.6, name)
    lx = ox + pw / 2 - 0.62
    k = col if on else tuple(c * 0.14 for c in col[:3]) + (1,)
    S.spr("@dot", lx, oy, 1.15, 1.15, (col[0], col[1], col[2], 0.22 if on else 0))
    S.spr("ring", lx, oy, 0.95, 0.95); S.spr("lens", lx, oy, 0.62, 0.62, k); S.spr("gloss", lx - 0.1, oy - 0.12, 0.55, 0.55)

def lamp_round(S, ox, oy, name, col, on, side="below"):
    k = col if on else tuple(c * 0.14 for c in col[:3]) + (1,)
    S.spr("@dot", ox, oy, 1.5, 1.5, (col[0], col[1], col[2], 0.25 if on else 0))
    sq = PAL in ("leo", "m1"); S.spr("ring_sq" if sq else "ring", ox, oy, 1.25, 1.25); S.spr("lens_sq" if sq else "lens", ox, oy, 0.85, 0.85, k); S.spr("gloss", ox - 0.14, oy - 0.16, 0.7, 0.7)
    if name:
        if side == "right": S.txt(ox + 0.9, oy, 3.2, 0.5, name, style=0, size=0.4)
        else: S.txt(ox, oy + 1.05, 2.6, 0.5, name, size=0.38)

def lamp_small(S, ox, oy, name, col, on):
    k = col if on else tuple(c * 0.14 for c in col[:3]) + (1,)
    S.spr("@dot", ox, oy, 1.2, 1.2, (col[0], col[1], col[2], 0.22 if on else 0))
    S.spr("ring", ox, oy, 0.95, 0.95); S.spr("lens", ox, oy, 0.64, 0.64, k); S.spr("gloss", ox - 0.1, oy - 0.12, 0.5, 0.5)
    if name: S.txt(ox, oy + 0.85, 2.1, 0.4, name, size=0.3)

def push_black(S, ox, oy, name, on):
    S.spr("recess", ox, oy, 2.1, 2.1); S.spr("ring", ox, oy, 1.7, 1.7, (0.25, 0.95, 0.35, 1) if on else (0.45, 0.46, 0.43, 1))
    S.spr("knob", ox, oy, 1.25, 1.25, (0.16, 0.16, 0.16, 1)); S.spr("gloss", ox - 0.2, oy - 0.25, 0.7, 0.7, (1, 1, 1, 0.5))
    S.txt(ox, oy + 1.4, 3.0, 0.5, name, size=0.38)

def toggle(S, ox, oy, name, ang, sc=1.0, lab=None):
    S.spr("recess", ox, oy, 1.7 * sc, 1.7 * sc); S.spr("ring", ox, oy, 1.15 * sc, 1.15 * sc)
    S.bar(S.U(ox), S.V(oy), u * 1.0 * sc, u * 0.3 * sc, ang, (1, 1, 1, 1), "lever")
    S.txt(ox, oy + 1.55 * sc, 2.6, 0.5, name, lab if lab else (0.84, 0.86, 0.8, 1), size=0.4 if sc >= 0.9 else 0.32)

def rotary(S, ox, oy, pos, idx, sc=1.0):
    S.spr("recess", ox, oy, 3.3 * sc, 3.3 * sc); S.spr("knob", ox, oy, 2.6 * sc, 2.6 * sc); S.spr("recess", ox, oy, 1.5 * sc, 1.5 * sc)
    for n, _, a in pos:
        S.txt(ox + math.sin(math.radians(a)) * 2.45 * sc, oy - math.cos(math.radians(a)) * 2.45 * sc, 1.8 * sc, 0.5, n, size=0.46 if sc >= 0.9 else 0.38)
    S.bar(S.U(ox), S.V(oy), u * 1.0 * sc, u * 0.26 * sc, pos[idx][2], (0.95, 0.95, 0.9, 1))

def gauge(S, ox, oy, r, name, mx, a0, a1, val, needle):
    D = r * 2 / 0.9
    S.spr(name, ox, oy, D, D)
    ang = a0 + (a1 - a0) * (max(0, min(mx, val)) / mx)
    L = r * 0.82 * u
    S.bar(S.U(ox), S.V(oy), L, L * 0.16, ang, needle)
    S.spr("knob", ox, oy, 0.55, 0.55, (0.7, 0.7, 0.7, 1))

def push(S, ox, oy, name, cap=(0.72, 0.1, 0.1, 1)):
    S.spr("recess", ox, oy, 2.0, 2.0); S.spr("ring", ox, oy, 1.65, 1.65); S.spr("lens", ox, oy, 1.2, 1.2, cap)
    S.spr("gloss", ox - 0.2, oy - 0.25, 0.8, 0.8); S.txt(ox, oy + 1.4, 3.2, 0.5, name)

SEG = {"0": "abcdef", "1": "bc", "2": "abged", "3": "abgcd", "4": "fgbc", "5": "afgcd", "6": "afgedc", "7": "abc", "8": "abcdefg", "9": "abcdfg", "-": "g", " ": "", "A": "abcefg", "F": "aefg", "b": "cdefg", "d": "bcdeg"}
def seven(S, ox, oy, text, n=4, k=1.0):
    wD, hD, t, st = 1.0 * k, 1.9 * k, 0.2 * k, 1.35 * k
    d = [(0, -hD / 2 + t / 2, wD - t * 1.2, t), (wD / 2 - t / 2, -hD / 4, t, hD / 2 - t * 1.2), (wD / 2 - t / 2, hD / 4, t, hD / 2 - t * 1.2),
         (0, hD / 2 - t / 2, wD - t * 1.2, t), (-wD / 2 + t / 2, hD / 4, t, hD / 2 - t * 1.2), (-wD / 2 + t / 2, -hD / 4, t, hD / 2 - t * 1.2), (0, 0, wD - t * 1.2, t)]
    text = text.rjust(n)
    for i in range(n):
        on = SEG[text[i]]
        for kx, (dx, dy, w, h) in enumerate(d):
            S.rect(ox + i * st + dx, oy + dy, w, h, (1, 0.16, 0.1, 1) if "abcdefg"[kx] in on else (0.2, 0.02, 0.02, 1))

def finish(S):
    S.paste(tex("glass"), sx + sw / 2, sy + sh / 2, sw, sh)
    if DIRT > 0: S.paste(tex("dirt"), sx + sw / 2, sy + sh / 2, sw, sh, (1, 1, 1, DIRT))

# ---------------------------------------------------------------- ISTASYON
VIOLET = (0.6, 0.35, 1, 1)
def station():
    global PAL
    PAL = "t72"
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "T-72B (Russian)  |  " + lbl("SCR_STATION"), lbl("ROLE_gunner"))
    # durum lambaları (kılavuz s.25)
    S.spr("label", 3.0, 3.6, 6.4, 4.4)
    for (x, y, k, c, on) in [(1.2, 2.7, "L_STAB", GREEN, 1), (3.0, 2.7, "L_MIRROR", RED, 1), (4.8, 2.7, "L_HYDR", GREEN, 1),
                             (3.0, 4.7, "L_DELTA", RED, 1), (4.8, 4.7, "L_LOADED", VIOLET, 1)]:
        lamp_small(S, x, y, lbl(k), c, on)
    # balistik üçgen + manuel anahtar
    S.txt(8.0, 1.8, 3.6, 0.5, lbl("BALL"), (0.62, 0.78, 0.58, 1))
    lamp_round(S, 8.0, 3.2, lbl("AM_KE"), AMBER, 1, "right"); lamp_round(S, 6.9, 5.0, lbl("AM_HE"), AMBER, 0); lamp_round(S, 8.0, 6.8, lbl("AM_HEAT"), AMBER, 0, "right")
    S.spr("knob", 10.2, 5.0, 1.5, 1.5); S.txt(10.2, 6.1, 2.6, 0.5, lbl("BALL_OVR"), size=0.38)
    toggle(S, 7.0, 9.0, lbl("T_AUTO"), 0); toggle(S, 9.6, 9.0, lbl("T_MIRROR"), 0)
    # mermi seçici, yükle, sayaç
    rotary(S, 3.0, 12.3, [(lbl("SEL_OFF"), "", -75), (lbl("SEL_KE"), "", -25), (lbl("SEL_HEAT"), "", 25), (lbl("SEL_HE"), "", 75)], 1)
    S.txt(3.0, 15.2, 5, 0.5, lbl("SEL_TITLE")); push(S, 6.9, 14.4, lbl("LOAD"), (0.2, 0.6, 0.25, 1))
    gauge(S, 9.8, 13.3, 1.4, "gauge_ammo", 11, -115, 115, 7, (0.05, 0.05, 0.05, 1)); S.txt(9.8, 15.2, 3.4, 0.5, lbl("AMMO_COUNT"), size=0.4)
    # LRF ekranı ve lambalar
    S.spr("display", 13.6, 2.6, 5.6, 2.7); seven(S, 11.575, 2.6, "1273")
    lamp_round(S, 18.0, 2.3, lbl("L_LRF"), GREEN, 1); lamp_round(S, 19.6, 2.3, lbl("L_READY"), RED, 1)
    # yay biçimli menzil çarkı + ateşe hazır lambası
    gauge(S, 14.4, 8.4, 3.1, "gauge_arc", 30, -80, 80, 12.7, (1, 0.45, 0.1, 1)) if False else None
    D = 3.1 * 2 / 0.9; S.spr("gauge_arc", 14.4, 8.4, D, D)
    L = 3.1 * 0.98 * u; S.bar(S.U(14.4), S.V(8.4), L, L * 0.16, -80 + 160 * 12.7 / 30, (1, 0.45, 0.1, 1)); S.spr("knob", 14.4, 8.4, 0.55, 0.55, (0.7, 0.7, 0.7, 1))
    lamp_round(S, 14.4, 6.9, "", RED, 1); S.txt(14.4, 9.6, 6, 0.5, lbl("RANGE"), size=0.42)
    push(S, 12.4, 11.6, lbl("LASE")); push(S, 15.4, 11.6, lbl("RESET"), (0.15, 0.15, 0.15, 1))
    toggle(S, 19.0, 11.3, lbl("T_MODE"), 0); S.txt(18.0, 9.9, 1.4, 0.5, "1200", size=0.4); S.txt(20.0, 9.9, 1.4, 0.5, "1800", size=0.4)
    push_black(S, 12.5, 14.3, lbl("T_DELTA"), 1); push_black(S, 14.9, 14.3, lbl("T_STAB"), 0); push_black(S, 17.3, 14.3, lbl("T_HYDR"), 0); toggle(S, 19.4, 14.5, lbl("T_LRFON"), 0)
    finish(S); PAL = ""; return S

# ---------------------------------------------------------------- MUHIMMAT
def ammo():
    S = Scene(); frame(S, 0, [("ISTASYON", 2), ("MUHIMMAT", 0), ("DURUM", 1)])
    header(S, "T-72B (Russian)  |  " + lbl("SCR_AMMO"), lbl("ROLE_gunner"))
    S.txt(2.4, 1.9, 4.8, 0.5, lbl("COL_WEAPON"), dim); S.txt(7.5, 1.9, 4.9, 0.5, lbl("COL_AMMO"), dim); S.txt(12.4, 1.9, 4.5, 0.5, lbl("COL_COUNT"), dim)
    rows = [("125MM 2A46", lbl("AM_KE_FULL"), 7, 1), ("125MM 2A46", lbl("AM_HEAT_FULL"), 8, 0), ("125MM 2A46", lbl("AM_HE_FULL"), 7, 0), ("PKT 7.62MM", "7.62MM PKT", 250, 0), ("NSVT 12.7MM", "12.7MM NSVT", 60, 0)]
    for i, (w, n, c, cur) in enumerate(rows):
        y = 3.5 + i * 2.3
        S.spr("label", 2.4, y, 4.8, 1.5); S.txt(2.4, y, 4.4, 0.6, w)
        S.spr("label", 7.5, y, 4.9, 1.5); S.txt(7.5, y, 4.5, 0.6, n, (1, 0.8, 0.3, 1) if cur else (0.84, 0.86, 0.8, 1))
        S.spr("display", 12.4, y, 4.5, 1.9); seven(S, 11.25, y, str(c), 3, 0.85)
        lx = 15.5; S.spr("ring", lx, y, 1.05, 1.05); S.spr("lens", lx, y, 0.68, 0.68, AMBER if cur else (0.14, 0.1, 0.02, 1)); S.spr("gloss", lx - 0.1, y - 0.12, 0.55, 0.55)
        S.spr("label", 18.2, y, 3.0, 1.4); S.txt(18.2, y, 2.8, 0.6, lbl("SELECT"), (0.6, 0.9, 0.6, 1))
    finish(S); return S

# ---------------------------------------------------------------- DURUM
def status():
    S = Scene(); frame(S, 1, [("ISTASYON", 2), ("MUHIMMAT", 0), ("DURUM", 1)])
    header(S, "T-72B (Russian)  |  " + lbl("SCR_STATUS"), lbl("ROLE_gunner"))
    dmg = {"hithull": 0.05, "hitengine": 0.0, "hitltrack": 0.35, "hitrtrack": 0.0, "hitturret": 0.0, "hitgun": 0.7, "hitfuel": 0.0}
    def col(d):
        h = 1 - d
        return (0.5, 0.8, 0.45, 1) if h >= 0.8 else ((1, 0.72, 0.15, 1) if h >= 0.4 else (0.95, 0.2, 0.15, 1))
    S.spr("display", 5.0, 8.7, 9.8, 14.6)
    for t, hp in [("tank_trackL", "hitltrack"), ("tank_trackR", "hitrtrack"), ("tank_hull", "hithull"), ("tank_engine", "hitengine"), ("tank_turret", "hitturret"), ("tank_gun", "hitgun")]:
        S.spr(t, 5.0, 8.7, 8.667, 13.0, col(dmg[hp]))
    zones = [(lbl("Z_hull"), "hithull"), (lbl("Z_engine"), "hitengine"), (lbl("Z_ltrack"), "hitltrack"), (lbl("Z_rtrack"), "hitrtrack"), (lbl("Z_turret"), "hitturret"), (lbl("Z_gun"), "hitgun"), (lbl("Z_fuel"), "hitfuel")]
    for i, (n, hp) in enumerate(zones):
        y = 2.7 + i * 1.35
        S.spr("label", 13.9, y, 5.6, 1.1); S.txt(11.3, y, 4.4, 0.6, n, style=0)
        S.txt(16.9, y, 2.3, 0.6, "%d%%" % round((1 - dmg[hp]) * 100), style=1)
        lx = 19.9; S.spr("ring", lx, y, 0.95, 0.95); S.spr("lens", lx, y, 0.62, 0.62, col(dmg[hp])); S.spr("gloss", lx - 0.1, y - 0.12, 0.5, 0.5)
    S.spr("display", 16.2, 13.5, 5.0, 2.3); seven(S, 15.1, 13.5, "32", 3, 0.85); S.txt(19.1, 13.5, 1.8, 0.5, lbl("KMH"), dim)
    gauge(S, 11.9, 14.0, 1.5, "gauge_fuel", 4, -60, 60, 3.1, (0.05, 0.05, 0.05, 1)); S.txt(11.9, 16.0, 3.0, 0.5, lbl("FUEL"), dim)
    lamp(S, 17.2, 16.0, lbl("ENGINE"), GREEN, 1, 3.8)
    finish(S); return S



# ---------------------------------------------------------------- SURUCU / KOMUTAN
def driver():
    S = Scene(); frame(S, 2, [("", 2), ("", 1)])
    header(S, "T-72B (Russian)  |  " + lbl("SCR_STATION"), lbl("ROLE_driver"))
    gauge(S, 5.6, 8.2, 4.2, "gauge_speed", 80, -120, 120, 32, (0.85, 0.15, 0.1, 1)); S.txt(5.6, 12.9, 4, 0.5, lbl("SPEED"), size=0.45)
    S.spr("display", 5.6, 15.3, 5.0, 2.2); seven(S, 4.4, 15.3, "32", 3, 0.9)
    gauge(S, 14.0, 4.6, 2.3, "gauge_fuel", 4, -60, 60, 3.1, (0.05, 0.05, 0.05, 1)); S.txt(14.0, 7.6, 4, 0.5, lbl("FUEL"), size=0.45)
    lamp_round(S, 11.8, 9.8, lbl("L_RUN"), GREEN, 1); S.txt(12.9, 8.6, 5, 0.5, lbl("FAULT"), dim, 2, 0.45)
    for x, k, on in ((14.8, "F_ENG", 0), (17.0, "F_LTR", 1), (19.2, "F_RTR", 0)): lamp_round(S, x, 9.8, lbl(k), RED, on)
    lamp_round(S, 11.8, 12.2, lbl("F_HULL"), RED, 0)
    toggle(S, 12.6, 14.6, lbl("T_ENGINE"), 0); toggle(S, 15.6, 14.6, lbl("T_LIGHT"), 180); toggle(S, 18.6, 14.6, lbl("T_HATCH"), 180)
    finish(S); return S

def cmdr():
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "T-72B (Russian)  |  " + lbl("SCR_STATION"), lbl("ROLE_commander"))
    crew = [("driver", "Baranov", 100), ("gunner", "hcinar33", 100), ("commander", "Sudakov", 85)]
    for i, (r, n, hp) in enumerate(crew):
        y = 2.8 + i * 1.7
        S.spr("label", 7.4, y, 14.2, 1.35); S.txt(0.9, y, 13, 0.7, lbl("ROLE_" + r) + ":  " + n + "   %d%%" % hp, style=0, size=0.5)
    for cx, k, v in ((3.5, "W_COAX", "250"), (9.0, "W_NSVT", "60"), (14.5, "SMOKE", "2")):
        S.txt(cx, 8.6, 5, 0.5, lbl(k), size=0.5); S.spr("display", cx, 10.2, 4.6, 2.0); seven(S, cx - 1.2, 10.2, v, 3, 0.9)
    for x, k, on in ((1.6, "F_ENG", 0), (4.2, "F_LTR", 1), (6.8, "F_RTR", 0), (9.4, "F_HULL", 0)): lamp_round(S, x, 13.4, lbl(k), RED, on)
    toggle(S, 16.0, 13.4, lbl("T_HATCH"), 180); push(S, 19.3, 13.2, lbl("SMOKE"), (0.45, 0.45, 0.45, 1))
    finish(S); return S

# ---------------------------------------------------------------- LEOPARD 2 AILESI
DIMG = (0.9, 0.92, 0.9, 1)
def leo_gunner():
    global PAL
    PAL = "leo"
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "Leopard 2A6  |  " + lbl("SCR_STATION"), lbl("ROLE_gunner"))
    S.spr("display", 4.9, 2.6, 7.6, 2.7); seven(S, 2.2, 2.6, "F196A", 5, 1.0); S.txt(4.9, 4.4, 7, 0.5, lbl("GPS_T"), DIMG, size=0.4)
    for x, k, c, on in [(11.2, "LED_BER", GREEN, 1), (13.5, "LED_ELD", RED, 1), (15.8, "LED_KSP", AMBER, 0), (18.1, "LED_STAB", GREEN, 1)]:
        lamp_round(S, x, 2.6, lbl(k), c, on)
    S.txt(0.9, 5.1, 8, 0.5, lbl("FC_TITLE"), DIMG, 0, 0.45)
    for k, y, on in [("FC_NORMAL", 6.3, 1), ("FC_EMERG", 7.7, 0), ("FC_MANUAL", 9.1, 0)]:
        S.spr("label", 4.4, y, 7.4, 1.15); lamp_round(S, 1.3, y, "", GREEN, on); S.txt(2.4, y, 6.5, 0.55, lbl(k), style=0, size=0.45)
    S.txt(10.6, 5.1, 7, 0.5, lbl("SEL_TITLE"), DIMG, 0, 0.45)
    for k, y, on, n, nd in [("AM_APFSDS", 6.3, 1, "18", 2), ("AM_HET", 7.7, 0, "10", 2), ("W_COAX", 9.1, 0, "3600", 4)]:
        S.spr("label", 15.2, y, 8.8, 1.15); lamp_round(S, 10.9, y, "", AMBER, on); S.txt(12.0, y, 5, 0.55, lbl(k), style=0, size=0.42)
        S.spr("display", 17.9, y, 3.0, 1.0); seven(S, 16.79 if nd == 4 else 17.53, y, n, nd, 0.55)
    push(S, 2.2, 10.8, lbl("LOAD"), (0.2, 0.6, 0.25, 1)); push(S, 5.4, 10.8, lbl("LASE")); push(S, 8.6, 10.8, lbl("RESET"), (0.15, 0.15, 0.15, 1))
    push(S, 11.8, 10.8, lbl("P_SS1500"), (0.45, 0.45, 0.45, 1)); push(S, 15.0, 10.8, lbl("P_BSL") + " 1000", (0.45, 0.45, 0.45, 1))
    toggle(S, 18.4, 11.0, lbl("T_LRFON"), 180)
    toggle(S, 2.2, 14.2, lbl("T_RMODE"), 0); push(S, 5.6, 14.0, lbl("P_RDN"), (0.45, 0.45, 0.45, 1)); push(S, 8.8, 14.0, lbl("P_RUP"), (0.45, 0.45, 0.45, 1))
    S.spr("display", 14.4, 14.2, 5.6, 1.9); seven(S, 12.4, 14.2, "1100", 4, 0.8); S.txt(18.0, 14.2, 3, 0.5, lbl("AVST_T"), DIMG, size=0.38)
    finish(S); PAL = ""; return S

def leo_cmdr(pal="leo", mg2="W_MG2", veh="Leopard 2A6"):
    global PAL
    PAL = pal
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, veh + "  |  " + lbl("SCR_STATION"), lbl("ROLE_commander"))
    for i, (r, n, hp) in enumerate([("driver", "Baranov", 100), ("gunner", "hcinar33", 100), ("commander", "Sudakov", 85)]):
        y = 2.8 + i * 1.6
        S.spr("label", 7.4, y, 14.2, 1.3); S.txt(0.9, y, 13, 0.7, lbl("ROLE_" + r) + ":  " + n + "   %d%%" % hp, style=0, size=0.5)
    S.txt(0.9, 7.6, 8, 0.5, lbl("T_TURRETPOS"), DIMG, 0, 0.45)
    S.spr("display", 10.4, 8.8, 18.6, 1.25)
    for i, n in enumerate([6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6]):
        S.txt(1.9 + i * 1.4, 8.8, 1.3, 0.7, str(n), (1, 0.72, 0.15, 1) if i == 6 else (0.45, 0.55, 0.43, 1), size=0.55)
    for cx, k, v in ((3.5, "W_COAX", "250"), (9.0, mg2, "60"), (14.5, "SMOKE", "16")):
        S.txt(cx, 10.4, 5, 0.5, lbl(k), size=0.5); S.spr("display", cx, 11.7, 4.6, 1.8); seven(S, cx - 1.1, 11.7, v, 3, 0.8)
    for x, k, on in ((1.6, "F_ENG", 0), (4.2, "F_LTR", 1), (6.8, "F_RTR", 0), (9.4, "F_HULL", 0)): lamp_round(S, x, 13.6, lbl(k), RED, on)
    toggle(S, 16.0, 13.4, lbl("T_HATCH"), 180); toggle(S, 12.8, 13.4, lbl("T_SMOKEARM"), 180); push(S, 19.3, 13.2, lbl("SMOKE"), (0.45, 0.45, 0.45, 1))
    finish(S); PAL = ""; return S

def leo_driver(pal="leo", veh="Leopard 2A6"):
    global PAL
    PAL = pal
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, veh + "  |  " + lbl("SCR_STATION"), lbl("ROLE_driver"))
    D = 2.9 * 2 / 0.9; S.spr("gauge_speed", 4.4, 5.8, D, D); L = 2.9 * 0.82 * u; S.bar(S.U(4.4), S.V(5.8), L, L * 0.16, -120 + 240 * 34 / 80, (0.85, 0.15, 0.1, 1)); S.spr("knob", 4.4, 5.8, 0.55, 0.55, (0.7, 0.7, 0.7, 1))
    S.txt(4.4, 9.4, 4, 0.5, lbl("SPEED"), size=0.45); S.spr("display", 4.4, 11.6, 5.0, 2.2); seven(S, 3.185, 11.6, "34", 3, 0.9)
    D = 1.2 * 2 / 0.9; S.spr("gauge_fuel", 9.2, 4.0, D, D); L = 1.2 * 0.82 * u; S.bar(S.U(9.2), S.V(4.0), L, L * 0.16, -60 + 120 * 3 / 4, (0.05, 0.05, 0.05, 1)); S.txt(9.2, 6.0, 3, 0.5, lbl("FUEL"), size=0.45)
    S.spr("display", 15.4, 6.6, 8.6, 7.6); S.txt(11.7, 3.1, 4, 0.5, lbl("REAR_T"), DIMG, 0, 0.42)
    for n in ["tank_trackL", "tank_trackR", "tank_hull", "tank_engine", "tank_turret", "tank_gun"]: S.spr(n, 15.4, 5.25, 2.7, 4.05, (0.5, 0.55, 0.48, 1))
    for m, y in [(5, 8.0), (10, 8.7), (15, 9.4)]:
        S.rect(15.4, y, 6.6, 0.05, (0.45, 0.55, 0.43, 1)); S.txt(11.7, y, 1.2, 0.5, str(m), DIMG, size=0.4)
    for cx, d, col in [(14.0, 11, GREEN), (15.4, 4, RED), (16.8, 8, AMBER)]:
        S.rect(cx, 7.3 + d * 0.14 / 2, 1.0, d * 0.14, col); S.txt(cx, 10.1, 1.6, 0.5, "%d m" % d, size=0.4)
    for x, k, c, on in [(10.6, "L_RUN", GREEN, 1), (12.8, "F_ENG", RED, 0), (15.0, "F_LTR", RED, 1), (17.2, "F_RTR", RED, 0), (19.4, "F_HULL", RED, 0)]: lamp_round(S, x, 11.3, lbl(k), c, on)
    toggle(S, 12.0, 13.9, lbl("T_ENGINE"), 0); toggle(S, 15.2, 13.9, lbl("T_LIGHT"), 180); toggle(S, 18.4, 13.9, lbl("T_HATCH"), 180)
    finish(S); PAL = ""; return S


def m1_gunner():
    global PAL
    PAL = "m1"
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "M1A2 Abrams  |  " + lbl("SCR_STATION"), lbl("ROLE_gunner"))
    S.spr("display", 4.9, 2.6, 7.6, 2.7); seven(S, 2.875, 2.6, "1960", 4, 1.0); S.txt(4.9, 4.4, 7, 0.5, lbl("RANGE_M"), DIMG, size=0.4)
    for x, k, c, on in [(11.2, "L_READY", GREEN, 1), (13.5, "L_LRF", RED, 1), (15.8, "W_COAX", AMBER, 0), (18.1, "LED_STAB", GREEN, 1)]:
        lamp_round(S, x, 2.6, lbl(k), c, on)
    S.txt(0.9, 5.1, 8, 0.5, lbl("M1_FC_T"), DIMG, 0, 0.45)
    for k, y, on in [("M1_FC_ON", 6.3, 1), ("M1_FC_PWR", 7.7, 0), ("M1_FC_MAN", 9.1, 0)]:
        S.spr("label", 4.4, y, 7.4, 1.15); lamp_round(S, 1.3, y, "", GREEN, on); S.txt(2.4, y, 6.5, 0.55, lbl(k), style=0, size=0.4)
    S.txt(10.6, 5.1, 7, 0.5, lbl("SEL_TITLE"), DIMG, 0, 0.45)
    for k, y, on, n, nd in [("AM_SABOT", 6.3, 1, "18", 2), ("AM_HEATM", 7.7, 0, "10", 2), ("W_COAXM", 9.1, 0, "3600", 4)]:
        S.spr("label", 15.2, y, 8.8, 1.15); lamp_round(S, 10.9, y, "", AMBER, on); S.txt(12.0, y, 5, 0.55, lbl(k), style=0, size=0.4)
        S.spr("display", 17.9, y, 3.0, 1.0); seven(S, 16.79 if nd == 4 else 17.53, y, n, nd, 0.55)
    push(S, 2.2, 10.8, lbl("LOAD"), (0.2, 0.6, 0.25, 1)); push(S, 5.4, 10.8, lbl("LASE")); push(S, 8.6, 10.8, lbl("RESET"), (0.15, 0.15, 0.15, 1))
    toggle(S, 18.4, 11.0, lbl("T_LRFON"), 180)
    toggle(S, 2.2, 14.2, lbl("T_RMODE"), 0); push(S, 5.6, 14.0, lbl("P_RDN"), (0.45, 0.45, 0.45, 1)); push(S, 8.8, 14.0, lbl("P_RUP"), (0.45, 0.45, 0.45, 1))
    S.spr("display", 14.4, 14.2, 5.6, 1.9); seven(S, 12.4, 14.2, "1100", 4, 0.8); S.txt(18.0, 14.2, 3, 0.5, lbl("AVST_T"), DIMG, size=0.38)
    finish(S); PAL = ""; return S


def m1_cmdr(): return leo_cmdr("m1", "W_M2", "M1A2 Abrams")
def m1_driver(): return leo_driver("m1", "M1A2 Abrams")

# ---------------------------------------------------------------- T-72B3 (2012) nisanci (yalnizca islevli parcalar)
def t72b3():
    global PAL
    PAL = "t72"
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "T-72B3  |  " + lbl("SCR_STATION"), lbl("ROLE_gunner"))
    S.spr("label", 3.4, 3.5, 6.0, 3.4)
    for (x, y, k, c, on) in [(1.5, 2.6, "L_STAB", GREEN, 1), (3.4, 2.6, "L_MIRROR", RED, 1), (5.3, 2.6, "L_HYDR", GREEN, 1), (3.4, 4.3, "L_DELTA", RED, 1), (5.3, 4.3, "L_LOADED", VIOLET, 1)]: lamp_small(S, x, y, lbl(k), c, on)
    push_black(S, 1.3, 7.6, lbl("T_DELTA"), 1); push_black(S, 3.5, 7.6, lbl("T_STAB"), 0); push_black(S, 5.7, 7.6, lbl("T_HYDR"), 0)
    rotary(S, 3.6, 12.1, [("О", "", -80), ("Б", "", -40), ("К", "", 0), ("У", "", 40), ("П", "", 80)], 1, 0.8)
    push(S, 7.2, 11.6, lbl("LOAD"), (0.2, 0.6, 0.25, 1))
    D = 0.95 * 2 / 0.9; S.spr("gauge_ammo", 7.2, 14.8, D, D); L = 0.95 * 0.82 * u; S.bar(S.U(7.2), S.V(14.8), L, L * 0.16, -115 + 230 * 7 / 11, (0.05, 0.05, 0.05, 1))
    S.spr("display", 13.4, 3.4, 5.4, 2.4); seven(S, 11.4, 3.4, "1273", 4, 0.95)
    lamp_small(S, 10.2, 6.3, "", (1, 0.85, 0.15, 1), 1); toggle(S, 11.7, 6.4, "Д", 0, 0.8)
    lamp_small(S, 10.2, 8.4, lbl("L_READY"), RED, 1)
    lamp_small(S, 10.2, 10.6, "", GREEN, 1); toggle(S, 11.7, 10.7, "РУЧ / АВТ", 180, 0.8)
    lamp_small(S, 10.2, 12.7, lbl("L_ATGM"), GREEN, 0)
    D = 3.0 * 2 / 0.9; S.spr("gauge_arc", 16.4, 12.4, D, D); L = 3.0 * 0.98 * u; S.bar(S.U(16.4), S.V(12.4), L, L * 0.16, -80 + 160 * 12.7 / 30, (1, 0.45, 0.1, 1)); S.spr("knob", 16.4, 12.4, 0.55, 0.55, (0.7, 0.7, 0.7, 1))
    S.txt(16.4, 15.1, 6, 0.5, lbl("RANGE"), size=0.42)
    push(S, 13.4, 13.0, lbl("P_RDN"), (0.45, 0.45, 0.45, 1)); push(S, 19.4, 13.0, lbl("P_RUP"), (0.45, 0.45, 0.45, 1))
    push(S, 15.6, 7.0, lbl("LASE")); push(S, 18.2, 7.0, lbl("RESET"), (0.15, 0.15, 0.15, 1))
    finish(S); PAL = ""; return S

def leo_ball():
    global PAL
    PAL = "leo"
    S = Scene(); frame(S, 2, [("", 2), ("", 0), ("", 1)])
    header(S, "Leopard 2A5  |  " + lbl("BAL_T"), lbl("ROLE_gunner"))
    for key, y, val in [("BAL_ALT", 3.8, " 12"), ("BAL_AIR", 6.1, " 18"), ("BAL_POW", 8.4, " 20"), ("BAL_WIND", 10.7, "  3")]:
        S.spr("label", 6.2, y, 11.0, 1.4); S.txt(0.9, y, 8.8, 0.6, lbl(key), style=0, size=0.45)
        S.spr("display", 14.0, y, 3.8, 1.5); seven(S, 12.9, y, val, 4, 0.55)
        push(S, 17.0, y, "", (0.45, 0.45, 0.45, 1)); S.txt(17.0, y, 1.0, 0.6, "-", (0.05, 0.05, 0.05, 1), size=0.6)
        push(S, 19.0, y, "", (0.45, 0.45, 0.45, 1)); S.txt(19.0, y, 1.0, 0.6, "+", (0.05, 0.05, 0.05, 1), size=0.6)
    toggle(S, 2.2, 13.0, lbl("T_RMODE"), 180)
    S.txt(9.6, 13.0, 9.5, 0.5, lbl("BAL_ENV") + ": 18 °C   12 (x10 m)   3 m/s", (0.9, 0.92, 0.9, 1), size=0.4)
    push(S, 19.0, 13.2, lbl("BAL_BACK"), (0.2, 0.6, 0.25, 1))
    finish(S); PAL = ""; return S

# ---------------------------------------------------------------- NISANGAH PLAKALARI (HUD)
def hud():
    global u, bx, by
    saved = (u, bx, by)          # HUD kendi ölçeğini kullanır; sonraki ekranlar bozulmasın diye geri yüklenir
    S = Scene()
    # arka plan: optik penceresi (kullanıcının ekran görüntüsündeki yerleşim) + Arma'nın kendi panelleri
    S.paste(RECT, W / 2, H / 2, W, H, (0.02, 0.02, 0.02, 1))
    S.paste(RECT, W / 2, H * 0.52, W * 0.74, H * 0.74, (0.52, 0.62, 0.72, 1))
    S.paste(RECT, W * 0.07, H * 0.09, W * 0.13, H * 0.1, (0.15, 0.15, 0.15, 1))        # Arma hasar paneli (sol üst)
    S.paste(RECT, W * 0.93, H * 0.06, W * 0.13, H * 0.08, (0.15, 0.12, 0.12, 1))       # Arma silah paneli (sağ üst)
    d = ImageDraw.Draw(S.im)
    f = ImageFont.truetype(FONT, 22)
    d.text((W / 2, H * 0.84), "0272 RDY", font=f, fill=(150, 235, 110), anchor="mm")    # Arma menzil göstergesi
    d.text((W * 0.07, H * 0.09), "Arma panel", font=f, fill=(200, 200, 200), anchor="mm")
    d.text((W * 0.93, H * 0.06), "Arma silah/mermi", font=f, fill=(230, 120, 120), anchor="mm")
    u = 0.013 * W                      # 1 U = ekran genişliğinin %1,3'ü
    colW, gap = 9, 0.6
    x0L, x0R, yTop = 0.5 * u, W - (colW + 0.5) * u, 0.17 * H
    def plate(px, py, w, h):
        global bx, by
        bx, by = px, py
        S.box(-0.12, -0.12, w + 0.24, h + 0.24, (0, 0, 0, 0.88)); S.box(0, 0, w, h, (0.27, 0.31, 0.22, 0.94)); S.box(0.2, 0.2, w - 0.4, h - 0.4, (0.05, 0.06, 0.05, 0.92))
        for fx, fy in [(0.04, 0.05), (0.96, 0.05), (0.04, 0.95), (0.96, 0.95)]:
            S.spr("ring", fx * w, fy * h, 0.34, 0.34, (0.6, 0.6, 0.57, 1))
    hA, hB, hC, hD = 8.4, 5.9, 6.0, 8.6
    plate(x0L, yTop, colW, hA)
    for key, y, on in (("AM_KE", 1.5, 1), ("AM_HE", 3.0, 0), ("AM_HEAT", 4.5, 0)): lamp_round(S, 1.3, y, lbl(key), AMBER, on, "right")
    lamp_round(S, 5.6, 1.5, lbl("L_LOADED"), VIOLET, 1, "right"); lamp_round(S, 5.6, 3.0, lbl("L_READY"), RED, 1, "right")
    S.txt(0.8, 6.2, 7.4, 0.7, lbl("W_MAIN") + " | " + lbl("AM_KE"), AMBER, 0, 0.55)
    yB = yTop + (hA + gap) * u
    plate(x0L, yB, colW, hB)
    lamp_round(S, 1.3, 1.5, lbl("L_STAB"), GREEN, 1, "right"); lamp_round(S, 5.6, 1.5, lbl("L_HYDR"), GREEN, 1, "right")
    lamp_round(S, 1.3, 3.0, lbl("L_MIRROR"), RED, 1, "right"); lamp_round(S, 5.6, 3.0, lbl("L_DELTA"), RED, 0, "right")
    lamp_round(S, 1.3, 4.5, lbl("L_LRF"), GREEN, 1, "right"); S.txt(5.6, 4.5, 3.2, 0.6, "NORM", (0.84, 0.86, 0.8, 1), 0, 0.5)
    plate(x0R, yTop, colW, hC)
    S.spr("display", 4.5, 2.6, 6.2, 2.7); seven(S, 2.475, 2.6, "0272"); S.txt(4.5, 4.9, 7, 0.6, lbl("RANGE_M"), dim, 2, 0.5)
    yD = yTop + (hC + gap) * u
    plate(x0R, yD, colW, hD)
    for key, val, y in (("AM_KE", "22", 1.7), ("AM_HE", "10", 3.5), ("AM_HEAT", "9", 5.3), ("W_COAX", "450", 7.1)):
        S.txt(0.9, y, 3.6, 0.6, lbl(key), (0.84, 0.86, 0.8, 1), 0, 0.55); seven(S, 4.4, y, val, 3, 0.6)
    u, bx, by = saved
    return S

if __name__ == "__main__":
    os.makedirs(OUTDIR, exist_ok=True)
    for name, fn in [("tablet_istasyon", station), ("tablet_muhimmat", ammo), ("tablet_durum", status), ("nisangah_hud", hud), ("surucu", driver), ("komutan", cmdr), ("leo_nisanci", leo_gunner), ("leo_komutan", leo_cmdr), ("leo_surucu", leo_driver), ("m1_nisanci", m1_gunner), ("m1_komutan", m1_cmdr), ("m1_surucu", m1_driver), ("t72b3_nisanci", t72b3), ("leo_balistik", leo_ball)]:
        fn().im.convert("RGB").save(os.path.join(OUTDIR, name + "_" + LANG + ".png")); print("yazildi", name + "_" + LANG)

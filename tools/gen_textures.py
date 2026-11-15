#!/usr/bin/env python3
"""
Steel Tank UI doku üretici (PNG). Arma için .paa'ya dönüştürülmelidir:
  Arma 3 Tools > ImageToPAA   (veya HEMTT/Mikero ile derlemede otomatik)
Dosya adı son ekleri: _ca = renk+alfa. Oyun kodu \\z\\tank33\\addons\\tankui\\data\\<ad>.paa yolunu arar;
yoksa düz renk yedeğine düşer.

Kullanım:  python3 tools/gen_textures.py [çıktı klasörü]
"""
import sys, math, os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "addons", "tankui", "data")
os.makedirs(OUT, exist_ok=True)
rng = np.random.default_rng(7)
FONT = "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf"
FONTB = "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf"


def font(size, bold=False):
    try:
        return ImageFont.truetype(FONTB if bold else FONT, size)
    except Exception:
        return ImageFont.load_default()


# ad -> (kir şiddeti, çizik sayısı, sararma). Ölçek kolay ayar için tek yerde.
WEAR = {
    "housing": (1.0, 55, 0.0), "gauge_ammo": (0.8, 26, 0.12), "gauge_fuel": (0.8, 26, 0.12), "gauge_speed": (0.8, 26, 0.12),
    "gauge_range": (0.6, 30, 0.0), "gauge_arc": (0.6, 30, 0.0), "knob": (0.6, 10, 0.0),
    "ring": (0.5, 6, 0.0), "recess": (0.4, 0, 0.0), "label": (0.9, 14, 0.0), "display": (0.5, 8, 0.0),
    "lever": (0.4, 4, 0.0), "tank_trackL": (0.3, 0, 0.0), "tank_trackR": (0.3, 0, 0.0), "tank_hull": (0.3, 0, 0.0),
    "tank_turret": (0.3, 0, 0.0), "tank_gun": (0.3, 0, 0.0), "tank_engine": (0.3, 0, 0.0),
}
WEAR_SCALE = 1.0   # genel kir çarpanı (0 = temiz)


def save(img, name):
    if name in WEAR and WEAR_SCALE > 0:
        st, sc, ye = WEAR[name]
        img = wear(img, st * WEAR_SCALE, int(sc * WEAR_SCALE), ye)
    # Arma/Pal2Pace yalnızca 2'nin kuvveti boyutları kabul eder (en/boy ayrı ayrı, azami 2048).
    # Oyunda doku kontrol kutusuna gerildiği için en-boy oranı bozulmaz.
    def p2(n):
        p = 1
        while p < n:
            p *= 2
        return min(2048, p)
    nw, nh = p2(img.size[0]), p2(img.size[1])
    if (nw, nh) != img.size:
        img = img.resize((nw, nh), Image.LANCZOS)
    img.save(os.path.join(OUT, name + "_ca.png"))
    print("yazildi", name + "_ca.png", img.size)


def arr(img):
    return np.asarray(img.convert("RGBA")).astype(np.float32)


def to_img(a):
    return Image.fromarray(np.clip(a, 0, 255).astype(np.uint8), "RGBA")


def smooth_noise(w, h, scale, amp):
    small = rng.normal(0, 1, (max(2, h // scale), max(2, w // scale)))
    im = Image.fromarray(((small - small.min()) / (np.ptp(small) + 1e-6) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
    return (np.asarray(im).astype(np.float32) / 255 - 0.5) * 2 * amp


def wear(img, s, scratches=0, yellow=0.0):
    """Toz/yağ lekeleri (kahverengimsi koyulaşma), çizikler, toz benekleri, hafif sararma. Alfa korunur."""
    a = arr(img)
    H, W = a.shape[:2]
    big = smooth_noise(W, H, max(6, W // 9), 1.0)
    mid = smooth_noise(W, H, max(3, W // 30), 1.0)
    D = np.clip(big * 0.9 + mid * 0.7 - 0.12, 0, 1) * min(1.0, s)
    a[..., :3] *= (1 - 0.48 * D)[..., None]
    a[..., 0] += 9 * D; a[..., 1] += 5 * D; a[..., 2] -= 7 * D               # kahverengi kir tonu
    a[..., :3] *= (1 - 0.05 * min(1.0, s))
    a[..., 2] *= (1 - yellow)                                                # eskimiş kadran sararması
    # damlama izleri: dikey koyu çizgiler
    if s > 0.5:
        L = Image.new("L", (W, H), 0)
        dr = ImageDraw.Draw(L)
        for _ in range(int(max(2, W // 60 * s))):
            x = int(rng.uniform(0, W)); y0 = int(rng.uniform(0, H * 0.7)); ln = int(rng.uniform(H * 0.05, H * 0.3))
            dr.line([x, y0, x + int(rng.normal(0, 2)), y0 + ln], fill=int(rng.uniform(14, 30)), width=int(rng.integers(1, 3)))
        m = np.asarray(L.filter(ImageFilter.GaussianBlur(1.2))).astype(np.float32)
        a[..., :3] *= (1 - m / 255)[..., None]
    # çizikler: ince açık çizgiler
    if scratches:
        L = Image.new("L", (W, H), 0)
        dr = ImageDraw.Draw(L)
        for _ in range(scratches):
            x, y = rng.uniform(0, W), rng.uniform(0, H)
            ang = rng.uniform(0, math.pi); ln = rng.uniform(0.02, 0.12) * max(W, H)
            dr.line([x, y, x + math.cos(ang) * ln, y + math.sin(ang) * ln], fill=int(rng.uniform(40, 120) * min(1.0, s + 0.3)), width=1)
        m = np.asarray(L.filter(ImageFilter.GaussianBlur(0.5))).astype(np.float32)
        a[..., :3] += m[..., None] * 0.9
    # toz benekleri
    sp = rng.random((H, W))
    a[..., :3] *= (1 - (sp > 0.9992) * 0.5)[..., None]
    a[..., :3] += ((sp < 0.0006) * 60)[..., None]
    return to_img(a)


def rrect_mask(w, h, box, radius, ss=3):
    m = Image.new("L", (w * ss, h * ss), 0)
    d = ImageDraw.Draw(m)
    x0, y0, x1, y1 = [v * ss for v in box]
    d.rounded_rectangle([x0, y0, x1, y1], radius=radius * ss, fill=255)
    return np.asarray(m.resize((w, h), Image.LANCZOS)).astype(np.float32) / 255


def circle_mask(size, r, cx=None, cy=None, ss=3):
    cx = size / 2 if cx is None else cx
    cy = size / 2 if cy is None else cy
    m = Image.new("L", (size * ss, size * ss), 0)
    ImageDraw.Draw(m).ellipse([(cx - r) * ss, (cy - r) * ss, (cx + r) * ss, (cy + r) * ss], fill=255)
    return np.asarray(m.resize((size, size), Image.LANCZOS)).astype(np.float32) / 255


def blur(a, r):
    return np.asarray(Image.fromarray((a * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(r))).astype(np.float32) / 255


# ------------------------------------------------------------------ kasa
def housing():
    W, H = 1152, 907
    base = np.zeros((H, W, 4), np.float32)
    yy, xx = np.mgrid[0:H, 0:W]
    light = 1.10 - 0.22 * (xx / W * 0.5 + yy / H * 0.5)             # sol-üstten ışık
    col = np.array([86, 98, 72], np.float32)                         # zeytin yeşili sert plastik
    base[..., :3] = col * light[..., None]
    grain = rng.normal(0, 3.2, (H, W))                               # ince tane
    base[..., :3] += grain[..., None] + smooth_noise(W, H, 40, 4.0)[..., None]
    base[..., 3] = 255

    outer = np.ones((H, W), np.float32)      # dış silüet dikdörtgen: köşelerde şeffaf boşluk kalmaz
    # kenar kabartması: üst/sol açık, alt/sağ koyu
    edge_in = blur(outer, 5)
    ex = np.gradient(edge_in, axis=1)
    ey = np.gradient(edge_in, axis=0)
    bevel = (-(ex + ey)) * 60
    base[..., :3] += bevel[..., None]

    base[:5, :, :3] += 26; base[:, :5, :3] += 18                   # üst/sol açık kenar
    base[-5:, :, :3] -= 30; base[:, -5:, :3] -= 22                  # alt/sağ koyu kenar

    # ekran deliği + iç gölge
    sx0, sy0, sx1, sy1 = int(W * 0.115), int(H * 0.07), int(W * 0.96), int(H * 0.93)
    hole = rrect_mask(W, H, (sx0, sy0, sx1, sy1), 14)
    shadow = blur(rrect_mask(W, H, (sx0 - 6, sy0 - 6, sx1 + 6, sy1 + 6), 18), 9)
    base[..., :3] *= (1 - 0.55 * shadow * (1 - hole))[..., None]

    # siyah lastik köşe tamponları
    bw, bh = int(W * 0.095), int(H * 0.115)
    ext = 60
    for (bx0, by0, bx1, by1) in [(-ext, -ext, bw, bh), (W - bw, -ext, W + ext, bh), (-ext, H - bh, bw, H + ext), (W - bw, H - bh, W + ext, H + ext)]:
        m = rrect_mask(W, H, (bx0, by0, bx1, by1), 34)
        rub = np.array([22, 23, 21], np.float32) + rng.normal(0, 2.2, (H, W))[..., None]
        for c in range(3):
            base[..., c] = base[..., c] * (1 - m) + rub[..., c] * m

    # kenar/köşe boya sıyrığı: gri metal
    band = np.clip(blur(outer, 2) - blur(outer, 14), 0, 1)
    chips = (smooth_noise(W, H, 14, 1.0) + rng.normal(0, 0.25, (H, W)) > 0.55) & (band > 0.12)
    metal = np.array([138, 138, 132], np.float32)
    for c in range(3):
        base[..., c] = np.where(chips, base[..., c] * 0.25 + metal[c] * 0.75, base[..., c])
    img = to_img(base)
    d = ImageDraw.Draw(img, "RGBA")

    # sol taraftaki donanım düğmesi yuvaları (config ile aynı konumlar)
    for i in range(3):
        y = int(H * (0.20 + 0.12 * i))
        d.rounded_rectangle([int(W * 0.022), y, int(W * 0.098), y + int(H * 0.075)], radius=12, fill=(18, 20, 17, 255), outline=(60, 66, 52, 255), width=2)
    d.rounded_rectangle([int(W * 0.022), int(H * 0.80), int(W * 0.098), int(H * 0.875)], radius=12, fill=(18, 20, 17, 255), outline=(60, 66, 52, 255), width=2)

    # LED yuvaları (üst-sol, tablet gibi)
    for i in range(4):
        cy = int(H * (0.105 + 0.0 * i)); cx = int(W * (0.03 + 0.02 * i))
        d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], fill=(14, 16, 13, 255), outline=(70, 76, 62, 255))

    # vidalar (tamponların üzerinde)
    def screw(cx, cy, r=11, a=35):
        d.ellipse([cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2], fill=(10, 11, 9, 255))
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(120, 124, 116, 255))
        d.ellipse([cx - r + 2, cy - r + 2, cx + r - 5, cy + r - 5], fill=(160, 164, 156, 120))
        dx, dy = math.cos(math.radians(a)) * (r - 3), math.sin(math.radians(a)) * (r - 3)
        d.line([cx - dx, cy - dy, cx + dx, cy + dy], fill=(40, 42, 38, 255), width=3)
    for (cx, cy) in [(W * 0.05, H * 0.06), (W * 0.95, H * 0.06), (W * 0.05, H * 0.94), (W * 0.95, H * 0.94)]:
        screw(int(cx), int(cy))

    # dış kenar alfa (yuvarlak köşeler) ve ekran deliği şeffaf
    out = np.asarray(img).astype(np.float32).copy()
    out[..., 3] = 255 * outer * (1 - hole)
    save(to_img(out), "housing")


# ------------------------------------------------------------------ cam
def glass():
    W, H = 1024, 800
    yy, xx = np.mgrid[0:H, 0:W]
    t = (xx / W + yy / H)                     # çapraz yansıma bandı
    band = np.exp(-((t - 0.55) / 0.10) ** 2) * 0.07 + np.exp(-((t - 0.95) / 0.05) ** 2) * 0.04
    vx = np.minimum(xx, W - 1 - xx) / (W * 0.5)
    vy = np.minimum(yy, H - 1 - yy) / (H * 0.5)
    vig = (1 - np.clip(np.minimum(vx, vy) * 6, 0, 1)) * 0.35      # kenar karartması
    a = np.zeros((H, W, 4), np.float32)
    a[..., :3] = 255
    a[..., 3] = band * 255
    v = np.zeros_like(a)
    v[..., 3] = vig * 255
    out = Image.alpha_composite(to_img(v), to_img(a))
    # parmak izi/yağ lekeleri ve cam çizikleri
    sm = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(sm)
    for _ in range(14):
        cx, cy = rng.uniform(0.1, 0.9) * W, rng.uniform(0.1, 0.9) * H
        rx, ry = rng.uniform(25, 90), rng.uniform(18, 60)
        d.ellipse([cx - rx, cy - ry, cx + rx, cy + ry], fill=(220, 220, 210, int(rng.uniform(8, 26))))
    sm = sm.filter(ImageFilter.GaussianBlur(7))
    sc = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(sc)
    for _ in range(36):
        x, y = rng.uniform(0, W), rng.uniform(0, H)
        ang = rng.uniform(0, math.pi); ln = rng.uniform(30, 260)
        d.line([x, y, x + math.cos(ang) * ln, y + math.sin(ang) * ln], fill=(235, 235, 225, int(rng.uniform(14, 48))), width=1)
    out = Image.alpha_composite(Image.alpha_composite(out, sm), sc)
    save(out, "glass")


def dirt():
    """Ayrı kir katmanı (cam üstü): köşelerde yağ/kurum, lekeler, toz. Oyunda CBA ayarıyla opaklığı değişir."""
    W, H = 1024, 800
    yy, xx = np.mgrid[0:H, 0:W]
    ex = np.minimum(xx, W - 1 - xx) / (W * 0.5)
    ey = np.minimum(yy, H - 1 - yy) / (H * 0.5)
    corner = np.clip(1 - np.minimum(ex, ey) * 3.2, 0, 1) ** 1.4
    blot = np.clip(smooth_noise(W, H, 70, 1.0) * 0.9 + smooth_noise(W, H, 18, 1.0) * 0.5 - 0.1, 0, 1)
    streak = np.clip(smooth_noise(W, H, 6, 1.0) * 0.4, 0, 1)
    A = np.clip(corner * 0.65 + blot * 0.30 + streak * 0.10, 0, 1)
    a = np.zeros((H, W, 4), np.float32)
    a[..., 0], a[..., 1], a[..., 2] = 30, 24, 16
    a[..., 3] = A * 215
    L = Image.new("L", (W, H), 0)
    d = ImageDraw.Draw(L)
    for _ in range(120):
        x, y = rng.uniform(0, W), rng.uniform(0, H)
        r = rng.uniform(1, 3.2)
        d.ellipse([x - r, y - r, x + r, y + r], fill=int(rng.uniform(40, 140)))
    sp = np.asarray(L.filter(ImageFilter.GaussianBlur(0.8))).astype(np.float32)
    a[..., 3] = np.clip(a[..., 3] + sp, 0, 255)
    save(to_img(a), "dirt")


# ------------------------------------------------------------------ gösterge kadranı
def gauge(name, vmax, a0, a1, label_step, face, ink, labels=None, sub=0, ring=(120, 122, 116)):
    S = 512
    c = S / 2
    R = S / 2 - 2
    a = np.zeros((S, S, 4), np.float32)
    yy, xx = np.mgrid[0:S, 0:S]
    rr = np.hypot(xx - c, yy - c)
    ang = np.degrees(np.arctan2(yy - c, xx - c))
    ring_m = circle_mask(S, R)
    face_r = R * 0.90
    face_m = circle_mask(S, face_r)
    # çerçeve: eğik fırçalanmış metal
    metal = (np.array(ring, np.float32) * (0.75 + 0.4 * np.cos(np.radians(ang - 225)) * 0.5 + 0.2))[..., None] if False else None
    shade = 0.78 + 0.28 * np.cos(np.radians(ang + 135))
    for ch in range(3):
        a[..., ch] = ring[ch] * shade + rng.normal(0, 2.0, (S, S))
    a[..., 3] = ring_m * 255
    # yüz
    f = np.array(face, np.float32)
    fg = 1.0 - 0.18 * np.clip((rr / face_r) ** 3, 0, 1)             # kenara doğru hafif koyulaşma
    for ch in range(3):
        a[..., ch] = a[..., ch] * (1 - face_m) + (f[ch] * fg + rng.normal(0, 1.5, (S, S))) * face_m
    # iç gölge halkası
    ins = blur(face_m, 6) - face_m
    a[..., :3] *= (1 - np.clip(blur(1 - face_m, 5) * face_m * 0.9, 0, 1))[..., None]
    img = to_img(a)
    d = ImageDraw.Draw(img, "RGBA")
    ink = tuple(ink) + (255,)
    n = vmax
    for i in range(n + 1):
        ang_d = a0 + (a1 - a0) * i / n
        s, co = math.sin(math.radians(ang_d)), -math.cos(math.radians(ang_d))
        r0, r1 = face_r * 0.72, face_r * 0.95
        d.line([c + s * r0, c + co * r0, c + s * r1, c + co * r1], fill=ink, width=5 if i % label_step == 0 else 3)
        if sub and i < n:
            for k in range(1, sub + 1):
                ad = a0 + (a1 - a0) * (i + k / (sub + 1)) / n
                s2, c2 = math.sin(math.radians(ad)), -math.cos(math.radians(ad))
                d.line([c + s2 * face_r * 0.84, c + c2 * face_r * 0.84, c + s2 * r1, c + c2 * r1], fill=ink, width=2)
        if i % label_step == 0:
            txt = labels[i // label_step] if labels else str(i)
            tx, ty = c + s * face_r * 0.52, c + co * face_r * 0.52
            f_ = font(34, True)
            bb = d.textbbox((0, 0), txt, font=f_)
            d.text((tx - (bb[2] - bb[0]) / 2, ty - (bb[3] - bb[1]) / 2 - bb[1]), txt, font=f_, fill=ink)
    save(img, name)


# ------------------------------------------------------------------ yay biçimli menzil çarkı (kılavuz s.15)
def gauge_arc(name="gauge_arc", vmax=30, a0=-80, a1=80, step=5):
    S = 512
    c = S / 2
    R = S / 2 - 4
    img = Image.new("RGBA", (S * 2, S * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cc = S                                                     # 2x süper örnekleme
    r_out, r_in = R * 2 * 0.98, R * 2 * 0.60
    # yay bandı: siyah, metal kenarlı
    d.pieslice([cc - r_out - 8, cc - r_out - 8, cc + r_out + 8, cc + r_out + 8], 270 + a0 - 3, 270 + a1 + 3, fill=(120, 122, 116, 255))
    d.pieslice([cc - r_out, cc - r_out, cc + r_out, cc + r_out], 270 + a0, 270 + a1, fill=(12, 13, 12, 255))
    d.pieslice([cc - r_in, cc - r_in, cc + r_in, cc + r_in], 270 + a0 - 1, 270 + a1 + 1, fill=(0, 0, 0, 0))
    ink = (232, 232, 224, 255)
    for i in range(vmax + 1):
        a = a0 + (a1 - a0) * i / vmax
        s_, c_ = math.sin(math.radians(a)), -math.cos(math.radians(a))
        major = i % step == 0
        r0 = r_in + (r_out - r_in) * (0.55 if major else 0.72)
        d.line([cc + s_ * r0, cc + c_ * r0, cc + s_ * (r_out - 12), cc + c_ * (r_out - 12)], fill=ink, width=8 if major else 4)
        if major:
            t = str(i)
            f_ = font(64, True)
            tx, ty = cc + s_ * (r_in + (r_out - r_in) * 0.30), cc + c_ * (r_in + (r_out - r_in) * 0.30)
            bb = d.textbbox((0, 0), t, font=f_)
            d.text((tx - (bb[2] - bb[0]) / 2, ty - (bb[3] - bb[1]) / 2 - bb[1]), t, font=f_, fill=ink)
    save(img.resize((S, S), Image.LANCZOS), name)


# ------------------------------------------------------------------ ibre
def needle():
    """Kare doku, pivot = merkez, ibre merkezden yukarı uzanır (uç üstte). Kontrol karesi merkez etrafında döndürüldüğü için
    oyunda hiçbir açıda kırpılmaz (ince dikdörtgen dokular döndürülünce kırpılıyordu)."""
    S = 512; c = S / 2; k = 2
    img = Image.new("RGBA", (S * k, S * k), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.polygon([((c - 14) * k, c * k), ((c + 14) * k, c * k), ((c + 10) * k, (c + 44) * k), ((c - 10) * k, (c + 44) * k)], fill=(200, 200, 200, 255))   # kuyruk
    d.polygon([((c - 12) * k, c * k), ((c + 12) * k, c * k), ((c + 3.5) * k, 6 * k), ((c - 3.5) * k, 6 * k)], fill=(240, 240, 240, 255))               # gövde
    d.polygon([(c * k, c * k), ((c + 12) * k, c * k), ((c + 3.5) * k, 6 * k), (c * k, 6 * k)], fill=(168, 168, 168, 255))                              # gölgeli yarı
    save(img.resize((S, S), Image.LANCZOS), "needle")


# ------------------------------------------------------------------ lens / halka / parlama
def lens():
    S = 128
    yy, xx = np.mgrid[0:S, 0:S]
    r = np.hypot(xx - S / 2, yy - S / 2) / (S / 2)
    a = np.zeros((S, S, 4), np.float32)
    a[..., :3] = (255 * (1.0 - 0.45 * np.clip(r, 0, 1) ** 2.2))[..., None]       # merkez parlak, kenar koyu
    a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "lens")


def gloss():
    S = 128
    yy, xx = np.mgrid[0:S, 0:S]
    r1 = np.hypot(xx - S * 0.36, yy - S * 0.30) / (S * 0.28)
    a = np.zeros((S, S, 4), np.float32)
    a[..., :3] = 255
    a[..., 3] = np.clip(1 - r1, 0, 1) ** 1.6 * 200
    save(to_img(a), "gloss")


def ring():
    S = 128
    yy, xx = np.mgrid[0:S, 0:S]
    ang = np.degrees(np.arctan2(yy - S / 2, xx - S / 2))
    r = np.hypot(xx - S / 2, yy - S / 2) / (S / 2)
    a = np.zeros((S, S, 4), np.float32)
    sh = 0.72 + 0.30 * np.cos(np.radians(ang + 135))
    a[..., :3] = (np.array([150, 152, 146], np.float32) * sh[..., None])
    inner = np.clip((r - 0.62) / 0.06, 0, 1)                    # iç koyu boşluk
    for ch, v in enumerate((16, 16, 15)):
        a[..., ch] = a[..., ch] * inner + v * (1 - inner)
    a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "ring")


def knob():
    S = 256
    yy, xx = np.mgrid[0:S, 0:S]
    dx, dy = xx - S / 2, yy - S / 2
    r = np.hypot(dx, dy) / (S / 2)
    ang = np.degrees(np.arctan2(dy, dx))
    base = 150 * (0.8 + 0.25 * np.cos(np.radians(ang + 135)) * np.clip(r * 1.4, 0, 1))
    base += 12 * np.sin(r * 90)                                  # fırçalanmış halkalar
    notch = (np.sin(np.radians(ang) * 12) > 0.3) & (r > 0.86)
    base = np.where(notch, base * 0.55, base)
    base *= (1 - 0.25 * np.clip((r - 0.9) / 0.1, 0, 1))
    a = np.zeros((S, S, 4), np.float32)
    a[..., :3] = (base + rng.normal(0, 2, (S, S)))[..., None]
    a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "knob")


def recess():
    S = 256
    yy, xx = np.mgrid[0:S, 0:S]
    r = np.hypot(xx - S / 2, yy - S / 2) / (S / 2)
    a = np.zeros((S, S, 4), np.float32)
    v = 20 + 14 * np.clip((r - 0.7) / 0.3, 0, 1)
    a[..., :3] = v[..., None]
    a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "recess")


def lever():
    """Kare doku, pivot = merkez; kol merkezden yukarı, ucunda topuz. 180 derece döndürülünce aşağı bakar."""
    S = 256; c = S / 2
    xx = np.arange(S)[None, :].repeat(S, 0).astype(np.float32)
    t = (xx - c) / 18.0
    shade = 170 + 70 * np.cos((t + 0.35) * 1.4) - 40 * np.minimum(1.0, np.abs(t))
    a = np.zeros((S, S, 4), np.float32)
    a[..., :3] = shade[..., None]
    m = Image.new("L", (S * 3, S * 3), 0)
    md = ImageDraw.Draw(m)
    md.rounded_rectangle([(c - 9) * 3, 24 * 3, (c + 9) * 3, (c + 10) * 3], radius=8 * 3, fill=255)     # gövde
    md.ellipse([(c - 20) * 3, 2 * 3, (c + 20) * 3, 42 * 3], fill=255)                                     # topuz
    md.ellipse([(c - 13) * 3, (c - 13) * 3, (c + 13) * 3, (c + 13) * 3], fill=255)                        # pivot göbeği
    a[..., 3] = np.asarray(m.resize((S, S), Image.LANCZOS)).astype(np.float32)
    save(to_img(a), "lever")


def label():
    W, H = 256, 64
    m = rrect_mask(W, H, (1, 1, W - 2, H - 2), 8)
    a = np.zeros((H, W, 4), np.float32)
    yy = np.mgrid[0:H, 0:W][0]
    a[..., :3] = (14 + 10 * (1 - yy / H))[..., None]
    edge = blur(m, 1.5)
    a[..., :3] += ((m - edge) * 90)[..., None]                       # ince açık kenar
    a[..., 3] = m * 255
    save(to_img(a), "label")


def display():
    W, H = 512, 224
    m = rrect_mask(W, H, (1, 1, W - 2, H - 2), 12)
    yy, xx = np.mgrid[0:H, 0:W]
    a = np.zeros((H, W, 4), np.float32)
    a[..., :3] = (6 + 10 * (1 - yy / H))[..., None]
    a[..., 2] += 4
    inner = rrect_mask(W, H, (8, 8, W - 9, H - 9), 8)
    a[..., :3] *= (0.6 + 0.4 * inner)[..., None]
    a[..., :3] += ((m - blur(m, 2)) * 120)[..., None]
    a[..., 3] = m * 255
    save(to_img(a), "display")


# ------------------------------------------------------------------ tank şeması (DURUM ekranı)
def tank_parts():
    W, H = 384, 576
    def new(): return Image.new("RGBA", (W, H), (0, 0, 0, 0))
    def finish(img, name):
        a = arr(img)
        a[..., :3] *= 1.0
        # hafif iç gölge/aydınlık: şekle kabartma
        m = a[..., 3] / 255
        gx = np.gradient(blur(m, 3), axis=1); gy = np.gradient(blur(m, 3), axis=0)
        a[..., :3] = np.clip(a[..., :3] + ((-(gx + gy)) * 400)[..., None] * (m[..., None]), 0, 255)
        save(to_img(a), name)
    # paletler
    for side, x0 in (("L", 40), ("R", W - 40 - 62)):
        im = new(); d = ImageDraw.Draw(im)
        d.rounded_rectangle([x0, 70, x0 + 62, H - 60], radius=14, fill=(215, 215, 215, 255))
        for y in range(84, H - 70, 22):
            d.line([x0 + 6, y, x0 + 56, y], fill=(160, 160, 160, 255), width=3)
        finish(im, "tank_track" + side)
    im = new(); d = ImageDraw.Draw(im)                                   # gövde
    d.polygon([(112, 96), (W - 112, 96), (W - 100, H - 80), (100, H - 80)], fill=(215, 215, 215, 255))
    d.polygon([(130, 70), (W - 130, 70), (W - 112, 112), (112, 112)], fill=(215, 215, 215, 255))
    finish(im, "tank_hull")
    im = new(); d = ImageDraw.Draw(im)                                   # taret
    d.ellipse([W / 2 - 88, 210, W / 2 + 88, 396], fill=(215, 215, 215, 255))
    d.ellipse([W / 2 - 30, 280, W / 2 + 30, 340], fill=(150, 150, 150, 255))
    finish(im, "tank_turret")
    im = new(); d = ImageDraw.Draw(im)                                   # top
    d.rounded_rectangle([W / 2 - 10, 6, W / 2 + 10, 250], radius=8, fill=(215, 215, 215, 255))
    d.rectangle([W / 2 - 16, 4, W / 2 + 16, 28], fill=(190, 190, 190, 255))
    finish(im, "tank_gun")
    im = new(); d = ImageDraw.Draw(im)                                   # motor güvertesi
    d.rounded_rectangle([W / 2 - 70, H - 190, W / 2 + 70, H - 90], radius=10, fill=(215, 215, 215, 255))
    for y in range(H - 180, H - 98, 14):
        d.line([W / 2 - 62, y, W / 2 + 62, y], fill=(150, 150, 150, 255), width=3)
    finish(im, "tank_engine")


if __name__ == "__main__":
    housing(); glass(); dirt()
    gauge("gauge_ammo", 11, -115, 115, 2, (236, 233, 220), (24, 24, 22))
    gauge("gauge_range", 30, -100, 100, 5, (14, 15, 14), (232, 232, 224), sub=4)
    gauge("gauge_fuel", 4, -60, 60, 1, (236, 233, 220), (24, 24, 22), labels=["E", "1/4", "1/2", "3/4", "F"], sub=3)
    gauge("gauge_speed", 8, -120, 120, 1, (236, 233, 220), (24, 24, 22), labels=["0", "10", "20", "30", "40", "50", "60", "70", "80"], sub=4)
    gauge_arc(); needle(); lens(); gloss(); ring(); knob(); recess(); lever(); label(); display(); tank_parts()

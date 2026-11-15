#!/usr/bin/env python3
"""
Steel Tank UI doku üretici (PNG). Arma için .paa'ya dönüştürülmelidir:
  Arma 3 Tools > ImageToPAA   (veya HEMTT/Mikero ile derlemede otomatik)
Dosya adı son ekleri: _ca = renk+alfa. Oyun kodu \\sb\\tankui\\data\\<ad>.paa yolunu arar;
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


def save(img, name):
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

    outer = rrect_mask(W, H, (0, 0, W - 1, H - 1), 70)
    # kenar kabartması: üst/sol açık, alt/sağ koyu
    edge_in = blur(outer, 5)
    ex = np.gradient(edge_in, axis=1)
    ey = np.gradient(edge_in, axis=0)
    bevel = (-(ex + ey)) * 60
    base[..., :3] += bevel[..., None]

    # ekran deliği + iç gölge
    sx0, sy0, sx1, sy1 = int(W * 0.115), int(H * 0.07), int(W * 0.96), int(H * 0.93)
    hole = rrect_mask(W, H, (sx0, sy0, sx1, sy1), 14)
    shadow = blur(rrect_mask(W, H, (sx0 - 6, sy0 - 6, sx1 + 6, sy1 + 6), 18), 9)
    base[..., :3] *= (1 - 0.55 * shadow * (1 - hole))[..., None]

    # siyah lastik köşe tamponları
    bw, bh = int(W * 0.095), int(H * 0.115)
    for (x0, y0) in [(0, 0), (W - bw, 0), (0, H - bh), (W - bw, H - bh)]:
        m = rrect_mask(W, H, (x0 + 2, y0 + 2, x0 + bw - 2, y0 + bh - 2), 34)
        rub = np.array([22, 23, 21], np.float32) + rng.normal(0, 2.2, (H, W))[..., None]
        for c in range(3):
            base[..., c] = base[..., c] * (1 - m) + rub[..., c] * m

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
    save(out, "glass")


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


# ------------------------------------------------------------------ ibre
def needle():
    W, H = 64, 512
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # konik ibre: tabanda geniş, uçta sivri; uç üstte
    d.polygon([(W / 2 - 13, H), (W / 2 + 13, H), (W / 2 + 2, 4), (W / 2 - 2, 4)], fill=(235, 235, 235, 255))
    d.polygon([(W / 2, H), (W / 2 + 13, H), (W / 2 + 2, 4), (W / 2, 4)], fill=(170, 170, 170, 255))
    save(img.filter(ImageFilter.GaussianBlur(0.6)), "needle")


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
    W, H = 48, 256
    a = np.zeros((H, W, 4), np.float32)
    xx = np.arange(W)[None, :].repeat(H, 0)
    t = (xx - W / 2) / (W / 2)
    shade = 170 + 70 * np.cos((t + 0.35) * 1.4) - 40 * np.abs(t)
    a[..., :3] = shade[..., None]
    a[..., 3] = 255
    img = to_img(a)
    m = Image.new("L", (W, H), 0)
    md = ImageDraw.Draw(m)
    md.rounded_rectangle([W / 2 - 11, 28, W / 2 + 11, H], radius=6, fill=255)
    md.ellipse([W / 2 - 22, 0, W / 2 + 22, 44], fill=255)         # uç topuz
    out = np.asarray(img).copy()
    out[..., 3] = np.asarray(m)
    save(Image.fromarray(out, "RGBA"), "lever")


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
    housing(); glass()
    gauge("gauge_ammo", 11, -115, 115, 2, (236, 233, 220), (24, 24, 22))
    gauge("gauge_range", 30, -100, 100, 5, (14, 15, 14), (232, 232, 224), sub=4)
    gauge("gauge_fuel", 4, -60, 60, 1, (236, 233, 220), (24, 24, 22), labels=["E", "1/4", "1/2", "3/4", "F"], sub=3)
    needle(); lens(); gloss(); ring(); knob(); recess(); lever(); label(); display(); tank_parts()

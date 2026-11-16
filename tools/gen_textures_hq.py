"""
Yüksek kaliteli doku üretimi (gen_textures.py üzerine): yükseklik haritası + gerçek aydınlatma (normal/diffüz/speküler),
çok oktavlı gürültü, kenar aşınması, süper örnekleme. Aynı dosya adlarının üzerine yazar; PNG -> PAA çevirmeyi unutmayın.
Kullanım: python3 tools/gen_textures_hq.py [housing|small|gauges|all]
"""
import sys, math
_WHAT = sys.argv[1] if len(sys.argv) > 1 else "all"
sys.argv = sys.argv[:1]            # gen_textures argv[1] bunu çıktı klasörü sanıyor
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
import gen_textures as G
from gen_textures import rng, save, to_img, blur, rrect_mask, circle_mask, font

LIGHT = np.array([-0.55, -0.60, 0.58], np.float32); LIGHT /= np.linalg.norm(LIGHT)


def fbm(w, h, base=96, octaves=6, persist=0.55):
    out = np.zeros((h, w), np.float32); amp = 1.0; tot = 0.0; s = base
    for _ in range(octaves):
        sm = rng.normal(0, 1, (max(2, h // max(1, s)), max(2, w // max(1, s)))).astype(np.float32)
        im = Image.fromarray(((sm - sm.min()) / (np.ptp(sm) + 1e-6) * 255).astype(np.uint8)).resize((w, h), Image.BICUBIC)
        out += (np.asarray(im).astype(np.float32) / 255 - 0.5) * 2 * amp
        tot += amp; amp *= persist; s = max(2, s // 2)
    return out / tot


def lit(height, albedo, strength=2.2, spec=0.30, shin=28, ambient=0.52):
    gy, gx = np.gradient(height)
    nx, ny, nz = -gx * strength, -gy * strength, np.ones_like(height)
    n = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / n, ny / n, nz / n
    diff = np.clip(nx * LIGHT[0] + ny * LIGHT[1] + nz * LIGHT[2], 0, 1)
    hv = LIGHT + np.array([0, 0, 1], np.float32); hv /= np.linalg.norm(hv)
    sp = np.clip(nx * hv[0] + ny * hv[1] + nz * hv[2], 0, 1) ** shin * spec
    dn = np.clip(diff / LIGHT[2], 0, 1.5)                                       # düz yüzey = 1.0 (albedo aynen)
    return albedo * (ambient + (1 - ambient) * dn)[..., None] + (sp * 255)[..., None]


def edge_wear_mask(shape_mask, wid=6, noise_scale=18, thr=0.0):
    """Şeklin kenarına yakın, gürültüyle parçalanmış sıyrık maskesi."""
    h, w = shape_mask.shape
    band = np.clip(blur(shape_mask, 2) - blur(shape_mask, wid), 0, 1)
    band = band / (band.max() + 1e-6)
    n = fbm(w, h, noise_scale, 4)
    return ((n * 0.8 + band * 1.6) > 0.55 + thr).astype(np.float32) * (band > 0.05)


def housing_hq(name, col, metal, chips_b, slot, slot_edge, gloss=0.22):
    W, H = 2048, 1613
    yy, xx = np.mgrid[0:H, 0:W]
    # ---- yükseklik haritası
    hgt = fbm(W, H, 400, 3) * 0.10 + rng.normal(0, 0.012, (H, W)).astype(np.float32)           # boya portakal kabuğu + ince tane
    hgt += fbm(W, H, 24, 3) * 0.012
    sx0, sy0, sx1, sy1 = int(W * 0.115), int(H * 0.07), int(W * 0.96), int(H * 0.93)
    hole = rrect_mask(W, H, (sx0, sy0, sx1, sy1), 24)
    ring_in = blur(hole, 14) - blur(hole, 3)                                                    # delik çevresi pah
    hgt += np.clip(blur(1 - hole, 10), 0, 1) * 0.55 - blur(hole, 5) * 0.3
    # dış kenar pahı
    edge = np.ones((H, W), np.float32); edge[:14] = 0; edge[-14:] = 0; edge[:, :14] = 0; edge[:, -14:] = 0
    hgt += blur(edge, 7) * 0.5
    # lastik tamponlar (yükseltilmiş, dokulu)
    bw, bh = int(W * 0.095), int(H * 0.115); ext = 100
    rub = np.zeros((H, W), np.float32)
    for (x0, y0, x1, y1) in [(-ext, -ext, bw, bh), (W - bw, -ext, W + ext, bh), (-ext, H - bh, bw, H + ext), (W - bw, H - bh, W + ext, H + ext)]:
        rub = np.maximum(rub, rrect_mask(W, H, (x0, y0, x1, y1), 58))
    hgt += blur(rub, 5) * 0.7 + rub * fbm(W, H, 5, 2) * 0.05
    # yan düğme yuvaları (çukur)
    slots = np.zeros((H, W), np.float32)
    for i in range(3):
        y = int(H * (0.20 + 0.12 * i)); slots = np.maximum(slots, rrect_mask(W, H, (int(W * 0.022), y, int(W * 0.098), y + int(H * 0.075)), 20))
    slots = np.maximum(slots, rrect_mask(W, H, (int(W * 0.022), int(H * 0.80), int(W * 0.098), int(H * 0.875)), 20))
    hgt -= blur(slots, 3) * 0.35
    # vidalar (yükseltilmiş başlık + yarık)
    screws = [(W * 0.05, H * 0.06), (W * 0.95, H * 0.06), (W * 0.05, H * 0.94), (W * 0.95, H * 0.94)]
    sc = np.zeros((H, W), np.float32)
    for (cx, cy) in screws:
        sc = np.maximum(sc, circle_mask_full(W, H, cx, cy, 19))
        # üst yarık
    hgt += blur(sc, 2) * 0.55
    # ---- albedo
    base = np.array(col, np.float32)
    alb = np.ones((H, W, 3), np.float32) * base
    alb *= (1.0 + fbm(W, H, 160, 4) * 0.07)[..., None]
    alb = np.where(rub[..., None] > 0.5, np.array([26, 27, 25], np.float32) * (1 + fbm(W, H, 4, 2)[..., None] * 0.15), alb)
    alb = np.where(blur(slots, 1)[..., None] > 0.5, np.array(slot, np.float32), alb)
    alb = np.where(sc[..., None] > 0.5, np.array([128, 130, 124], np.float32), alb)
    # kenar/köşe sıyrığı: açık metal + ikinci tip (astar/pas)
    body = (1 - hole) * (1 - rub)
    w1 = edge_wear_mask(body, 9, 22) * body
    alb = np.where(w1[..., None] > 0.5, np.array(metal, np.float32) * (0.85 + 0.3 * fbm(W, H, 6, 3)[..., None]), alb)
    if chips_b is not None:
        w2 = edge_wear_mask(body, 16, 10, 0.24) * body * (1 - w1)
        alb = np.where(w2[..., None] > 0.5, np.array(chips_b, np.float32) * (0.8 + 0.4 * fbm(W, H, 5, 3)[..., None]), alb)
    # kir: delik çevresi ambient occlusion + dikey akıntılar + genel leke
    ao = np.clip(blur(hole, 28) * 1.5 - 0.1, 0, 1) * (1 - hole)                                  # delik kenarına yakın bölge
    alb *= (1 - 0.35 * ao)[..., None]
    streak = fbm(W, H, 3, 2)
    stm = np.asarray(Image.fromarray(((np.clip(rng.normal(0, 1, (H // 40, W // 3)), -2, 2) + 2) / 4 * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)).astype(np.float32) / 255
    alb *= (1 - 0.10 * np.clip(stm - 0.45, 0, 1) * (yy / H) * 2.2)[..., None]
    alb *= (1 - 0.18 * np.clip(fbm(W, H, 200, 4) * 0.8 + 0.1, 0, 1))[..., None]
    img = lit(hgt, alb, 2.4, gloss, 30)
    out = np.zeros((H, W, 4), np.float32); out[..., :3] = img
    # çizikler
    L = Image.new("L", (W, H), 0); dr = ImageDraw.Draw(L)
    for _ in range(140):
        x, y = rng.uniform(0, W), rng.uniform(0, H); a = rng.uniform(0, math.pi); ln = rng.uniform(0.02, 0.14) * W
        dr.line([x, y, x + math.cos(a) * ln, y + math.sin(a) * ln], fill=int(rng.uniform(30, 90)), width=int(rng.integers(1, 3)))
    out[..., :3] += (np.asarray(L.filter(ImageFilter.GaussianBlur(0.6))).astype(np.float32) * 0.8)[..., None]
    # vida yarıkları
    pil = to_img(np.concatenate([np.clip(out[..., :3], 0, 255), np.full((H, W, 1), 255, np.float32)], axis=2))
    d = ImageDraw.Draw(pil, "RGBA")
    for i, (cx, cy) in enumerate(screws):
        a = math.radians(30 + 55 * i); dx, dy = math.cos(a) * 15, math.sin(a) * 15
        d.line([cx - dx, cy - dy, cx + dx, cy + dy], fill=(34, 36, 33, 255), width=5)
    for i in range(4):
        cx = int(W * (0.03 + 0.02 * i)); cy = int(H * 0.105)
        d.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], fill=(14, 16, 13, 255), outline=tuple(slot_edge) + (255,))
    res = np.asarray(pil).astype(np.float32).copy()
    res[..., 3] = 255 * (1 - hole)
    save(to_img(res), name)


def circle_mask_full(W, H, cx, cy, r, ss=3):
    m = Image.new("L", (W, H), 0)
    ImageDraw.Draw(m).ellipse([cx - r, cy - r, cx + r, cy + r], fill=255)
    return np.asarray(m.filter(ImageFilter.GaussianBlur(1.0))).astype(np.float32) / 255


def disk_height(S, r_edge=0.96):
    yy, xx = np.mgrid[0:S, 0:S]
    r = np.hypot(xx - S / 2, yy - S / 2) / (S / 2)
    return r, np.degrees(np.arctan2(yy - S / 2, xx - S / 2))


def knob_hq(S=512):
    r, ang = disk_height(S)
    h = np.clip(1 - r ** 3, 0, 1) * 0.5                                                          # hafif kubbe
    h += ((np.sin(np.radians(ang) * 18) > 0.15) & (r > 0.86) & (r < 0.99)) * 0.18                # tırtıl
    h += np.sin(r * 160) * 0.03 * (1 + fbm(S, S, 6, 2)) + rng.normal(0, 0.006, (S, S)).astype(np.float32)               # fırçalama halkaları
    h -= np.clip((r - 0.95) / 0.05, 0, 1) * 0.5
    alb = np.ones((S, S, 3), np.float32) * 150
    alb *= (1 + fbm(S, S, 20, 3) * 0.06)[..., None]
    a = np.zeros((S, S, 4), np.float32); a[..., :3] = lit(h, alb, 5.0, 0.55, 22, 0.55); a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "knob")


def ring_hq(S=256, sq=False):
    r, ang = disk_height(S)
    if sq:
        m = rrect_mask(S, S, (2, 2, S - 3, S - 3), S * 0.16); inner = rrect_mask(S, S, (S * 0.17, S * 0.17, S * 0.83, S * 0.83), S * 0.08)
        h = blur(m, 6) * 0.8 - blur(inner, 4) * 0.9
    else:
        m = circle_mask(S, S / 2 - 1); inner = circle_mask(S, S * 0.31)
        h = blur(m, 5) * 0.8 - blur(inner, 3) * 0.9
    h += rng.normal(0, 0.006, (S, S)).astype(np.float32)
    alb = np.ones((S, S, 3), np.float32) * 138
    img = lit(h, alb, 4.0, 0.5, 26, 0.5)
    for ch, v in enumerate((14, 14, 13)):
        img[..., ch] = img[..., ch] * (1 - inner) + v * inner
    a = np.zeros((S, S, 4), np.float32); a[..., :3] = img; a[..., 3] = m * 255
    save(to_img(a), "ring_sq" if sq else "ring")


def lens_hq(S=256, sq=False):
    yy, xx = np.mgrid[0:S, 0:S]
    if sq:
        m = rrect_mask(S, S, (2, 2, S - 3, S - 3), S * 0.14)
        dist = np.minimum.reduce([xx, yy, S - xx, S - yy]) / (S * 0.5)
        h = np.clip(dist * 2.2, 0, 1) ** 0.6
    else:
        m = circle_mask(S, S / 2 - 1)
        r = np.hypot(xx - S / 2, yy - S / 2) / (S / 2)
        h = np.sqrt(np.clip(1 - np.clip(r, 0, 1) ** 2, 0, 1))
    alb = np.ones((S, S, 3), np.float32) * 235
    img = lit(h * 0.5, alb, 3.0, 0.7, 40, 0.62)
    img = np.clip(img, 0, 255)
    a = np.zeros((S, S, 4), np.float32); a[..., :3] = img; a[..., 3] = m * 255
    save(to_img(a), "lens_sq" if sq else "lens")


def recess_hq(S=256):
    r, _ = disk_height(S)
    v = 14 + 16 * np.clip((r - 0.65) / 0.35, 0, 1) ** 1.5 - 6 * np.clip(1 - r * 1.2, 0, 1)
    v += (rng.normal(0, 1.2, (S, S))).astype(np.float32)
    a = np.zeros((S, S, 4), np.float32); a[..., :3] = v[..., None]; a[..., 3] = circle_mask(S, S / 2 - 1) * 255
    save(to_img(a), "recess")


def label_hq():
    W, H = 512, 128
    m = rrect_mask(W, H, (2, 2, W - 3, H - 3), 14)
    h = blur(m, 4) * 0.7 + fbm(W, H, 8, 3) * 0.02
    alb = np.ones((H, W, 3), np.float32) * 16
    img = lit(h, alb, 3.0, 0.25, 20, 0.7)
    a = np.zeros((H, W, 4), np.float32); a[..., :3] = img; a[..., 3] = m * 255
    save(to_img(a), "label")


def display_hq():
    W, H = 1024, 448
    m = rrect_mask(W, H, (2, 2, W - 3, H - 3), 22)
    inner = rrect_mask(W, H, (16, 16, W - 17, H - 17), 14)
    yy, xx = np.mgrid[0:H, 0:W]
    v = 7 + 9 * (1 - yy / H) + 3 * fbm(W, H, 40, 3)
    refl = np.clip(1 - np.abs((xx / W) * 0.9 + (yy / H) * 0.5 - 0.55) * 7, 0, 1) * 7                 # çapraz cam yansıması
    a = np.zeros((H, W, 4), np.float32)
    a[..., :3] = (v + refl * inner)[..., None]; a[..., 2] += 4
    a[..., :3] *= (0.55 + 0.45 * inner)[..., None]
    a[..., :3] += ((m - blur(m, 3)) * 140)[..., None]
    a[..., 3] = m * 255
    save(to_img(a), "display")


def run_housings():
    housing_hq("housing", (86, 98, 72), (138, 138, 132), None, (18, 20, 17), (60, 66, 52))
    housing_hq("housing_leo", (190, 192, 184), (104, 106, 100), (140, 96, 62), (24, 25, 24), (96, 98, 92), 0.3)
    housing_hq("housing_m1", (198, 192, 172), (108, 106, 98), (128, 88, 58), (24, 25, 24), (96, 98, 92), 0.3)
    housing_hq("housing_t72", (62, 68, 74), (132, 136, 138), (110, 70, 48), (16, 18, 20), (70, 76, 82), 0.35)


def run_gauges():
    S = 1024
    G.gauge("gauge_ammo", 11, -115, 115, 2, (236, 233, 220), (24, 24, 22), S=S)
    G.gauge("gauge_range", 30, -100, 100, 5, (14, 15, 14), (232, 232, 224), sub=4, S=S)
    G.gauge("gauge_fuel", 4, -60, 60, 1, (236, 233, 220), (24, 24, 22), labels=["E", "1/4", "1/2", "3/4", "F"], sub=3, S=S)
    G.gauge("gauge_speed", 8, -120, 120, 1, (236, 233, 220), (24, 24, 22), labels=["0", "10", "20", "30", "40", "50", "60", "70", "80"], sub=4, S=S)
    G.gauge_arc(S=S)


def run_small():
    knob_hq(); ring_hq(); ring_hq(sq=True); lens_hq(); lens_hq(sq=True); recess_hq(); label_hq(); display_hq()


if __name__ == "__main__":
    what = _WHAT
    G.WEAR_SCALE = 0.0 if what != "wear" else 1.0            # hq üretimde kir doğrudan dokuya işlenir; ek wear yok
    if what in ("housing", "all"): run_housings()
    if what in ("small", "all"): run_small()
    if what in ("gauges", "all"): run_gauges()

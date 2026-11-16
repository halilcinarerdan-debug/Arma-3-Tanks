# Leopard 2 / Strv 122 istasyonları (kendi cümlelerimizle özet)

Kaynak: Steel Beasts Strv 122 kılavuzu (yalnızca referans; metin ve görseller repoda yok). Aşağıdaki, gerçek araçtaki
kumanda mantığının bizim ekranlara nasıl çevrildiğidir.

## Nişancı
- **GPS alt satırı:** `F196A` = ateşe hazır (F) / menzil ÷ 10 (196 → 1960 m) / mermi (A = APFSDS, b = HE-T, d = MG). Ekranda 7 segment, nişangâh plakasında da aynı satır.
- **Kontrol ünitesi LED sırası:** Ber (hazır), Eld (ateş), KSP (MG seçili), Stab.
- **Ateş kontrol modu:** STAB TILL = güçlü + stabilize (normal) · OBSERVATION = güçlü, stabilizasyonsuz (acil) · TORN FRÅN = güç yok (manuel). Oyunda: hidrolik/stab/taret kilidi (T-72 ile ortak, Leo'da ısınma yok).
- **Mermi:** SLPILPRJ 95 (APFSDS), SLSGR 95 (HE-T), KSP (MG). Seçince yükleme süresi CBA ayarına göre işler.
- **Balistik bilgisayar:** Avstånd AUTOM/MAN, elle menzil (±100 m), savaş nişanı 1100 m, SS 1500, LRF aç/kapat.
- **Oyunda karşılığı olmayanlar (çizilmedi):** yan rüzgâr, hava/barut sıcaklığı, rakım, drift, ışık düğmeleri, TIS polarite/zoom.

## Komutan
Mürettebat, taretin gövdeye göre saat konumu (TIM saat şeridi gibi, 6…12…6), MG/duman sayıları, arıza lambaları, kapak, duman atışı.
Komutanın nişancıyı ezmesi (RK / ÖV / VCH-PRIO) Arma'da yok, bu yüzden düğme olarak koyulmadı.

## Sürücü
Hız göstergesi + 7 segment, yakıt, arıza lambaları, motor/far/kapak. Geri görüş: kamera görüntüsü yok; arkaya üç ışın atılır, 5/10/15 m işaretleri
üzerinde canlı engel mesafesi çubuk olarak gösterilir.

## Yükleyici
Arma'da yükleyici koltuğu yok; yükleme YÜKLE düğmesiyle (insan yükleyici süresi) yapılır.

## SB "Leopard 2" ve "Leopard 1" kontrol listeleri (kullanıcıdan)
- **Leopard 2** (araca özgü): Dynamic lead P · Toggle magnification (Leo2a5 gunner) N · KH / KW / ZU mode (Leo2 TC) · Peri cancel (Leo2 TC) · Palm switch (gunner / TC) ·
  Load Main Gun (Gnr) V · Cycle day sight visual filter Shift+R · Toggle sight reticle illumination R. Mermi seçimi, ateş kontrol modu, savaş nişanı, M (ana top/koaks) ortak nişancı listesinde.
  Ekranımızdaki gerçek işlevler (yükle, mermi, ateş kontrol modu, BS 1100, SS 1500, koaks) bu listeyle uyumlu; KH/KW/ZU komutan ezme modları, dinamik lead, yakınlaştırma, filtre, retikül ışığı Arma'da yok (eklenmedi).
- **Leopard 1** (ayrı araç): Pano (TC panoramik periskop) kontrolleri, Battle-sight range (Backspace), Toggle magnification N, Fire control: Stab Bereit L, Dynamic lead, palm switch.
  Leopard 1 için şimdilik ekran yok (Generic profil); `leopard2`/`strv` eşleşmesi Leopard 1'i artık yakalamıyor.

## SB Leopard 2 (DE) iç görselleri: doğrulananlar
- Kontrol ünitesi LED/tuş sırası (soldan): `BEREIT / EIN` (yeşil), `FEUER` (kırmızı), `KH / KH HZF`, `MG / HW`, `STAB EIN` (krem), `WNA` (mavi), `E 1000`. Üstte `BEREICH 1 / BEREICH 2` tablosu: A = KE, b = MZ (çok amaçlı), D = MG → GPS satırındaki harfler (A / b / d) bunlar.
- Ateş kontrol modu paneli: `STAB EIN` · `BEOBACHT` · `TURM AUS` (+ `BORDNETZ` tuşu, işlevi bilinmiyor). Balistik bilgisayar: `LASER` anahtarı EIN/AUS, `ENTFERNUNG AUTOM/MANUELL` + düğme x10 (m), `ANZEIGEWAHL`, `HÖHE`, `LUFTTEMP.`, `PULVERTEMP.`, `QUERWIND AUTOM/MANUELL`, `VAR ENTF AUS / 1500`, `WAFFE MG / HW`.
- **Savaş nişanı:** Leopard 2 (DE) `E 1000` (1000 m); Strv 122 1100 m (SB Strv 122 kılavuzu). Profil özelliği `bsRange` (Leopard2 = 1000, Strv122 = 1100). `VAR ENTF 1500` ikisinde de var.
- **Arma'da karşılığı yok / bağlanmadı:** `KH`, `KH HZF`, `WNA`, `BORDNETZ`, `RÜCKSTEUERUNG`, `VERKANTUNG-KORR.`, `WISCHER`, drift ve justaj düğmeleri, termal cihaz grubu (EIN/BER/AUS, polarite, FERN/NAH, SEHFELD, BILDHELLIGKEIT, KONTRAST), `FJA`, aydınlatma düğmeleri.
- **Gelecek fikri (sistemsel derinlik):** yükseklik / hava / barut sıcaklığı / yan rüzgâr girişleri gerçek değerlerden saparsa atış sapması (T-72 balistik düğmesindeki gibi); henüz yapılmadı.

## SB Leopard 2A4 iç görselleri
2A4 = 2A5 ile aynı kontrol ünitesi / balistik bilgisayar / ateş kontrol paneli (tek fark: 3. tuş `KH / KW`). Ek parça: `MEHRFACHWURFANLAGE` (kırmızı lamba, `EIN/AUS` şalteri, `Links / Fächer / Rechts` ve 0–8 seçici) → Arma'da yalnızca
EIN/AUS karşılığı var: komutan ekranında şalter EIN olmadan DUMAN düğmesi atmaz (profil özelliği `smokeArm`). Seçici (hangi tüpler) Arma'da yok, eklenmedi.
Termal cihaz paneli (polarite, görüş alanı, odak, parlaklık, kontrast), lamba testi, `40%` kadranı Arma'da karşılığı yok.

## SB Leopard 1A5 iç görselleri
- Balistik bilgisayar paneli Leopard 2A4 ile birebir aynı (LASER, RÜCKSTEUERUNG, VERKANTUNG-KORR., WISCHER, ENTFERNUNG AUTOM/MANUELL, ANZEIGEWAHL, HÖHE, LUFTTEMP., PULVERTEMP., QUERWIND; ekran dinlenmede `+ 100` = 1000 m).
- Nişancı panelleri: üstte tuşlar (`STAB EIN` dahil; diğerleri okunamadı), `TURM AUS` / `BORDNETZ` seçicisi, aydınlatma düğmeleri, `LAMPEN-FUNKTION-TEST` kutusu; sağda termal cihaz + `WAFFE MG/HW` + `FJA` (2A4 ile aynı); iki tutamak (kırmızı avuç anahtarı); büyük kırmızı kadran (azimut/menzil benzeri, işlevi bilinmiyor).
- Balistik panelin sağında `RESET` / `SET ZERO` tuşlu ayrı kutu (kırmızı ekran sönük): işlevi bilinmiyor, eklenmedi.
- Karar: Leopard 1 (`leopard1`, `leopard_1`, `leo1`) Leopard 2 istasyon ekranını kullanır (`bsRange = 1000`, balistik giriş sayfası açık, duman şalteri yok). Ateş kontrol modlarının tam konumları doğrulanmadı (SB listesinde yalnızca `Fire control: Stab Bereit`); 105 mm mermi satırları APFSDS-T / HE-T olarak eşleşiyor.
- Leopard AS1 için görsel yok; profile eklenmedi.

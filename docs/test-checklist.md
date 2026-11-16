# Oyunda test listesi

## Hazırlık
1. `addons/tankui/data/*.png` dosyalarının **hepsini** PAA'ya çevirin (28 dosya, `_ca.png` → `_ca.paa`), PBO'yu yeniden derleyin (prefix `z\tank33\addons\tankui`).
2. CBA, ACE3 ve (araçlar için) CUP yüklü olsun. Menü: **Ctrl+T** ya da ACE self-interaction "Tank sistemleri".
3. İlk açışta RPT'de şu satırı arayın: `[SB_TankUI] arac=<sınıf> profil=<profil> istasyon=<istasyon> rol=<rol>`.

## Araç araç
- **T-72 (genel), T-72B, T-80, T-90:** eski T-72 ekranı. Lamba matrisi, siyah butonlar (МЕХ-Д / СТАБИЛ / ПРИВОД), seçici Б К О, ЗАРЯД, menzil çarkı. T-80/T-90/T-72B3'te ATGM konumu (У) görünür; `t72b` ve `t72` profillerinde ATGM yok.
- **T-72B3 (`t72b3` adı):** yeni ekran; menzil −/+, koaks (П), Д ve РУЧ/АВТ şalterleri.
- **Leopard 2 / 2A4 / 2A5 / Leopard 1A5 / Strv 122:** GPS satırı `F…`, ateş kontrol modu (STAB EIN / BEOBACHT / TURM AUS), SLPILPRJ/APFSDS-T, HE-T, koaks, E 1000 (Strv 122: BS 1100), SS 1500; komutan: duman atıcı şalteri EIN olmadan DUMAN atmaz.
- **M1A1 / M1A2:** FIRE CONTROL MODE, GUN / AMMUNITION SELECT (SABOT, HEAT/MPAT, COAX), BATTLE SIGHT (1200 m), RANGE ARM / SAFE; menzil `0150` biçiminde.
- Menzil −/+ ve elle menzil yalnızca ekranda değeri değiştirir; Arma'nın kendi balistiği lazere bağlı.

## Kontrol edilecek davranışlar
1. Mermi seçince ve YÜKLE'ye basınca yükleme göstergesi ("YUKLUYOR…") bitip ekran güncelleniyor mu?
2. STAB/hidrolik: kapalıyken taret kilitleniyor mu, açıkken hareket halinde atışta sapma azalıyor mu? (CBA "Panel etkileri" açıkken)
3. Koaks (П / COAX) seçimi: silah gerçekten koaksa geçiyor mu, bir mermi tipi seçince ana topa dönüyor mu?
4. İki oyuncuyla: aynı araçta durumlar (STAB, mermi, yükleme) iki tarafta aynı mı?
5. Opsiyonel balistik sayfa (CBA "Balistik giris sapmasi", Leopard): BAL anahtarı sayfayı açıyor mu, rüzgârı MANUELL + 5 m/s saptırınca 2 km'de atış yana kayıyor mu?

## Sorun olursa gönderin
Ekran görüntüsü + RPT'deki `[SB_TankUI]` satırları + `Error` içeren satırlar. Araç sınıfı: `copyToClipboard typeOf vehicle player`.

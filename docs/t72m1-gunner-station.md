# T-72M1 nişancı istasyonu: 2D ekran spec'i

Kaynak: Steel Beasts T-72M1 kılavuzu (yerel referans, repoya girmez) + gerçek T-72 çalışma mantığı.
Bu dosya kendi cümlelerimizle yazılmış fonksiyonel özettir. Görsel ve metin kopyalanmaz.

## Araç verisi (kılavuz s.2)
- Top 125 mm 2A46; hazır/depo 22/22 (toplam 44, otomatik yükleyici)
- Varsayılan mühimmat (hazır/depo): APFSDS BM-32 7/7, HEAT BK-18 8/7, HE-Frag OF-26 7/8
- Koaksiyel 7,62 mm PK-T: 250 hazır / 1500 depo
- Komutan kupolası 12,7 mm NSVT: 60 hazır / 240 depo (kutu başına 60)
- Dumanlayıcı 902A 81 mm, 3D6: 2 hazır
- Ağırlık 41,5 t; motor 780 hp V46-6 V12 dizel
- Mürettebat 3: sürücü, nişancı, komutan. Yükleyici yok, mekanik otomatik yükleyici var.

## Ekran öğeleri (nişancı istasyonu)
| Öğe | Davranış |
|---|---|
| Menzil çarkı | FCS'ye girilen menzil (yüzlerce metre), mesafe girilince nişan noktası kayar |
| HAZIR lambası | Top yüklü + nişan uyumlu + LRF hazır olunca yanar |
| LRF sayısal ekranı | Son ölçülen tam menzil (4 hane) |
| LRF modu | 1200 / 1800 / NORMAL (sınırdan uzağı kabul etmez). FCS 3000 m üstünü girmez. Kötü ölçümde "battlesight" 800 m'ye düşer. |
| Durum lambaları (üst) | Stabilizasyon, GPS ayna stabilizasyonu, hidrolik |
| Durum lambaları (alt) | Komutan müdahalesi (TKN-3), Delta-d, top yüklü |
| Balistik lambaları | KE / HE / HEAT: balistik bilgisayara indekslenen mermi tipi |
| Mermi seçici | KAPALI + 3 tip. Otomatik yükleyiciye bir sonraki mermi tipini söyler |
| Mermi sayacı | Seçili tipin karuseldeki adedi, kapalıyken boş yuva sayısı. Maks. 11 |
| 3'lü şalter sırası | Delta-d / stabilizasyon / hidrolik |
| Oto yükleyici AUT/MAN | Normalde AUT |
| Düğmeler | YÜKLE, MENZİL SIFIRLA (0), LAZER ATIŞI, ANA TOP/KOAKS seçimi |

## Çalışma mantığı (simüle edilecek durumlar)
- Başlatma sırası: elle kranklar bağla, kilitleri kontrol et, hidrolik aç (jiroskop ısınır ~2 dk), GPS ayna kilidini aç, stabilizasyon aç, lazer aç, AUT kontrolü.
- Menzil 0 iken koaksiyel nişan noktaları geçerli; başka menzilde geçersiz.
- Stabilizasyon ~50-60 dk sürekli açık kalırsa hidrolik ısınır ve kaybolur. Maksimum taret hızında geçici kayıp.
- FCS **ön görü (lead) hesaplamaz**; nişancı kendi verir. Delta-d menzili kat edilen mesafeyle azaltır.
- Oto yükleyici: sadece tek yönde döner; yükleme ~6 sn, en kötü ~15 sn. Arızada komutan elle ~1 dk+.

## Arma 3 eşlemesi
| Öğe | Kaynak |
|---|---|
| Mermi tipi, adet, aktif mermi | Gerçek, `magazinesAllTurrets` / `currentMagazineTurret` |
| Mermi seçimi + YÜKLE | Gerçek, `loadMagazine` (CBA targetEvent) + yükleme gecikmesi (script) |
| Koaksiyel / NSVT / duman sayacı | Gerçek, aynı yöntem |
| Taret/top hasarı | Gerçek, `getAllHitPointsDamage` |
| Menzil, LRF ekranı | Script: nişan yönünden `lineIntersectsSurfaces` ile ölçüm |
| Stabilizasyon, hidrolik, Delta-d, durum lambaları | Script durumu; Arma'da doğrudan karşılığı yok, oyun etkisi opsiyonel |

## Açık sorular
- CUP'taki T-72 varyantı (M1 değil, muhtemelen CUP_O_T72_*): sınıf adı ve mermi sınıfları alınacak.
- Kılavuzdaki "1000 / 18000" ifadesi yazım hatası görünüyor; 1200 / 1800 esas alındı.
- Seçicideki kiril işaretlerinin eşlemesi kılavuzda yazmıyor (KE/HE/HEAT olarak alındı).

# Rus T serisi: sistem notları (internet + genel bilgi; SB kılavuzlarıyla DOĞRULANACAK)

Durum: Steel Beasts lisansı gelene kadar genel kaynaklarla yazıldı. `www.steelbeasts.com`, `rhsmods.org`, `fkgaming.eu` bu oturumda ağ izni yüzünden okunamadı;
aşağıdakiler arama sonuçlarından ve genel bilgiden. Kaynaklar birbirini tutmadığı yerler işaretlidir.

## Araç ailesi → profil
| Profil | `match` | FCS (`fcs`) | LRF | ATGM |
|---|---|---|---|---|
| T72 (M1 sınıfı, varsayılan) | `t72` | 1 | 3000 m, 1200/1800 modları | yok |
| T72B | `t72b` (T-72B3 dahil) | 2: 1A40-1 (TPD-K1 lazer + analog balistik bilgisayar, otomatik lead) | 4000 m | var (Svir, 1K13 görüşü) |
| T80 | `t80` | 3: 1A45 Irtysh / 1G46 görüş / 1V528-1 bilgisayar | 4000 m | var (Refleks 9M119, ~100–4000 m) |
| T90 | `t90` | 3: 1A45T Irtysh; Buran-M (erken) / Catherine-FC (sonraki) termal | 4000 m | var |

Bilinen çelişkiler: T-80U mühimmat 45–46 mermi (28 değil); otomatik yükleyici döngüsü T-90 için 6–8 sn (tek kaynak 7,1 sn); T-72B1'de Svir yok;
T-90A'nın FCS adı kaynaklara göre 1A45T veya 1A42; avcı-avlayıcı (hunter-killer) iddiası Kalina ile ilgili, T-90A için doğrulanmadı.

## Sistemsel olarak ne modellendi
- **ATGM kanalı:** füze mermileri "ATGM" sınıfı sayılır (önceden "OTHER"). Seçici 5. konum ATGM; YÜKLE ile gövde topuna yüklenir.
- **ATGM hazır lambası:** yüklü mermi ATGM + LRF açık/ısınmış + ölçülen menzil `atgmMin..atgmMax` içinde.
- **LRF sınırı profile bağlı:** T-72M1'de 3000 m ve 1200/1800 modu; B / U / T-90'da 4000 m ve mod şalteri yok.
- Ortak sistemler aynen: stab/hidrolik/ayna, taret kilidi, gerçek top stabilizasyonu, yükleme süresi, senkron durum.

## Sabaha kalanlar
1. SB T-72B / T-80U / T-90A kılavuzlarıyla: kumanda düzeni, otomatik yükleyici süreleri, mermi sayacı üst sınırı, LRF/hazır mantığı.
2. **Tank personeli gördüğünde tanısın (hedef tanıma)** – sabahki iş.
3. Otomatik lead (1A40-1 / 1A45) – Arma'da çalışma anında ayarlanamıyor; panelde nasıl temsil edileceği.
4. Shtora-1 / duman panel mantığı, komutan–nişancı avcı-avlayıcı devri, termal görüş (Buran-M).

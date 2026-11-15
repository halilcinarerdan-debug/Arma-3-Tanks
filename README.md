# Steel Tank UI (Arma 3)

CUP tankları için tuşla açılan, tıklanabilir 2D mürettebat ekranları. Gereksinimler: **CBA_A3**, **ACE3**. CUP araçları sınıf adı eşleştirmesiyle algılanır, diğer tanklar `Generic` profille çalışır.

## Tasarım ilkesi: Steel Beasts'e sadakat

Referans: Steel Beasts mürettebat ekranları.

| Birebir izlenir | Birebir kopyalanmaz |
|---|---|
| Ekran/menü hiyerarşisi ve gezinme mantığı | Texture, ikon ve piksel görünüm |
| Gerçek terimler ve kısaltmalar (ör. AP/HEAT, FCS, LRF) | Telifli görsel varlıklar |
| Bilgi sırası, hangi veri nerede | Font ve ekran çerçevesi |
| Operasyon akışı (kim neyi, hangi sırayla yapar) | |

Amaç: oyuncu bir gün Steel Beasts'e geçtiğinde burada öğrendiği ekran mantığını orada tanısın. Görsel kimlik (yeşil fosfor, koyu zemin) bu moda özgüdür ve `addons/tankui/gui/baseClasses.hpp` içindeki tema renkleriyle değiştirilir. Texture bu aşamada engel değildir; şimdilik düz renkli kontroller kullanılır.

Her yeni ekran şu sırayla yapılır:
1. Steel Beasts ekran görüntüsü alınır.
2. Hiyerarşi, terimler ve veri alanları çıkarılır (görsel kopyalanmaz).
3. Arma 3 verisine eşlenir (`magazinesAllTurrets`, `getAllHitPointsDamage`, `fuel`, ...).
4. `SB_Rsc*` kontrolleriyle 2D ekran olarak kurulur.

## Durum (v0.1.0, test edilmedi)

- Roller: driver, gunner, commander koltuğuna göre farklı sekmeler (`CfgSBTankUI >> Roles`)
- Tuş: **Ctrl+T** (CBA Keybinds > Steel Tank UI), ayrıca ACE self-interact > "Tank sistemleri"
- Sekme MUHIMMAT: silah, mermi tipi, adet, aktif mermi işareti, **SEC** ile mermi seçimi (`loadMagazine`, CBA targetEvent ile)
- Sekme DURUM: gövde/motor/palet/taret/top/yakıt deposu hasarı (canlı), hız, yakıt, motor, mürettebat
- Sekme ISTASYON (gunner, T-72 profili): durum/balistik lambaları, mermi seçici + YUKLE (6 sn otomatik yükleyici gecikmesi), LRF (lazer, mod, menzil sıfırla), şalterler. Spec: `docs/t72m1-gunner-station.md`
- Profiller: `CfgSBTankUI` (M1A2, Leopard 2, Challenger 2, T-72, Generic)

Bu ekranlar **yer tutucudur**; Steel Beasts görselleri geldikçe araç başına gerçek düzene çevrilecek.

## Kurulum / derleme

`addons/tankui` klasörünü PBO'ya paketleyin (prefix `sb\tankui`, bkz. `$PBOPREFIX$`; HEMTT veya Mikero pboProject). Hedef yapı: `@SB_TankUI/addons/sb_tankui.pbo` + `mod.cpp`.

Oyun içi test: bir CUP tankına binin, Ctrl+T.

## Cihaz görünümü ve dokular

Arayüz tek parça bir tablet cihazı: zeytin gövde, siyah köşe tamponları, cam ekran. Başlık ve sekme yok; soldaki üç donanım düğmesi ekranı değiştirir (ISTASYON / MUHIMMAT / DURUM), alttaki KAPAT kapatır.
Ortak ekipman widget'ları (`addons/tankui/kit.sqf`): etiket kutulu LED, kollu şalter, dönel seçici, basma düğmesi, 7 segmentli ekran, ibreli kadran.

Dokular `addons/tankui/data/*.png` olarak üretilir (`python3 tools/gen_textures.py`). Oyun `.paa` bekler:
1. Arma 3 Tools > ImageToPAA ile her `*_ca.png` dosyasını aynı adla `.paa`'ya çevirin (veya HEMTT ile derlemede otomatik).
2. `.paa` dosyaları PBO'ya `\sb\tankui\data\` altına girmelidir.

Dokular yoksa kod düz renk yedeğine düşer (çalışır, ama kadran çentikleri ve gövde dokusu görünmez).

Önizleme (oyun içi görüntü değil): `python3 tools/preview.py <çıktı klasörü>`.
`ctrlSetAngle` ters dönerse `config.cpp` içinde `angleSign = -1` yapın.

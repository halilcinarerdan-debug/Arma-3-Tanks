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

`addons/tankui` klasörünü PBO'ya paketleyin (prefix `z\tank33\addons\tankui`, bkz. `$PBOPREFIX$`; HEMTT veya Mikero pboProject). Hedef yapı: `@SB_TankUI/addons/sb_tankui.pbo` + `mod.cpp`.

Oyun içi test: bir CUP tankına binin, Ctrl+T.

## Cihaz görünümü ve dokular

Arayüz tek parça bir tablet cihazı: zeytin gövde, siyah köşe tamponları, cam ekran. Başlık ve sekme yok; soldaki üç donanım düğmesi ekranı değiştirir (ISTASYON / MUHIMMAT / DURUM), alttaki KAPAT kapatır.
Ortak ekipman widget'ları (`addons/tankui/kit.sqf`): etiket kutulu LED, kollu şalter, dönel seçici, basma düğmesi, 7 segmentli ekran, ibreli kadran.

Dokular `addons/tankui/data/*.png` olarak üretilir (`python3 tools/gen_textures.py`). Oyun `.paa` bekler:
1. Arma 3 Tools > ImageToPAA ile her `*_ca.png` dosyasını aynı adla `.paa`'ya çevirin (veya HEMTT ile derlemede otomatik).
2. `.paa` dosyaları PBO'ya `\z\tank33\addons\tankui\data\` altına girmelidir.

Dokular yoksa kod düz renk yedeğine düşer (çalışır, ama kadran çentikleri ve gövde dokusu görünmez).

Önizleme (oyun içi görüntü değil): `python3 tools/preview.py <çıktı klasörü>`.
`ctrlSetAngle` ters dönerse `config.cpp` içinde `angleSign = -1` yapın.

## CBA ayarları (Addon Options > Steel Tank UI)
| Ayar | Açıklama |
|---|---|
| Etiket dili | Araç dili (otomatik) / Türkçe / English / Русский / Deutsch. Otomatik: T-72 Rusça, Leopard Almanca, M1/Challenger İngilizce, diğerleri Türkçe (profildeki `language`) |
| Cihaz kirliliği | Cam üstü kir katmanının opaklığı, 0-100 (varsayılan 60) |
| Otomatik yükleyici süresi | T-72 yükleme gecikmesi, sn (varsayılan 6; AUT/MAN "MAN" iken 65 sn) |
| İbre yönü | `ctrlSetAngle` ters dönüyorsa "Ters" |

Etiketler `tools/labels.py` içinde; `python3 tools/gen_stringtable.py` ile `stringtable.xml` üretilir. Her dil ayrı anahtardır (`STR_SB_<dil>_<ANAHTAR>`), bu yüzden oyun dilinden bağımsız araç dili gösterilebilir.
**Rusça/Almanca etiketler en iyi bilgiyle yazıldı, doğrulanmadı** (özellikle `T_DELTA`, `L_TC`, `L_DELTA`, `SEL_OFF`). Steel Beasts görselleriyle kontrol edilmeli.

Doku kiri `tools/gen_textures.py` içindeki `WEAR` / `WEAR_SCALE` ile ayarlanır (0 = temiz); cam kiri ayrıdır (`dirt_ca`) ve oyunda CBA ayarıyla değişir.

## Derleme notu (pboProject / Pal2Pace)
Tüm dokular 2'nin kuvveti boyutlarda üretilir (`tools/gen_textures.py` bunu otomatik yapar); aksi hâlde `Pal2Pace failed` hatası alınır.
PBO ön eki `addons/tankui/$PBOPREFIX$` dosyasından okunur (`z\tank33\addons\tankui`). Dosya projeye kopyalanmazsa pboProject ön eki klasör yolundan türetir ve koddaki `\z\tank33\addons\tankui\...` yolları (doku, kit.sqf) bozulur.

**Ön eki değiştirmek:** pboProject dosyaları P: sürücüsünde ön ekle arar, proje `P:\<ön ek>` altında durmalıdır (şu an `z\tank33\addons\tankui`). Başka bir yerde derlenecekse:
`python3 tools/set_prefix.py "yeni\on\ek"` tüm yolları ve `$PBOPREFIX$` dosyasını birlikte günceller.

## Kullanım
**Gereksinim:** CBA_A3, ACE3, CUP Vehicles. PBO derlenirken dokular `.paa`'ya çevrilir (pboProject).

**Açma/kapama:** tank içindeyken `Ctrl+T` (Esc > Configure > Controls > Configure Addons > Steel Tank UI'dan değiştirilebilir) veya ACE self-interact > "Tank sistemleri". Kapatma: aynı tuş, KAPAT düğmesi ya da Esc. Menü açıkken nişan alınamaz/ateş edilemez: ayarla, kapat, ateş et.

**Ekranlar** (soldaki üç donanım düğmesi): ISTASYON (yalnızca T-72 nişancı), MUHIMMAT, DURUM. Sürücüde yalnız DURUM, komutanda MUHIMMAT + DURUM, nişancıda üçü. Koltuk değiştirirsen menü kapanır.

## Gerçek etkiler (T-72 istasyonu)
| Kontrol | Etki |
|---|---|
| Mermi seçici + YUKLE, SEC | Mermiyi gerçekten yükler (`loadMagazine`) |
| AUT/MAN | MAN: yükleme 65 sn |
| STAB + HIDROLIK | Stabilizasyon yalnızca STAB açık + hidrolik açık + 120 sn ısınma sonrası etkindir; etkin değilken **hareket halinde atış saptırılır** (hızla artar, 30 km/h'de azami ~0,5°). 55 dk sürekli açık kalırsa hidrolik ısınır, STAB kapanır |
| Balistik anahtarı (ELLE) | Yüklü mermiden farklı tipe indekslenirse atış kısa/uzun sapar (~0,35°) |
| LAZER, LRF, DELTA-D, AYNA KILIDI | Yalnızca panel (menzil ölçümü gösterilir, silahı etkilemez) |

Etkiler `Fired` olayıyla uygulanır ve istasyon ekranı bir araçta ilk açıldığında devreye girer (hiç açmayan oyuncuya sapma uygulanmaz). CBA ayarları: "Panel etkileri" (aç/kapa), "Sapma siddeti (%)".
Henüz yapılmayanlar (komut sözdizimi doğrulanamadı): HIDROLIK ile taret kilidi, AYNA KILIDI ile optik stabilizasyon, LAZER ile gerçek nişan düzeltmesi, DELTA-D.

## Mermi seçici ve balistik farkı
- **Mermi seçici (MERMI SECICI):** Otomatik yükleyiciye **hangi mermi tipinin** yükleneceğini söyler (BPS/BKS/OFS). YUKLE'ye basınca o mermi namluya girer. Yalnızca seçici tek başına bir şey yüklemez.
- **Balistik (BALISTIK lambaları + ELLE anahtarı):** Nişan bilgisayarının **hangi mermi tablosunu** kullandığını gösterir. Normalde yüklü mermiyi otomatik izler; ELLE yalnızca bilgisayar bozulduğunda elle indekslemek içindir. Yüklü mermiyle uyuşmazsa nişan o mermi için yanlış hesaplanır (atış sapar).
- Yükleme sonucu oyunda sohbete yazılır ("Yuklendi: ..." / "Yukleme basarisiz ..."), ayrıntı RPT'de `[SB_TankUI] loadMagazine sonuc`.

## Nişangâh plakaları (HUD)
Nişancı/komutan optiğe baktığında (cameraView = GUNNER) iki yandaki boş şeritlerde, Arma'nın kendi üst köşe panellerinin altında dört plaka görünür (girişi engellemez, menü açıkken gizlenir):
- **Sol-üst:** yüklü mermi tipi (BPS/OFS/BKS), YUKLU/HAZIR lambaları, aktif silah | mermi, yükleyici durumu.
- **Sol-alt:** gerçek stabilizasyon durumu (STAB), hidrolik, ayna, Delta-d, LRF açık, LRF modu.
- **Sağ-üst:** LRF menzil ekranı (7 segment).
- **Sağ-alt:** kalan mermi sayıları (BPS/OFS/BKS/PKT).
CBA ayarları: "Nisangah plakalari" (aç/kapa), "Nisangah plaka boyutu (%)". Arma'nın kendi arayüzündeki pusula, taret simgesi/EL, "menzil RDY" ile çakışmaz.

## Sürücü ve komutan istasyonları (T-72)
- **Sürücü (ISTASYON):** hız kadranı + 7 segment, yakıt, motor çalışıyor lambası, arıza lambaları (motor/paletler/gövde, hasar >= %30), şalterler: MOTOR (aç/kapa), FARLAR, KAPAK (aç/kapat). Steel Beasts kılavuzunda T-72M1 sürücü paneli modellenmediği için tasarım gerçek T-72 sürücü göstergelerine ve Arma'nın verebildiği verilere göre.
- **Komutan (ISTASYON):** mürettebat (isim + sağlık), PKT / NSVT / duman sayıları, arıza lambaları, KAPAK şalteri, DUMAN düğmesi (902A fırlatıcı).
- Motor aç/kapa (`engineOn`) kesin; farlar, kapak ve duman atışı (`action lightOn/TurnOut`, `fire`) wiki'den doğrulanamadı. Bu eylemler `fn_t72ActionX.sqf` içinde yalıtıldı (hata nişancı istasyonunu bozmaz); duman atışı sonucu sohbette bildirilir.

## Wiki ile doğrulanan etkiler (v2)
| Özellik | Komut (wiki'de doğrulandı) | Davranış |
|---|---|---|
| Menzil ekranları | `player currentZeroing [silah]` -> `[mesafe, indeks]` (mesafe lazer menzilini içerir, Arma 2.20+; araç değil birim ister) | İstasyon ve nişangâh plakasındaki menzil artık Arma'nın kendi lazer menzili (nişangâhtaki sayı). CBA "Menzil kaynagi" ile panel lazerine (LAZER düğmesi) dönülebilir |
| Hidrolik -> taret | `araç setTurretLimits [taret, minDönüş, maxDönüş, minYükseliş, maxYükseliş]`, sıfırlama `[taret]` | HIDROLIK kapanınca taret mevcut yönünde kilitlenir, açılınca serbest. Araçtan inince kilit kalkar. CBA: "Hidrolik kapaliyken taret kilitlenir" |
| Ayna kilidi -> optik | `araç enableDirectionStabilization [bool, taret]` | Hidrolik açık + ayna açık + 120 sn ısınma tamamsa optik yön stabilizasyonu açık, değilse kapalı. Yalnızca optik modunda `directionStabilized` config'te varsa etkili. CBA: "Ayna kilidi optik stabilizasyonu etkiler" |
| Silah seçimi | `unit selectWeapon [silah, namlu, atışModu]` (araç silahları da), atış modu `weaponState` ile | TOP/PKT şalteri ve MUHIMMAT'taki SEC; etkisizse eski tek argümanlı biçim denenir |
| Duman atışı | `unit fire muzzle` (yerel birim, `selectWeapon` ile birlikte) | Komutan/nişancı DUMAN düğmesi kendi taretindeki fırlatıcıyı seçip oyuncuya ateş ettirir, ardından eski silaha döner |

`action ["TurnOut"/"TurnIn"/"LightOn"/"LightOff"]` artık wiki'de doğrulandı (kapak yalnızca aracın etkin komutanı olan oyuncuda çalışır, yani sürücü koltuğunda çalışmayabilir). Hâlâ doğrulanmayan: durum okuyucular `isLightOn` / `isTurnedOut`.
Tüm doğrulanmış sözdizimleri: `docs/arma-ref/arma3-verified-commands.md`; ham eylem listesi: `docs/arma-ref/arma3-actions-raw.txt`.

## Gerçek top stabilizasyonu (Arma 2.22+)
STAB şalteri artık `enableGunStabilization` ile **gerçekten** top stabilizasyonunu (mod 3: iki düzlem) açıp kapatır: STAB etkin = şalter açık + hidrolik açık + 120 sn ısınma tamam + 55 dk aşırı ısınma yok; değilse mod 0. Araçtan inince geçersiz kılma (-1) ile eski hâline döner. CBA "Stabilizasyon yontemi": gerçek stabilizasyon (varsayılan) ya da eski atış sapması simülasyonu; Arma 2.22 altında otomatik olarak sapma simülasyonuna düşer. Balistik anahtarı sapması her durumda uygulanır.


## Leopard 2 ailesi (Strv 122 mantığı)

Strv 122 (Leo 2S) CUP'ta bulunmayabilir; bu yüzden ayrı bir araç sınıfına değil **Leopard 2 profiline** bağlanır
(`leopard2`, `leo2`, `strv122`, `strv` eşleşir). `station = "LEO2"`. Ayrıntı: [`docs/strv122-stations.md`](docs/strv122-stations.md).

- **Nişancı:** GPS satırı `F196A`, Ber/Eld/KSP/Stab lambaları, ateş kontrol modu (STAB TILL / OBSERVATION / TORN FRÅN), APFSDS / HE-T / MG seçimi + YÜKLE, Avstånd AUTOM/MAN, elle menzil ±100, BS 1100, SS 1500, LRF.
- **Komutan:** mürettebat, taret yönü saat şeridi, MG/duman sayıları, arıza lambaları, kapak, duman.
- **Sürücü:** hız, yakıt, arıza lambaları, geri görüş mesafe kılavuzu (5/10/15 m), motor/far/kapak.
- Dil: araç dili Almanca; CBA'dan **Svenska** seçilebilir (STAB TILL, OBSERVATION, TORN FRÅN, SLPILPRJ 95 …).

## Çok oyunculu / bot senkronu

- Panel durumları (STAB, HIDR, mermi seçimi, yükleme zamanı, lazer/menzil, ayna vb.) araç üzerinde **herkese yayınlanan** değişkenlerdir; aynı araçtaki iki nişancı aynı durumu görür. Zamanlayıcılar `serverTime` ile tutulur.
- Aynı taretteki başka bir oyuncu veya bot mermiyi değiştirirse seçici ve lambalar oyunun gerçek durumuna 0,3 sn içinde uyar (`SB_fnc_syncSel`).
- ACE Advanced Vehicle Damage ile uyum: hasar ekranı hitpoint değerlerini okur (ACE bunları günceller); ayrıca ACE'in kendi tamir/yangın sistemi bu paneldeki lambaların yerine geçmez.

## Leopard 2 paleti (`palette = "leo"`)

Leopard 2 / Strv 122 profili, Steel Beasts Strv 122 kılavuzundaki iç mekan görsellerinden esinlenen kendi paletini kullanır:
açık gri-krem boya + kenarlarda astar/pas sıyrığı (`housing_leo`), siyah lastik tamponlar, beyaz gravür yazı, **kare basmalı LED düğmeler** (`lens_sq`, `ring_sq`).
Yeni PNG'leri (`housing_leo_ca.png`, `lens_sq_ca.png`, `ring_sq_ca.png`) PAA'ya çevirmeyi unutmayın. Başka bir araç için palet eklemek: profile `palette = "ad"` + `housing_<ad>_ca.paa`.

## M1 Abrams ailesi (`station = "M1"`, `palette = "m1"`)

`m1a2`, `m1a1`, `m1_abrams`, `m1a2_tusk` eşleşir. Nişancı: menzil ekranı, READY/LASER/COAX/STAB lambaları, taret/top kontrolü (GÜÇ+STAB / GÜÇ AÇIK / MANUEL),
SABOT / HEAT-MPAT / koaksiyel seçimi + YÜKLE, LRF, elle menzil. Komutan: mürettebat, taret yönü saat şeridi, M240 / .50 cal / duman sayıları. Sürücü: Leopard sürücü ekranıyla ortak.
**Not:** Steel Beasts M1A2 kılavuzu henüz incelenmedi; ekran gerçek Abrams kumandalarının yaklaşık uyarlamasıdır. Kılavuz gelince inceltilecek.
Yeni doku: `housing_m1_ca.png` (PAA'ya çevirin). Dil: İngilizce.

## Rus T serisi profilleri

`t90`, `t80`, `t72b`, `t72` ayrı profillerdir (ilk eşleşen kazanır). Hepsi T-72 istasyonunu kullanır; sistem farkları profil özelliklerinden gelir
(`fcs`, `lrfMax`, `lrfModes`, `atgm`, `atgmMin`, `atgmMax`). Ayrıntı ve doğrulanacaklar: [`docs/t-series-systems.md`](docs/t-series-systems.md).

## T-72 paneli (palette = "t72")

Koyu mavi-gri boyalı çelik gövde (`housing_t72_ca.png`, PAA'ya çevrilmeli); SB T-72 görüntülerindeki biçimler: tek plakada kompakt 2×3 lamba matrisi,
МЕХ-Д / СТАБИЛ / ПРИВОД için siyah yuvarlak butonlar (açıkken ince yeşil halka), seçicide harfler (Б / К / О). T-72, T-72B, T-80 ve T-90 profilleri kullanır.
Görüntüden okunamayan parçalar (sol alt renkli butonlar, menzil ekranı yanındaki sarı lamba, РУЧ/ПОДДОН penceresi) bilerek eklenmedi.

## Doku kalitesi (`tools/gen_textures_hq.py`)

`python3 tools/gen_textures_hq.py [housing|small|gauges|all]` yüksek kalite sürümü üretir: yükseklik haritası + gerçek aydınlatma (pah, speküler), kenar aşınması
(açık metal ve pas sıyrığı), çok oktavlı kir/akıntı, 2048×2048 gövde, 1024×1024 kadran, 512 topuz, 256 lens/halka. Aynı dosya adlarının üzerine yazar; **tüm PNG'leri yeniden PAA'ya çevirin**.

## Balistik giriş sapması (opsiyonel, Leopard 2 / Strv 122)

CBA ayarı **"Balistik giris sapmasi (opsiyonel)"** (varsayılan kapalı). Açıkken istasyon ekranında `BAL` anahtarı çıkar; açılan sayfada panelin HÖHE / LUFTTEMP. / PULVERTEMP. / QUERWIND girişleri
vardır. Girilen değer gerçek ortamdan saparsa atış saparır (**basit oyun dengesi modeli, fizik değil**; ölçek "Sapma siddeti" ile). Girilmeyen değer gerçek değer sayılır (sapma yok);
yan rüzgâr AUTOM iken sensör gerçeği bilir, MANUELL iken girilen değer kullanılır. ACE Weather açıksa sıcaklık ondan (`ace_weather_currentTemperature`), rüzgâr oyun rüzgârından (`wind`) okunur.
Doğrulanmadı: `ace_weather_currentTemperature` adı ve `ambientTemperature` dönüş biçimi (yoksa yedek değer kullanılır).

## Konum ve boyut ayarları (CBA → Steel Tank UI → "Konum ve boyut")

- **Menu (tablet) boyutu (%)**: 40–130, varsayılan 100. Menü bir sonraki açılışta geçerli olur.
- **Menu yatay / dikey konum (%)**: ekran genişliği/yüksekliğinin yüzdesi kadar kaydırır (0 = ortalı; yatay + sağa, dikey + aşağı).
- **Nisangah plakalari yukseklik (%)**: sol/sağ plakaların üst kenardan uzaklığı (17 = varsayılan). Boyutu ayrıca "Nisangah plaka boyutu".

## Araç tanınmıyorsa (yalnızca Mühimmat ve Durum sekmesi görünüyorsa)

Araç hiçbir profile eşleşmemiş demektir; menü açılınca sohbette sınıf adı yazar. CBA → Steel Tank UI → **Sinif eslestirme** alanına `sinif=Profil` yazın
(örn. `leopard2a6=Leopard2`; birden çoksa `;` ile ayırın). Profiller: Leopard2, Leopard1, Strv122, M1A2, T72B3, T72B, T72, T80, T90. Sınıf adının küçük harfli bir parçası yeter.

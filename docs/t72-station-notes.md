# T-72 nişancı istasyonu: SB görüntülerinden okunanlar (kendi cümlelerimizle)

Kaynak: kullanıcının Steel Beasts ekran görüntüleri (repoda yok). "Net" = yazı/şekil okundu. "Belirsiz" = okunamadı veya anlamı bilinmiyor. Tahmin yürütülmedi.

## İki ayrı panel düzeni görüldü
| | Düzen A | Düzen B |
|---|---|---|
| SB sağ üst satırı | `BM-26 APFSDS-T: 8 \| 8` | `BM-59 Svinets-1 APFSDS-T: 7 \| 8`, `Fuel 100%`, `COORDINATE` |
| Ayırt edici | 1A40-1 gövdesi, sol ТПН 3-49 görüşü | ek СОСНА-У paneli, TAALES panelleri, monitör, РС1-РС4 kutusu |
| Yıl | kullanıcı "1984" dedi | kullanıcı "2012" dedi |
(Hangisinin hangi yıla ait olduğu kullanıcıdan teyit bekliyor.)

## Net okunanlar (her iki düzen)
- 6 lambalı matris, 2x3: üst sıra turkuaz / turuncu-kırmızı / turkuaz; alt sıra kırmızı / turuncu-kırmızı / mor-lacivert. Yanma durumları zamanla değişiyor (05:56:31 → 05:57:17 görüntüleri), lambalarda yazı yok.
- Üç siyah buton: `МЕХ-Д`, `СТАБИЛ`, `ПРИВОД`; altlarında ortada `ВЫКЛЮЧЕНО`.
- Çift pencere: `РУЧ` (yeşil yazı) ve `ПОДДОН` (kırmızı yazı).
- Menzil ekranı: 4 haneli kırmızı, `0000`. Yanında sarı/turuncu ve yeşil lambalar, yeşilin altında `АВТ`; altında küçük turuncu lamba ve siyah buton.
- Sol görüş: `ТПН 3-49`, `ОБОГРЕВ` (sarı lambalı buton), `ШТОРКА / ПРИБОР / ОТКР / ВЫКЛ`; plakada АВТ tumbleri ile dış parlamadan koruma uyarısı.
- Sol alt: sarı, sarı, yeşil, turuncu halkalı 4 basmalı lamba (yazısız).
- Soldaki küçük kadran: 0…22 ölçekli, üst yayda 1-3-5-7-9-11.
- Sağda `Угол ЗАР` dikey ölçeği: 0°, 10°, 13° (kırmızı çizgiler).
- Üst panel: üç lamba (açık yeşil, yeşil, sarı), `СВЕТОФИЛЬТР` kolu, `ПОПРАВКА` kadranı.

## Düzen A'ya özgü
- Dönel seçici harfleri: `ЗАГР`, `У`, `О`, `Б`, `К` (beş konum).

## Düzen B'ye özgü
- Dönel seçici harfleri: `ЗАГР`, `О`, `Б`, `К`, `П`, `У`, `УН` (yedi konum). Seçicinin üstünde `РУЧ`/`ПОДДОН` pencereleri ve iki siyah buton `ВКЛ.А`, `АВТ./РУЧ.`.
- Menzil ekranı yanında iki şalter: `ВКЛ/ВЫКЛ` + `Д`, `РУЧ/АВТ`; turuncu ve yeşil lamba bu şalterlerin yanında.
- СОСНА-У paneli: sarı lambalar `ГОТОВ` başlığı altında `ССУ`, `БВ`, `Д` | `У`, `АВТОМАТ`, `ОБОГРЕВ`; şalterler `ВЫВЕРКА Д`, `Д.У. СВК ВЫКЛ`; düğmeler `МЕНЮ`, `ЗАПИСЬ ПОДСВЕТКА`, `−`, `+`, `ВОЗВРАТ`; 4x / 12x kolu; `ВКЛ ◁ АВТОМАТ ВЫКЛ` şalteri.
- Ek: `РС1 РС2 РС3 РС4 ВС` kutusu, `АСЦ ВЫКЛ / АСЦ ВКЛ` kolu, küçük monitör (`ССУ ВКЛ` yazısı, +/−/parlaklık), TAALES kontrol paneli.

## Nişangâh (TPD-K1) görüntüsü (düzen A)
- Üstte kırmızı yay: menzil tamburu ölçeği (12, 13, 14, 15, 16; imleç 14'te) → mevcut "ДАЛЬНОСТЬ x100 м" yay göstergemizle uyumlu.
- Retikül: yatay yanal-lead ölçeği (32…4…32), dikey menzil işaretleri (4…18, 46, 50), sağda 5–40 ölçeği, altta `ПУЛ ОФ` yazısı (retikül mermi tipine göre etiketli).

## Belirsiz (anlamı bilinmiyor, koda alınmadı)
Altı lambanın hangisinin ne olduğu; sarı/yeşil lambaların işlevi; sol alt dört basmalı lamba; soldaki iki kadran; РУЧ/ПОДДОН ne zaman yanıyor; `ЗАГР`, `У`, `УН`, `П` konumları; РС1-РС4/ВС; АСЦ; Düzen B'deki tüm СОСНА-У işlevleri.
Not: `АВТ./РУЧ.` yazısı, mevcut "АВТ / РУЧ" yükleyici şalterimizle tutarlı ama bağlantı teyit edilmedi.

## T-72B3 (2012) ekranı: ne bağlı, ne görsel
`station = "T72B3"` (profil `t72b3`). Her parça tabletten tıklanır; **oyuna etkisi olanlar:** lamba matrisi (STAB / aynayı / hidrolik / delta / yüklü), МЕХ-Д / СТАБИЛ / ПРИВОД butonları,
seçicide Б, К, О (mermi seçimi) + ЗАРЯД düğmesi (bizim eklememiz), `Д` şalteri (LRF aç/kapat; "Д" = дальномер etiketine dayalı), `РУЧ / АВТ` şalteri (yükleyici elle/oto; etiket eşleşmesi),
menzil ekranı, LAZER / sıfırla, mermi sayacı. **Yalnızca görsel (etkisi bilinmiyor):** СОСНА-У paneli (lambalar, şalterler, МЕНЮ / ЗАПИСЬ / − / + / ВОЗВРАТ),
РС1–РС4 / ВС, АСЦ, monitör düğmeleri, `ЗАГР` / `П` / `У` / `УН` seçici konumları, `РУЧ`/`ПОДДОН` penceresi, `ВКЛ.А` ve `АВТ/РУЧ` küçük butonlar.
Taales paneli çizilmedi.

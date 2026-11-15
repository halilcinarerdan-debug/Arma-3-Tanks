# -*- coding: utf-8 -*-
"""
Etiket sözlüğü: anahtar -> (tr, en, ru, de). stringtable.xml ve önizleme buradan üretilir.
NOT: Rusça/Almanca etiketler en iyi bilgiyle yazıldı; Steel Beasts/kılavuz görselleriyle doğrulanmalı
(özellikle T_DELTA, L_TC, L_DELTA, SEL_OFF).
"""
LANGS = ["tr", "en", "ru", "de", "sv"]
L = {
    # koltuk rolleri / ekran adları / yan düğmeler
    "ROLE_driver":    ("SURUCU", "DRIVER", "МЕХАНИК-ВОДИТЕЛЬ", "FAHRER"),
    "ROLE_gunner":    ("NISANCI", "GUNNER", "НАВОДЧИК", "RICHTSCHÜTZE"),
    "ROLE_commander": ("KOMUTAN", "COMMANDER", "КОМАНДИР", "KOMMANDANT"),
    "ROLE_other":     ("MURETTEBAT", "CREW", "ЭКИПАЖ", "BESATZUNG"),
    "SCR_STATION":    ("ISTASYON", "STATION", "ПОСТ", "STATION"),
    "SCR_AMMO":       ("MUHIMMAT", "AMMUNITION", "БОЕКОМПЛЕКТ", "MUNITION"),
    "SCR_STATUS":     ("DURUM", "STATUS", "СОСТОЯНИЕ", "ZUSTAND"),
    "CLOSE":          ("KAPAT", "CLOSE", "ЗАКРЫТЬ", "SCHLIESSEN"),
    # istasyon: lambalar
    "L_STAB":   ("STAB", "STAB", "СТАБ", "STAB"),
    "L_MIRROR": ("AYNA", "MIRROR", "ЗЕРКАЛО", "SPIEGEL"),
    "L_HYDR":   ("HIDR", "HYDR", "ПРИВОД", "HYDR"),
    "L_TC":     ("TC", "TC", "КОМ", "KDT"),
    "L_DELTA":  ("DELTA", "DELTA", "МЕХ-Д", "DELTA"),
    "L_LOADED": ("YUKLU", "LOADED", "ЗАРЯЖ", "GELADEN"),
    "L_LRF":    ("LAZER", "LASER", "ЛД", "LASER"),
    "L_READY":  ("HAZIR", "READY", "ГОТОВ", "BEREIT"),
    # balistik / mermi
    "BALL":       ("BALISTIK", "BALLISTICS", "БАЛЛИСТИКА", "BALLISTIK"),
    "BALL_OVR":   ("ELLE", "MANUAL", "РУЧН", "MANUELL"),
    "AM_KE":      ("BPS", "KE", "БПС", "KE"),
    "AM_HE":      ("OFS", "HE", "ОФС", "HE"),
    "AM_HEAT":    ("BKS", "HEAT", "БКС", "HEAT"),
    "AM_KE_FULL":   ("BPS (APFSDS)", "KE (APFSDS)", "БПС (APFSDS)", "KE (APFSDS)"),
    "AM_HE_FULL":   ("OFS (HE-FRAG)", "HE-FRAG", "ОФС (HE-FRAG)", "HE-FRAG"),
    "AM_HEAT_FULL": ("BKS (HEAT)", "HEAT", "БКС (HEAT)", "HEAT"),
    "SEL_OFF":    ("KAPALI", "OFF", "ВЫКЛ", "AUS"),
    "SEL_TITLE":  ("MERMI SECICI", "AMMO SELECT", "ВЫБОР СНАРЯДА", "MUNITIONSWAHL"),
    "AMMO_COUNT": ("MERMI SAYAC", "ROUND COUNT", "ОСТАТОК", "MUNITIONSZÄHLER"),
    # düğmeler
    "LOAD":    ("YUKLE", "LOAD", "ЗАРЯД", "LADEN"),
    "LOADING": ("YUKLUYOR...", "LOADING...", "ЗАРЯЖАЮ...", "LÄDT..."),
    "LASE":    ("LAZER", "LASE", "ЛАЗЕР", "LASERN"),
    "RESET":   ("MENZIL 0", "RANGE 0", "ДАЛЬН. 0", "ENTF. 0"),
    "RANGE":   ("MENZIL x100 m", "RANGE x100 m", "ДАЛЬНОСТЬ x100 м", "ENTFERNUNG x100 m"),
    "FIRE_RDY": ("ATESE HAZIR", "FIRE READY", "ГОТОВ", "FEUERBEREIT"),
    # şalterler
    "T_DELTA":  ("DELTA-D", "DELTA-D", "МЕХ.-Д", "DELTA-D"),
    "T_STAB":   ("STAB", "STAB", "СТАБИЛ", "STAB"),
    "T_HYDR":   ("HIDROLIK", "HYDRAULICS", "ПРИВОД", "HYDRAULIK"),
    "T_LRFON":  ("LRF ACIK", "LRF ON", "ЛД ВКЛ", "LRF AN"),
    "T_AUTO":   ("OTO / EL", "AUT / MAN", "АВТ / РУЧ", "AUT / MAN"),
    "T_MIRROR": ("AYNA KILIDI", "MIRROR LOCK", "ЗЕРКАЛО", "SPIEGEL"),
    "T_MODE":   ("LRF MOD", "LRF MODE", "РЕЖИМ ЛД", "LRF-MODUS"),
    "T_WEAPON": ("TOP / PKT", "GUN / COAX", "ПУШКА / ПКТ", "KANONE / KOAX"),
    # nişangâh plakaları (HUD)
    "W_MAIN":  ("TOP", "GUN", "ПУШКА", "KANONE"),
    "W_COAX":  ("PKT", "COAX", "ПКТ", "KOAX"),
    "RANGE_M": ("MENZIL m", "RANGE m", "ДАЛЬН. м", "ENTF. m"),
    # sürücü / komutan istasyonları
    "T_ENGINE": ("MOTOR", "ENGINE", "ДВИГАТЕЛЬ", "MOTOR"),
    "T_LIGHT":  ("FARLAR", "LIGHTS", "ФАРЫ", "LICHT"),
    "T_HATCH":  ("KAPAK", "HATCH", "ЛЮК", "LUKE"),
    "SPEED":    ("HIZ", "SPEED", "СКОРОСТЬ", "GESCHW."),
    "L_RUN":    ("CALISIYOR", "RUNNING", "РАБОТАЕТ", "LAEUFT"),
    "FAULT":    ("ARIZA", "FAULT", "НЕИСПРАВНОСТЬ", "STOERUNG"),
    "F_ENG":    ("MOTOR", "ENG", "ДВИГ.", "MOT"),
    "F_LTR":    ("SOL PL.", "L TRK", "ЛЕВ.ГУС", "L.KETTE"),
    "F_RTR":    ("SAG PL.", "R TRK", "ПРАВ.ГУС", "R.KETTE"),
    "F_HULL":   ("GOVDE", "HULL", "КОРПУС", "WANNE"),
    "SMOKE":    ("DUMAN", "SMOKE", "ДЫМ", "NEBEL"),
    "W_NSVT":   ("NSVT 12.7", "NSVT 12.7", "НСВТ 12.7", "NSVT 12.7"),
    "CREW_EMPTY": ("BOS", "EMPTY", "ПУСТО", "LEER"),
    # muhimmat ekranı
    "COL_WEAPON": ("SILAH", "WEAPON", "ОРУЖИЕ", "WAFFE"),
    "COL_AMMO":   ("MUHIMMAT", "AMMUNITION", "СНАРЯД", "MUNITION"),
    "COL_COUNT":  ("ADET", "ROUNDS", "КОЛ.", "ANZAHL"),
    "SELECT":     ("SEC", "SELECT", "ВЫБОР", "WAHL"),
    "NO_AMMO":    ("MUHIMMAT BULUNAMADI", "NO AMMUNITION", "БОЕПРИПАСОВ НЕТ", "KEINE MUNITION"),
    # durum ekranı
    "Z_hull":    ("GOVDE", "HULL", "КОРПУС", "WANNE"),
    "Z_engine":  ("MOTOR", "ENGINE", "ДВИГАТЕЛЬ", "MOTOR"),
    "Z_ltrack":  ("SOL PALET", "LEFT TRACK", "ЛЕВАЯ ГУСЕНИЦА", "LINKE KETTE"),
    "Z_rtrack":  ("SAG PALET", "RIGHT TRACK", "ПРАВАЯ ГУСЕНИЦА", "RECHTE KETTE"),
    "Z_turret":  ("TARET", "TURRET", "БАШНЯ", "TURM"),
    "Z_gun":     ("TOP", "GUN", "ПУШКА", "KANONE"),
    "Z_fuel":    ("YAKIT DEPOSU", "FUEL TANK", "ТОПЛИВНЫЙ БАК", "TANK"),
    "KMH":       ("KM/H", "KM/H", "КМ/Ч", "KM/H"),
    "FUEL":      ("YAKIT", "FUEL", "ТОПЛИВО", "KRAFTSTOFF"),
    "ENGINE":    ("MOTOR", "ENGINE", "ДВИГАТЕЛЬ", "MOTOR"),
}


# ---------------------------------------------------------------- Strv 122 (Leo2S) nişancı istasyonu
# Yeni anahtarlar sözlük biçiminde (yalnızca ihtiyaç duyulan diller; eksik dil için en -> tr yedeği kullanılır).
# Kılavuzdan (Steel Beasts Strv 122, s.6-14) alınanlar: İsveççe terimler (STAB TILL, OBSERVATION, TORN FRÅN, BER, ELD, RK, KSP,
# SLPILPRJ 95, SLSGR 95, EMES/HW/WBG Almanca kısaltmaları). Diğer çeviriler en iyi bilgiyle yazıldı, doğrulanmadı.
L.update({
    "GPS_T":     {"tr": "GPS NISANGAH", "en": "GPS SIGHT", "de": "EMES", "sv": "SKYTTENS SIKTE"},
    "FC_TITLE":  {"tr": "ATIS KONTROL MODU", "en": "FIRE CONTROL MODE", "de": "FEUERLEITMODUS", "sv": "ELDLEDNINGSLÄGE"},
    "FC_NORMAL": {"tr": "NORMAL", "en": "NORMAL", "de": "STAB EIN", "sv": "STAB TILL"},
    "FC_EMERG":  {"tr": "ACIL", "en": "EMERGENCY", "de": "BEOBACHTEN", "sv": "OBSERVATION"},
    "FC_MANUAL": {"tr": "MANUEL", "en": "MANUAL", "de": "TURM AUS", "sv": "TORN FRÅN"},
    "AM_APFSDS": {"tr": "APFSDS-T", "en": "APFSDS-T", "de": "APFSDS-T", "sv": "SLPILPRJ 95"},
    "AM_HET":    {"tr": "HE-T", "en": "HE-T", "de": "HE-T", "sv": "SLSGR 95"},
    "LED_BER":   {"tr": "HAZIR", "en": "RDY", "de": "BER", "sv": "BER"},
    "LED_ELD":   {"tr": "ATES", "en": "FIRE", "de": "FEUER", "sv": "ELD"},
    "LED_RK":    {"tr": "KMT", "en": "TC", "de": "KH", "sv": "RK"},
    "LED_KSP":   {"tr": "MG", "en": "MG", "de": "MG", "sv": "KSP"},
    "LED_STAB":  {"tr": "STAB", "en": "STAB", "de": "STAB", "sv": "STAB"},
    "T_KANKSP":  {"tr": "TOP/MG", "en": "GUN/MG", "de": "HW/MG", "sv": "KAN/KSP"},
    "T_FUSE":    {"tr": "SPOLET", "en": "FUSE", "de": "ZÜNDER", "sv": "TÄNDRÖR"},
    "T_RMODE":   {"tr": "OTO/EL", "en": "AUTO/MAN", "de": "AUT/MAN", "sv": "AUTOM/MAN"},
    "T_IRV":     {"tr": "TIS", "en": "TIS", "de": "WBG", "sv": "IRV"},
    "T_POL":     {"tr": "POL B/S", "en": "POL W/B", "de": "POL W/S", "sv": "POL V/S"},
    "P_SS1500":  {"tr": "SS 1500", "en": "SS 1500", "de": "SS 1500", "sv": "SS 1500"},
    "P_BS":      {"tr": "BS 1100", "en": "BS 1100", "de": "BS 1100", "sv": "BS 1100"},
    "W_MG2":     {"tr": "MG 2", "en": "MG 2", "de": "MG3 (LADER)", "sv": "KSP 2"},
    "AVST_T":    {"tr": "MENZIL GIRISI", "en": "RANGE ENTRY", "de": "ENTFERNUNG", "sv": "AVSTÅND"},
    "P_RDN":     {"tr": "-100", "en": "-100", "de": "-100", "sv": "-100", "ru": "-100"},
    "P_RUP":     {"tr": "+100", "en": "+100", "de": "+100", "sv": "+100", "ru": "+100"},
    "T_TURRETPOS": {"tr": "TARET YONU (GOVDEYE GORE)", "en": "TURRET DIRECTION (RELATIVE TO HULL)", "de": "TURMRICHTUNG (ZUR WANNE)", "sv": "TORNRIKTNING (MOT SKROV)"},
    "REAR_T":    {"tr": "GERI GORUS", "en": "REAR VIEW", "de": "RÜCKFAHRKAMERA", "sv": "BACKKAMERA"},
    "M1_FC_T":   {"tr": "TARET / TOP KONTROLU", "en": "TURRET / GUN CONTROL"},
    "M1_FC_ON":  {"tr": "GUC + STAB ACIK", "en": "POWER + STAB ON"},
    "M1_FC_PWR": {"tr": "GUC ACIK / STAB KAPALI", "en": "POWER ON / STAB OFF"},
    "M1_FC_MAN": {"tr": "GUC KAPALI (MANUEL)", "en": "POWER OFF (MANUAL)"},
    "AM_SABOT":  {"tr": "SABOT (KE)", "en": "SABOT (KE)"},
    "AM_HEATM":  {"tr": "HEAT / MPAT", "en": "HEAT / MPAT"},
    "W_COAXM":   {"tr": "KOAKS M240", "en": "COAX M240"},
    "W_M2":      {"tr": ".50 CAL (CWS)", "en": ".50 CAL (CWS)"},
    "W_M240L":   {"tr": "M240 (YUKLEYICI)", "en": "M240 (LOADER)"},
    "LEO_NOTE":  {"tr": "Leopard 2 ailesi", "en": "Leopard 2 family", "de": "Leopard 2", "sv": "Leopard 2-familjen"},
})

# Svenska: ortak anahtarlar
_SV = {"CLOSE": "STÄNG", "ROLE_driver": "FÖRARE", "ROLE_gunner": "SKYTT", "ROLE_commander": "VAGNCHEF", "ROLE_other": "BESÄTTNING",
       "SCR_STATION": "STATION", "SCR_AMMO": "AMMUNITION", "SCR_STATUS": "STATUS", "LOAD": "LADDA", "LOADING": "LADDAR...",
       "FUEL": "BRÄNSLE", "SMOKE": "RÖK", "KMH": "KM/H", "ENGINE": "MOTOR", "COL_WEAPON": "VAPEN", "COL_AMMO": "AMMUNITION",
       "COL_COUNT": "ANTAL", "L_RUN": "GÅR", "F_ENG": "MOTOR", "F_LTR": "V BAND", "F_RTR": "H BAND", "F_HULL": "SKROV", "T_ENGINE": "MOTOR", "T_LIGHT": "LJUS", "SPEED": "HASTIGHET", "LASE": "LASRA", "RESET": "AVST 0", "W_MAIN": "KAN", "W_COAX": "KSP", "T_LRFON": "LRF PÅ", "L_LRF": "LASER", "T_HATCH": "LUCKA", "L_READY": "KLAR", "L_LOADED": "LADDAD", "RANGE_M": "AVST m", "CREW_EMPTY": "TOM", "SELECT": "VÄLJ", "NO_AMMO": "INGEN AMMUNITION", "SEL_TITLE": "AMMUNITIONSVAL"}
for _k, _v in _SV.items():
    if isinstance(L[_k], tuple):
        L[_k] = dict(zip(LANGS, L[_k]))
    L[_k]["sv"] = _v


def variants(key):
    """key -> {dil: metin} (yalnızca tanımlı olanlar)."""
    v = L[key]
    return v if isinstance(v, dict) else dict(zip(LANGS, v))


def text(key, lang):
    """Yedekli metin: dil -> en -> tr -> anahtar."""
    d = variants(key)
    return d.get(lang) or d.get("en") or d.get("tr") or key

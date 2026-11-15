# -*- coding: utf-8 -*-
"""
Etiket sözlüğü: anahtar -> (tr, en, ru, de). stringtable.xml ve önizleme buradan üretilir.
NOT: Rusça/Almanca etiketler en iyi bilgiyle yazıldı; Steel Beasts/kılavuz görselleriyle doğrulanmalı
(özellikle T_DELTA, L_TC, L_DELTA, SEL_OFF).
"""
LANGS = ["tr", "en", "ru", "de"]
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

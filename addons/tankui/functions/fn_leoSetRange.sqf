/*
 * Elle menzil girişi (Leopard 2 / Strv 122 balistik bilgisayarı: Avstånd MAN, savaş nişanı 1100 m, SS 1500).
 * params: [araç, metre]
 */
params ["_veh", "_m"];
_veh setVariable ["SB_range", _m, true];
_veh setVariable ["SB_lrfText", str _m, true];
_veh setVariable ["SB_rngMan", true, true];
if !(_veh getVariable ["SB_manHint", false]) then {
    _veh setVariable ["SB_manHint", true];
    systemChat "Elle menzil: bilgisayar degeri gosterilir; Arma'nin kendi balistigi nisangahtaki lazer/sifirlamaya baglidir.";
};

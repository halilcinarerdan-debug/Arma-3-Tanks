/*
 * Stabilizasyon gerçekten etkin mi? (kılavuz s.25-28)
 * STAB şalteri açık VE hidrolik açık VE jiroskop ısınmış (hidrolikten 120 sn sonra) VE aşırı ısınma yok.
 * Hidrolik ~50-60 dk (burada 55 dk = 3300 sn) sürekli STAB'dan sonra ısınır ve stabilizasyon kaybolur.
 * params: [araç] -> bool
 */
params ["_veh"];
private _now = time;
private _on = _veh getVariable ["SB_stab", false];
if (_on && {_now - (_veh getVariable ["SB_stabOn", _now]) >= 3300}) then {
    _veh setVariable ["SB_stab", false];
    _on = false;
    if (player in _veh) then { systemChat "T-72: hidrolik asiri isindi, stabilizasyon kayboldu (STAB'i yeniden acin)." };
};
_on && {_veh getVariable ["SB_hydr", false]} && {_now - (_veh getVariable ["SB_hydrOn", _now]) >= 120}

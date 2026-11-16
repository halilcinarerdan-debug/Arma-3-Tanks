/*
 * Menzil metni, başı sıfırla 4 hane ("0150"): M1A2 nişangâhının alt göstergesi böyle yazar (SB görüntüsü).
 * Menzil yoksa SB_fnc_rangeText'in "----" değeri aynen döner. params: [araç] -> metin
 */
params ["_veh"];
private _t = [_veh] call SB_fnc_rangeText;
if ((_t find "-") >= 0) exitWith {_t};
while {count _t < 4} do { _t = "0" + _t };
_t

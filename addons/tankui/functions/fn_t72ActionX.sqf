/*
 * Sürücü/komutan istasyonu eylemleri. Bu dosya BİLEREK ayrıdır: kullanılan bazı komutlar (action TurnOut/TurnIn/lightOn/lightOff,
 * fire) bu oturumda wiki'den doğrulanamadı; bir hata burada kalsın, nişancı istasyonunu (SB_fnc_t72Action) etkilemesin.
 * params: [eylem]  ->  engine | lights | hatch | smoke
 */
params ["_action"];
private _veh = uiNamespace getVariable ["SB_TankUI_vehicle", objNull];
if (isNull _veh) exitWith {};

switch (_action) do {
    case "engine": {
        // engineOn, aracın sahibinde (local) çalışmalı
        ["SB_TankUI_engine", [_veh, !(isEngineOn _veh)], _veh] call CBA_fnc_targetEvent;
    };
    case "lights": {
        player action [["lightOn", "lightOff"] select (call compile "isLightOn (uiNamespace getVariable 'SB_TankUI_vehicle')"), _veh];
    };
    case "hatch": {
        if (call compile "isTurnedOut player") then { player action ["TurnIn", _veh] } else { player action ["TurnOut", _veh] };
    };
    case "smoke": {
        // duman fırlatıcıyı bul: komutan veya nişancı tarette, silah, "smoke" içeren mermi kabul eden
        private _found = "";
        {
            { private _w = _x;
                if (_found == "" && {((compatibleMagazines _w) findIf {((toLower _x) find "smoke") >= 0}) >= 0}) then { _found = _w };
            } forEach (_veh weaponsTurret _x);
        } forEach [[0], [0, 0]];
        if (_found == "") exitWith { systemChat "Duman fırlatıcı bulunamadi." };
        private _count = { private _n = 0; { if (((toLower (_x select 1)) find "smoke") >= 0) then { _n = _n + (_x select 3) } } forEach ([_veh] call SB_fnc_getAmmoList); _n };
        private _before = call _count;
        ["SB_TankUI_fire", [_veh, _found], _veh] call CBA_fnc_targetEvent;
        [{
            params ["_before", "_count"];
            private _after = call _count;
            systemChat (if (_after < _before) then {"Duman atildi."} else {"Duman atilamadi (fire etkisiz kaldi). RPT'ye bakin."});
        }, [_before, _count], 1.2] call CBA_fnc_waitAndExecute;
    };
};

/*
 * Sürücü/komutan istasyonu eylemleri. Ayrı dosyada tutulur ki bir hata nişancı istasyonunu (SB_fnc_t72Action) etkilemesin.
 * Doğrulanmış sözdizimleri: docs/arma-ref/arma3-verified-commands.md (action TurnIn/TurnOut/LightOn/LightOff, fire, selectWeapon).
 * Hâlâ doğrulanmayan: durum okuyucular isLightOn / isTurnedOut (aşağıda compile içinde).
 * Not (wiki): TurnIn/TurnOut için birim, aracın ETKİN KOMUTANI olan bir oyuncu olmalıdır; yalnızca turn-in/out koltuklarında kullanılmalı.
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
        // Leopard 2 / Strv 122: MEHRFACHWURFANLAGE şalteri EIN olmadan duman atılmaz (profil özelliği smokeArm)
        if (([_veh, "smokeArm", 0] call SB_fnc_tProfile) > 0 && {!(_veh getVariable ["SB_smokeArmed", false])}) exitWith {
            systemChat "Duman atici kapali: MWA salterini EIN yapin.";
        };
        // fire/selectWeapon yalnızca YEREL birim için güvenilir: duman fırlatıcı oyuncunun kendi taretinde aranır ve oyuncuya ateş ettirilir
        private _own = uiNamespace getVariable ["SB_TankUI_turret", [0]];
        private _found = ["", ""];
        {
            private _w = _x;
            private _muz = getArray (configFile >> "CfgWeapons" >> _w >> "muzzles");
            if (_muz isEqualTo []) then { _muz = ["this"] };
            {
                private _m = if (_x == "this") then {_w} else {_x};
                if ((_found select 0) == "" && {((compatibleMagazines [_w, _m]) findIf {((toLower _x) find "smoke") >= 0}) >= 0}) then { _found = [_w, _m] };
            } forEach _muz;
        } forEach (_veh weaponsTurret _own);
        if ((_found select 0) == "") exitWith { systemChat "Duman firlatici bu koltukta yok (baska koltuktaki oyuncu atmali)." };

        private _prev = _veh currentWeaponTurret _own;
        private _count = { private _n = 0; { if (((toLower (_x select 1)) find "smoke") >= 0) then { _n = _n + (_x select 3) } } forEach ([_veh] call SB_fnc_getAmmoList); _n };
        private _before = call _count;
        [_veh, _own, _found select 0, _found select 1] call SB_fnc_selectWeapon;
        [{
            params ["_veh", "_own", "_muzzle", "_prev", "_before", "_count"];
            player fire _muzzle;
            [{
                params ["_veh", "_own", "_prev", "_before", "_count"];
                systemChat (if ((call _count) < _before) then {"Duman atildi."} else {"Duman atilamadi (fire etkisiz kaldi). RPT'ye bakin."});
                // önceki silaha dön
                if (_prev != "") then { [_veh, _own, _prev, _prev] call SB_fnc_selectWeapon };
            }, [_veh, _own, _prev, _before, _count], 1.2] call CBA_fnc_waitAndExecute;
        }, [_veh, _own, _found select 1, _prev, _before, _count], 0.9] call CBA_fnc_waitAndExecute;
    };
};

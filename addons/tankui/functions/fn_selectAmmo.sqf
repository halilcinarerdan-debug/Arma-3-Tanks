/* params: [turretPath, magClass] -> o taretteki uyumlu silah/namlu bulunur ve mermi yüklenir. */
params ["_turret", "_mag", ["_veh", objNull]];
if (isNull _veh) then { _veh = uiNamespace getVariable ["SB_TankUI_vehicle", objNull] };
if (isNull _veh) exitWith {};

([_veh, _turret, _mag] call SB_fnc_findWeapon) params ["_weaponToUse", "_muzzleToUse"];

if (_muzzleToUse isEqualTo "") exitWith {
    systemChat format ["Steel Tank UI: %1 icin uyumlu silah bulunamadi.", _mag];
};

// Mermi yükleme isteği (araç sahibinde çalışır; sonuç isteyen oyuncuya bildirilir)
private _sendLoad = {
    params ["_veh", "_turret", "_muzzle", "_mag"];
    systemChat format ["Yukleniyor: %1", getText (configFile >> "CfgMagazines" >> _mag >> "displayName")];
    ["SB_TankUI_loadMagazine", [_veh, _turret, _muzzle, _mag, player], _veh] call CBA_fnc_targetEvent;
};

private _curWeapon = _veh currentWeaponTurret _turret;
private _mine = (player in _veh) && {_turret isEqualTo (uiNamespace getVariable ["SB_TankUI_turret", [0]])};
private _wDisp = getText (configFile >> "CfgWeapons" >> _weaponToUse >> "displayName");

if (_curWeapon != _weaponToUse) then {
    // PKT / duman fırlatıcı gibi başka bir SİLAH seçiliyor: önce silahı seç (yalnızca kendi koltuğumuzun silahı seçilebilir)
    if !(_mine) exitWith { systemChat format ["%1 baska bir koltugun silahi; o koltuktaki oyuncu secmeli.", _wDisp] };
    player selectWeapon _muzzleToUse;
    systemChat format ["Silah secildi: %1", _wDisp];
    [{
        params ["_veh", "_turret", "_weapon", "_muzzle", "_mag"];
        if ((_veh currentWeaponTurret _turret) != _weapon) exitWith {
            systemChat "Silah secilemedi (selectWeapon etkisiz kaldi). RPT'ye bakin.";
            diag_log format ["[SB_TankUI] selectWeapon basarisiz: istenen=%1 mevcut=%2 taret=%3", _weapon, _veh currentWeaponTurret _turret, _turret];
        };
        // silah değişti; seçilen mermi zaten yüklü değilse yükle
        if ((_veh currentMagazineTurret _turret) != _mag) then {
            systemChat format ["Yukleniyor: %1", getText (configFile >> "CfgMagazines" >> _mag >> "displayName")];
            ["SB_TankUI_loadMagazine", [_veh, _turret, _muzzle, _mag, player], _veh] call CBA_fnc_targetEvent;
        };
    }, [_veh, _turret, _weaponToUse, _muzzleToUse, _mag], 0.4] call CBA_fnc_waitAndExecute;
} else {
    if ((_veh currentMagazineTurret _turret) isEqualTo _mag) then {
        systemChat format ["Zaten secili ve yuklu: %1", getText (configFile >> "CfgMagazines" >> _mag >> "displayName")];
    } else {
        [_veh, _turret, _muzzleToUse, _mag] call _sendLoad;
    };
};

// ACE self-interact: araç içindeyken "Tank sistemleri" girişi.
if (isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) then {
    private _action = [
        "SB_TankUI_open", "Tank sistemleri", "",
        {[] call SB_fnc_openMenu},
        {_player in _target && {alive _target}}
    ] call ace_interact_menu_fnc_createAction;
    ["Tank", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
};

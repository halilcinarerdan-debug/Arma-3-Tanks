/* Gerçek top stabilizasyonu (enableGunStabilization) kullanılıyor mu? CBA ayarı "SB_TankUI_stabMode" = 0 ve Arma >= 2.22. -> bool */
((missionNamespace getVariable ["SB_TankUI_stabMode", 0]) == 0) && {(productVersion select 2) >= 222}

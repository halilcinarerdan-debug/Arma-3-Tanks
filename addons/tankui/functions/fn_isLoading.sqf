/*
 * Yükleyici çalışıyor mu? Bayrak yerine ZAMAN DAMGASI: SB_loadEnd geçince "yükleniyor" kendiliğinden biter.
 * (Önceki boolean bayrak, kapatan geri çağrım hiç çalışmazsa/hata verirse "YUKLUYOR..." yazısını takılı bırakıyordu.)
 * params: [araç] -> bool
 */
params ["_veh"];
time < (_veh getVariable ["SB_loadEnd", 0])

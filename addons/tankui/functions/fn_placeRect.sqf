/*
 * Bir dikdörtgen kontrolü (ibre, çubuk, şalter kolu, çentik) taban noktasından açıya doğru uzatır.
 * params: [ctrl, tabanX, tabanY, uzunluk(yükseklik oranı), kalınlık(yükseklik oranı), açı(derece, 0=yukarı, saat yönü), asp, sgn]
 * Kontrolün kendi merkezi etrafında döndürülür (pivot belirsizliği yok).
 */
params ["_c", "_bx", "_by", "_len", "_thick", "_ang", "_asp", "_sgn"];
private _w = _thick * _asp;
private _cx = _bx + (sin _ang) * (_len / 2) * _asp;
private _cy = _by - (cos _ang) * (_len / 2);
_c ctrlSetPosition [_cx - _w / 2, _cy - _len / 2, _w, _len];
_c ctrlCommit 0;
// Açı, konum commit'inden SONRA verilir (önce verildiğinde oyunda uygulanmıyordu)
_c ctrlSetAngle [_ang * _sgn, 0.5, 0.5];
_c ctrlCommit 0;

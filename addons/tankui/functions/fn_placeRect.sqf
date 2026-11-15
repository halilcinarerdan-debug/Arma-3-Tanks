/*
 * İbre / kol / işaretçi kontrolünü pivot noktasında döndürür.
 * params: [ctrl, pivotX, pivotY, uzunluk(pivottan uca, yükseklik oranı), (kullanılmıyor), açı(derece, 0=yukarı, saat yönü), asp, sgn]
 *
 * Doku KARE ve pivot dokunun merkezindedir; kontrol de pivot etrafında 2*uzunluk kenarlı kare olarak yerleştirilir.
 * Neden: ctrlSetAngle döndürülen resmi kontrolün ORİJİNAL dikdörtgenine kırpıyor; ince dikdörtgen kullanıldığında
 * ibre yalnızca küçük bir parça olarak görünüyordu. Kare kontrol, merkez etrafında her açıda kendi içinde kalır.
 */
params ["_c", "_bx", "_by", "_len", "_thick", "_ang", "_asp", "_sgn"];
private _side = _len * 2;
private _w = _side * _asp;
_c ctrlSetPosition [_bx - _w / 2, _by - _side / 2, _w, _side];
_c ctrlCommit 0;
_c ctrlSetAngle [_ang * _sgn, 0.5, 0.5];
_c ctrlCommit 0;

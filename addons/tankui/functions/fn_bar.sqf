/* params: [0..1 değer, (opsiyonel) uzunluk] -> "[#######-----]" */
params ["_val", ["_len", 20]];
private _n = round ((0 max _val min 1) * _len);
private _s = "[";
for "_i" from 1 to _len do { _s = _s + (["-", "#"] select (_i <= _n)) };
_s + "]"

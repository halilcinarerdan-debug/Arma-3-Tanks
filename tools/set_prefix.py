#!/usr/bin/env python3
"""
PBO ön ekini tüm projede değiştirir ($PBOPREFIX$, config, SQF include/doku yolları, dokümanlar).
pboProject dosyaları P: sürücüsünde bu ön ekle arar; proje P:\\<ön ek> altında durmalıdır.

Kullanım:  python3 tools/set_prefix.py "z\\tank33\\addons\\tankui"
"""
import os, sys

if len(sys.argv) != 2:
    sys.exit(__doc__)
new = sys.argv[1].strip().strip("\\").replace("/", "\\")
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
pfile = os.path.join(root, "addons", "tankui", "$PBOPREFIX$")
old = open(pfile).read().strip()
if old == new:
    sys.exit("zaten bu on ek: " + old)
n = 0
for base, dirs, files in os.walk(root):
    dirs[:] = [d for d in dirs if d not in (".git", "data")]
    for f in files:
        if not f.endswith((".cpp", ".hpp", ".sqf", ".md", ".py", ".xml")) and f != "$PBOPREFIX$":
            continue
        p = os.path.join(base, f)
        s = open(p, encoding="utf-8").read()
        t = s.replace(old, new).replace(old.replace("\\", "\\\\"), new.replace("\\", "\\\\"))
        if t != s:
            open(p, "w", encoding="utf-8", newline="").write(t); n += 1
open(pfile, "w", newline="").write(new)
print("%d dosya guncellendi: %s -> %s" % (n, old, new))

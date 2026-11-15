#!/usr/bin/env python3
"""labels.py -> addons/tankui/stringtable.xml. Her dil ayrı anahtar (STR_SB_<dil>_<ANAHTAR>), yalnızca <Original>:
oyun dili ne olursa olsun araç dili etiketleri döner (araca özgü dil)."""
import os, sys
from xml.sax.saxutils import escape
sys.path.insert(0, os.path.dirname(__file__))
from labels import L, LANGS
out = ['<?xml version="1.0" encoding="utf-8"?>', '<Project name="SB_TankUI">', '    <Package name="SB_TankUI">']
for key, vals in L.items():
    for lang, v in zip(LANGS, vals):
        out.append(f'        <Key ID="STR_SB_{lang}_{key}"><Original>{escape(v)}</Original></Key>')
out += ['    </Package>', '</Project>', '']
path = os.path.join(os.path.dirname(__file__), "..", "addons", "tankui", "stringtable.xml")
open(path, "w", encoding="utf-8").write("\n".join(out))
print("yazildi", os.path.normpath(path), len(L) * len(LANGS), "anahtar")

"""Regenerates lib/core/config/default_config.g.dart from tool/config/config.json.

The app bundles this JSON as its fallback until Firestore `config/*` loads.
Run from app/:  python tool/config/gen_defaults.py
"""
import json
import pathlib

root = pathlib.Path(__file__).resolve().parents[2]
raw = (root / 'tool/config/config.json').read_text(encoding='utf-8')
compact = json.dumps(json.loads(raw), ensure_ascii=False, separators=(',', ':'))
escaped = compact.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
out = (
    '// GENERATED from tool/config/config.json by tool/config/gen_defaults.py.\n'
    '// Do not edit by hand. Bundled fallback used before Firestore config loads.\n'
    '// ignore_for_file: lines_longer_than_80_chars\n\n'
    "const String kDefaultConfigJson = '" + escaped + "';\n"
)
target = root / 'lib/core/config/default_config.g.dart'
target.write_text(out, encoding='utf-8', newline='\n')
print('wrote', target.relative_to(root), len(out), 'chars')

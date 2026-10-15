#!/usr/bin/env bash
set -e
python3 - <<'PY'
from pathlib import Path
import re
import shutil
import subprocess

p = Path.home() / 'pi-apps' / 'api'
if not p.is_file():
    raise SystemExit('No existe ~/pi-apps/api. Primero instala Pi-Apps.')
text = p.read_text()
marker = '  return 0 # bypass local para Breadstick'
if marker in text:
    raise SystemExit('El parche ya esta aplicado. Abre con: bash ~/pi-apps/gui')
pattern = r'(?m)^[ \t]*(?:function[ \t]+is_supported_system(?:[ \t]*\(\))?|is_supported_system[ \t]*\(\))[ \t\r\n]*\{'
match = re.search(pattern, text)
if not match:
    raise SystemExit('No encontre la funcion. No se modifico ningun archivo.')
patched = text[:match.end()] + chr(10) + marker + chr(10) + text[match.end():]
check = subprocess.run(['bash', '-n'], input=patched, text=True, capture_output=True)
if check.returncode:
    raise SystemExit('Validacion fallida. No se modifico el archivo. ' + check.stderr)
backup = p.with_name('api.bak-breadstick')
if not backup.exists():
    shutil.copy2(p, backup)
p.write_text(patched)
print('Listo. Copia de seguridad:', backup)
print('Abre Pi-Apps con: bash ~/pi-apps/gui')
print('Esto solo omite la comprobacion; no garantiza compatibilidad con Breadstick.')
PY

#!/usr/bin/env python3
"""Descarga pública y conversión local; nunca ejecuta código de la página."""
import html
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import urllib.request

url = "https://dromercode.github.io/chuleta-entorno-nvim/"
dest = Path(sys.argv[1])
try:
    req = urllib.request.Request(url, headers={"User-Agent": "entorno-nvim/1.0"})
    with urllib.request.urlopen(req, timeout=15) as response:
        raw = response.read(2_000_001)
    if len(raw) > 2_000_000:
        raise ValueError("página demasiado grande")
    source = raw.decode("utf-8")
    if "Chuleta Entorno-Nvim" not in source:
        raise ValueError("la respuesta no parece la chuleta esperada")
    # El autor utiliza divs con spans para bloques de comandos; convertirlos
    # a pre antes de Pandoc conserva los saltos de línea y evita ejecutarlos.
    def codeblock(match):
        content = html.unescape(re.sub(r"<[^>]*>", "", match.group(1)))
        return "<pre>" + html.escape(content) + "</pre>"
    source = re.sub(r'<div class="codeblock">(.*?)</div>', codeblock, source, flags=re.S)
    result = subprocess.run(["pandoc", "-f", "html-native_divs-native_spans", "-t", "gfm-raw_html", "--wrap=none"],
                            input=source, capture_output=True, text=True, check=True, timeout=20)
    # La chuleta del 2026-11-08 ya no recomienda `git restore .` y explica que
    # el reset de mini.diff usa el índice Git: basta con indicar su origen.
    warning = "> Copia de la chuleta del alumnado (dromercode.github.io).\n\n"
    dest.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", dir=dest.parent, delete=False) as temporary:
        temp = Path(temporary.name)
        temporary.write(warning + result.stdout)
    try:
        os.replace(temp, dest)
    finally:
        temp.unlink(missing_ok=True)
except Exception as error:
    print(str(error), file=sys.stderr)
    sys.exit(1)

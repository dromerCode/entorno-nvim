#!/usr/bin/env python3
"""Comprueba selección de configuración y degradación, sin instalar delta."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="delta-test-") as directory:
    work = Path(directory)
    binary = work / "bin"
    binary.mkdir()
    config = work / "config con espacios"
    config.mkdir()
    (config / "config.yml").write_text("gui:\n  mouseEvents: true\n")
    lazygit = binary / "lazygit"
    lazygit.write_text('''#!/usr/bin/python3
import json, os, sys
if sys.argv[1:] == ["--version"]: print(os.environ["FAKE_VERSION"])
elif sys.argv[1:] == ["--print-config-dir"]: print(os.environ["FAKE_CONFIG"])
else: print(json.dumps(sys.argv[1:]))
''')
    lazygit.chmod(0o755)
    for name in ["sed", "dirname"]:
        (binary / name).symlink_to(shutil.which(name))
    env = dict(os.environ, PATH=str(binary), FAKE_VERSION="version=0.66.2",
               FAKE_CONFIG=str(config), LG_CONFIG_FILE="")

    def run():
        result = subprocess.run(["/bin/sh", str(root / "scripts/lazygit.sh")], env=env,
                                check=True, capture_output=True, text=True)
        return json.loads(result.stdout)

    assert run() == [], "Sin delta, lazygit normal"
    delta = binary / "delta"
    delta.write_text("#!/bin/sh\nexit 0\n")
    delta.chmod(0o755)
    args = run()
    assert args == ["--use-config-file", str(config / "config.yml") + "," + str(root / "config/lazygit-delta.yml")]
    env["FAKE_VERSION"] = "commit=v0.63.0, version=0.63.0, git version=2.56.0"
    assert run()[1].endswith("lazygit-delta-legacy.yml")
    env["LG_CONFIG_FILE"] = str(work / "personal.yml")
    assert run()[1].startswith(env["LG_CONFIG_FILE"] + ",")
    env["FAKE_VERSION"] = "versión desconocida"
    assert run() == [], "Versión desconocida: lazygit normal"
print("OK: delta opcional, lazygit moderno/antiguo, configuración personal y rutas con espacios")

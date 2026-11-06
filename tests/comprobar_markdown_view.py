#!/usr/bin/env python3
"""Prueba el ciclo real de ventanas en un servidor tmux temporal."""
from pathlib import Path
import os
import shutil
import subprocess
import tempfile
import time

root = Path(__file__).resolve().parents[1]
socket = f"markdown-view-test-{os.getpid()}"

def tmux(*args, **kwargs):
    return subprocess.run(["tmux", "-L", socket, *args], check=True,
                          text=True, capture_output=True, **kwargs).stdout.strip()

def wait_for(predicate):
    deadline = time.monotonic() + 8
    while time.monotonic() < deadline:
        if predicate():
            return
        time.sleep(0.1)
    raise AssertionError("No se alcanzó el estado esperado de tmux")

with tempfile.TemporaryDirectory(prefix="markdown-view-test-") as directory:
    work = Path(directory)
    binary = work / "mdcat"
    binary.write_text('#!/bin/sh\nprintf "MDCAT %s\\n" "$*"\n')
    binary.chmod(0o755)
    document = work / "léeme $(touch NO-EJECUTAR).md"
    document.write_text("# Prueba\n")
    other = work / "otro documento.md"
    other.write_text("# Otro\n")
    try:
        origin = tmux("-f", "/dev/null", "new-session", "-d", "-P", "-F", "#{pane_id}",
                      "-s", "prueba", "-c", str(work))
        tmux("set-environment", "-t", "prueba", "PATH", str(work) + ":" + os.environ["PATH"])
        env = dict(os.environ, PATH=str(work) + ":" + os.environ["PATH"],
                   TMUX=tmux("display-message", "-p", "-t", origin, "#{socket_path},0,0"))

        def open_doc(path, pane=origin):
            subprocess.run(["bash", str(root / "scripts/markdown-view.sh"), "--open", pane, str(path)],
                           env=env, check=True, capture_output=True, text=True)

        def windows():
            return tmux("list-windows", "-t", "prueba", "-F", "#{window_id} #{@entorno_window_role}").splitlines()

        open_doc(document)
        docs = next(row.split()[0] for row in windows() if row.endswith(" docs"))
        wait_for(lambda: "q: cerrar" in tmux("capture-pane", "-p", "-t", docs))
        output = tmux("capture-pane", "-p", "-t", docs)
        assert "--local -P --" in output and "NO-EJECUTAR" in output
        assert not (work / "NO-EJECUTAR").exists()
        tmux("send-keys", "-t", docs, "r")
        wait_for(lambda: "q: cerrar" in tmux("capture-pane", "-p", "-t", docs))
        open_doc(other)
        assert len(windows()) == 2
        wait_for(lambda: "otro documento.md" in tmux("capture-pane", "-p", "-t", docs))
        second = tmux("new-session", "-d", "-P", "-F", "#{pane_id}", "-s", "segunda")
        tmux("set-environment", "-t", "segunda", "PATH", env["PATH"])
        open_doc(document, second)
        assert len(tmux("list-windows", "-t", "segunda").splitlines()) == 2
        assert len(windows()) == 2
        tmux("send-keys", "-t", docs, "q")
        wait_for(lambda: len(windows()) == 1)
        assert tmux("display-message", "-p", "-t", "prueba", "#{pane_id}") == origin
        long_document = work / "documento largo.md"
        long_document.write_text("# Inicio\n\n" + "\n\n".join(f"Párrafo {i}" for i in range(100)))
        open_doc(long_document)
        long_docs = next(row.split()[0] for row in windows() if row.endswith(" docs"))
        # Cambiar el doble por uno que produzca muchas líneas, sin exigir mdcat.
        binary.write_text('#!/bin/sh\nprintf "PRINCIPIO-DEL-DOCUMENTO\\n"\ni=0\nwhile [ "$i" -lt 100 ]; do printf "Línea %s\\n" "$i"; i=$((i+1)); done\n')
        tmux("send-keys", "-t", long_docs, "r")
        wait_for(lambda: tmux("display-message", "-p", "-t", long_docs, "#{pane_in_mode}") == "1")
        # capture-pane no refleja el desplazamiento de un cliente adjunto.
        # Verificar la posición real del modo copia en el extremo superior.
        wait_for(lambda: tmux("display-message", "-p", "-t", long_docs,
                             "#{==:#{scroll_position},#{history_size}}") == "1")
        assert "PRINCIPIO-DEL-DOCUMENTO" in tmux("capture-pane", "-p", "-S", "-", "-t", long_docs)
        tmux("send-keys", "-t", long_docs, "q")
        wait_for(lambda: tmux("display-message", "-p", "-t", long_docs, "#{pane_in_mode}") == "0")
        tmux("send-keys", "-t", long_docs, "q")
        wait_for(lambda: len(windows()) == 1)
        if shutil.which("mdcat"):
            tmux("set-environment", "-t", "prueba", "PATH", os.environ["PATH"])
            env["PATH"] = os.environ["PATH"]
            open_doc(other)
            real_docs = next(row.split()[0] for row in windows() if row.endswith(" docs"))
            wait_for(lambda: "q: cerrar" in tmux("capture-pane", "-p", "-t", real_docs))
            rendered = tmux("capture-pane", "-p", "-t", real_docs)
            assert "Otro" in rendered and "No se pudo representar" not in rendered, rendered
            tmux("send-keys", "-t", real_docs, "q")
            wait_for(lambda: len(windows()) == 1)
            print("OK: mdcat real representa Markdown dentro de tmux (sin comprobación gráfica)")
        print("OK: apertura, recarga, reutilización, cierre, retorno y aislamiento entre sesiones tmux")
    finally:
        subprocess.run(["tmux", "-L", socket, "kill-server"], capture_output=True)

"""Selección por arquitectura y rechazo temprano; no instala paquetes del sistema.

Opcional: pasar un tarball oficial ARM64 para probar extracción e integridad
sin ejecutar el binario ARM en el equipo anfitrión.
"""
import hashlib
import os
import shutil
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix="entorno-arm-") as directory:
    work = Path(directory)
    bin_dir = work / "bin"
    bin_dir.mkdir()
    uname = bin_dir / "uname"
    uname.write_text('#!/bin/sh\ncase "$1" in -s) echo Linux ;; -m) echo "$TEST_ARCH" ;; *) exit 1 ;; esac\n')
    uname.chmod(0o755)
    env = dict(os.environ, PATH=f"{bin_dir}:{os.environ['PATH']}", WSL_DISTRO_NAME="Ubuntu")
    for arch, nvim, node in [("x86_64", "linux-x86_64", "linux-x64"),
                             ("aarch64", "linux-arm64", "linux-arm64"),
                             ("arm64", "linux-arm64", "linux-arm64"),
                             ("armv7l", "", "")]:
        env["TEST_ARCH"] = arch
        proc = subprocess.run(["sh", "-c", '. "$1/scripts/lib/versiones.sh"; '
                               '. "$1/scripts/lib/plataforma.sh"; '
                               'printf "%s|%s|%s" "$ENTORNO_NVIM_PLATFORM" '
                               '"$ENTORNO_NODE_PLATFORM" "$ENTORNO_IS_WSL"', "test", str(root)],
                              env=env, capture_output=True, text=True, check=True)
        assert proc.stdout == f"{nvim}|{node}|1", proc.stdout
        alumno = subprocess.run(["sh", str(root / "scripts/instalar-alumno.sh"), "--comprobar"],
                                env=env, stdin=subprocess.DEVNULL, capture_output=True, text=True)
        if nvim:
            assert "Perfil: alumno" in alumno.stdout, alumno.stderr
        else:
            assert alumno.returncode != 0 and "detectado Linux armv7l" in alumno.stderr
        if not nvim:
            env["ENTORNO_NVIM_OPT_ROOT"] = str(work / "unsupported")
            proc = subprocess.run(["sh", str(root / "scripts/instalar-neovim.sh")],
                                  env=env, capture_output=True, text=True)
            assert proc.returncode != 0 and "armv7l" in proc.stderr, proc
            assert not (work / "unsupported").exists()
    print("OK: x86_64, aarch64 y arm64 en WSL; ARM32 rechazado antes de escribir")
    # Ubuntu/WSL simulado con herramientas ausentes: revisar nombres de
    # paquetes y que ni --comprobar ni --sin-sistema autoricen sudo.
    minimal = work / "minimal"
    minimal.mkdir()
    for tool in ("dirname", "id", "cat", "grep", "tr"):
        (minimal / tool).symlink_to(shutil.which(tool))
    (minimal / "uname").symlink_to(uname)
    sed = minimal / "sed"
    sed.write_text('#!/bin/sh\nfor arg do\n'
                   ' if [ "$arg" = /etc/os-release ]; then echo "$TEST_DISTRO"; exit; fi\n'
                   'done\nexec /usr/bin/sed "$@"\n')
    sed.chmod(0o755)
    sudo = minimal / "sudo"
    sudo.write_text('#!/bin/sh\necho "ERROR: sudo ejecutado" >&2; exit 99\n')
    sudo.chmod(0o755)
    for distro in ("ubuntu", "debian", "arch", "cachyos"):
        for arch in ("x86_64", "aarch64", "arm64"):
            package_env = dict(env, PATH=str(minimal), TEST_ARCH=arch, TEST_DISTRO=distro,
                               ENTORNO_PERFIL_GUARDADO=str(work / "perfil"))
            for args in (["--comprobar"], ["--yes", "--sin-sistema"]):
                proc = subprocess.run(["/bin/sh", str(root / "scripts/instalar-alumno.sh"), *args],
                                      env=package_env, stdin=subprocess.DEVNULL,
                                      capture_output=True, text=True)
                assert proc.returncode == 1, proc
                command = proc.stdout.split("Comando para instalarlos:\n  ")[1].splitlines()[0]
                if distro in ("ubuntu", "debian"):
                    assert command.startswith("sudo apt-get update"), command
                    packages = ("fd-find", "ripgrep", "xz-utils", "shellcheck", "python3")
                else:
                    assert command.startswith("sudo pacman -S --needed"), command
                    packages = ("fd", "ripgrep", "xz", "shellcheck", "python")
                    assert "python3" not in command
                for package in packages:
                    assert package in command.split(), (package, command)
                assert "ERROR: sudo ejecutado" not in proc.stderr
                assert not (work / "perfil").exists()
    print("OK: paquetes Debian/Ubuntu/Arch/CachyOS x86_64 y ARM64; sin sudo ni perfil guardado en comprobación/fallo")
    if len(sys.argv) > 1:
        env["TEST_ARCH"] = "aarch64"
        env["TEST_ARCHIVE"] = str(Path(sys.argv[1]).resolve())
        env["ENTORNO_NVIM_OPT_ROOT"] = str(work / "tools")
        curl = bin_dir / "curl"
        curl.write_text('#!/bin/sh\nwhile [ "$#" -gt 0 ]; do\n'
                        ' if [ "$1" = --output ]; then cp "$TEST_ARCHIVE" "$2"; exit; fi\n'
                        ' shift\ndone\nexit 1\n')
        curl.chmod(0o755)
        subprocess.run(["sh", str(root / "scripts/instalar-neovim.sh")], env=env, check=True)
        installed = next((work / "tools").glob("nvim-*/bin/nvim"))
        digest = hashlib.sha256(installed.read_bytes()).hexdigest()
        assert digest == "d9635db0b272b7c81cd705ef0d8bbf16edfeb05b08b36b4228ab0d6a92ec384f"
        bad = work / "bad.tar.gz"
        bad.write_bytes(b"descarga corrupta")
        env["TEST_ARCHIVE"] = str(bad)
        env["ENTORNO_NVIM_OPT_ROOT"] = str(work / "bad-tools")
        proc = subprocess.run(["sh", str(root / "scripts/instalar-neovim.sh")],
                              env=env, capture_output=True, text=True)
        assert proc.returncode != 0 and "SHA-256 incorrecto" in proc.stderr
        assert not list((work / "bad-tools").glob("nvim-*"))
        print("OK: tarball ARM64 oficial instalado y verificado sin ejecutarlo; corrupción rechazada")

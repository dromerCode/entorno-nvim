# Propuesta: documentación Markdown en tmux

Análisis del 06/11/2026. Implementación local realizada posteriormente: véase [uso y comprobaciones](visor-markdown.md). Este documento conserva el planteamiento previo.

## Flujo propuesto

- Espacio m r: leer el Markdown actual en una ventana tmux «docs».
- Espacio m d: seleccionar documentación Markdown del proyecto, usando la búsqueda existente.
- Mantener Espacio m p y Espacio m v para el PDF del perfil profesor.
- Lectura disponible en todos los perfiles, independientemente de la exportación PDF.
- Reutilizar una ventana de documentación por sesión; q cierra el visor y devuelve el foco al editor de origen.
- Primera fase: leer la versión guardada y avisar si hay modificaciones; no guardar implícitamente. Mantener la ventana abierta tras terminar mdcat, con controles explícitos para volver o cerrar y sin acumular un shell huérfano.
- Sin tmux: terminal de Neovim con el mismo visor.

## Motor

Elección del señor tras prueba propia: mdcat directo, conservando las imágenes que ya ve correctamente con mdcat README.md. No forzar paginación ni ANSI en el flujo principal; ambos limitarían la representación gráfica. Mantener recursos locales por defecto. Detectar ejecutable y opciones antes de usarlas: hay versiones antiguas diferentes. Glow queda descartado para este flujo: el señor informa de errores con imágenes que mdcat representa correctamente. Sin visor, explicar qué falta y permitir lectura como texto.

El original swsnr/mdcat está archivado; BIRSAx2/mdcat mantiene la continuación. Revisar procedencia y versión al preparar instaladores. No añadir Rust, Go o Node solo para el visor: preferir paquetes disponibles o binarios de versión fijada y procedencia comprobada.

La lectura paginada de mdcat desactiva imágenes con paginadores convencionales. No prometer equivalencia con navegador, CSS ni PDF; mantener Pandoc/CSS/Chromium para comprobar el resultado de impresión. Tablas anchas, enlaces, imágenes y documentos con HTML requieren comprobaciones específicas.

## Portabilidad prevista (no validación física)

| Entorno | Estrategia |
| --- | --- |
| WSL2 Ubuntu/Debian | Neovim, tmux y visor Linux en la misma distribución; Windows Terminal como anfitrión. Sin necesidad de WSLg para texto. |
| Debian 13 / Ubuntu | Consultar paquete y versión realmente disponibles; no asumir apt install mdcat universal. |
| Arch / CachyOS | Consultar paquetes y su procedencia; distinguir paquete de repositorio de AUR. |
| Fedora / openSUSE | Consultar repositorios habilitados; binario fijado si procede, sin compilador como requisito. |
| SSH / terminal limitada | ANSI básico; degradación a texto si faltan capacidades. |

En WSL, preferir proyectos en /home por rendimiento; admitir también /mnt/c y rutas con espacios. Usar herramientas Linux, sin mezclar rutas C:\ con rutas del visor. Intel y AMD comparten normalmente binarios x86_64; ARM64 necesita su compilación correspondiente. Las capacidades visuales dependen también del emulador y tmux.

## Corrección aportada por el señor — 06/11/2026

El señor confirma que mdcat README.md muestra imágenes correctamente en su entorno y comunica errores con Glow. Es evidencia de su uso directo; aún falta comprobar esa misma representación dentro de la ventana tmux propuesta. Priorizar conservar imágenes. Probar primero mdcat directo y desplazamiento del terminal/tmux; no introducir less ni forzar ANSI como valor predeterminado. El desplazamiento con imágenes dentro de tmux también debe validarse, no solo su aparición inicial.

## Integración y comprobaciones pendientes

Módulo Lua pequeño y helper shell siguiendo scripts/tmux-lazygit.sh, con selección explícita de sesión/panel y socket actual. Pasar rutas como argumentos, sin concatenar comandos sin escapar. Etiquetar ventana con metadata; evitar crear duplicados o afectar otras sesiones. Sin nuevos plugins de Neovim.

Probar apertura, reutilización, cierre y retorno al editor, cancelación del selector, archivo sin guardar, ruta con espacios/acentos, ejecutable ausente, dos sesiones y ejecución sin tmux. Después validar físicamente WSL2 y Linux. Actualización automática al guardar sería una fase posterior; --watch y paginación deben probarse juntos antes de ofrecerlos como una sola función.

## Evidencia local

HEAD 99bd752, árbol limpio antes de este documento. Instalados mdcat 2.19.0, glow 3.0.0 y tmux 3.8. Renderizado de muestra temporal con título, negrita, código y tabla: mdcat --local --ansi terminó con código 0 y contenido esperado. Glow con configuración personal terminó con código 0 pero salida sin contenido; repetido con --config /dev/null, estilo dark y anchura 80 por stdin, devolvió el contenido esperado. No se inspeccionó ni modificó su configuración personal. No se ha probado una ventana tmux interactiva ni equipos WSL2.

## Fuentes consultadas

- https://github.com/BIRSAx2/mdcat
- https://github.com/BIRSAx2/mdcat/blob/main/mdcat.1.adoc
- https://github.com/swsnr/mdcat
- https://github.com/charmbracelet/glow
- https://learn.microsoft.com/en-us/windows/wsl/filesystems

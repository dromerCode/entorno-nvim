# Leer Markdown con mdcat

## Uso

En modo normal de Neovim:

- **Espacio m r** abre el Markdown actual guardado.
- **Espacio m d** busca documentación desde la carpeta de trabajo, respetando los archivos ignorados por rg.
- **r** recarga el documento en el visor; **q** lo cierra y vuelve al panel de origen.
- Desplazar en tmux: rueda o **Ctrl-a [**, y después flechas/PageUp/PageDown. En modo copia, q sale primero de ese modo; otra q cierra el visor.

Los documentos largos se abren por el principio en el modo de desplazamiento de tmux: q sale de ese modo; después r recarga o q cierra el visor.

Se reutiliza una ventana **docs** por sesión tmux. No se guardan cambios automáticamente: si el documento tiene modificaciones en Neovim, se pide guardar con Espacio w. Se admiten .md y .markdown. Disponible en todos los perfiles; Espacio m p/m v conserva el flujo PDF del profesor.

Sin tmux se abre una terminal dentro de Neovim; no se garantizan imágenes en esa terminal integrada. El visor se cierra con q estando en modo terminal; si has salido a modo normal, pulsa i para volver a enviar teclas al visor.

## Imágenes y portabilidad

El helper ejecuta mdcat --local -P directamente: no fuerza ANSI ni usa less. Conserva la detección gráfica de mdcat; --local admite imágenes locales y evita descargar recursos remotos. Las imágenes enlazadas mediante URL no se descargan en este flujo. Las rutas relativas se resuelven desde el directorio del documento.

Mostrar imágenes fuera de tmux no certifica que se vean dentro: depende del protocolo del emulador, mdcat y tmux. Esta implementación no cambia TERM ni la configuración gráfica global; el aspecto y desplazamiento con imágenes necesitan la prueba visual del usuario. No reproduce CSS ni la composición del PDF.

En Linux y WSL2 se usan las mismas herramientas Linux dentro de la misma distribución. No requiere WSLg para texto. Admitidas rutas con espacios y acentos, también bajo /mnt/c; se recomienda /home para rendimiento. Intel/AMD x86_64 usan la misma arquitectura; ARM64 requiere binario propio.

## Requisitos y mantenimiento

mdcat es una dependencia directa opcional para lectura con formato. Ya existe en el equipo del señor (2.19.0). Resuelve el renderizado e imágenes sin nuevos plugins. La alternativa sencilla es leer el archivo en Neovim; no se introduce Glow. No se añade ninguna dependencia a los instaladores ni se instala nada automáticamente. En otra máquina, comprobar command -v mdcat y mdcat --version, y revisar paquete/versión/procedencia antes de instalar. No se presupone que apt disponga del paquete. La continuación actual es https://github.com/BIRSAx2/mdcat ; el original swsnr está archivado. Se utilizan --local y -P, presentes en la versión local; versiones ajenas requieren comprobación.

## Probarlo en este ordenador

No hace falta ejecutar actualizar.sh: los cambios están en este repositorio local. En una sesión nueva del entorno ya se cargan. Para habilitar los atajos sin salir del Neovim del repositorio, ejecuta:

```vim
:lua dofile(require('config.paths').repository() .. '/nvim/lua/config/keymaps.lua')
```

Después abre README.md, guarda si procede y pulsa Espacio m r. Esta orden recarga los atajos; F1 se actualiza al reiniciar Neovim. No modifica la configuración activa en ~/.config/nvim. Otros equipos necesitarán publicación y actualización, aún no realizadas.

## Verificación

Pruebas específicas: tests/comprobar_markdown_view.lua y tests/comprobar_markdown_view.py, incorporadas a scripts/comprobar.sh. Servidor tmux temporal para apertura, recarga, reutilización, retorno, separación de sesiones y ruta con espacios/acentos y caracteres de shell. Sin prueba física WSL2 ni certificación visual de imágenes. La configuración previa se recupera por Git; para retirar esta función, revertir únicamente sus archivos/atajos propios, conservando cambios ajenos.

Resultado local 06/11/2026: pruebas específicas Lua y Python/tmux correctas, incluido mdcat real con texto; núcleo de Neovim y checkhealth terminaron con código 0, informe sin ERROR y con avisos. ShellCheck no está instalado. Sintaxis bash/sh y git diff --check correctos. No se ejecutó la suite completa. Pruebas con sockets en servidor temporal fuera del sandbox por su restricción de sockets, sin afectar sesiones reales.

<img src="../IMG/logo.png" alt="entorno-nvim · IFL" width="560">

# Guía completa de teclas y uso del entorno

Referencia del repositorio revisada el 13 de septiembre de 2026.
Incluye los atajos propios, los del explorador instalado y las operaciones
nativas necesarias para trabajar. No es una enumeración de todos los comandos
posibles de Vim, Git, Bash o de cada cliente de IA.

## Índice

1. [Arrancar y pedir ayuda](#arrancar-y-pedir-ayuda)
2. [Cómo leer las teclas](#cómo-leer-las-teclas)
3. [Pantalla principal](#pantalla-principal)
4. [Editor](#editor)
5. [Explorador lateral](#explorador-lateral)
6. [Buscar archivos y texto](#buscar-archivos-y-texto)
7. [Ventanas, buffers y pestañas de Neovim](#ventanas-buffers-y-pestañas-de-neovim)
8. [Autocompletado y lenguajes](#autocompletado-y-lenguajes)
9. [Markdown y PDF](#markdown-y-pdf)
10. [Tmux](#tmux)
11. [Consola](#consola)
12. [Inteligencia artificial](#inteligencia-artificial)
13. [Git y LazyGit](#git-y-lazygit)
14. [Perfiles y dependencias](#perfiles-y-dependencias)
15. [Problemas frecuentes](#problemas-frecuentes)
16. [Fuentes y alcance](#fuentes-y-alcance)

## Arrancar y pedir ayuda

Desde la carpeta del trabajo:

```bash
entorno-dev
```

`entorno-dev` es el comando recomendado desde cualquier carpeta. Ambos
instaladores preparan el lanzador en `~/.local/bin`. Si aparece «command not
found», consulte [preparar el comando](../README.md#usar-entorno-dev-desde-cualquier-carpeta).
No necesita escribir la ruta del repositorio cada vez.

```bash
# Otra carpeta; las opciones van antes de la ruta
entorno-dev /ruta/proyecto
# Solo editor
entorno-dev --sin-tmux
# Sin integración ni panel IA
entorno-dev --sin-ia
# Selector de proyectos
entorno-dev --elegir
# Ayuda del lanzador
entorno-dev --help
```

Sin opciones y sin variables de perfil heredadas: perfil profesor y tres
paneles tmux, editor, agente y terminal. Reconectar conserva la sesión existente;
no reconstruye sus ventanas ni reinicia los editores.

| Dónde | Ayuda |
| --- | --- |
| Cualquier panel del tmux del entorno | `Ctrl+a` → `?` |
| Dentro de NvimTree | `g?` |
| Dentro de LazyGit | `?` |
| Neovim | `:help` y `:help tema` |
| Estado del perfil y componentes ausentes | `:EntornoInfo` |
| Volver a la pantalla inicial | `:IFL` |
| Ver mensajes de error | `:messages` |
| Ver qué hace un atajo | `:verbose nmap <Space>e` |

La ayuda de tmux se organiza por categorías: `Enter` abre, `Esc` vuelve,
`q` cierra. Es una chuleta, no ejecuta las acciones descritas. Puede mostrar
funciones no habilitadas en un perfil reducido.
Para cerrar una ventana de ayuda de Neovim, use `:helpclose`; `:q` actúa sobre
la ventana actual y puede cerrar el editor si ya no está en la ayuda.

## Cómo leer las teclas

- `Ctrl+a`: mantener Ctrl mientras se pulsa a.
- `Ctrl+a` → `t`: pulsar Ctrl+a, soltar y después t.
- `Espacio e`: pulsar Espacio y después e, sin mantenerlos juntos.
- `Espacio e`: Espacio y después e. El líder de Neovim es Espacio.
- Las mayúsculas importan: `p` y `P` son acciones distintas.
- Los comandos que empiezan por `:` se escriben dentro de Neovim y se
  confirman con `Enter`, salvo que se indique el indicador de comandos de tmux.
- Los atajos del editor se usan en modo normal: pulsar primero `Esc`.
- `Espacio e` puede esperar brevemente porque también existen `ee` y `ef`.
- El terminal o el escritorio pueden interceptar combinaciones. Especialmente
  `Ctrl+Espacio`, teclas Command de Mac y Alt+Shift no están garantizadas en
  todos los emuladores, conexiones SSH o WSL.

### Tres niveles distintos

| Elemento | Qué contiene | Crear | Cambiar |
| --- | --- | --- | --- |
| Ventana tmux | Una página de terminal con paneles | `Ctrl+a` → `c` | `Ctrl+a` → número |
| Panel tmux | Un proceso: editor, agente o shell | `Ctrl+a` → `-` o `\|` | `Ctrl+a` → `h/j/k/l` |
| Ventana Neovim | Una vista de un buffer | `:split` / `:vsplit` | `Ctrl+h/j/k/l` |
| Pestaña Neovim | Un conjunto de ventanas del editor | `:tabnew` | `gt` / `gT` |
| Buffer Neovim | Un archivo cargado, visible o no | `:edit archivo` | `Espacio f b` |

## Pantalla principal

Estas teclas sueltas solo tienen este significado en el inicio IFL:

| Tecla | Acción |
| --- | --- |
| `f` | Buscar archivos |
| `g` | Buscar texto del proyecto |
| `e` | Abrir explorador lateral |
| `b` | Elegir buffer |
| `r` | Archivos recientes |
| `l` | LazyGit |
| `n` | Nuevo buffer vacío; guardar después con `:w nombre` |
| `c` | Abrir el init.lua del proyecto |
| `q` | Cerrar la ventana actual |

## Editor

### Atajos propios

| Tecla | Modo | Acción |
| --- | --- | --- |
| `Espacio w` | Normal | Guardar archivo |
| `Esc` | Normal | Limpiar resaltado de búsqueda |
| `Espacio t d` | Normal | Duplicar línea debajo (`yyp`); `Espacio t` agrupa más operaciones de texto |
| `Espacio r` | Normal | Ejecutar el archivo actual en la terminal de abajo |
| `Espacio s` | Normal | Lista de plantillas con buscador |
| `Espacio b` | Normal | Archivos abiertos: lista, siguiente, anterior, cerrar |
| `Espacio e` | Normal | Mostrar/ocultar explorador |
| `Espacio E` | Normal | Localizar archivo actual en el árbol |
| `Espacio f f` | Normal | Buscar archivos |
| `Espacio f g` | Normal | Buscar texto del proyecto |
| `Espacio f b` | Normal | Elegir buffer |
| `Espacio g g` | Normal | Abrir LazyGit |
| `Espacio u l` | Normal | Alternar caracteres invisibles |
| `Espacio u t` | Normal | Elegir Catppuccin, Tokyo Night o Kanagawa |
| `Espacio` y esperar | Normal/visual | Ver las teclas disponibles y sus descripciones |
| `gl` | Normal | Diagnósticos de la línea actual |
| `Espacio l d` | Normal | Diagnósticos de todo el archivo |
| `]d` / `[d` | Normal | Diagnóstico siguiente/anterior |
| `Espacio l f` | Normal con LSP | Solicitar formato al servidor |
| `Espacio l j` | Normal con LSP JS/TS | Generar documentación de la función |
| `Espacio m p` / `Espacio m v` | Normal, profesor | PDF / PDF y visor |
| `Espacio a c` | Normal o visual, IA activa | Preparar contexto y petición para el agente |
| `jk` | Inserción | Volver a normal; escribir las dos letras seguidas |
| `Ctrl+h/j/k/l` | Normal | Ventana del editor izquierda/abajo/arriba/derecha |
| `Alt+Shift+j/k` | Normal o visual | Mover línea/selección abajo/arriba, Linux |
| `Command+Shift+↓/↑` | Normal o visual | Mover línea/selección, Mac si el terminal lo transmite |
| `<` / `>` | Visual | Reducir/aumentar sangría y conservar selección |
| `n` / `N` | Normal | Resultado siguiente/anterior y centrar pantalla |
| `Esc Esc` | Terminal integrada | Salir del modo terminal, sin terminar el proceso |

### Modos, movimiento y edición nativos

| Teclas | Acción |
| --- | --- |
| `Esc` | Modo normal |
| `i` / `a` | Insertar antes/después del cursor |
| `I` / `A` | Insertar al inicio útil/final de línea |
| `o` / `O` | Nueva línea debajo/encima y escribir |
| `v` / `V` / `Ctrl+v` | Selección por caracteres/líneas/bloque |
| `h j k l` | Izquierda, abajo, arriba, derecha |
| `w` / `b` / `e` | Palabra siguiente/anterior/final de palabra |
| `0` / `^` / `$` | Inicio de línea/primer carácter no blanco/final |
| `gg` / `G` | Inicio/final del archivo |
| `42G` / `:42` | Ir a la línea 42 |
| `Ctrl+d` / `Ctrl+u` | Media pantalla abajo/arriba |
| `%` | Pareja de paréntesis, llave o corchete |
| `f` seguido de carácter | Buscar carácter en la línea |
| `;` / `,` | Repetir búsqueda de carácter / inversa |
| `zz` | Centrar línea actual |
| `x` / `dd` | Borrar carácter/línea |
| `dw` / `diw` / `ciw` | Borrar hasta palabra siguiente/borrar palabra/cambiar palabra |
| `yy` / `y` en visual | Copiar línea/selección al registro Vim |
| `p` / `P` | Pegar después/antes |
| `u` / `Ctrl+r` | Deshacer/rehacer |
| `.` | Repetir última modificación |
| `r` y un carácter | Reemplazar un carácter |
| `J` | Unir línea siguiente |
| `>>` / `<<` | Aumentar/reducir sangría |
| `gcc` / `gc` en visual | Comentar línea/selección, función nativa si commentstring es adecuado |
| `Ctrl+o` / `Ctrl+i` | Saltos anteriores/posteriores |

Se pueden anteponer números: `5j`, `3dd`, `2yy`. Los registros internos no
son necesariamente el portapapeles del escritorio. `"+y` en visual copia al
portapapeles y `"+p` pega si hay proveedor de portapapeles disponible.

Para cambiar apariciones iguales sin un plugin de multicursor, coloque el
cursor sobre la palabra y use `*` para buscar las siguientes; `cgn` cambia la
siguiente coincidencia y `.` repite el cambio en la siguiente. Para sustituir
todas las apariciones de una vez, use `:%s/palabra/otra/gc` y confirme
cada una. `Ctrl+d` en este editor conserva su función de bajar media pantalla;
la selección de ocurrencias con `Ctrl+d` de VS Code no está configurada.

### Ayuda por teclas y snippets

Pulsa `Espacio` y espera medio segundo para ver las acciones disponibles; las
teclas `g`, `[` y `]` también muestran sus comandos. En insertar, `Ctrl+x`
muestra las opciones de completado.

Los snippets propios están en `nvim/snippets/`, con un archivo JSON por tipo de
archivo. En TypeScript, escribe `cabts` y pulsa `Ctrl+j` para insertar una
cabecera, `docfn` justo encima de una función para generar su JSDoc con los
nombres de parámetros reales; en HTML, `!` y `Ctrl+j` insertan un
documento HTML5. Durante la edición, `Ctrl+l` y `Ctrl+h` avanzan y retroceden
por los campos; `Esc` o `Ctrl+c` terminan la plantilla y eliminan sus marcas.
Los campos vacíos no muestran puntos ni cuadrados. Los archivos usan la forma
`prefix`/`body`/`description` de los snippets de VS Code, aunque las
transformaciones y el campo `scope` de VS Code no se aplican automáticamente.

En HTML y CSS, **Ctrl+j también expande Emmet**. Las plantillas propias con
prefijo exacto tienen prioridad (`!`, `main`, `centrar`...); una línea vacía
sigue mostrando las plantillas. En JavaScript/TypeScript, `clg` y `Ctrl+j`
siguen insertando `console.log`. No escriba `<` antes de una abreviatura:

| Escribir en inserción y pulsar Ctrl+j | Resultado |
| --- | --- |
| `p*5` | Cinco párrafos vacíos |
| `p#average` | `<p id="average"></p>` |
| `p#nota$*5` | Cinco párrafos con ids `nota1`…`nota5` |
| `ul#student-list` | Lista vacía con ese id |
| `ul>li*3` | Lista con tres elementos |

Para el ejemplo de notas de DAW, escriba esta línea y pulse Ctrl+j:

```text
main>h1{Notas de 2.º DAW}+p#average+p#passed+p#best+ul#student-list
```

En otra línea, `script[type=module src=/src/main.ts]` y Ctrl+j generan el
script externo. `ci"` en modo normal cambia el contenido entre comillas.
Tab conserva el completado y sus saltos habituales; no activa Emmet.
Emmet no crea una sesión de campos de mini.snippets: para editar sus atributos
puede salir con Esc y usar `ci"`. Referencia: [sintaxis Emmet](https://docs.emmet.io/abbreviations/syntax/).

En JavaScript y TypeScript también puede escribir `/**` justo encima de una
función y pulsar `Enter`, o usar `Espacio l j` desde la línea de la función.
El servidor TypeScript genera los nombres de parámetros y el retorno cuando
corresponde; el alumno rellena las descripciones. Requiere el servidor activo.

### Guardar, buscar y sustituir

| Comando/tecla | Acción |
| --- | --- |
| `:w` / `:w nombre.md` | Guardar / asignar nombre al buffer |
| `:wa` | Guardar todos los buffers modificados con nombre |
| `:q` / `:wq` | Cerrar ventana / guardar y cerrar |
| `:qa` / `:wqa` | Cerrar Neovim / guardar y cerrar Neovim |
| `:q!` / `:qa!` | Forzar cierre; puede perder cambios |
| `/texto` / `?texto` | Buscar adelante/atrás |
| `*` / `#` | Buscar palabra del cursor adelante/atrás |
| `:%s/viejo/nuevo/gc` | Sustituir en todo el archivo con confirmación |
| `:s/viejo/nuevo/g` | Sustituir en línea actual |

No confundir `:qa` con cerrar tmux: solo cierra ese Neovim.

## Explorador lateral

El explorador del proyecto es **NvimTree**. `Espacio e` lo muestra/oculta
manteniendo el editor al lado. `g?` dentro del árbol muestra su ayuda real.
Las acciones de esta tabla se ejecutan con el cursor dentro del árbol.

| Tecla | Acción |
| --- | --- |
| `j/k`, flechas | Mover cursor |
| `Enter` / `o` / doble clic izquierdo | Abrir archivo o desplegar carpeta |
| `q` / `Espacio e` | Cerrar panel lateral |
| `Ctrl+t` | Abrir archivo en pestaña Neovim |
| `Ctrl+v` / `Ctrl+x` | Abrir en división vertical/horizontal |
| `Tab` | Previsualizar archivo |
| `Ctrl+e` | Abrir reemplazando el buffer del árbol |
| `O` | Abrir sin selector de ventana |
| `Backspace` | Cerrar carpeta padre |
| `P` | Ir al nodo padre |
| `-` | Subir la raíz del árbol a la carpeta superior |
| `Ctrl+]` / doble clic derecho | Cambiar raíz al nodo |
| `a` | Crear archivo o directorio; terminar nombre en `/` para directorio |
| `r` / `e` | Renombrar / renombrar nombre base |
| `u` / `Ctrl+r` | Renombrar ruta completa / modificar ruta conservando nombre |
| `c` / `x` / `p` | Copiar / cortar / pegar nodos |
| `gp` | Mover nodo |
| `d` / `Supr` | Borrar: leer confirmación; no equivale a papelera |
| `D` | Enviar a papelera si hay herramienta compatible |
| `y` / `Y` / `gy` / `ge` | Copiar nombre/ruta relativa/ruta absoluta/nombre base |
| `R` | Refrescar |
| `E` / `W` | Expandir todo / contraer todo |
| `f` / `F` | Filtro interactivo / limpiar filtro |
| `S` | Buscar nodo |
| `H` / `I` / `U` | Filtros ocultos/ignorados Git/personalizados |
| `B` / `C` / `M` | Filtros sin buffer/limpios Git/sin marca |
| `m` | Alternar marca |
| `bd` / `bt` / `bmv` | Borrar/enviar a papelera/mover nodos marcados |
| `>` / `<` | Hermano siguiente/anterior |
| `J` / `K` | Último/primer hermano |
| `L` | Alternar agrupación de carpetas vacías |
| `[c` / `]c` | Nodo Git anterior/siguiente |
| `[e` / `]e` | Diagnóstico anterior/siguiente |
| `.` / `s` | Ejecutar comando sobre nodo / abrir con sistema |
| `g?` | Mostrar/ocultar ayuda |

En este proyecto, `Ctrl+h/j/k/l` se sobrescriben para navegar entre ventanas;
**Ctrl+k no abre el popup informativo predeterminado de NvimTree**.
Git, diagnósticos y filtros del árbol están deshabilitados en la configuración
inicial del plugin: sus teclas pueden no producir resultados útiles mientras
esas funciones sigan apagadas. La papelera y la apertura con el sistema también
dependen de herramientas externas. `e` suelta en el árbol renombra; no significa
lo mismo que `e` en la pantalla inicial.

## Buscar archivos y texto

`Espacio f f`, `Espacio f g`, `Espacio f b` abren fzf-lua.

| Dentro del buscador | Acción |
| --- | --- |
| Escribir | Filtrar resultados |
| `Ctrl+j` / `Ctrl+k`, flechas | Bajar/subir |
| `Enter` | Abrir selección; la acción de archivos admite quickfix para múltiples resultados |
| `Esc` | Cancelar |

La búsqueda de archivos incluye ocultos, pero excluye `.git`, `node_modules`,
`.next`, `dist`, `build`, `coverage` y `.cache`. Requiere `rg`; el selector
requiere `fzf`. Las imágenes en la previsualización requieren `chafa`.
Para resultados quickfix: `:copen`, `:cnext`, `:cprev`, `:cclose`.

## Ventanas, buffers y pestañas de Neovim

| Acción | Tecla/comando |
| --- | --- |
| Dividir arriba/abajo | `:split` o `Ctrl+w` → `s` |
| Dividir izquierda/derecha | `:vsplit` o `Ctrl+w` → `v` |
| Abrir archivo en división | `:split archivo` / `:vsplit archivo` |
| Cambiar de ventana | `Ctrl+h/j/k/l` o `Ctrl+w` → `h/j/k/l` |
| Recorrer ventanas | `Ctrl+w` → `w` |
| Igualar tamaños | `Ctrl+w` → `=` |
| Aumentar/reducir altura | `Ctrl+w` → `+` / `-` |
| Aumentar/reducir anchura | `Ctrl+w` → `>` / `<` |
| Cerrar ventana | `Ctrl+w` → `c` o `:close` |
| Conservar solo ventana actual | `Ctrl+w` → `o` o `:only` |
| Crear pestaña | `:tabnew` o `:tabedit archivo` |
| Pestaña siguiente/anterior | `gt` / `gT` |
| Pestaña número 2 | `2gt` |
| Cerrar pestaña | `:tabclose` |
| Mover pestaña al final | `:tabmove` |
| Mostrar buffers | Barra superior, `:ls` o `Espacio f b` |
| Buffer siguiente/anterior | `]b` / `[b` o `:bnext` / `:bprevious` |
| Elegir buffer por número | `:buffer 3` |
| Buffer alternativo | `Ctrl+^` (según teclado) |
| Cerrar buffer | `:bdelete`; no forzar si hay cambios |

La barra superior muestra los buffers de archivo, resalta el actual y marca
con `[+]` los cambios sin guardar. Permite abrir un archivo con clic izquierdo;
los buffers sin nombre no aparecen. Usa funciones nativas y no instala plugins.
Una pestaña Neovim puede mostrar varias ventanas y varios archivos; la barra
superior muestra archivos, no las pestañas de Neovim.

## Autocompletado y lenguajes

En inserción, el completado LSP se activa automáticamente al conectar un
servidor que lo soporte. No es IA generativa.

| Tecla | Acción |
| --- | --- |
| `Ctrl+Espacio` | Solicitar completado LSP |
| `Tab` / `Shift+Tab` con menú visible | Sugerencia siguiente/anterior |
| `Enter` con menú visible | Confirmar mediante Ctrl+y |
| `Ctrl+n` / `Ctrl+p` | Navegar completado; sin menú, completado nativo de palabras |
| `Ctrl+y` / `Ctrl+e` | Aceptar/cancelar menú nativo |
| `Tab` / `Shift+Tab` sin menú, con snippet activo | Campo siguiente/anterior |
| `Tab` sin menú ni snippet | Tab normal |
| `Enter` sin menú | Nueva línea |
| `gd` / `gD` | Definición/declaración, atajos propios con LSP y diagnósticos habilitados |
| `Espacio l f` | Formato, solo si el servidor lo soporta |
| `Espacio l d`, `]d`, `[d` | Ver/navegar diagnósticos |

También se pueden solicitar funciones nativas sin depender de un atajo:

```vim
:lua vim.lsp.buf.hover()
:lua vim.lsp.buf.rename()
:lua vim.lsp.buf.references()
:lua vim.lsp.buf.code_action()
:lua vim.lsp.buf.signature_help()
```

Consultar `:help lsp-defaults` para los mapas nativos de la versión instalada
(por ejemplo familia `gr`). Estos no los define el repositorio y pueden variar.

Ayuda prevista por servidores: HTML, CSS, JSON, JavaScript, TypeScript, JSX,
TSX, Tailwind; Python y Lua según perfil. React se trabaja mediante JSX/TSX,
no mediante un supuesto servidor React separado. Sin servidor instalado no
hay completado semántico aunque el editor arranque.

`mini.pairs` empareja delimitadores al escribir. `nvim-ts-autotag` cierra y
renombra etiquetas en HTML/JSX/TSX si hay parser adecuado. No hay colección
de snippets ni asistente IA de completado en línea configurados. No se
garantiza formato con Prettier: no se ha añadido una integración propia.

## Markdown y PDF

Disponible por defecto en perfil profesor. Abrir un archivo `.md` con nombre.

| Acción | Tecla/comando |
| --- | --- |
| Generar PDF junto al Markdown | `Espacio m p` |
| Generar y abrir visor | `Espacio m v` |
| Generar con comando | `:MarkdownPdf` |
| Elegir salida | `:MarkdownPdf /ruta/salida.pdf` |
| Desde consola | `/ruta/entorno-nvim/scripts/markdown-pdf.sh entrada.md [salida.pdf]` |

La exportación guarda primero el buffer si está modificado. El PDF toma el
nombre del Markdown con extensión `.pdf` salvo salida explícita; una nueva
exportación puede reemplazar esa salida. Requiere Pandoc y un navegador
Chromium compatible con la conversión. El visor requiere una aplicación
disponible; en servidor sin escritorio generar y visualizar son problemas
distintos. No se ha comprobado aquí toda la cadena PDF en WSL.

No hay una tecla propia para previsualización Markdown en vivo: el flujo
configurado genera PDF y opcionalmente lo abre. Véase [Markdown y PDF](markdown-pdf.md)
para imágenes, estilos y opciones del exportador.

## Tmux

En todas las filas siguientes, pulsar **Ctrl+a, soltar y después la tecla**.
El servidor del proyecto se llama `entorno-nvim` salvo override explícito.

### Paneles, ventanas y sesiones

| Después de Ctrl+a | Acción |
| --- | --- |
| `?` | Ayuda del entorno |
| `n` | Ir al panel editor; NO ventana siguiente |
| `a` / `t` | Ir al panel agente/terminal |
| `h/j/k/l` | Panel izquierda/abajo/arriba/derecha |
| `H/J/K/L` | Redimensionar panel en esa dirección, 3 celdas |
| `\|` | Dividir a derecha, en directorio del panel |
| `-` | Dividir debajo, en directorio del panel |
| `z` | Maximizar/restaurar panel |
| `o` | Recorrer paneles, binding nativo |
| `q` | Mostrar números de panel; elegir mientras aparecen |
| `c` | Crear ventana tmux, equivalente práctico a pestaña de terminal |
| `1`…`9` | Elegir ventana por número |
| `p` | Ventana anterior |
| `w` | Selector de ventanas |
| `,` | Renombrar ventana |
| `s` | Selector de sesiones |
| `$` | Renombrar sesión |
| `P` | Selector de proyectos del entorno |
| `g` | Abrir/reutilizar ventana LazyGit |
| `i` | Selector emergente de agente |
| `d` | Desconectar conservando procesos |
| `Q` | Cerrar definitivamente la sesión actual, con confirmación |
| `:` | Indicador de comandos tmux |
| `Ctrl+a` | Enviar Ctrl+a literal a la aplicación |

Para siguiente ventana, usar `Ctrl+a` → `:` y escribir `next-window`;
`n` está reservado para el editor y `l` para el panel derecho.
Los números empiezan en 1. El ratón permite seleccionar y redimensionar.
Los bindings nativos citados dependen de tmux; comprobarlos con
`tmux -L entorno-nvim list-keys -T prefix` si hay diferencias.

### Historial y copia

| Secuencia | Acción |
| --- | --- |
| `Ctrl+a` → `[` | Entrar en modo copia |
| `h/j/k/l`, `Ctrl+u/d` en modo copia | Moverse/recorrer historial |
| `v` en modo copia | Empezar selección |
| `y` en modo copia | Copiar y salir |
| `q` / `Esc` en modo copia | Salir |
| `Ctrl+a` → `]` | Pegar buffer tmux |

El buffer tmux no garantiza integración con el portapapeles de Windows o
Wayland. El entorno no instala un sincronizador de portapapeles tmux.

### Cerrar sin sorpresas

| Objetivo | Acción |
| --- | --- |
| Salir sin detener nada | `Ctrl+a` → `d` |
| Cerrar proyecto completo con confirmación | `Ctrl+a` → `Q` |
| Terminar shell del panel | `exit` o Ctrl+d con línea vacía |
| Cerrar panel a la fuerza | `Ctrl+a` → `x`, confirmar |
| Cerrar ventana con sus paneles | `Ctrl+a` → `&`, confirmar |
| Cerrar sesión actual completa | `Ctrl+a` → `:` y `kill-session` |
| Cerrar todas las sesiones de este servidor | En shell: `tmux -L entorno-nvim kill-server` |

**Los cierres forzosos terminan procesos y pueden perder cambios. Guardar
antes.** El último comando no debe sustituirse por un `kill-server` sin socket.
Si cambió `ENTORNO_TMUX_SOCKET`, debe usar ese nombre en lugar de `entorno-nvim`.
Las sesiones sobreviven a desconectar, no a reiniciar el equipo.

```bash
tmux -L entorno-nvim list-sessions
tmux -L entorno-nvim attach-session -t NOMBRE
```

## Consola

El panel inferior usa la shell del usuario: el proyecto no sustituye Bash,
Zsh o Fish ni impone todos sus atajos. La tabla de edición siguiente describe
el modo Emacs habitual de Bash/Readline; Zsh/Fish y el modo Vi pueden diferir.

| Tecla | Acción habitual |
| --- | --- |
| `Enter` | Ejecutar comando |
| `Tab` | Completar ruta/comando según shell |
| `↑` / `↓` | Historial anterior/siguiente |
| `Ctrl+r` | Buscar en historial |
| `Ctrl+c` | Interrumpir proceso en primer plano |
| `Ctrl+d` | EOF; en prompt vacío puede cerrar shell |
| `Ctrl+l` | Limpiar pantalla, no borrar necesariamente scrollback |
| `Ctrl+a` / `Ctrl+e` | Inicio/final de línea; dentro de tmux enviar Ctrl+a con Ctrl+a → Ctrl+a |
| `Ctrl+u` / `Ctrl+k` | Cortar hasta inicio/final |
| `Ctrl+w` / `Alt+d` | Borrar palabra anterior/siguiente |
| `Alt+b` / `Alt+f` | Mover por palabras |
| `Ctrl+y` | Recuperar texto cortado en Readline |
| `Ctrl+z` | Suspender proceso; no cerrarlo |

Tras suspender: `jobs` lista tareas y `fg` vuelve al primer plano. Para detener
un servidor de desarrollo normalmente se usa Ctrl+c, no cerrar todo tmux.

Consola dentro del editor: `:terminal`, `i` para interactuar, `Esc Esc` para
volver a normal y usar los movimientos del editor. `:split` seguido de
`:terminal` crea una consola en una división Neovim. Es distinta del panel tmux.

Comandos de trabajo, no atajos ni herramientas instaladas automáticamente:

```bash
pwd
ls -la
cd carpeta
mkdir tarea
git status
# Solo si el proyecto define estos scripts y tiene dependencias preparadas:
pnpm run dev
pnpm test
# Solo si Docker/kubectl estan instalados y configurados:
docker ps
docker compose logs -f
kubectl get pods
```

Los perfiles SI no instalan Docker ni Kubernetes ni aíslan sus efectos sobre
el sistema. Este entorno de configuración no es una máquina virtual ni una
barrera de seguridad para comandos.

## Inteligencia artificial

| Acción | Teclas |
| --- | --- |
| Ir al panel IA | `Ctrl+a` → `a` |
| Abrir selector emergente | `Ctrl+a` → `i` |
| Elegir en selector | Escribir para filtrar, flechas y Enter |
| Cancelar selector | Esc; menú textual: seguir indicación de vacío/Salir |
| Volver al editor | `Ctrl+a` → `n` |
| Petición sobre posición/archivo | Normal: `Espacio a c` |
| Petición con fragmento | Seleccionar con v/V/Ctrl+v y `Espacio a c` |
| Enviar la petición pegada | Revisar en el agente y pulsar Enter manualmente |

El catálogo ofrece Codex, OpenCode, Claude, Pi y Shell. `[OK]` significa que
se encuentra el ejecutable, **no** que haya autenticación, saldo, red o
configuración válida. El selector no instala ni autentica clientes.

Flujo recomendado:

1. Elegir un agente y esperar a que arranque.
2. Volver al editor; seleccionar solo el fragmento necesario si procede.
3. Pulsar Espacio a c y escribir la petición.
4. Revisar el contenido pegado en el agente.
5. Pulsar Enter para enviarlo; revisar después el diff y las pruebas.

En modo normal se envían metadatos y petición, no el archivo completo. En
visual se añade la selección. El transporte no pulsa Enter y rechaza shells
como destino; Shell no se convierte en agente por aparecer en el menú.
Salir normalmente del cliente devuelve al selector. Los comandos de salida,
reanudación y atajos internos de cada cliente no son uniformes: consultar su
ayuda propia. No usar una combinación inventada como universal para todos.

El contexto tiene límite predeterminado de 32768 bytes y bloqueos preventivos
para nombres sensibles. **No garantiza detectar todos los secretos. Antes de
enviar información del centro educativo a una IA externa, solicitar
confirmación explícita al señor.** El bloqueo de nombres no sustituye esa regla.

## Git y LazyGit

Abrir con `Espacio g g` en Neovim, `l` desde el inicio, `Ctrl+a` → `g` en tmux,
o `lazygit` desde una shell en el repositorio. El acceso tmux utiliza una ventana
dedicada reutilizable. La integración conserva la configuración personal de
LazyGit; por tanto puede haber remapeos locales.

### Uso diario (defaults de LazyGit 0.65.0 instalado)

| Tecla | Contexto / acción |
| --- | --- |
| `?` | Menú de ayuda contextual: referencia definitiva en cada panel |
| `q` / `Esc` | Salir / volver o cancelar |
| `h/l`, flechas izquierda/derecha | Panel anterior/siguiente |
| `Tab` / `Shift+Tab` | Panel siguiente/anterior |
| `1`…`5` / `0` | Panel numerado / vista principal |
| `j/k`, flechas | Elemento siguiente/anterior |
| `[` / `]` | Subpestaña anterior/siguiente |
| `/`, `n`, `N` | Buscar, siguiente, anterior |
| `Enter` | Entrar/confirmar |
| `Espacio` en archivos | Alternar preparado para commit (stage) |
| `a` en archivos | Alternar stage de todos |
| `c` / `C` en archivos | Commit / commit con editor |
| `A` en archivos | Amend: modifica último commit; revisar antes |
| `e` / `o` | Editar / abrir archivo según contexto |
| `d` / `D` en archivos | Menú de descarte / opciones de reset; potencialmente destructivo |
| `s` / `S` en archivos | Stash de cambios / opciones de stash |
| `f` en archivos | Fetch |
| `p` / `P` | Pull / push: afectan remoto o trabajo local |
| `R` | Refrescar |
| `n` en ramas | Nueva rama mediante acción contextual |
| `Espacio` en ramas | Seleccionar/cambiar rama según menú contextual |
| `r` / `M` en ramas | Rebase / merge; no son navegación |
| `z` / `Z` | Deshacer/rehacer operaciones Git compatibles; no garantiza recuperar cualquier borrado |
| `Ctrl+r` | Repositorios recientes |
| `:` | Ejecutar comando shell |
| `+` / `_` | Cambiar modo de pantalla |

Las teclas cambian de significado entre paneles. En commits, por ejemplo,
`s` hace squash y `t` revert; en archivos `s` gestiona stash. No probar letras
al azar sobre un repositorio importante. Leer siempre la ayuda y confirmación.

Flujo sencillo: revisar cambios → preparar archivos concretos con Espacio →
`c` y mensaje → revisar commit. Hacer push solo cuando se quiera publicar.
No saltarse hooks (`w` en archivos), forzar checkout, hacer reset/rebase ni
reescribir commits publicados como parte de una rutina de navegación.

Alternativa desde shell:

```bash
git status
git diff
git diff --staged
git log --oneline -10
git add archivo-concreto
git commit -m "Describe el cambio"
```

### Inventario completo de defaults de LazyGit

El anexo [teclas predeterminadas de LazyGit](lazygit-teclas-defaults.md) contiene
todos los bindings que declara la versión instalada, agrupados por contexto.
No es una lectura de credenciales ni de la configuración personal. Si esta
última los modifica, consultar `?` dentro de LazyGit.

## Perfiles y dependencias

| Perfil | LSP seleccionado si está preparado | Diagnósticos | PDF | IA sin override |
| --- | --- | --- | --- | --- |
| profesor, predeterminado | Web, Python, Lua | Sí | Sí | Sí |
| inicial | Web | Ocultos | No | No |
| dwec | Web, Tailwind, JSX/TSX | Sí | No | No |
| si | Python | Sí | No | No |

`--perfil dwec`, `--perfil inicial`, `--perfil si` son opciones explícitas.
`--ia` habilita IA y `--sin-ia` la deshabilita. Las variables ENTORNO_PERFIL y
ENTORNO_IA heredadas también influyen. `:EntornoInfo` muestra el resultado.

Los plugins fijados incluyen Lazy, NvimTree, devicons, fzf-lua, mini.pairs,
Tree-sitter, autotag, lspconfig y tres temas. No es LazyVim. No hay atajos
propios de un IDE gráfico que no figuren aquí por el simple hecho de usar Lua.
Los plugins están instalados en el repositorio, pero esto no acredita la
instalación ni el funcionamiento de todos los servidores LSP, parsers y PDF.

## Problemas frecuentes

| Problema | Qué comprobar |
| --- | --- |
| Espacio escribe un espacio | Pulsar Esc: probablemente modo inserción |
| Espacio e no actúa en el agente o shell | Ir al editor con Ctrl+a → n |
| No aparecen los cambios recientes de configuración | Guardar y `:restart` dentro de Neovim |
| Sale Netrw en vez de árbol lateral | Faltan plugins; consultar :EntornoInfo. No es equivalente a NvimTree |
| Quiero volver al inicio | `:IFL` |
| Quiero salir sin perder procesos | Ctrl+a → d |
| No hay sugerencias | Perfil, servidor LSP y archivo adecuados; :EntornoInfo y :checkhealth |
| No aparece PDF | Usar perfil profesor y revisar Pandoc/navegador; :messages |
| IA no recibe selección | Cliente activo, no Shell; perfil IA habilitado y revisar mensaje |
| Se reconecta al mismo estado viejo | tmux conserva procesos; reconectar no reinicia Neovim |
| Ctrl+a no lleva al inicio de la línea de shell | Ctrl+a → Ctrl+a envía el carácter literal |
| Una tecla difiere de la tabla | Ayuda contextual y `:verbose nmap` antes de cambiar configuración |

## Fuentes y alcance

Contraste local con `nvim/lua/config/keymaps.lua`, `completion.lua`, `lsp.lua`,
`dashboard.lua`, `navigation.lua`, `profile.lua`, `markdown_pdf.lua`,
`theme.lua`, `nvim/lua/plugins/`, `tmux/tmux.conf`, los scripts de lanzamiento,
selector y transporte de IA, y los defaults del NvimTree fijado en lockfile.
LazyGit: salida de `lazygit --config`, versión 0.65.0; no configuración personal.

Esta tarea documenta el funcionamiento y no cambia atajos ni configuraciones
de Omarchy. La prueba específica del explorador real verifica abrir/cerrar el
panel, pero no se han ejecutado todas las acciones destructivas, comandos Git,
operaciones PDF, clientes IA ni todas las combinaciones de cada plataforma.

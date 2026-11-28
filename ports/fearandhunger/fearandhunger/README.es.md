[English](https://github.com/lowlevel-1989/quixjs/blob/master/games/fearandhunger/README.md) | Español

[![Buy Me A Coffee](https://raw.githubusercontent.com/lowlevel-1989/quixjs/master/docs/coffee.svg)](https://ko-fi.com/lowlevel1989)

Si quieres que [quixjs](https://github.com/lowlevel-1989/quixjs) siga recibiendo actualizaciones y
soporte, puedes apoyar el proyecto invitandome a un cafe.

## Notas

Gracias a Miro Haverinen por crear Fear & Hunger. Este port solo ejecuta el
juego, con quixjs: https://github.com/lowlevel-1989/quixjs.

Necesita Fear & Hunger **1.4.1** para Windows (itch.io o Steam).

## Controles

| Botón | Acción |
|--|--|
| Cruceta / palanca izquierda | Moverse |
| A | OK (aceptar, hablar) |
| B | Cancel (cancelar) |
| X | Skill (habilidad) |
| Y | Menu (menú) |
| L1 / R1 | Personaje o página anterior / siguiente, en los menús |
| (lo eliges en Controls) | Torch (antorcha) |
| (lo eliges en Controls) | Phase |
| Select + L1 | Lupa: un cuadro que amplía; la cruceta o las palancas lo mueven, R1 / L1 zoom, Y / X tamaño, A centra, Start la fija (el mando vuelve al juego) y la desfija, B la cierra |
| Select + R1 | Captura de pantalla (en `screenshots/`) |
| Select + R2 | Volver al menú del port |
| Select + Start | Salir |

Mods (activos): [rumble](mods/rumble/README.es.md) (vibración), [party-bars](mods/party-bars/README.es.md) (Hunger, Body y Mind en el mapa; L1 / R1 cambian de personaje).

## Compilar

```
git clone https://github.com/lowlevel-1989/quixjs.git
cd quixjs
make portmaster PORT=fearandhunger
```

Construye `build/fearandhunger.zip`.

## Instalar

Para usar este port necesitas el juego: Fear & Hunger 1.4.1 para Windows,
que puedes comprar en itch.io (https://mirohaver.itch.io/fear-hunger) o en
Steam (https://store.steampowered.com/app/1002300/).

1. **Consigue los archivos del juego.** Descarga la versión de Windows 1.4.1
   de itch.io y descomprímela en tu PC, o, en Steam, instala el juego y abre
   su carpeta (en la biblioteca, clic derecho en el juego, Administrar, Ver
   archivos locales). El port solo necesita la carpeta `www/`.

2. **Instala el port.** Copia `fearandhunger.zip`, sin descomprimirlo, en la
   carpeta `autoinstall` de PortMaster de la SD de tu handheld:

   | Sistema | Carpeta `autoinstall` |
   |--|--|
   | ROCKNIX, AmberELEC, JELOS, uOS | `/roms/ports/PortMaster/autoinstall/` |
   | ArkOS | `/roms/tools/PortMaster/autoinstall/` |
   | muOS | `/mmc/MUOS/PortMaster/autoinstall/` |
   | Knulli | `/userdata/system/.local/share/PortMaster/autoinstall/` |

   Después abre PortMaster en la handheld: al arrancar instala el zip solo
   (con la imagen que enseña EmulationStation) y lo quita de `autoinstall`.
   Luego puedes cerrar PortMaster.

3. **Copia el juego.** Comprime la carpeta `www/` del paso 1 en un zip llamado `www.zip` (en
   Windows: botón derecho sobre `www`, Enviar a, Carpeta comprimida) y cópialo en `ports/fearandhunger/`, junto a `port.toml`, en la
   carpeta de ports de tu consola (donde está `Fear and Hunger.sh`). Debe quedar así:

   ```
   ports/
     Fear and Hunger.sh
     fearandhunger/
       port.toml
       www.zip
   ```

   En ROCKNIX la carpeta de ports es `/roms/ports/` (`/storage/roms/ports/`
   por SSH).

   Mejor un zip sin compresión (con 7-Zip: Nivel de compresión, Almacenar; en
   Linux o macOS: `zip -0 -r`). Uno comprimido también vale: la primera vez
   que arranca el juego se prepara (un momento, solo una vez).

   Si tu archivo tiene otro nombre, escríbelo en `ports/fearandhunger/port.toml`, en
   `rom = "www.zip"`.

4. **Juega.** Reinicia EmulationStation (o actualiza su lista de juegos) y
   abre Fear & Hunger desde Ports.

Para actualizar el port, repite el paso 2 con el zip nuevo. El juego, tus
partidas y tus logros (`gamedata/www/save/`) se quedan.

Sin PortMaster: descomprime el zip en la carpeta de ports. Así puede que
EmulationStation no enseñe la imagen del port.

## port.toml

**port.toml** le dice a quixjs dónde está el juego y dónde van las partidas. Las rutas son relativas a la carpeta que tiene port.toml.

```toml
rom      = "www.zip"
game_dir = "www"
```

- `rom`: la carpeta `www/` del juego (la que tiene `data/`, `js/` ...) comprimida en un zip y puesta junto a port.toml.
- `game_dir`: la carpeta dentro del zip donde empieza el juego. Al comprimir una carpeta en Windows, la propia carpeta queda dentro del zip, así que esto le dice a quixjs dónde mirar.
- Las partidas van a `gamedata/`, junto a port.toml, así `www.zip` nunca se modifica.

```
port.toml
www.zip
  www/
    data/
    js/
    ...
gamedata/
```

## Android

Necesitas el juego y dos archivos de las releases de quixjs
(https://github.com/lowlevel-1989/quixjs/releases), la última versión
(`VERSION` en los nombres es su número):

- `quixjs-VERSION-android-arm64.apk`: la app
- `fearandhunger-VERSION-portmaster.zip`: el port

1. Instala el `.apk` en el teléfono.
2. En tu PC, descomprime `fearandhunger-VERSION-portmaster.zip`. Sale la carpeta
   `fearandhunger/`.
3. Copia el juego (`www.zip`, paso 3 de Instalar) en `fearandhunger/`, junto a `port.toml`. Queda así:

   ```
   fearandhunger/
     port.toml
     www.zip
   ```

4. Comprime la carpeta `fearandhunger/` en un `.zip` y pásalo al teléfono.
5. En quixjs, toca "Import game" y elige ese `.zip`. Después toca el juego
   y Play.

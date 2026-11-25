[English](README.md) | Español

# rumble

La consola vibra en los momentos fuertes de la partida, con efectos que
tienen forma, no un zumbido plano:

| Cuándo                                         | Efecto                                             |
|------------------------------------------------|----------------------------------------------------|
| empieza una batalla (te atrapa un enemigo)     | `heartbeat`: dos latidos y un temblor que se apaga |
| alguien del grupo recibe daño                  | `impact`: un golpe seco y su rebote                |
| cae alguien del grupo                          | `fade`: largo y cada vez más flojo                 |
| daño en el mapa (veneno, sangrado)             | `sting`: un pinchazo doble y flojo                 |

Vibra el mando si tiene motor (la RG CubeXX, por ejemplo). En Android, si
el mando no vibra, vibra el teléfono. Las consolas sin motor no hacen nada.

Viene activado. Para apagarlo: Options > Vibration: Off, o `rumble: Off` en
la opción Mods del menú del port. Funciona con cualquier otro mod.

Los efectos son presets de quixjs
([runtime/engines/lib/rumble.js](../../../../runtime/engines/lib/rumble.js)):
`heartbeat`, `impact`, `heavy-impact`, `fade`, `quake`, `alarm`, `sting`,
`tick`. Para cambiar cómo se siente un momento, se cambia su nombre en
`rumble.js` de este mod.

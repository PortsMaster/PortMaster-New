// rumble: vibra cuando pasa algo fuerte en la partida, y despues hace lo de
// siempre. Un solo archivo para las funciones de hooks.toml: recibe la
// original y su ruta, y la ruta dice que efecto suena.
//
// Los efectos son los presets de runtime/engines/lib/rumble.js (heartbeat,
// impact, heavy-impact, fade, quake, alarm, sting, tick): para cambiar como
// se siente un momento, se cambia su nombre aqui.
//
// Las funciones son las de RPG Maker MV, con lo que les hayan cambiado los
// plugins del juego: el hook solo agrega la vibracion y llama a la que habia.
function (original, path) {
  var EFFECT = {
    'BattleManager.setup': 'heartbeat',               // te atrapan: empieza una batalla
    'Game_Actor.prototype.performDamage': 'impact',   // te hacen dano
    'Game_Actor.prototype.performCollapse': 'fade',   // cae alguien del grupo
    'Game_Actor.prototype.performMapDamage': 'sting'  // dano en el mapa (veneno, sangrado)
  };
  var rumble = quix.engine.lib('rumble'),
    effect = EFFECT[path];
  if (!rumble || !effect) return original;
  return function () {
    rumble.play(effect);
    return original.apply(this, arguments);
  };
}

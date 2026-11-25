// party-bars: en el mapa, arriba a la izquierda, un personaje del grupo con
// sus tres barras, las del menu (GALV_BustMenu) y en su orden:
//   Hunger  el hambre: la barra de experiencia del menu (xpRate), ocre;
//           vacia sin hambre, se llena cuanta mas hambre (comer la baja)
//   Body    la vida (hp / mhp), rojo sangre
//   Mind    la mente (mp / mmp), azul gris
// Los personajes, tambien en el orden del menu (battleMembers).
// L1 y R1 (pageup y pagedown, que en el mapa no hacen nada) pasan al
// personaje anterior o al siguiente; con varios, sale "1/3" junto al nombre.
// Pequeno, sin marco ni fondo y transparente: tapa poco y se ve lo
// que hay detras, y a un tamano que se lee en una portatil. Se redibuja solo
// cuando cambia algo. Solo se ve mientras
// caminas ($gamePlayer.canMove() y el jugador visible): no en los eventos,
// las escenas, los mensajes, los cambios de mapa, las cargas ni al elegir
// personaje (ahi el jugador es invisible y no corre ningun evento). Se va
// solo cuando eso dura un rato (HOLD imagenes): caminando, el juego fuerza
// una ruta una imagen de cada nueve y parpadeaba.
function (original, path) {
  var W = 280, H = 90, PAD = 10, BAR = 11, STEP = 16, HOLD = 20;
  var COLORS = ['#9a7a3a', '#8e2a22', '#4e5f7a'];
  var TEXT = '#d8cfb8', MUTED = '#8a8270', EMPTY = 'rgba(30, 24, 18, 0.6)';
  var OPACITY = 150;   // todo el recuadro, de 255: se ve el juego a traves
  var index = 0;   // el personaje que se ve

  function hunger(actor) {
    return actor.isMaxLevel() ? 0 : actor.xpRate();
  }

  function values(actor) {
    return [hunger(actor), actor.hp / Math.max(1, actor.mhp), actor.mp / Math.max(1, actor.mmp)];
  }

  function draw(sprite) {
    var members = $gameParty.battleMembers();
    var b = sprite.bitmap;
    if (!members.length) {
      b.clear();
      sprite._quixKey = '';
      return;
    }
    index = (index + members.length) % members.length;
    var actor = members[index];
    var key = index + '/' + members.length + actor.name() + values(actor).join(',');
    if (key === sprite._quixKey) return;
    sprite._quixKey = key;
    b.clear();
    b.outlineColor = 'rgba(0, 0, 0, 0.8)';
    b.outlineWidth = 3;
    b.fontSize = 28;
    b.textColor = TEXT;
    b.drawText(actor.name(), PAD, PAD - 4, W - PAD * 2, 32);
    if (members.length > 1) {
      b.fontSize = 21;
      b.textColor = MUTED;
      b.drawText((index + 1) + '/' + members.length, PAD, PAD - 4, W - PAD * 2, 32, 'right');
    }
    values(actor).forEach(function (v, k) {
      var y = PAD + 34 + k * STEP;
      b.fillRect(PAD, y, W - PAD * 2, BAR, EMPTY);
      b.fillRect(PAD, y, Math.round((W - PAD * 2) * Math.max(0, Math.min(1, v))), BAR, COLORS[k]);
    });
  }

  if (path === 'Scene_Map.prototype.createDisplayObjects') {
    return function () {
      original.apply(this, arguments);
      this._quixBars = new Sprite(new Bitmap(W, H));
      this._quixBars.x = 8;
      this._quixBars.y = 8;
      this._quixBars.opacity = OPACITY;
      this._quixBars.visible = false;
      this._quixBarsFor = 0;
      this.addChild(this._quixBars);
    };
  }
  return function () {
    original.apply(this, arguments);
    var s = this._quixBars;
    if (!s) return;
    // sale en cuanto puedes caminar; se va cuando llevas HOLD imagenes
    // seguidas sin poder
    var want = $gamePlayer.canMove() && !$gamePlayer.isTransferring() && !$gamePlayer.isTransparent();
    this._quixBarsFor = want ? 0 : this._quixBarsFor + 1;
    s.visible = want || (s.visible && this._quixBarsFor < HOLD);
    if (!s.visible) return;
    if (Input.isTriggered('pageup')) index--;
    if (Input.isTriggered('pagedown')) index++;
    draw(s);
  };
}

'use strict';

(function() {
  PMJS.phases.on('afterPlugins', 'pmjs.isat.battle-popup-text', function() {
    var qualification = PMJS.isatSourceQualification;
    var Popup = globalThis.Sprite_CustomDamage, DrawingWindow = globalThis.Window_DamageSprite;
    var Base = globalThis.Window_Base, SpriteClass = globalThis.Sprite;
    if (!qualification || qualification.verified !== true || !Popup || !DrawingWindow || !Base || !SpriteClass) return;
    var prototype = Popup.prototype, drawing = DrawingWindow.prototype;
    var original = prototype.createChildSprite;
    function eligible(setup) {
      return PMJS.isatSourceQualification === qualification && globalThis.SceneManager &&
        SceneManager._scene instanceof Scene_Battle && globalThis.$gameTroop && $gameTroop._troopId === 26 &&
        setup && setup.font === 'this.standardFontFace()' && setup.size === 'this.standardFontSize()' &&
        (setup.color === 'this.normalColor()' || typeof setup.color === 'string' && /^(['"])#[\da-f]{6}\1$/i.test(setup.color));
    }

    // These private helpers supply text surfaces, never display-tree windows.
    function TextHelper(setup) {
      this._sprite = setup;
      this.x = this.y = 0;
      this._width = this._height = 0;
      this._padding = this.standardPadding();
      this._windowskin = ImageManager.loadSystem('Window');
      this.createContents();
      this._opening = this._closing = false;
      this._dimmerSprite = null;
      this.initWindowId();
      this._isMenuEditTarget = false;
    }
    TextHelper.prototype = Object.create(drawing);
    Object.defineProperties(TextHelper.prototype, {
      x: { value: 0, writable: true, configurable: true }, y: { value: 0, writable: true, configurable: true },
      contents: { configurable: true, get: function() { return this._contents; }, set: function(value) { this._contents = value; } },
      move: { value: function(x, y, width, height) {
        this.x = x || 0; this.y = y || 0;
        this._width = Math.ceil(width || 0); this._height = Math.ceil(height || 0);
      }, writable: true, configurable: true }
    });
    function optimized(setup, motion) {
      if (!eligible(setup)) { return original.apply(this, arguments); }
      var sprite = new SpriteClass();
      sprite.motion = motion;
      sprite.setup = setup;
      this.refreshMotion(sprite);
      sprite.anchor.x = 0.5;
      sprite.anchor.y = 0.5;
      sprite.opacity = 0;
      sprite.delay = 0;
      sprite.mx = setup.x;
      sprite.my = setup.y;
      sprite.scale.x = sprite.text.motion.zoom.x / 100;
      sprite.scale.y = sprite.text.motion.zoom.y / 100;
      sprite.x = Math.floor(sprite.sx + sprite.mx);
      sprite.y = Math.floor(sprite.sy + sprite.my);
      sprite.window = new TextHelper(setup);
      this.addChild(sprite);
      return sprite;
    }
    prototype.createChildSprite = optimized;
  });
})();

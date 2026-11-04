'use strict';

(function() {
  var id = 'isat.neutral-tone-bypass';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'retain the authored neutral screen-tone composition pass' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.neutral-tone', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    var prototype = globalThis.Spriteset_Base && Spriteset_Base.prototype;
    var update = prototype && prototype.updateToneChanger;
    var create = prototype && prototype.createWebGLToneChanger;
    var webgl = prototype && prototype.updateWebGLToneChanger;
    var hash = PMJS.isatMethodHash;
    if (typeof globalThis.ToneFilter !== 'function' || !hash ||
        hash(create) !== '92ec27688f58bff9c19fcc5f7183e6717d7a23712572a7bedfb3dd0e02d1e677' ||
        hash(update) !== '706ae66cd6736f0200fd55e8d41136ea7f3f6c7ce07c6cd1f4c5e52f586f2f45' ||
        hash(webgl) !== '385d2fd8f898fd005e3b7dd05d5e7383f98119e15e65bb25a5d807863ee7bdfc') {
      PMJS.optimizations.refuse(id, 'unrecognized screen-tone lifecycle');
      return;
    }
    var template = new ToneFilter();
    var fields = ['vertexSrc', 'fragmentSrc', 'apply', 'resolution', 'padding', 'autoFit'];
    var contract = fields.map(function(field) { return template[field]; });
    var suppressed = new WeakMap();
    function eligible(spriteset, filter) {
      if (PMJS.isatSourceQualification !== qualification ||
          spriteset.createWebGLToneChanger !== create || spriteset.updateWebGLToneChanger !== webgl) return false;
      var tone = spriteset._tone;
      var filters = spriteset._baseSprite && spriteset._baseSprite.filters;
      if (!Graphics.isWebGL() || !tone || tone.length !== 4 ||
          tone[0] !== 0 || tone[1] !== 0 || tone[2] !== 0 || tone[3] !== 0 ||
          !filter || Object.getPrototypeOf(filter) !== ToneFilter.prototype ||
          filter.constructor !== ToneFilter || !filters || filters.indexOf(filter) < 0 ||
          filter.alpha !== 1 || filter.blendMode !== PIXI.BLEND_MODES.NORMAL) return false;
      if (!fields.every(function(field, index) { return filter[field] === contract[index]; })) return false;
      // A plugin can alter the matrix without changing $gameScreen's tone.
      var matrix = filter.matrix;
      if (!matrix || matrix.length !== 20) return false;
      for (var n = 0; n < 20; n++) {
        if (matrix[n] !== (n === 0 || n === 6 || n === 12 || n === 18 ? 1 : 0)) return false;
      }
      return true;
    }
    prototype.updateToneChanger = function() {
      var result = update.apply(this, arguments);
      var filter = this._toneFilter;
      var previous = suppressed.get(this);
      var bypass = eligible(this, filter);
      if (previous && (previous.filter !== filter || !bypass)) {
        if (previous.filter.enabled === false) previous.filter.enabled = previous.enabled;
        suppressed.delete(this);
        previous = null;
      }
      if (bypass && (previous || filter.enabled !== false)) {
        if (!previous) suppressed.set(this, { filter: filter, enabled: filter.enabled });
        // Disabling preserves the filter array, order and authored resource ownership.
        // This intentionally accepts the tiny sampling change from skipping its pass.
        filter.enabled = false;
      }
      return result;
    };
  });
})();

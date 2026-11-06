'use strict';

(function() {
  var id = 'isat.screen-effects-lifecycle';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'authored screen-effect filter lifecycle' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.screen-effects', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    var prototype = globalThis.Spriteset_Base && Spriteset_Base.prototype;
    var create = prototype && prototype.createScreenEffectFilters;
    var controller = prototype && prototype.updateScreenEffects;
    var update = prototype && prototype.update;
    var fields = ['_ase_blur_filter', '_ase_zblur_filter', '_ase_glow_filter',
      '_ase_wave_filter', '_ase_dist_filter'];
    var hash = PMJS.isatMethodHash;
    if (!hash || hash(create) !== '9fe339a77b586665ba978b1148582cd9fef5c77e0a3e22769a6f7ff38e42dfcc' ||
        hash(controller) !== 'fd2eab7e3329c22ac2b61c7af7afffccadb3600bd8d72a7c461ce40ba36eb37c' ||
        hash(update) !== '4d0d4af66fd4dde0e62c43325992e423015ca6c64dcf08c37d9638048c3b53db') {
      PMJS.optimizations.refuse(id, 'unrecognized screen-effect filter lifecycle');
      return;
    }
    function eligible(spriteset) {
      return PMJS.isatSourceQualification === qualification &&
        spriteset.updateScreenEffects === controller;
    }
    function disable(spriteset) {
      fields.forEach(function(field) {
        if (spriteset[field]) spriteset[field].enabled = false;
      });
    }
    prototype.createScreenEffectFilters = function() {
      var result = create.apply(this, arguments);
      if (eligible(this)) disable(this);
      return result;
    };
    prototype.update = function() {
      var result = update.apply(this, arguments);
      // Effects off also suppresses the idle wave's non-neutral brightness.
      if (eligible(this) && globalThis.ConfigManager && ConfigManager.screenEffectsEnabled === false) disable(this);
      return result;
    };
  });
})();

'use strict';

(function() {
  var id = 'isat.bourdon-sprite-dispatch';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary battle transform and sprite-segment selection' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.battle-sprite-dispatch', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified battle sources');
      return;
    }
    var policies = new WeakMap();
    var selected = { worldState: 'pixi', plainSpriteSegments: false };
    function restore(scene) {
      var previous = policies.get(scene);
      if (!previous) return;
      var current = PMJS.pixi4.getStageRenderOptions(scene);
      if (current) {
        var options = Object.assign({}, current);
        for (var key in selected) {
          if (current[key] !== selected[key]) continue;
          if (previous[key].present) options[key] = previous[key].value;
          else delete options[key];
        }
        if (Object.keys(options).length) {
          if (!Object.prototype.hasOwnProperty.call(options, 'worldState')) options.worldState = 'native';
          PMJS.pixi4.setStageRenderOptions(scene, options);
        } else PMJS.pixi4.setStageRenderOptions(scene, null);
      }
      policies.delete(scene);
    }
    var create = Scene_Battle.prototype.createDisplayObjects;
    Scene_Battle.prototype.createDisplayObjects = function() {
      restore(this);
      var result = create.apply(this, arguments);
      if (PMJS.isatSourceQualification !== qualification || !$gameTroop || $gameTroop._troopId !== 26) return result;
      var current = PMJS.pixi4.getStageRenderOptions(this), previous = {};
      for (var key in selected) previous[key] = {
        present: !!current && Object.prototype.hasOwnProperty.call(current, key),
        value: current && current[key]
      };
      policies.set(this, previous);
      PMJS.pixi4.setStageRenderOptions(this, Object.assign({}, current, selected));
      return result;
    };
    var terminate = Scene_Battle.prototype.terminate;
    Scene_Battle.prototype.terminate = function() {
      restore(this);
      return terminate.apply(this, arguments);
    };
  });
})();

'use strict';

(function() {
  var id = 'isat.dormont-sprite-dispatch';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'retain ordinary renderer transform and sprite-segment selection' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.map-sprite-dispatch', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified map sources');
      return;
    }
    var create = Scene_Map.prototype.createDisplayObjects;
    var policies = new WeakMap();
    var selected = { worldState: 'pixi', plainSpriteSegments: false };
    function eligible() {
      return PMJS.isatSourceQualification === qualification && qualification.verified === true && $gameMap.mapId() === 30;
    }
    function restore(scene) {
      var previous = policies.get(scene);
      if (!previous) return;
      var current = PMJS.pixi4.getStageRenderOptions(scene);
      if (current) {
        var restored = Object.assign({}, current);
        for (var key in selected) {
          if (current[key] !== selected[key]) continue;
          if (previous[key].present) restored[key] = previous[key].value;
          else delete restored[key];
        }
        if (Object.keys(restored).length) {
          if (!Object.prototype.hasOwnProperty.call(restored, 'worldState')) restored.worldState = 'native';
          PMJS.pixi4.setStageRenderOptions(scene, restored);
        } else PMJS.pixi4.setStageRenderOptions(scene, null);
      }
      policies.delete(scene);
    }
    Scene_Map.prototype.createDisplayObjects = function() {
      var result = create.apply(this, arguments);
      var current = PMJS.pixi4.getStageRenderOptions(this);
      var previous = policies.get(this);
      if (eligible()) {
        if (!previous) {
          previous = {};
          for (var field in selected) previous[field] = {
            present: !!current && Object.prototype.hasOwnProperty.call(current, field),
            value: current && current[field]
          };
          policies.set(this, previous);
        }
        PMJS.pixi4.setStageRenderOptions(this,
          Object.assign({}, current, selected));
      } else restore(this);
      return result;
    };
    var update = Scene_Map.prototype.update;
    Scene_Map.prototype.update = function() {
      if (!eligible()) restore(this);
      return update.apply(this, arguments);
    };
    var terminate = Scene_Map.prototype.terminate;
    Scene_Map.prototype.terminate = function() {
      restore(this);
      return terminate.apply(this, arguments);
    };
  });
})();

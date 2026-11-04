'use strict';

(function() {
  PMJS.phases.on('afterPlugins', 'pmjs.isat.battle-hidden-gauges', function() {
    if (!PMJS.isatSourceQualification || PMJS.isatSourceQualification.verified !== true) return;
    var suppressed = new WeakSet();
    function install(Class, shown) {
      if (!Class) return;
      var original = Class.prototype.update;
      Class.prototype.update = function() {
        var battler = this._battler;
        if (globalThis.$gameTroop && $gameTroop._troopId === 26 && battler &&
            battler.isEnemy() && battler.enemyId() >= 56 && battler.enemyId() <= 61 &&
            !battler[shown]() && this.contentsOpacity === 0) {
          suppressed.add(this);
          return;
        }
        if (suppressed.delete(this)) {
          this._requestRefresh = true;
        }
        return original.apply(this, arguments);
      };
    }
    install(globalThis.Window_VisualHPGauge, 'hpGaugeVisible');
    install(globalThis.Window_EnemyVisualATB, 'showATBGauge');
  });
})();

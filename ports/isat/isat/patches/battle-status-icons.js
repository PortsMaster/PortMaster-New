'use strict';

(function() {
  var id = 'isat.battle-status-icons';
  PMJS.optimizations.register({
    id: id,
    owner: 'pmjs-isat',
    fallback: 'authored battle status refresh checks'
  });

  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.battle-status-icons', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, qualification && qualification.reason || 'unqualified battle status sources');
      return;
    }
    var status = globalThis.Window_BattleStatusUpgrade;
    var prototype = status && status.prototype;
    var update = prototype && prototype.updateRefreshes;
    var drawIcons = prototype && prototype.drawActorIconsScale;
    if (typeof update !== 'function' || typeof drawIcons !== 'function' ||
        Function.prototype.toString.call(update)
          .indexOf('info[0] !== eval(info[1])') < 0 ||
        Function.prototype.toString.call(drawIcons)
          .indexOf('this._checkForRefresh.push([actor.allIcons(), "actor.allIcons()"])') < 0) {
      PMJS.optimizations.refuse(id, 'unrecognized battle status icon refresh');
      return;
    }

    prototype.updateRefreshes = function() {
      var actor = this._actor;
      var length = this._checkForRefresh.length;
      for (var i = 0; i < length; i++) {
        var info = this._checkForRefresh[i];
        var current = eval(info[1]);
        if (info[0] === current) continue;
        if (info[1] === 'actor.allIcons()' &&
            Array.isArray(info[0]) && Array.isArray(current) &&
            info[0].length === current.length &&
            info[0].every(function(icon, index) { return icon === current[index]; })) {
          continue;
        }
        this.refresh();
        break;
      }
    };
  });
})();

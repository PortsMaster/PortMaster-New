'use strict';

(function() {
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.battle-selection-refresh', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || !qualification.verified) return;
    var prototype = Window_EnemyVisualSelect.prototype, refresh = prototype.refresh, update = prototype.update;
    if (PMJS.isatMethodHash(refresh) !==
        'cc796b00a881745f0dec5998e9086949e9ba8491203477c5691c5ed8bf72e720') return;
    var settled = new WeakSet();
    prototype.refresh = function() {
      var result = refresh.apply(this, arguments);
      if (PMJS.isatSourceQualification === qualification &&
          this._battler && !this._showEnemyName && this._requestRefresh) {
        this._requestRefresh = false;
        settled.add(this);
      }
      return result;
    };
    prototype.update = function() {
      if (settled.has(this) && this._showEnemyName) {
        settled.delete(this);
        this._requestRefresh = true;
      }
      return update.apply(this, arguments);
    };
  });
})();

'use strict';

(function() {
  PMJS.phases.on('afterPlugins', 'pmjs.isat.battle-closed-windows', function() {
    if (!PMJS.isatSourceQualification || PMJS.isatSourceQualification.verified !== true) return;
    var original = Window_Selectable.prototype.update;
    Window_Selectable.prototype.update = function() {
      if (globalThis.$gameTroop && $gameTroop._troopId === 26 && !this.active &&
          !this._opening && !this._closing && (this.visible === false || this.openness === 0) &&
          PMJS.isatHorrorPresentation && PMJS.isatHorrorPresentation.isInactive()) {
        // Plugin children and base window state keep advancing while input is idle.
        Window_Base.prototype.update.call(this);
        this.updateArrows();
        if (this.active) {
          this.processCursorMove();
          this.processHandling();
          this.processWheel();
          this.processTouch();
        } else this._touching = false;
        this._stayCount++;
        return;
      }
      return original.apply(this, arguments);
    };
  });
})();

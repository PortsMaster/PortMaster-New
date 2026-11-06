'use strict';

(function() {
  PMJS.phases.on('afterPlugins', 'pmjs.isat.message-fast-forward', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) return;
    var fastForward = Window_Message.prototype.isFastForward;
    var updateMap = Scene_Map.prototype.updateMainMultiply;
    function permitted() {
      // The three authored skip common events are enabled by these switches.
      return ($gameSwitches.value(2) || $gameSwitches.value(19) || $gameSwitches.value(237)) &&
        !TDDP_NoFastForward.isTextFfDisabled();
    }
    Window_Message.prototype.isFastForward = function() {
      if (PMJS.isatSourceQualification === qualification && !permitted()) {
        $gameTemp._fastForwardCD = null;
        return false;
      }
      return fastForward.apply(this, arguments);
    };
    Scene_Map.prototype.updateMainMultiply = function() {
      if (PMJS.isatSourceQualification === qualification && !permitted()) {
        $gameTemp._fastForwardCD = null;
        if (this._messageWindow) this._messageWindow._showFast = false;
      }
      return updateMap.apply(this, arguments);
    };
  });
})();

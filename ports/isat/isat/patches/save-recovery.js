'use strict';

PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.save-recovery', function() {
  var controls = globalThis.Olivia && Olivia.MetaControls;
  if (!controls) return;
  var original = controls.___DataManager_saveGame___;
  if (PMJS.isatMethodHash(original) !==
      '877e1a9f1fea9c52e9d8c4af2cd589d027e872762f35e4a9e0cc82fea48994b8') {
    console.warn('[pmjs-isat] save recovery skipped: unrecognized save handler');
    return;
  }
  controls.___DataManager_saveGame___ = function(savefileId) {
    var backedUp = false;
    try {
      var hadSave = StorageManager.exists(savefileId);
      StorageManager.backup(savefileId);
      backedUp = hadSave;
      return this.saveGameWithoutRescue(savefileId);
    } catch (error) {
      console.error(error);
      if (backedUp) {
        try {
          StorageManager.restoreBackup(savefileId);
        } catch (restoreError) {
          console.error(restoreError);
        }
      }
      return false;
    }
  };
});

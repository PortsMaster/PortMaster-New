'use strict';

PMJS.isatSourcePatches.register('js/plugins/JKL_PersistentData.js', 'persistent data after slot extraction', (src) => {
  const marker = 'var _DataManager_extractSaveContents = DataManager.extractSaveContents;';
  if (src.includes(marker)) return null;
  const newline = src.includes('\r\n') ? '\r\n' : '\n';
  const before = [
    'var _Scene_Load_onLoadSuccess = Scene_Load.prototype.onLoadSuccess;',
    'Scene_Load.prototype.onLoadSuccess = function() {',
    '_Scene_Load_onLoadSuccess.call(this);',
    'PersistManager.load();',
    '}',
  ].join(newline);
  if (!src.includes(before)) return src;
  const after = [
    'var _DataManager_extractSaveContents = DataManager.extractSaveContents;',
    'DataManager.extractSaveContents = function(contents) {',
    '_DataManager_extractSaveContents.call(this, contents);',
    'PersistManager.load();',
    '};',
  ].join(newline);
  return src.replace(before, after);
});

(function() {
  var initialized = false;
  var conflict = false;
  var notices = [];
  var lastSave = null;
  var legacy = 'filePersistent.rpgsave';
  var imported = legacy + '.imported';

  function notify(message) {
    console.warn('[pmjs-isat] ' + message);
    notices.push(message);
  }

  function decode(json) {
    var value = JSON.parse(json);
    if (!value || typeof value !== 'object' || Array.isArray(value) ||
        (value.switches !== undefined && !Array.isArray(value.switches)) ||
        (value.variables !== undefined && !Array.isArray(value.variables))) {
      throw new Error('invalid persistent progress record');
    }
    return json;
  }

  function preserve(name, raw) {
    var target = name + '.corrupt';
    var index = 1;
    while (NativeHost.storage.exists(target)) target = name + '.corrupt.' + index++;
    NativeHost.storage.writeText(target, raw);
    return target;
  }

  function initialize(manager, name) {
    if (initialized) return;
    if (NativeHost.storage.exists(legacy) &&
        !NativeHost.storage.exists(legacy + '.deleted') &&
        !NativeHost.storage.exists(name + '.deleted')) {
      var raw = NativeHost.storage.readText(legacy);
      if (!manager.exists('Persistent')) {
        NativeHost.storage.writeText(name, raw);
        NativeHost.storage.writeText(imported, raw);
      } else if (NativeHost.storage.readText(name) !== raw &&
                 NativeHost.storage.readText(imported) !== raw) {
        conflict = true;
      }
    }
    initialized = true;
  }

  // A later save plugin replaces the persistent plugin's filename hook.
  PMJS.methods.wrap({
    key: 'StorageManager.localFilePath',
    id: 'pmjs.isat.persistent-path',
    getTarget: function() { return StorageManager; },
    method: 'localFilePath',
    wrap: function(filePath) {
      return function(id) {
        return id === 'Persistent' ? this.localFileDirectoryPath() + 'persistent.rpgsave' :
          filePath.apply(this, arguments);
      };
    }
  });

  PMJS.methods.wrap({
    key: 'StorageManager.load',
    id: 'pmjs.isat.persistent-load',
    getTarget: function() { return StorageManager; },
    method: 'load',
    wrap: function(load) {
      return function(id) {
        if (id !== 'Persistent') return load.apply(this, arguments);
        lastSave = null;
        var name = this.localFilePath(id).replace(/^\/save\//, '');
        initialize(this, name);
        var json = load.apply(this, arguments);
        if (!this.exists(id)) return json;
        try {
          if (json === null || json === '') throw new Error('persistent progress could not be decoded');
          decode(json);
          if (conflict) {
            notify('Different persistent progress records were found. Using ' + name +
              '; the previous native record is kept as ' + legacy + '.');
            conflict = false;
          }
          return json;
        } catch (error) {
          conflict = false;
          var raw = NativeHost.storage.readText(name);
          var source = name;
          if (raw === null) {
            source = name + '.bak';
            raw = NativeHost.storage.readText(source);
          }
          if (raw === null) throw error;
          var kept = preserve(source, raw);
          var backup = NativeHost.storage.readText(name + '.bak');
          var restored = null;
          if (source !== name + '.bak' && backup !== null) {
            try { restored = decode(LZString.decompressFromBase64(backup)); }
            catch (_) { restored = null; }
          }
          var restoredFrom = 'backup';
          if (!restored && NativeHost.storage.exists(legacy) &&
              !NativeHost.storage.exists(legacy + '.deleted')) {
            var previous = NativeHost.storage.readText(legacy);
            try { restored = decode(LZString.decompressFromBase64(previous)); }
            catch (_) { restored = null; }
            restoredFrom = 'the previous native record';
          }
          var fresh = restored || '{"switches":[],"variables":[]}';
          NativeHost.storage.writeText(name, LZString.compressToBase64(fresh));
          notify((restored ? 'Restored persistent progress from ' + restoredFrom + '.' :
            'Unreadable persistent progress was replaced with a fresh record.') +
            ' The unreadable copy is kept as ' + kept + '.');
          return fresh;
        }
      };
    }
  });

  PMJS.methods.wrap({
    key: 'StorageManager.save',
    id: 'pmjs.isat.persistent-save',
    getTarget: function() { return StorageManager; },
    method: 'save',
    wrap: function(save) {
      return function(id, json) {
        if (id !== 'Persistent') return save.apply(this, arguments);
        try {
          var storage = NativeHost.storage;
          var generation = typeof storage.generation === 'function' ? storage.generation() : null;
          var name = this.localFilePath(id);
          if (lastSave && lastSave.storage === storage && lastSave.name === name &&
              lastSave.generation === generation && lastSave.json === json) return lastSave.result;
          lastSave = null;
          var result = save.apply(this, arguments);
          if (result !== false && typeof json === 'string' && typeof generation === 'number' &&
              NativeHost.storage === storage && this.localFilePath(id) === name) {
            lastSave = { storage: storage, name: name, json: json, result: result,
              generation: storage.generation() };
          }
          return result;
        }
        catch (error) {
          lastSave = null;
          console.error('[pmjs-isat] persistent progress was not saved:', error);
          notify('Persistent progress could not be saved. Check the storage space and permissions.');
          return false;
        }
      };
    }
  });

  // Boot creates game objects again before pre-title, replacing Game_Message.
  PMJS.methods.wrap({
    key: 'SceneManager.updateScene',
    id: 'pmjs.isat.persistent-notices',
    getTarget: function() { return SceneManager; },
    method: 'updateScene',
    wrap: function(update) {
      return function() {
        var result = update.apply(this, arguments);
        if (notices.length && this._sceneStarted &&
            !(this._scene instanceof Scene_Boot) && globalThis.$gameMessage) {
          notices.forEach(function(message) { $gameMessage.add(message); });
          notices.length = 0;
        }
        return result;
      };
    }
  });
})();

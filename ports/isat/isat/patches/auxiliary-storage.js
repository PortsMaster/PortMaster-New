'use strict';

(function() {
  function parse(json, kind) {
    var value = JSON.parse(json);
    if (kind === 'global' ? !Array.isArray(value) :
        !value || typeof value !== 'object' || Array.isArray(value)) {
      throw new Error('invalid ' + kind + ' record');
    }
    return value;
  }

  function preserve(id) {
    var name = StorageManager.localFilePath(id).replace(/^\/save\//, '');
    var raw = NativeHost.storage.readText(name);
    var source = name;
    if (raw === null) {
      source += '.bak';
      raw = NativeHost.storage.readText(source);
    }
    if (raw === null) throw new Error('unreadable auxiliary source disappeared: ' + name);
    var target = source + '.corrupt';
    var index = 1;
    while (NativeHost.storage.exists(target)) {
      if (NativeHost.storage.readText(target) === raw) return target;
      target = source + '.corrupt.' + index++;
    }
    NativeHost.storage.writeText(target, raw);
    return target;
  }

  function valid(id, kind) {
    var json = StorageManager.load(id);
    if (json === null && !StorageManager.exists(id)) return true;
    try {
      if (json === null || json === '') throw new Error('empty auxiliary record');
      parse(json, kind);
      return true;
    } catch (_) { return false; }
  }

  function slotInfo(manager, contents) {
    if (!contents || !contents.system || typeof contents.system !== 'object' ||
        Array.isArray(contents.system) || !contents.party || !contents.actors ||
        !Array.isArray(contents.party._actors) || !Array.isArray(contents.actors._data) ||
        typeof contents.party.maxBattleMembers !== 'function') {
      throw new Error('save contents lack system, party or actors');
    }
    // Saved party accessors consult live actors. Read this slot's actor table
    // instead, without extracting the save into the running game.
    var actors = contents.party._actors.slice(0, contents.party.maxBattleMembers())
      .map(function(id) {
        var actor = contents.actors._data[id];
        if (!actor) throw new Error('saved party actor is missing');
        return actor;
      }).filter(function(actor) { return !actor._hidden; });
    var characters = [], faces = [];
    actors.forEach(function(actor) {
      if (typeof actor._characterName !== 'string' || typeof actor._faceName !== 'string' ||
          !Number.isInteger(actor._characterIndex) || !Number.isInteger(actor._faceIndex)) {
        throw new Error('invalid saved actor images');
      }
      characters.push([actor._characterName, actor._characterIndex]);
      faces.push([actor._faceName, actor._faceIndex]);
    });
    var system = contents.system;
    var seconds = Number.isFinite(system._playtime) && system._playtime >= 0
      ? Math.floor(system._playtime / 1000)
      : Number.isFinite(system._framesOnSave) && system._framesOnSave >= 0
        ? Math.floor(system._framesOnSave / 60) : null;
    var playtime = seconds === null ? '' : [Math.floor(seconds / 3600),
      Math.floor(seconds / 60) % 60, seconds % 60].map(function(value) {
      return String(value).padStart(2, '0');
    }).join(':');
    return { globalId: manager._globalId, title: $dataSystem.gameTitle,
      characters: characters, faces: faces, playtime: playtime, timestamp: Date.now() };
  }

  function rebuild(manager, info) {
    var changed = false;
    for (var id = 1; id <= manager.maxSavefiles(); id++) {
      if (info[id] && typeof info[id] === 'object' && !Array.isArray(info[id])) continue;
      if (!StorageManager.exists(id)) continue;
      var json = StorageManager.load(id);
      try {
        if (!json) throw new Error('save could not be decoded');
        info[id] = slotInfo(manager, JsonEx.parse(json));
        changed = true;
      } catch (error) {
        console.warn('[pmjs-isat] Slot ' + id + ' could not be indexed: ' + error.message +
          '. Its save file is unchanged.');
      }
    }
    return changed;
  }

  PMJS.methods.wrap({
    key: 'ConfigManager.load',
    id: 'pmjs.isat.config-recovery',
    getTarget: function() { return ConfigManager; },
    method: 'load',
    wrap: function(load) {
      return function() {
        if (valid(-1, 'config')) return load.apply(this, arguments);
        var kept = preserve(-1);
        console.warn('[pmjs-isat] Unreadable settings were preserved as ' + kept +
          '. Using the default settings until the next option save.');
        return this.applyData({});
      };
    }
  });

  PMJS.methods.wrap({
    key: 'DataManager.loadGlobalInfo',
    id: 'pmjs.isat.global-recovery',
    getTarget: function() { return DataManager; },
    method: 'loadGlobalInfo',
    wrap: function(load) {
      return function() {
        var json = StorageManager.load(0);
        var info = [], malformed = false;
        if (json !== null || StorageManager.exists(0)) {
          try {
            if (json === null || json === '') throw new Error('empty auxiliary record');
            info = parse(json, 'global');
          } catch (_) { malformed = true; }
        }
        var kept = malformed ? preserve(0) : null;
        if (!globalThis.$dataSystem) {
          if (kept) console.warn('[pmjs-isat] Unreadable save index was preserved as ' + kept +
            '. Index repair is waiting for the game database.');
          return malformed ? info : load.apply(this, arguments);
        }
        var changed = rebuild(this, info);
        if (malformed || changed) {
          this.saveGlobalInfo(info);
          console.warn('[pmjs-isat] ' + (kept ? 'Unreadable save index was preserved as ' + kept + '. ' : '') +
            'Rebuilt missing save index entries from the available saves; recovered timestamps reflect this recovery.');
        }
        return load.apply(this, arguments);
      };
    }
  });
})();

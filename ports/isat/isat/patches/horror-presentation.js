'use strict';

(function installHorrorPresentation() {
  var id = 'isat.dormont-horror-presentation';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'authored sprite horror presentation' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.horror-presentation', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified guest sources');
      return;
    }
    var hash = PMJS.isatMethodHash;
    function refuse(reason) { PMJS.optimizations.refuse(id, reason); }

    if (!globalThis.Olivia || !Olivia.HorrorEffects) return refuse('missing horror plugin');
    var ordinary = Sprite.prototype.update;
    var inactive = Olivia.HorrorEffects.___Sprite_update___;
    if (typeof ordinary !== 'function' || typeof inactive !== 'function' ||
        hash(ordinary) !== '27950ec1883504d9dc0543d220c7b3149b48aaae13c837b2f7c5a937927877ef' ||
        hash(inactive) !== '0fd3a3e3f5fa2f6d60b4b6c805f4fe3533b02bcb1e154b7716503b626d32cfa9' ||
        Object.getOwnPropertyDescriptor(Sprite.prototype, '_horrorFiltersSource')) {
      return refuse('unrecognized horror presentation composition');
    }
    var modelMethods = ['clearHorrorEffects', 'createHorrorEffect', 'removeHorrorEffect', 'setHorrorEffectToValue'];
    var localMethods = ['createHorrorNoise', 'createHorrorGlitch', 'createHorrorTV'];
    if (!modelMethods.every(function(name) { return typeof Game_System.prototype[name] === 'function'; }) ||
        !localMethods.every(function(name) { return typeof Sprite.prototype[name] === 'function'; }) ||
        typeof Game_Player.prototype.refresh !== 'function' || typeof Game_Follower.prototype.refresh !== 'function') {
      return refuse('missing horror producer');
    }
    var stockUpdate = inactive;
    inactive = function inactiveHorrorUpdate() {
      if (!bypass) return ordinary.apply(this, arguments);
      var result = stockUpdate.apply(this, arguments);
      // A child may activate its parent's effect while the child walk is running.
      if (!bypass) this.updateHorrorEffects();
      return result;
    };
    var values = new WeakMap(), currentScene = null, bypass = false;
    var inventoryCalls = 0, admissions = 0, fallbacks = 0, rearms = 0, lastReason = 'not-admitted';
    var sceneDirty = false, updateDepth = 0, startDepth = 0;
    var scenes = new Map();
    Object.getOwnPropertyNames(globalThis).forEach(function(name) {
      if (!/^Scene_/.test(name)) return;
      var type = globalThis[name];
      if (typeof type === 'function' && type.prototype && !scenes.has(type.prototype)) {
        scenes.set(type.prototype, { name: name, type: type });
      }
    });
    function eligibleScene(scene) {
      var entry = scene && scenes.get(Object.getPrototypeOf(scene));
      return !!entry && globalThis[entry.name] === entry.type && PMJS.isatSourceQualification === qualification;
    }
    function markSceneDirty() {
      if (currentScene) sceneDirty = true;
    }
    function neutralFilters(object) {
      if (!object || !('_horrorFilters' in object)) return true;
      var owner = object, descriptor;
      while (owner && !(descriptor = Object.getOwnPropertyDescriptor(owner, '_horrorFilters'))) owner = Object.getPrototypeOf(owner);
      return descriptor && Object.prototype.hasOwnProperty.call(descriptor, 'value') && !active(descriptor.value);
    }
    function neutralIncomingTree(node) {
      if (!node || typeof node !== 'object' || !neutralFilters(node)) return false;
      if ('_horrorFiltersSource' in node) {
        // Borrowed data properties must first pass the ordinary inventory, which
        // installs the source notification or refuses a nonconfigurable owner.
        if (Object.prototype.hasOwnProperty.call(node, '_horrorFiltersSource')) return false;
        var owner = Object.getPrototypeOf(node), descriptor;
        while (owner && !(descriptor = Object.getOwnPropertyDescriptor(owner, '_horrorFiltersSource'))) owner = Object.getPrototypeOf(owner);
        if (!descriptor || descriptor.get !== getSource || descriptor.set !== setSource || !neutralFilters(values.get(node))) return false;
      }
      var children = Object.getOwnPropertyDescriptor(node, 'children');
      if (!children) return !('children' in node);
      if (!Object.prototype.hasOwnProperty.call(children, 'value') || !Array.isArray(children.value)) return false;
      for (var index = 0; index < children.value.length; index++) if (!neutralIncomingTree(children.value[index])) return false;
      return true;
    }
    if (globalThis.PIXI && typeof PIXI.Container === 'function') ['addChild', 'addChildAt'].forEach(function(name) {
      var original = PIXI.Container.prototype[name];
      if (typeof original !== 'function') return;
      PIXI.Container.prototype[name] = function() {
        if ((name === 'addChildAt' || arguments.length === 1) && arguments[0] && arguments[0].parent === this) {
          return original.apply(this, arguments);
        }
        if (currentScene && eligibleScene(currentScene)) {
          var parent = this;
          while (parent && parent !== currentScene) parent = parent.parent;
          if (parent === currentScene) {
            var count = name === 'addChildAt' ? Math.min(arguments.length, 1) : arguments.length;
            for (var index = 0; index < count; index++) {
              var child = arguments[index];
              if (!child || child.parent === this) continue;
              var owner = child.parent;
              while (owner && owner !== currentScene) owner = owner.parent;
              if (owner !== currentScene && !neutralIncomingTree(child)) { markSceneDirty(); fallback('tree:' + name); break; }
            }
          }
          // Reordering or moving an already-admitted child inside the same
          // scene cannot introduce an unobserved effect source. Detached neutral
          // subtrees need only a local check, including remove/readd z sorting.
        }
        return original.apply(this, arguments);
      };
    });
    function active(filters) {
      return !!(filters && (filters.noiseFilter || filters.glitchFilter || filters.tvFilter));
    }
    function fallback(reason) {
      if (!bypass) return;
      fallbacks++;
      lastReason = reason || 'fallback';
      bypass = false;
      if (Sprite.prototype.update === inactive) Sprite.prototype.update = ordinary;
    }
    function getSource() { return values.get(this); }
    function setSource(value) {
      var previous = values.get(this);
      if (value && active(value._horrorFilters)) {
        if (bypass) { markSceneDirty(); fallback('active-source-assignment'); }
      } else if (previous !== value && previous && active(previous._horrorFilters)) markSceneDirty();
      values.set(this, value);
    }
    Object.defineProperty(Sprite.prototype, '_horrorFiltersSource', { configurable: true,
      get: getSource, set: setSource });
    function notify(object, name) {
      var method = object[name];
      object[name] = function() {
        markSceneDirty(); fallback('producer:' + name);
        return method.apply(this, arguments);
      };
    }
    modelMethods.forEach(function(name) { notify(Game_System.prototype, name); });
    [Game_Player.prototype, Game_Follower.prototype].forEach(function(proto) { notify(proto, 'refresh'); });
    localMethods.forEach(function(name) { notify(Sprite.prototype, name); });
    ['removeHorrorNoise', 'removeHorrorGlitch', 'removeHorrorTV'].forEach(function(name) {
      if (typeof Sprite.prototype[name] === 'function') notify(Sprite.prototype, name);
    });

    function inventory(scene, eligible) {
      fallback('scene-inventory');
      inventoryCalls++;
      sceneDirty = false;
      currentScene = scene;
      if (!eligible) { lastReason = 'scene-ineligible'; return; }
      if (Sprite.prototype.update !== ordinary) { lastReason = 'sprite-update-changed'; return; }
      var found = false, seen = new Set();
      function visit(node) {
        if (!node || seen.has(node)) return;
        seen.add(node);
        if (active(node._horrorFilters) || node._horrorFiltersSource && active(node._horrorFiltersSource._horrorFilters)) found = true;
        if (node instanceof Sprite) {
          var descriptor = Object.getOwnPropertyDescriptor(node, '_horrorFiltersSource');
          if (descriptor) {
            if (!descriptor.configurable || !Object.prototype.hasOwnProperty.call(descriptor, 'value')) found = true;
            else { values.set(node, descriptor.value); delete node._horrorFiltersSource; }
          }
        }
        var children = node.children || [];
        for (var i = 0; i < children.length; i++) visit(children[i]);
      }
      visit(scene);
      if (!found) { Sprite.prototype.update = inactive; bypass = true; admissions++; lastReason = null; }
      else lastReason = 'active-filter-or-source-descriptor';
    }
    scenes.forEach(function(entry, prototype) {
      if (Object.prototype.hasOwnProperty.call(prototype, 'start') && typeof prototype.start === 'function') {
        var start = prototype.start;
        prototype.start = function() {
          startDepth++;
          try {
            var result = start.apply(this, arguments);
          } finally { startDepth--; }
          if (!startDepth && currentScene !== this) inventory(this, eligibleScene(this));
          return result;
        };
      }
      if (Object.prototype.hasOwnProperty.call(prototype, 'terminate') && typeof prototype.terminate === 'function') {
        var terminate = prototype.terminate;
        prototype.terminate = function() {
          fallback('scene-terminate');
          if (currentScene === this) { currentScene = null; sceneDirty = false; }
          return terminate.apply(this, arguments);
        };
      }
      if (Object.prototype.hasOwnProperty.call(prototype, 'update') && typeof prototype.update === 'function') {
        var update = prototype.update;
        prototype.update = function() {
          var completed = false;
          updateDepth++;
          try {
            var result = update.apply(this, arguments);
            completed = true;
            return result;
          } finally {
            updateDepth--;
            // Coalesce nested scene callbacks and effect notifications. Stable
            // frames do not repeat the display-tree inventory.
            if (completed && !updateDepth && sceneDirty && currentScene === this && eligibleScene(this) &&
                globalThis.SceneManager && SceneManager._scene === this) {
              if (Sprite.prototype.update === ordinary || Sprite.prototype.update === inactive) {
                rearms++;
                inventory(this, true);
              } else { sceneDirty = false; lastReason = 'sprite-update-changed'; }
            }
          }
        };
      }
    });
    PMJS.isatHorrorPresentation = { ordinaryUpdate: ordinary, inactiveUpdate: inactive, stockUpdate: stockUpdate,
      isInactive: function() { return bypass && Sprite.prototype.update === inactive; },
      diagnostics: function() { return { inventoryCalls: inventoryCalls, admissions: admissions, fallbacks: fallbacks,
        rearms: rearms, dirty: sceneDirty, reason: lastReason,
        inactive: bypass && Sprite.prototype.update === inactive }; } };
  });
})();

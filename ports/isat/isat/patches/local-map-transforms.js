'use strict';

(function() {
  PMJS.phases.on('beforeBoot', 'pmjs.isat.local-map-transforms', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true || qualification.dormontDataVerified !== true) return;
    var req = __pmjsBuiltinRequire;
    function digest(method) {
      if (typeof method !== 'function') return '';
      var text = Function.prototype.toString.call(method).replace(/\/\*[\s\S]*?\*\/|\/\/[^\n]*/g, '')
        .replace(/^function(?:\s+[\w$]+)?\s*\(/, 'function(').replace(/\s/g, '');
      return req('node:crypto').createHash('sha256').update(text).digest('hex');
    }
    var reviewed = new Set([
      '9b72717c412d296ece91ea0cc7fab4b4fb6e4616acd1695f341e65c38577bdf6',
      'f73a944d5eaf648b2bc889563092d8453183be562e30e64d1ba4218d57614677',
      'cb1dd91963c974a21bdaa4d31b75bc8aa5883c0f7f9ef52873fcd028f33771ae',
      'd3ad6a2cb5ce923b424a85a4397e81df1cfa310ee441831aafb18443faee4668',
      'a7412bdc5b39ba5fc985062655147982aa5f03502f0995cc08f8b622144ccb39',
      '5e32e41b3f0bc2145bafdc719d2f913aca029c89c09b4bfeecd93b874b2eddbe',
      '6d1393221107188f680e8137675a6665f39d061935185d51d1579d073250c9b5'
    ]);
    var approved = new Set(), graph = [];
    var classes = { Container: PIXI.Container, PixiSprite: PIXI.Sprite, Sprite: globalThis.Sprite,
      Window: globalThis.Window, Tilemap: globalThis.Tilemap, ShaderTilemap: globalThis.ShaderTilemap,
      TilingSprite: globalThis.TilingSprite, PixiTilingSprite: PIXI.extras && PIXI.extras.TilingSprite,
      RectTileLayer: PIXI.tilemap && PIXI.tilemap.RectTileLayer,
      CompositeRectTileLayer: PIXI.tilemap && PIXI.tilemap.CompositeRectTileLayer };
    var yepPredecessor = globalThis.Yanfly && Yanfly.Core && Yanfly.Core.Sprite_updateTransform;
    var yepSource = function() {
      Yanfly.Core.Sprite_updateTransform.call(this);
      this.worldTransform.tx = Math.floor(this.worldTransform.tx);
      this.worldTransform.ty = Math.floor(this.worldTransform.ty);
    };
    for (var key in classes) {
      var proto = classes[key] && classes[key].prototype;
      if (!proto) continue;
      var method = proto.updateTransform, hash = digest(method);
      var valid = reviewed.has(hash) || key === 'Sprite' && digest(yepSource) === hash &&
        yepPredecessor === PIXI.Container.prototype.updateTransform;
      if (valid) approved.add(method);
      graph.push({ prototype: proto, method: method });
    }
    // Admitted preparation callbacks update local presentation state only.
    var preparationHashes = {
      "Window": {
        "_updateCursor": [
          "a77e25d57e76cc0f5e1aa6882708e71a6c5e12e4e27916517f0ef6a070b44f59"
        ],
        "_updateArrows": [
          "da37860ee278f66bda8429edce0530bdfea95011a407aaaba80f17d62a72e975",
          "adcf781f35d354856a470be523bef78f50d022158bde803b6b1fa9122d4e09f7"
        ],
        "_updatePauseSign": [
          "647037b14332964b24f3e311f9c1594f53ce90353c0a066d711c478147da606f",
          "f2a783f854f0738c927db5ca4fe6f6d7d18bf6ac963dee08053aae0b8bf9a710"
        ],
        "_updateContents": [
          "9356942ccd393c4a101c9621344b1015b1ac842b737d5226d1a1bda17ffcfa2d"
        ],
        "isOpen": [
          "a327ecf5ced279f7d111ca8e5ba74f2bb61dfb45a375585a92cd04716cb8065c"
        ]
      },
      "Tilemap": {
        "_sortChildren": [
          "64357a55744a6dedad2a098e2faaedb1d2e96512326322ff470f8069bd6439bb"
        ],
        "_compareChildOrder": [
          "6224a1718ee087ea4ad7ea0924e5ffcae7b35323e8669afaeafa234735d6fcff"
        ],
        "_readMapData": [
          "e374a294caa62275df3645088c1c84dc8c302c80f71e80081b6705a3d44680b5"
        ]
      },
      "ShaderTilemap": {
        "_updateLayerPositions": [
          "844174ccf2450159afbfacc884f8df4ba39b38de06628bd4f6ae5f9560af96c5"
        ],
        "_paintAllTiles": [
          "eb620cfeb6d5c0dec8757f95fd1e8ba16f19d64d645e717b38593e533759307c"
        ],
        "_paintTiles": [
          "4c1866088809380fdf280ef25eb358eecc58841a9858069d164685be67a83daf"
        ],
        "_drawTile": [
          "589b5d8e5bbe0634990ed122102e59bdc4d7b9b733ddd2aab41c8a7fe0ea447f"
        ],
        "_drawNormalTile": [
          "333935c500ce73250962cdf061811dac8aa8fe963d2b4a2df1c647d5dd56e3c2"
        ],
        "_drawAutotile": [
          "0e0b9f1f7308e0fb0ec616eade2164d856490ee424d27214eb7d8f59cbbc2002"
        ],
        "_drawShadow": [
          "5baab8503394f0cfa4d54a159aac212dbc620c828f701f901c20ac7e469de990",
          "660d3891e32e600de0ce7365c31f0758cdc50a58161900ae5e639998a1a4dc93"
        ],
        "_drawTableEdge": [
          "bbfa6123dd1a1fe61c9fe08fbe219292e9deed881a44c282f158797222f45dec"
        ]
      }
    };
    var preparationPrototypes = { Window: Window.prototype, Tilemap: Tilemap.prototype, ShaderTilemap: ShaderTilemap.prototype };
    var preparationReady = true, preparationMethods = [];
    var preparationRefusals = [];
    for (var owner in preparationHashes) for (var name in preparationHashes[owner]) {
      var prototype = preparationPrototypes[owner], method = prototype[name];
      if (preparationHashes[owner][name].indexOf(digest(method)) < 0) {
        preparationReady = false; preparationRefusals.push(owner + '.' + name);
      }
      preparationMethods.push({ prototype: prototype, name: name, method: method });
    }
    var masterArrows = digest(Window.prototype._updateArrows) === "adcf781f35d354856a470be523bef78f50d022158bde803b6b1fa9122d4e09f7";
    var arrowPredecessor = globalThis.master2015hp && master2015hp.isatSnp && master2015hp.isatSnp.b_67;
    if (masterArrows && digest(arrowPredecessor) !== "da37860ee278f66bda8429edce0530bdfea95011a407aaaba80f17d62a72e975") {
      preparationReady = false; preparationRefusals.push('master arrow predecessor');
    }
    function rendererCallbacksAllowed(renderer) {
      if (typeof renderer.listeners !== 'function') return typeof renderer.emit !== 'function';
      var callbacks = renderer.listeners('prerender');
      var manager = renderer.filterManager;
      return callbacks.every(function(callback) { return manager && callback === manager._onPrerender; }) &&
        renderer.listeners('postrender').length === 0;
    }
    if (!preparationReady) {
      console.warn('[pmjs-isat] local map transforms unavailable: ' + preparationRefusals.join(', '));
      return;
    }
    var scenes = new WeakMap(), owners = new WeakMap(), active = null, renderers = new WeakSet();
    var lastReason = 'not-admitted';
    function refuse(reason) { lastReason = reason; }
    function invalidate(node, why) {
      var record = owners.get(node);
      if (record && !record.invalid) record.invalid = why;

    }
    var weatherEpoch = 0, weatherGraph = [], weatherNotifications = false;
    var weatherHashes = {"weatherEX_initialize": "826b5d30e0a258accca58fb36b2d0ac0198bdf450ea5138180173bd24f7f12ed", "clearWeatherEX": "e463b6b48ec048059b47f71914c4b72282e9baaeaffb45a8f1dfb9bc9de79030", "commandSetupWeather": "bc974b11b6d00ba4a845265278e4a3c076d70c23da5a9adf8cf873c5fecd38e7"};
    if (globalThis.Game_System && Object.keys(weatherHashes).every(function(name) {
      return digest(Game_System.prototype[name]) === weatherHashes[name];
    })) {
      weatherNotifications = true;
      Object.keys(weatherHashes).forEach(function(name) {
        var original = Game_System.prototype[name];
        var wrapped = Game_System.prototype[name] = function() {
          weatherEpoch++;
          if (active) invalidate(active.stage, 'weather-producer:' + name);
          return original.apply(this, arguments);
        };
        weatherGraph.push({ name: name, method: wrapped });
      });
    }
    ['addChild', 'addChildAt', 'removeChild', 'removeChildAt', 'removeChildren', 'setChildIndex', 'swapChildren'].forEach(function(name) {
      var original = PIXI.Container.prototype[name];
      if (typeof original !== 'function') return;
      PIXI.Container.prototype[name] = function() {
        invalidate(this, 'tree:' + name);
        return original.apply(this, arguments);
      };
    });
    ['filters', 'mask'].forEach(function(name) {
      var proto = PIXI.DisplayObject.prototype, descriptor = Object.getOwnPropertyDescriptor(proto, name);
      if (!descriptor || !descriptor.configurable || !descriptor.set) return;
      Object.defineProperty(proto, name, Object.assign({}, descriptor, { set: function(value) {
        invalidate(this, 'property:' + name); return descriptor.set.call(this, value);
      } }));
    });
    if (globalThis.Sprite && typeof Sprite.prototype.createHorrorFilter === 'function') {
      var createHorrorFilter = Sprite.prototype.createHorrorFilter;
      Sprite.prototype.createHorrorFilter = function() { invalidate(this, 'horror-filter'); return createHorrorFilter.apply(this, arguments); };
    }
    function filtersAllowed(node) {
      var filters = node._filters;
      if (!filters) return true;
      for (var index = 0; index < filters.length; index++) {
        var filter = filters[index];
        if (!filter || filter.enabled === false) continue;
        if (typeof WindowLayer === 'function' && node instanceof WindowLayer && filter === WindowLayer.voidFilter && node.filterArea) continue;
        return false;
      }
      return true;
    }
    function inventory(stage) {
      var record = { stage: stage, invalid: null, effects: [], instanceTransforms: [], refusals: [], localRenders: 0 };
      function walk(node) {
        var name = node.constructor && node.constructor.name || 'node';
        var hash = digest(node.updateTransform);
        if (!approved.has(node.updateTransform)) record.refusals.push(name + ':unknown-transform:' + hash);
        var ownTransform = Object.getOwnPropertyDescriptor(node, 'updateTransform');
        if (ownTransform) {
          // Disabling Pixi's bitmap cache restores the inherited method as an own property.
          if (!('value' in ownTransform) || ownTransform.value !== Object.getPrototypeOf(node).updateTransform) {
            record.refusals.push(name + ':own-transform');
          } else record.instanceTransforms.push({ node: node, method: ownTransform.value });
        }
        if (node._mask || node.mask) record.refusals.push(name + ':mask');
        if (node._cacheAsBitmap) record.refusals.push(name + ':cache');
        if (!filtersAllowed(node)) record.refusals.push(name + ':active-filter');
        if (node.shader) record.refusals.push(name + ':shader');
        if (PIXI.Text && node instanceof PIXI.Text || PIXI.extras && PIXI.extras.BitmapText && node instanceof PIXI.extras.BitmapText ||
            PIXI.mesh && PIXI.mesh.Mesh && node instanceof PIXI.mesh.Mesh) record.refusals.push(name + ':unreviewed-preparation');
        for (var owner in preparationHashes) {
          if (!(node instanceof classes[owner])) continue;
          for (var callback in preparationHashes[owner]) {
            if (node[callback] !== preparationPrototypes[owner][callback]) record.refusals.push(name + ':own-preparation:' + callback);
          }
        }
        if (node._filters) record.effects.push({ node: node, filters: node._filters });
        owners.set(node, record);
        var children = node.children || [];
        for (var index = 0; index < children.length; index++) walk(children[index]);
      }
      walk(stage);
      if (record.refusals.length) record.invalid = 'inventory';
      record.sunlight = admitSunlight(stage._spriteset);
      record.weatherEpoch = weatherEpoch;
      record.gameSystem = globalThis.$gameSystem;
      record.mapData = globalThis.$dataMap;
      record.commonEvents = globalThis.$dataCommonEvents;
      scenes.set(stage, record);
      return record;
    }
    function sunlightData(data) {
      return data && data.mode === 21 && data.power === 15 && data.speed === 100 &&
        data.blendMode === 1 && data.fileName === 'SunLight_01B' && data.z === 1 &&
        data.scale === 100 && data.frames === 1;
    }
    function admitSunlight(set) {
      var owner = set && set._weatherEXSprites && set._weatherEXSprites[0];
      var data = globalThis.$gameSystem && $gameSystem._weatherEX_Data && $gameSystem._weatherEX_Data[0];
      var allData = globalThis.$gameSystem && $gameSystem._weatherEX_Data;
      if (allData && allData.some(function(value, index) { return index > 0 && value && value.mode >= 0; })) return null;
      if (!owner || !globalThis.SpriteWeatherEX || Object.getPrototypeOf(owner) !== SpriteWeatherEX.prototype ||
          owner._id !== 0 || !sunlightData(data) || owner.parent !== set._weatherField_2 ||
          !owner._sprites || owner._sprites.length !== 15 || owner.children.length !== 15) return null;
      for (var index = 0; index < owner._sprites.length; index++) {
        var sprite = owner._sprites[index];
        if (owner.children[index] !== sprite || Object.getPrototypeOf(sprite) !== Sprite.prototype ||
            sprite.children.length || sprite.bitmap !== owner._image || sprite.blendMode !== 1) return null;
      }
      return { owner: owner, data: data, sprites: owner._sprites, image: owner._image };
    }
    function sunlightReason(set, record) {
      var admitted = record.sunlight, list = set._weatherEXSprites || [];
      if (record.weatherEpoch !== weatherEpoch || record.gameSystem !== globalThis.$gameSystem) return 'weather-producer';
      var fields = [set._weatherField_1, set._weatherField_2, set._weatherField_3];
      if (!admitted) {
        if (list.some(function(value) { return !!value; })) return 'weather-ex';
        for (var index = 0; index < fields.length; index++) {
          if (fields[index] && fields[index].children.length) return 'weather-live';
        }
        return null;
      }
      var owner = admitted.owner, data = globalThis.$gameSystem && $gameSystem._weatherEX_Data;
      if (!data || data[0] !== admitted.data || !sunlightData(data[0]) ||
          !weatherNotifications && data.some(function(value, index) { return index > 0 && value && value.mode >= 0; }) ||
          list[0] !== owner || list.some(function(value, index) { return index > 0 && !!value; }) ||
          owner._image !== admitted.image || owner._sprites !== admitted.sprites || owner._sprites.length !== 15 ||
          owner.children.length !== 15 || owner.parent !== fields[1]) return 'sunlight-changed';
      for (var index = 0; index < fields.length; index++) {
        var children = fields[index] && fields[index].children;
        if (children && (index === 1 ? children.length !== 1 || children[0] !== owner : children.length)) return 'weather-live';
      }
      return null;
    }
    function liveReason(stage, record) {
      if (record.invalid) return record.invalid;
      for (var index = 0; index < record.instanceTransforms.length; index++) {
        var instance = record.instanceTransforms[index];
        if (instance.node.updateTransform !== instance.method || instance.node._cacheAsBitmap) return 'instance-transform';
      }
      if (PMJS.isatSourceQualification !== qualification) return 'source-qualification';
      if (record.mapData !== globalThis.$dataMap || record.commonEvents !== globalThis.$dataCommonEvents) return 'event-data';
      if (!preparationReady) return 'preparation-source';
      for (var index = 0; index < preparationMethods.length; index++) {
        var callback = preparationMethods[index];
        if (callback.prototype[callback.name] !== callback.method) return 'preparation-method';
      }
      if (masterArrows && master2015hp.isatSnp.b_67 !== arrowPredecessor) return 'arrow-predecessor';
      if (!globalThis.$gameMap || $gameMap.mapId() !== 30 || !globalThis.SceneManager || SceneManager._scene !== stage ||
          Object.getPrototypeOf(stage) !== Scene_Map.prototype) return 'scene';
      if (SceneManager._nextScene || stage._fadeDuration > 0 || stage._encounterEffectDuration > 0 ||
          globalThis.$gamePlayer && $gamePlayer.isTransferring() ||
          globalThis.EncounterEffect && EncounterEffect.isRunning && EncounterEffect.isRunning()) return 'transition';
      if ($gameMap.isEventRunning() || globalThis.$gameTemp && $gameTemp.isManipulatingHud) return 'event-or-hud';
      var screen = globalThis.$gameScreen, set = stage._spriteset;
      if (weatherNotifications) for (var index = 0; index < weatherGraph.length; index++) {
        var producer = weatherGraph[index];
        if (Game_System.prototype[producer.name] !== producer.method) return 'weather-method';
      }
      if (!screen || screen.zoomScale() !== 1 || screen._zoomDuration > 0 || !set ||
          set.scale.x !== 1 || set.scale.y !== 1) return 'zoom-or-spriteset';
      var tone = screen.tone();
      if (!tone || tone[0] || tone[1] || tone[2] || tone[3]) return 'tone';
      var weather = set._weather;
      if (weather && (weather.type !== 'none' || weather._sprites && weather._sprites.length)) return 'weather';
      var weatherReason = sunlightReason(set, record);
      if (weatherReason) return weatherReason;
      for (var index = 0; index < record.effects.length; index++) {
        var effect = record.effects[index];
        if (effect.node._filters !== effect.filters || !filtersAllowed(effect.node)) return 'effect';
      }
      for (var index = 0; index < graph.length; index++) {
        if (graph[index].prototype.updateTransform !== graph[index].method) return 'transform-graph';
      }
      if (yepPredecessor && Yanfly.Core.Sprite_updateTransform !== yepPredecessor) return 'yep-predecessor';
      return null;
    }
    function restore(context) {
      var current = PMJS.pixi4.getStageRenderOptions(context.stage);
      if (!current || current.worldState !== 'local') return false;
      var restored = Object.assign({}, current);
      if (context.hadWorldState) restored.worldState = context.worldState;
      else delete restored.worldState;
      if (Object.keys(restored).length) {
        if (!Object.prototype.hasOwnProperty.call(restored, 'worldState')) restored.worldState = 'native';
        PMJS.pixi4.setStageRenderOptions(context.stage, restored);
      } else PMJS.pixi4.setStageRenderOptions(context.stage, null);
      return true;
    }
    function suspend(context) {
      if (context.record.invalid) return;
      var current = PMJS.pixi4.getStageRenderOptions(context.stage);
      PMJS.pixi4.setStageRenderOptions(context.stage, Object.assign({}, current, { worldState: 'local' }));
    }
    function installRenderer(renderer) {
      if (!renderer || renderers.has(renderer)) return;
      renderers.add(renderer);
      var render = renderer.render;
      renderer.render = function(stage, renderTexture, clear, transform, skipUpdateTransform) {
        if (active) {
          var outer = active; active = null;
          var restored = restore(outer);
          var before = PMJS.pixi4.getStageRenderOptions(outer.stage);
          var worldState = before ? before.worldState : 'native';
          try { return render.apply(this, arguments); }
          finally {
            var current = PMJS.pixi4.getStageRenderOptions(outer.stage);
            // A nested render can install its own world mode or remove the policy.
            if (restored && (current ? current.worldState : 'native') === worldState) suspend(outer);
            active = outer;
          }
        }
        if (renderTexture || transform || skipUpdateTransform || !stage || !globalThis.Scene_Map ||
            Object.getPrototypeOf(stage) !== Scene_Map.prototype || !globalThis.$gameMap || $gameMap.mapId() !== 30) {
          return render.apply(this, arguments);
        }
        var record = scenes.get(stage);
        if (!record) {
          if ($gameMap.isEventRunning() || globalThis.$gameTemp && $gameTemp.isManipulatingHud ||
              globalThis.ImageManager && !ImageManager.isReady()) {
            refuse('admission-not-ready'); return render.apply(this, arguments);
          }
          record = inventory(stage);
        }
        var reason = rendererCallbacksAllowed(this) ? liveReason(stage, record) : 'renderer-callback';
        if (reason) { refuse(reason); return render.apply(this, arguments); }
        var options = PMJS.pixi4.getStageRenderOptions(stage);
        var context = { stage: stage, record: record,
          hadWorldState: !!options && Object.prototype.hasOwnProperty.call(options, 'worldState'),
          worldState: options && options.worldState };
        active = context; suspend(context);
        try {
          var result = render.apply(this, arguments);
          record.localRenders++; lastReason = null;
          return result;
        } finally { restore(context); active = null; }
      };
    }
    var renderGraphics = Graphics.render;
    Graphics.render = function() { installRenderer(this._renderer); return renderGraphics.apply(this, arguments); };
    PMJS.isatMapTransforms = { diagnostics: function(stage) {
      var record = scenes.get(stage);
      return { localRenders: record ? record.localRenders : 0,
        reason: record && record.invalid || lastReason };
    } };
  });
})();

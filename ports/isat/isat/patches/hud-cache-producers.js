'use strict';

(function() {
  var id = 'isat.dormont-bitmap-cache-producers';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary bitmap-cache preparation' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.hud-cache-producers', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified HUD cache producers');
      return;
    }
    var crypto = __pmjsBuiltinRequire('crypto');
    function hash(source) {
      return crypto.createHash('sha256').update(source.replace(/\r\n/g, '\n')).digest('hex');
    }
    var producer = typeof MapHUD === 'function' && MapHUD.prototype.updateVisibility;
    var mapReady = qualification.dormontDataVerified === true && typeof producer === 'function' &&
      PMJS.isatMethodHash(producer) ===
        '9168991577fa8d790c99900b297737426d8994f98bfb030a5da7a3d590ad2976';
    var battleProducer = typeof BattleHUD === 'function' && BattleHUD.prototype.updateVisibility;
    var battleScene = globalThis.Scene_Battle;
    var battleReady = typeof Scene_Battle === 'function' && typeof battleProducer === 'function' &&
      PMJS.isatMethodHash(battleProducer) ===
        'd47f7cbb9ced6396a05994c37693ecf2dc54b756d88ef892ea1175d45ce8e9eb';
    if (battleReady) {
      try {
        battleReady = hash(NativeHost.fs.readText('data/BattleHUD.json')) ===
          '4f53cda18c2baa0c0354bb5f9a3ecbe5ed12ab4d8e11ba873c2f11161202b945';
      } catch (_) { battleReady = false; }
    }
    if (!mapReady && !battleReady) {
      PMJS.optimizations.refuse(id, 'unrecognized MapHUD cache producer');
      return;
    }
    var policies = new WeakMap(), states = new WeakMap(), configureCalls = 0;
    PMJS.isatHudCacheProducers = { diagnostics: function(scene) {
      var state = states.get(scene);
      var previous = policies.get(scene);
      var current = scene && PMJS.pixi4.getStageRenderOptions(scene);
      return { mapReady: mapReady, battleReady: battleReady, configureCalls: configureCalls,
        sceneConfigureCalls: state && state.calls || 0, reason: state && state.reason || (state ? null : 'not-configured'),
        installed: !!(previous && current && current.bitmapCacheProducers === previous.installed) };
    } };
    function restore(scene) {
      var previous = policies.get(scene);
      if (!previous) return;
      var current = PMJS.pixi4.getStageRenderOptions(scene);
      var state = states.get(scene);
      if (state) state.reason = current && current.bitmapCacheProducers === previous.installed ? 'policy-restored' : 'foreign-policy-replaced';
      if (current && current.bitmapCacheProducers === previous.installed) {
        var options = Object.assign({}, current);
        if (previous.present) options.bitmapCacheProducers = previous.value;
        else delete options.bitmapCacheProducers;
        if (!previous.hadOptions && Object.keys(options).length === 1 && options.worldState === 'native') {
          PMJS.pixi4.setStageRenderOptions(scene, null);
        } else PMJS.pixi4.setStageRenderOptions(scene, options);
      }
      policies.delete(scene);
    }
    function admitMap(scene) {
      if (!mapReady || $gameMap.mapId() !== 30) return { reason: 'scene-ineligible' };
      var hud = scene._hud;
      if (!hud || hud.constructor !== MapHUD || hud.updateVisibility !== producer) return { reason: 'hud-producer' };
      var map = $gameMap, data = $dataMap, common = $dataCommonEvents;
      return { hud: hud, HUD: MapHUD, valid: function() {
        return scene._hud === hud && hud.constructor === MapHUD && hud.updateVisibility === producer &&
          MapHUD.prototype.updateVisibility === producer && $gameMap === map && map.mapId() === 30 &&
          $dataMap === data && $dataCommonEvents === common;
      } };
    }
    function admitBattle(scene) {
      var owner = globalThis.$gameTroop, troop = owner && owner.troop();
      if (!battleReady || !troop || troop.id !== 26) return { reason: 'scene-ineligible' };
      if (globalThis.Scene_Battle !== battleScene || Object.getPrototypeOf(scene) !== battleScene.prototype) return { reason: 'battle-prototype' };
      var hud = scene._hud;
      if (!hud || hud.constructor !== BattleHUD || hud.updateVisibility !== battleProducer ||
          Object.getPrototypeOf(hud) !== BattleHUD.prototype) return { reason: 'hud-producer' };
      var data = globalThis.$dataBattleHUD;
      if (!Array.isArray(data) || data.length !== 0) return { reason: 'battle-data' };
      var HUD = BattleHUD;
      return { hud: hud, HUD: HUD, valid: function() {
        return scene._hud === hud && hud.constructor === HUD && hud.updateVisibility === battleProducer &&
          HUD.prototype.updateVisibility === battleProducer && globalThis.BattleHUD === HUD &&
          Object.getPrototypeOf(hud) === HUD.prototype && globalThis.Scene_Battle === battleScene &&
          Object.getPrototypeOf(scene) === battleScene.prototype && $gameTroop === owner &&
          $gameTroop.troop() === troop && troop.id === 26 && globalThis.$dataBattleHUD === data && data.length === 0;
      } };
    }
    function configure(scene, battle) {
      restore(scene);
      configureCalls++;
      var priorState = states.get(scene);
      var state = { calls: (priorState && priorState.calls || 0) + 1, reason: null };
      states.set(scene, state);
      function reject(reason) { state.reason = reason; }
      var admission = battle ? admitBattle(scene) : admitMap(scene);
      if (admission.reason) return reject(admission.reason);
      var hud = admission.hud, HUD = admission.HUD;
      // The reviewed map/plugin composition has exactly this possible producer.
      // Reject a retained or foreign HUD even when its cache is currently inactive.
      var extra = false;
      function inspect(node) {
        if (!node || extra) return;
        if ((typeof MapHUD === 'function' && node instanceof MapHUD || node instanceof HUD) && node !== hud) { extra = true; return; }
        var children = node.children || [];
        for (var i = 0; i < children.length; i++) inspect(children[i]);
      }
      inspect(scene);
      if (extra) return reject('extra-hud');
      var policy = { nodes: [hud], valid: function(stage) {
        return stage === scene && SceneManager._scene === scene &&
          PMJS.isatSourceQualification === qualification && admission.valid();
      } };
      var current = PMJS.pixi4.getStageRenderOptions(scene);
      var previous = { hadOptions: !!current, present: !!current && Object.prototype.hasOwnProperty.call(current, 'bitmapCacheProducers'),
        value: current && current.bitmapCacheProducers };
      PMJS.pixi4.setStageRenderOptions(scene,
        Object.assign({ worldState: 'native' }, current, { bitmapCacheProducers: policy }));
      previous.installed = PMJS.pixi4.getStageRenderOptions(scene).bitmapCacheProducers;
      policies.set(scene, previous);
    }
    function installLifecycle(prototype, method, battle) {
      var create = prototype[method];
      prototype[method] = function() {
        var result = create.apply(this, arguments);
        configure(this, battle);
        return result;
      };
      var terminate = prototype.terminate;
      prototype.terminate = function() {
        restore(this);
        return terminate.apply(this, arguments);
      };
    }
    if (mapReady) installLifecycle(Scene_Map.prototype, 'createDisplayObjects', false);
    if (battleReady) installLifecycle(Scene_Battle.prototype, 'start', true);
  });
})();

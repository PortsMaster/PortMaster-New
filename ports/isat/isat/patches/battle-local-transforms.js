'use strict';

(function() {
  var id = 'isat.bourdon-local-transforms';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat', fallback: 'ordinary battle world-transform preparation' });
  PMJS.phases.on('beforeBoot', 'pmjs.isat.battle-local-transforms', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!PMJS.optimizations.isEnabled(id) || !qualification || !qualification.verified) return;
    function matches(method, expected) {
      if (typeof method !== 'function') return false;
      var hash = PMJS.isatMethodHash(method);
      return (Array.isArray(expected) ? expected : [expected]).indexOf(hash) >= 0;
    }
    var container = PIXI.Container.prototype.updateTransform, sprite = Sprite.prototype.updateTransform;
    var windowTransform = Window.prototype.updateTransform, faceTransform = Window_BattleStatus.prototype.updateTransform;
    var faceContents = Window_BattleStatus.prototype.updateFaceContents;
    var tiling = TilingSprite.prototype.updateTransform;
    if (!matches(container, '1a091756d85883232da57aa53141f43968c21abfc58b6b231a46c0faa9014861') ||
        !matches(sprite, '866ba21d861bf698e1a5ef3d034a58f8453b55fe618be6596beb29cd6b473429') ||
        !matches(windowTransform, 'cfcbeacef1f4ca9ed869519fdba23e734e6e70e75bce5b05bb75718e6fea548a') ||
        !matches(faceTransform, 'cd4de4fc15070a40391f9d83441cad6ec0c4f0c0de750077eb7d6ee180d61e9b') ||
        !matches(faceContents, 'a65e8bc34deb1695087b0ed37be40ab4c004e9d0130f26c55bd99ca17f70707f') ||
        !matches(tiling, '387766129c695c855bf5a624b0dd29893b5188d97f812d310ff6a7aa41979f8a')) {
      PMJS.optimizations.refuse(id, 'unrecognized battle transform hooks'); return;
    }
    var preparation = {
      _updateCursor: ['3cd215fcefb0811c8bded097aa4f94ea3e2f320f35f7db9ac385232186bf027b'],
      _updateArrows: ['f22a3f57cd8ecd7fa97860cdb1c90cd89f74dd1cbe38718aab423556574217f5',
        '84e126939b66b8a8dd33f8b9789917285c4e3164029fdc3d578036de87256923'],
      _updatePauseSign: ['ae29cd24d4b3d406e92e302d2901dad4ec5d00367fb0883fe5b4ff55afbc43f7',
        'c4e17a506604483ea089ea66f2397355a0a53470079d7efc0e3d2452c310d35f'],
      _updateContents: ['24f637291593ed4f2e7afb4cf23c5278a2be1ac224fe6bd82b07edc1c2c7a2f1'],
      isOpen: ['de6e8974f6ffcc880d122d5f97b5d75e1559bf42e23835b1664a897121473105']
    };
    var callbacks = {};
    for (var name in preparation) {
      callbacks[name] = Window.prototype[name];
      if (!matches(callbacks[name], preparation[name])) {
        PMJS.optimizations.refuse(id, 'unrecognized window preparation: ' + name); return;
      }
    }
    var arrowPredecessor = globalThis.master2015hp && master2015hp.isatSnp.b_67;
    if (arrowPredecessor && !matches(arrowPredecessor, preparation._updateArrows[0])) return;
    if (arrowPredecessor) {
      callbacks.arrowBitmapReady = Window.prototype.arrowBitmapReady;
      if (!matches(callbacks.arrowBitmapReady, '2d813330b4d954885a03f59ea7db8fea2f88002f60c45496700020c319e5d65d')) {
        PMJS.optimizations.refuse(id, 'unrecognized arrow bitmap preparation'); return;
      }
    }
    var approved = new Set([container, sprite, windowTransform, faceTransform, tiling]);
    var renderers = new WeakSet(), active = null, localRenders = 0, fallbacks = 0, lastReason = null;
    function inspect(node, parent, faces, windowChild, parentDraws) {
      // Native preparation skips hidden branches; a Window can expose its own children.
      if (node && node.visible === false && !windowChild) return null;
      if (!node || !approved.has(node.updateTransform)) return 'unknown-transform';
      var owner = node.parent, alpha = node.alpha;
      if (owner instanceof Window) {
        if (node === owner._windowCursorSprite) alpha = Math.max(alpha, owner.contentsOpacity / 255);
        if (node === owner._windowPauseSignSprite) alpha = owner.pause ? 1 : 0;
      }
      var draws = parentDraws !== false && alpha > 0;
      if (node.updateTransform === tiling && node.updateTransformTS !== container) return 'tiling-predecessor';
      if (node.mask || node._cacheAsBitmap || node.shader) return 'advanced-rendering';
      var filters = node._filters || [];
      for (var i = 0; i < filters.length; i++) {
        var filter = filters[i];
        if (filter && filter.enabled !== false &&
            !(node instanceof WindowLayer && filter === WindowLayer.voidFilter && node.filterArea)) return 'filter';
      }
      if (node instanceof Window) {
        for (var key in callbacks) if (node[key] !== callbacks[key]) return 'window-preparation';
        if (arrowPredecessor && node.isOpen() && (node.upArrowVisible || node.downArrowVisible)) return 'animated-window-arrows';
      }
      if (node.updateTransform === faceTransform) {
        if (node.updateFaceContents !== faceContents) return 'portrait-preparation';
        faces.push(node);
      }
      var transform = node.transform;
      if (!transform || typeof transform.updateLocalTransform !== 'function') return 'transform';
      transform.updateLocalTransform();
      var local = transform.localTransform;
      var world = {
        a: parent.a * local.a + parent.c * local.b, b: parent.b * local.a + parent.d * local.b,
        c: parent.a * local.c + parent.c * local.d, d: parent.b * local.c + parent.d * local.d,
        tx: parent.a * local.tx + parent.c * local.ty + parent.tx,
        ty: parent.b * local.tx + parent.d * local.ty + parent.ty
      };
      // Local composition must not bypass Yanfly's observable translation rounding.
      if (draws && node.updateTransform === sprite &&
          (!Number.isInteger(world.tx) || !Number.isInteger(world.ty))) {
        // Reviewed Window preparation keeps disabled arrows hidden, including odd-width gauges.
        var hiddenArrow = owner instanceof Window &&
          (node === owner._upArrowSprite && (!owner.isOpen() || !owner.upArrowVisible) ||
           node === owner._downArrowSprite && (!owner.isOpen() || !owner.downArrowVisible));
        if (!hiddenArrow) return 'fractional-sprite-position';
      }
      var children = node.children || [];
      for (var index = 0; index < children.length; index++) {
        var reason = inspect(children[index], world, faces, node instanceof Window, draws);
        if (reason) return reason;
      }
      return null;
    }
    function restore(context) {
      var current = PMJS.pixi4.getStageRenderOptions(context.stage);
      if (!current || current.worldState !== 'local') return;
      var options = Object.assign({}, current);
      if (context.present) options.worldState = context.worldState;
      else delete options.worldState;
      if (Object.keys(options).length) {
        if (!Object.prototype.hasOwnProperty.call(options, 'worldState')) options.worldState = 'native';
        PMJS.pixi4.setStageRenderOptions(context.stage, options);
      } else PMJS.pixi4.setStageRenderOptions(context.stage, null);
    }
    function foreignCallbacks(renderer) {
      if (typeof renderer.listeners !== 'function') return typeof renderer.emit === 'function';
      return renderer.listeners('postrender').length > 0 || renderer.listeners('prerender').some(function(callback) {
        return !renderer.filterManager || callback !== renderer.filterManager._onPrerender;
      });
    }
    function install(renderer) {
      if (!renderer || renderers.has(renderer)) return;
      renderers.add(renderer);
      var render = renderer.render;
      renderer.render = function(stage, texture, clear, transform, skip) {
        if (active) {
          var outer = active; active = null; restore(outer);
          try { return render.apply(this, arguments); }
          finally { active = outer; }
        }
        if (texture || transform || skip || !stage || Object.getPrototypeOf(stage) !== Scene_Battle.prototype ||
            SceneManager._scene !== stage || !globalThis.$gameTroop || $gameTroop._troopId !== 26 ||
            PMJS.isatSourceQualification !== qualification || SceneManager._nextScene || stage._fadeDuration > 0 ||
            !PMJS.isatHorrorPresentation || !PMJS.isatHorrorPresentation.isInactive() ||
            globalThis.EncounterEffect && EncounterEffect.isRunning()) return render.apply(this, arguments);
        var options = PMJS.pixi4.getStageRenderOptions(stage);
        if (options && options.worldState !== 'pixi') return render.apply(this, arguments);
        var faces = [], reason = null;
        if (Yanfly.Core.Sprite_updateTransform !== container || Window_Selectable.prototype.updateTransform !== windowTransform ||
            arrowPredecessor && master2015hp.isatSnp.b_67 !== arrowPredecessor) reason = 'transform-predecessor';
        else if (foreignCallbacks(this)) reason = 'renderer-callback';
        else reason = inspect(stage, { a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0 }, faces);
        if (reason) { lastReason = reason; fallbacks++; return render.apply(this, arguments); }
        var context = { stage: stage, present: !!options && Object.prototype.hasOwnProperty.call(options, 'worldState'),
          worldState: options && options.worldState };
        active = context;
        try {
          for (var index = 0; index < faces.length; index++) faceContents.call(faces[index]);
          PMJS.pixi4.setStageRenderOptions(stage, Object.assign({}, options, { worldState: 'local' }));
          var result = render.apply(this, arguments);
          localRenders++; lastReason = null;
          return result;
        } finally { restore(context); active = null; }
      };
    }
    var renderGraphics = Graphics.render;
    Graphics.render = function() { install(this._renderer); return renderGraphics.apply(this, arguments); };
    PMJS.isatBattleTransforms = { diagnostics: function() { return { localRenders: localRenders, fallbacks: fallbacks, reason: lastReason }; } };
  });
})();

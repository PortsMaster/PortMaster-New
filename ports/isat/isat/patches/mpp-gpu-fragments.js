'use strict';

PMJS.isatSourcePatches.register('js/plugins/MPP_EncounterEffect.js', 'Native GPU encounter presenter', (src) => {
  const marker = '/* pmjs-isat: native encounter */';
  if (src.includes(marker)) return null;
  const call = 'EncounterEffect.setup(SceneManager.snap(), type)';
  const end = /\}\)\(\);\s*$/;
  if (src.split(call).length !== 2 || !end.test(src)) return src;
  const newline = src.includes('\r\n') ? '\r\n' : '\n';
  return src.replace(call,
    'EncounterEffect.setup(pmjsMppNative ? EncounterEffect.captureSnapshot(this, type) : SceneManager.snap(), type)')
    .replace(end, [
      'var pmjsMppNative = globalThis.PMJS && typeof PMJS.installMppGpuFragments === "function" &&',
      '    PMJS.installMppGpuFragments(EncounterEffect, MPPlugin, Sprite_Fragment.FlashRate, Encounter_Fragment);',
      marker,
      '})();',
      ''
    ].join(newline));
}, 'optimization');

(function() {
  var id = 'plugins.mpp.gpu-fragments';
  var installed = false;
  PMJS.optimizations.register({ id: id, owner: 'port/mpp-gpu-fragments',
    fallback: 'MPP Canvas snapshot and fragments' });
  PMJS.phases.on('afterGuestPlugins', 'port.mpp-gpu-fragments', function() {
    if (!installed) {
      PMJS.optimizations.refuse(id, 'MPP GPU fragment integration was not installed');
    }
  });

  function stats() {
    return globalThis.__isatMppGpuFragmentStats ||
      (globalThis.__isatMppGpuFragmentStats = {
        captures: 0, captureMs: 0, fragments: 0, destroys: 0
      });
  }

  PMJS.installMppGpuFragments = function(effect, plugin, flashRate, Fragment) {
    if (!PMJS.optimizations.isEnabled(id)) return null;
    var map = globalThis.Scene_Map;
    var base = globalThis.Scene_Base;
    if (!map || !base || !PMJS.pixi4 ||
        !PMJS.plugins.mpp || typeof PMJS.plugins.mpp.setTriangleBitmap !== 'function' ||
        typeof PMJS.pixi4.createGpuStandaloneBitmapRegion !== 'function' ||
        typeof PMJS.pixi4.getStageRenderOptions !== 'function' ||
        typeof PMJS.pixi4.setStageRenderOptions !== 'function' ||
        !PMJS.pixi4.supportsGpuSpriteTextures ||
        typeof PMJS.plugins.mpp.clearBackground !== 'function' ||
        typeof map.prototype.launchBattle !== 'function' ||
        typeof base.prototype.createEncEffSprites !== 'function' ||
        !Fragment || typeof Fragment.prototype.createBitmap !== 'function' ||
        typeof Fragment.prototype.initFrame !== 'function' ||
        typeof Fragment.prototype.setSnap !== 'function' ||
        typeof effect.fragments !== 'function' ||
        typeof effect.clear !== 'function') {
      PMJS.optimizations.refuse(id, 'MPP GPU fragment composition is unavailable');
      return null;
    }
    effect.gpuFragments = function() { return this._isatGpuActive === true; };
    var createBitmap = Fragment.prototype.createBitmap;
    var initFrame = Fragment.prototype.initFrame;
    var setSnap = Fragment.prototype.setSnap;
    Fragment.prototype.createBitmap = function() {
      if (!effect.gpuFragments()) return createBitmap.apply(this, arguments);
      var fragment = this;
      this.bitmap = { _context: {
        save: function() {}, restore: function() {}, clip: function() {}, stroke: function() {},
        drawImage: function(_image, x, y) {
          fragment._isatSnapX = x;
          fragment._isatSnapY = y;
        }
      } };
    };
    Fragment.prototype.initFrame = function() {
      if (!effect.gpuFragments()) return initFrame.apply(this, arguments);
    };
    Fragment.prototype.setSnap = function(snap) {
      if (effect.gpuFragments()) {
        this._isatGpuSnap = snap;
        this._isatGpuColor = effect._color.slice();
      }
      return setSnap.apply(this, arguments);
    };
    var originalSort = effect.sortFragment;
    effect.sortFragment = function(direction) {
      if (!this.gpuFragments()) return originalSort.apply(this, arguments);
      var fragments = this._data;
      var descriptor = Object.getOwnPropertyDescriptor(fragments, 'sort');
      Object.defineProperty(fragments, 'sort', {
        configurable: true, value: function(compare) {
          return PMJS.plugins.mpp.sortFragments(this, compare);
        }
      });
      try {
        return originalSort.call(this, direction);
      } finally {
        if (descriptor) Object.defineProperty(fragments, 'sort', descriptor);
        else delete fragments.sort;
      }
    };
    function spriteTransformCompatible() {
      var stock = PIXI.Sprite && PIXI.Sprite.prototype.updateTransform;
      var yep = globalThis.Yanfly && Yanfly.Core;
      return Sprite.prototype.updateTransform === stock ||
        !!(yep && yep.Sprite_updateTransform === stock);
    }
    var originalLaunch = map.prototype.launchBattle;
    var originalCreate = base.prototype.createEncEffSprites;
    var authoredNeedClip = null;
    var worldStateScenes = new Map();
    effect.gpuFragmentsFor = function(type) {
      if (!PMJS.isatSourceQualification || PMJS.isatSourceQualification.verified !== true ||
          !PMJS.optimizations.isEnabled('sprite.native-tint') || !spriteTransformCompatible() || (type !== 1 && type !== 3) || !Graphics._renderer ||
          typeof Graphics._renderer.generateTextureGpu !== 'function') {
        return false;
      }
      if (type === 1) return !!(PMJS.plugins.mpp.supportsPolygonBitmaps && Graphics.isWebGL() && PIXI.mesh && PIXI.mesh.Mesh &&
        typeof PMJS.plugins.mpp.setPolygonBitmap === 'function' &&
        typeof PMJS.plugins.mpp.clearBackgroundPolygons === 'function' && plugin.TypeParams && plugin.TypeParams[1]);
      var params = plugin.TypeParams && plugin.TypeParams[3];
      return !!(Graphics.isWebGL() && PIXI.mesh && PIXI.mesh.Mesh && params &&
        params['Shape Type'] === 1 && params['Split X'] === 10 && params['Split Y'] === 6);
    };
    effect.captureGpuSnap = function(stage) {
      var started = performance.now();
      var texture = null;
      try {
        texture = Graphics._renderer.generateTextureGpu(stage,
          PIXI.SCALE_MODES.NEAREST, 1,
          new PIXI.Rectangle(0, 0, Graphics.width, Graphics.height));
        stage.worldTransform.identity();
      } catch (error) {
        if (texture) texture.destroy({ destroyBase: true });
        throw error;
      }
      var counters = stats();
      counters.captures++;
      counters.captureMs += performance.now() - started;
      this.NeedClip = false;
      return texture;
    };
    effect.captureSnapshot = function(stage, type) {
      this._isatGpuActive = false;
      if (this.gpuFragmentsFor(type)) {
        var snapshot = null;
        var needClip = this.NeedClip;
        try {
          snapshot = this.captureGpuSnap(stage);
        } catch (error) {
          console.warn('GPU encounter capture failed; using canvas fragments', error);
        }
        if (snapshot) {
          this._isatGpuSnap = snapshot;
          this._isatGpuActive = true;
          return snapshot;
        }
        this.NeedClip = needClip;
      }
      return SceneManager.snap();
    };
    map.prototype.launchBattle = function() {
      if (authoredNeedClip === null) authoredNeedClip = effect.NeedClip;
      effect.NeedClip = authoredNeedClip;
      return originalLaunch.apply(this, arguments);
    };
    base.prototype.createEncEffSprites = function() {
      if (!effect.gpuFragments()) return originalCreate.apply(this, arguments);
      this._encEffContainer = new Sprite();
      this._encEffContainer.bitmap = null;
      var presenter = new Presenter(effect.fragments());
      presenter.__isatMppGpuPresentation = true;
      this._encEffContainer.addChild(presenter);
      this.addChild(this._encEffContainer);
      this.testSprite = presenter;
      if (presenter && presenter._background) {
        if (!worldStateScenes.has(this)) {
          var previous = PMJS.pixi4.getStageRenderOptions(this);
          worldStateScenes.set(this, { hadWorldState: !!previous && Object.prototype.hasOwnProperty.call(previous, 'worldState'),
            worldState: previous && previous.worldState });
          PMJS.pixi4.setStageRenderOptions(this, Object.assign({}, previous, { worldState: 'pixi' }));
        }
        var background = this._encEffContainer.__isatMppGpuBackground;
        if (background) background.visible = false;
        presenter._background.visible = this instanceof map;
      }
    };
    var clearEffect = effect.clear;
    effect.clear = function() {
      // Scene startup can install independent rendering policies during the handoff.
      worldStateScenes.forEach(function(previous, scene) {
        var current = PMJS.pixi4.getStageRenderOptions(scene);
        if (!current || current.worldState !== 'pixi') return;
        var restored = Object.assign({}, current);
        if (previous.hadWorldState) restored.worldState = previous.worldState;
        else delete restored.worldState;
        if (Object.keys(restored).length) {
          if (!Object.prototype.hasOwnProperty.call(restored, 'worldState')) restored.worldState = 'native';
          PMJS.pixi4.setStageRenderOptions(scene, restored);
        } else PMJS.pixi4.setStageRenderOptions(scene, null);
      });
      worldStateScenes.clear();
      var snapshot = this._isatGpuSnap;
      this._isatGpuSnap = null;
      this._isatGpuActive = false;
      if (snapshot) {
        snapshot.destroy({ destroyBase: true });
        stats().destroys++;
      }
      return clearEffect.apply(this, arguments);
    };
    installed = true;
    var Presenter = createPresenter(effect, plugin, flashRate, function() {
      return authoredNeedClip === null ? effect.NeedClip : authoredNeedClip;
    });
    return Presenter;
  };

  function createPresenter(effect, plugin, flashRate, needsClip) {
    var retainedPresenter = null;
    function releaseFlashAtlases(presenter) {
      if (!presenter._flashAtlases) return;
      presenter._flashAtlases.forEach(function(entry) { entry.texture.destroy(true); });
      presenter._flashAtlases.clear();
    }
    var originalClear = effect.clear;
    effect.clear = function() {
      if (retainedPresenter && retainedPresenter._atlas) {
        PMJS.pixi4.releaseSceneResources(retainedPresenter);
        releaseFlashAtlases(retainedPresenter);
        retainedPresenter._atlas.destroy(true);
        if (retainedPresenter._backgroundTexture) retainedPresenter._backgroundTexture.destroy(true);
        retainedPresenter._backgroundTexture = null;
        retainedPresenter._atlas = null;
      }
      retainedPresenter = null;
      return originalClear.apply(this, arguments);
    };
    function GpuPresenter(fragments) {
      if (retainedPresenter && retainedPresenter._fragments === fragments) {
        retainedPresenter._items.forEach(function(item) {
          item.flashDuration = 0;
          item.flashColor = [0, 0, 0, 0];
          item.image.texture = item.texture;
          item.image._blendColor = item.flashColor;
        });
        retainedPresenter.update();
        var counters = stats();
        counters.handoffs = (counters.handoffs || 0) + 1;
        return retainedPresenter;
      }
      try {
        this.initialize(fragments);
      } catch (error) {
        // These textures and meshes belong solely to the failed presenter.
        PMJS.pixi4.releaseSceneResources(this);
        releaseFlashAtlases(this);
        if (this._items) this._items.forEach(function(item) {
          PMJS.pixi4.releaseSceneResources(item.image);
          item.image.destroy();
        });
        if (this._backgroundTexture) this._backgroundTexture.destroy(true);
        if (this._atlas) this._atlas.destroy(true);
        throw error;
      }
      retainedPresenter = this;
    }
    GpuPresenter.prototype = Object.create(Sprite.prototype);
    GpuPresenter.prototype.constructor = GpuPresenter;
    GpuPresenter.prototype.initialize = function(fragments) {
      Sprite.prototype.initialize.call(this);
      PMJS.pixi4.setStageRenderOptions(this, { worldState: 'pixi' });
      this._fragments = fragments;
      this._items = [];
      this._flashAtlases = new Map();
      this._broken = fragments.map(function() { return false; });
      this._clipBackground = needsClip();
      this._polygonFragments = effect.type === 1;
      var texture = fragments[0]._isatGpuSnap;
      var zoom = effect.Zoom;

      for (var index = 0; index < fragments.length; index++) {
        var fragment = fragments[index], frame = fragment._frame;
        var rect = fragment.rect();
        var bitmapWidth = Math.ceil(rect.width / zoom) + 2;
        var bitmapHeight = Math.ceil(rect.height / zoom) + 2;
        var anchorX = fragment.anchorX(), anchorY = fragment.anchorY();
        var vertices = new Float32Array(frame.length * 2);
        for (var point = 0; point < frame.length; point++) {
          var at = point * 2;
          vertices[at] = frame[point].x / zoom;
          vertices[at + 1] = frame[point].y / zoom;
        }
        // Preserve the authored path coordinates through stroke outline construction.
        var left = rect.x / zoom - 1, top = rect.y / zoom - 1;
        var bounds = [left, top, left + bitmapWidth, top + bitmapHeight];
        var quad = new Float32Array([bounds[0], bounds[1], bounds[2], bounds[1],
          bounds[2], bounds[3], bounds[0], bounds[3]]);
        var quadUvs = new Array(8);
        for (var corner = 0; corner < 4; corner++) {
          quadUvs[corner * 2] = (fragment._isatSnapX +
            (quad[corner * 2] - left - 1) * zoom) / Graphics.width;
          quadUvs[corner * 2 + 1] = (fragment._isatSnapY +
            (quad[corner * 2 + 1] - top - 1) * zoom) / Graphics.height;
        }
        var image = new PIXI.mesh.Mesh(texture, quad, quadUvs,
          new Uint16Array([0, 1, 2, 0, 2, 3]), PIXI.mesh.Mesh.DRAW_MODES.TRIANGLES);
        PMJS.pixi4.retainMeshGeometry(image);
        image.uploadUvTransform = true;
        var color = fragment._isatGpuColor;
        var paint = this._polygonFragments ? PMJS.plugins.mpp.setPolygonBitmap : PMJS.plugins.mpp.setTriangleBitmap;
        paint.call(PMJS.plugins.mpp, image, {
          points: frame.map(function(_point, index) { return [vertices[index * 2], vertices[index * 2 + 1]]; }),
          sourceBounds: bounds,
          stroke: { color: [color[0]/255,color[1]/255,color[2]/255],
            alpha: plugin.LineWidth > 0 ? 0.5 : 0,
            width: Math.max(0, plugin.LineWidth / zoom), miterLimit: 10 }
        });
        this._items.push({ image: image, anchorX: anchorX, anchorY: anchorY, bitmapBounds: bounds,
          flashColor: [0, 0, 0, 0], flashDuration: 0 });
      }

      var bakeStart = performance.now();
      var atlasStage = new PIXI.Container();
      var atlasWidth = 1024, cursorX = 0, cursorY = 0, rowHeight = 0;
      this._items.forEach(function(item) {
        var bounds = item.bitmapBounds;
        var width = Math.round(bounds[2] - bounds[0]);
        var height = Math.round(bounds[3] - bounds[1]);
        if (width > atlasWidth) throw new Error('MPP fragment exceeds atlas width');
        if (cursorX + width > atlasWidth) {
          cursorX = 0; cursorY += rowHeight; rowHeight = 0;
        }
        item.atlasRect = [cursorX, cursorY, width, height];
        item.image.x = cursorX - bounds[0];
        item.image.y = cursorY - bounds[1];
        atlasStage.addChild(item.image);
        cursorX += width; rowHeight = Math.max(rowHeight, height);
      });
      var atlasHeight = cursorY + rowHeight;
      var captureScaleMode = texture.baseTexture.scaleMode;
      texture.baseTexture.scaleMode = PIXI.SCALE_MODES.LINEAR;
      try {
        this._atlas = Graphics._renderer.generateTextureGpu(atlasStage,
          effect.Smooth ? PIXI.SCALE_MODES.LINEAR : PIXI.SCALE_MODES.NEAREST, 1,
          new PIXI.Rectangle(0, 0, atlasWidth, atlasHeight), { alphaMode: 'premultiplied' });
      } finally {
        texture.baseTexture.scaleMode = captureScaleMode;
        PMJS.pixi4.releaseSceneResources(atlasStage);
      }
      this._items.forEach(function(item) {
        var old = item.image, tile = item.atlasRect;
        var image = new Sprite();
        image.texture = PMJS.pixi4.createGpuStandaloneBitmapRegion(this._atlas,
          new PIXI.Rectangle(tile[0], tile[1], tile[2], tile[3]));
        image.anchor.x = item.anchorX;
        image.anchor.y = item.anchorY;
        item.image = image;
        item.texture = image.texture;
        old.destroy();
      }, this);
      var atlasCounters = stats();
      atlasCounters.atlasBuilds = (atlasCounters.atlasBuilds || 0) + 1;
      atlasCounters.atlasBytes = atlasWidth * atlasHeight * 4;
      atlasCounters.atlasBuildMs = (atlasCounters.atlasBuildMs || 0) + performance.now() - bakeStart;

      var backgroundVertices = new Float32Array([0, 0, Graphics.width, 0,
        Graphics.width, Graphics.height, 0, Graphics.height]);
      var backgroundUvs = new Float32Array([0, 0, 1, 0, 1, 1, 0, 1]);
      var backgroundIndices = new Uint16Array([0, 1, 2, 0, 2, 3]);
      var copy = new PIXI.mesh.Mesh(texture, backgroundVertices, backgroundUvs,
        backgroundIndices, PIXI.mesh.Mesh.DRAW_MODES.TRIANGLES);
      copy.uploadUvTransform = true;
      try {
        this._backgroundTexture = Graphics._renderer.generateTextureGpu(copy,
          PIXI.SCALE_MODES.NEAREST, 1,
          new PIXI.Rectangle(0, 0, Graphics.width, Graphics.height), { alphaMode: 'premultiplied' });
      } finally {
        PMJS.pixi4.releaseSceneResources(copy);
        copy.destroy();
      }
      this._background = new Sprite();
      this._background.texture = this._backgroundTexture;
      this.addChild(this._background);
      this._items.forEach(function(item) { this.addChild(item.image); }, this);
      var counters = stats();
      counters.fragments += fragments.length;
      counters.fragmentGeometry = (counters.fragmentGeometry || 0) + fragments.length;
      counters.borderGeometry = counters.borderGeometry || 0;
      counters.backgroundCopies = (counters.backgroundCopies || 0) + 1;
      counters.backgroundBytes = Graphics.width * Graphics.height * 4;
      this.update();
    };
    GpuPresenter.prototype.flashRegion = function(item, color) {
      if (this._flashCacheDisabled) return null;
      var key = color.join(','), entry = this._flashAtlases.get(key);
      if (!entry) {
        // Bound temporary GPU storage when a custom effect supplies more colors.
        if (this._flashAtlases.size >= 4) return null;
        var before = performance.now(), sprite = new Sprite(), texture = null;
        var scale = this._atlas.baseTexture.scaleMode;
        sprite.texture = this._atlas;
        sprite._blendColor = color.slice();
        this._atlas.baseTexture.scaleMode = PIXI.SCALE_MODES.NEAREST;
        try {
          texture = Graphics._renderer.generateTextureGpu(sprite, scale, 1,
            new PIXI.Rectangle(0, 0, this._atlas.width, this._atlas.height), { alphaMode: 'premultiplied' });
        } catch (error) {
          this._flashCacheDisabled = true;
          return null;
        } finally {
          this._atlas.baseTexture.scaleMode = scale;
          PMJS.pixi4.releaseSceneResources(sprite);
          sprite.destroy();
        }
        entry = { texture: texture, regions: new Map() };
        this._flashAtlases.set(key, entry);
        var counters = stats();
        counters.flashAtlasBuilds = (counters.flashAtlasBuilds || 0) + 1;
        counters.flashAtlasBuildMs = (counters.flashAtlasBuildMs || 0) + performance.now() - before;
        counters.flashAtlasBytes = (counters.flashAtlasBytes || 0) + this._atlas.width * this._atlas.height * 4;
      }
      var region = entry.regions.get(item);
      if (!region) {
        var tile = item.atlasRect;
        region = PMJS.pixi4.createGpuStandaloneBitmapRegion(entry.texture,
          new PIXI.Rectangle(tile[0], tile[1], tile[2], tile[3]));
        entry.regions.set(item, region);
      }
      return region;
    };
    GpuPresenter.prototype.update = function() {
      var clearPoints = [], clearRectangles = [], clearSizes = [];
      for (var index = 0; index < this._fragments.length; index++) {
        var fragment = this._fragments[index];
        var item = this._items[index];
        if (fragment.visible && !this._broken[index]) {
          this._broken[index] = true;
          if (this._clipBackground) {
            fragment._frame.forEach(function(point) { clearPoints.push(point.x, point.y); });
            clearSizes.push(fragment._frame.length);
            var rect = fragment.rect();
            clearRectangles.push(rect.x, rect.y, rect.width, rect.height);
          }
        }
        item.image.visible = fragment.visible;
        item.image.x = fragment.x;
        var y = fragment.y - fragment.jumpHeight;
        item.image.y = y;
        item.image.scale.x = fragment.scaleX();
        item.image.scale.y = fragment.scaleY();
        item.image.rotation = fragment.rotation();
        if (fragment.flashColor) {
          item.flashDuration = 25;
          item.flashColor = fragment.flashColor.clone();
          item.flashColor[3] = plugin.FlashOpacity;
          fragment.flashColor = null;
        }
        if (item.flashDuration > 0) {
          var duration = item.flashDuration--;
          item.flashColor[3] *= (duration - 1) / duration;
          if (duration % flashRate === 1) {
            var region = item.flashColor[3] > 0 ? this.flashRegion(item, item.flashColor) : null;
            item.image.texture = region || item.texture;
            item.image._blendColor = region ? [0, 0, 0, 0] : item.flashColor.slice();
          }
        }
      }
      if (clearPoints.length) {
        if (this._polygonFragments) PMJS.plugins.mpp.clearBackgroundPolygons(this._backgroundTexture,
          clearPoints, clearRectangles, clearSizes);
        else PMJS.plugins.mpp.clearBackground(this._backgroundTexture, new Float32Array(clearPoints),
          new Float32Array(clearRectangles));
        var counters = stats();
        counters.backgroundEraseBatches = (counters.backgroundEraseBatches || 0) + 1;
        counters.backgroundErasedTriangles = (counters.backgroundErasedTriangles || 0) + (this._polygonFragments ? 0 : clearPoints.length / 6);
      }
      if (this._broken.every(function(broken) { return broken; })) this._background.visible = false;
    };
    return GpuPresenter;
  }
})();

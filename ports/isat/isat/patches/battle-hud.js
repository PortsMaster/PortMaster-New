'use strict';

(function() {
  var id = 'isat.retained-battle-hud';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary synchronous battle status painting' });
  PMJS.phases.on('afterPlugins', 'pmjs.isat.battle-hud', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    var prototype = globalThis.Window_BattleStatusUpgrade && Window_BattleStatusUpgrade.prototype;
    if (!qualification || !qualification.verified || !prototype) {
      PMJS.optimizations.refuse(id, qualification && qualification.reason || 'unqualified battle status sources');
      return;
    }
    var hash = PMJS.isatMethodHash;
    var reviewedMethods = {
      "refresh": "12f3f65a6f4325c0b64102976ca10653727f48865de7007ac382fab0e78df437",
      "drawItem": "bb6471d0e665817d51c21d6bd596541635b378ba58fc45bf0201ee4ae4d4e493",
      "drawAllImages": "67f7e85eaa88dfd1a938fe04f94f3e0dbd9cb833ae0b0b316ebf1354ac856e54",
      "drawAllTexts": "f46bc3ec932384c4a7ca497eaccb880d8f1b3fd09a7c5b043eb1812eb92154e3",
      "drawAllGauges": "b179edf14d74785a4632fd3ad535d1b62fb6945c672fd675fcb4d8af7d6e03ce",
      "drawBasicGauge": "cc83dc7fa2b960e8465e3f23ed0be9d5d6bb3e5dc1679545a5a429fad5fe899a",
      "drawGaugeUpgrade": "6c1a454402d1738caa29e93447d6a364f0036f93d0c8a08927027b763e3e8f81",
      "drawIcons": "f16041bc14f21d1237f4eef9670bd8f1c3803a59fd2e4e69d43a2af04a21b83b"
    };
    var reviewedConfig = {
      "faceX": "(boxWidth - 144) / 2",
      "faceY": "0",
      "faceWidth": "144",
      "faceHeight": "144",
      "iconX": "0",
      "iconY": "93",
      "iconWidth": "boxWidth",
      "iconScale": "1",
      "gaugeX": "0",
      "gaugeY": "0",
      "gaugeTextX": "x + 4",
      "gaugeTextY": "y + 5",
      "gaugeFont": "Gamefont",
      "gaugeFontSize": "18",
      "gaugeItalic": false,
      "gaugeTextColor": "#ffffff",
      "gaugeOutlineColor": "rgba(0, 0, 0, 0.5)",
      "gaugeOutlineWidth": 4
    };
    var reviewedGauges = {
      "1": {
        "text": "TextManager.hpA",
        "cur": "actor.hp",
        "max": "actor.mhp",
        "x": "0",
        "y": "boxHeight - 42",
        "width": "boxWidth",
        "height": "23",
        "color1": "\"#CECECE\"",
        "color2": "this.hpGaugeColor2()",
        "back": "\"#000000\"",
        "cm": true
      },
      "5": {
        "text": "",
        "cur": "actor._atbSpeed",
        "max": "Math.max(5000, BattleManager.highestBaseAgi() * 100)",
        "x": "0",
        "y": "boxHeight - 32",
        "width": "boxWidth",
        "height": "10",
        "color1": "\"#393939\"",
        "color2": "\"#818181\"",
        "back": "\"#000000\"",
        "cm": false
      }
    };
    function matches(object, expected) {
      return object && Object.keys(expected).every(function(key) {
        var value = object[key];
        return (typeof value === 'string' ? value.trim() : value) === expected[key];
      });
    }
    if (!Object.keys(reviewedMethods).every(function(name) { return hash(prototype[name]) === reviewedMethods[name]; }) ||
        !matches(SRD.BattleStatusCustomizer, reviewedConfig) ||
        !matches(SRD.BattleStatusCustomizer.gauges[1], reviewedGauges[1]) ||
        !matches(SRD.BattleStatusCustomizer.gauges[5], reviewedGauges[5]) ||
        SRD.BattleStatusCustomizer.gauges[1].absorb || SRD.BattleStatusCustomizer.gauges[5].absorb) {
      PMJS.optimizations.refuse(id, 'unrecognized battle status pipeline or layout');
      return;
    }
    var styles = ['fontFace', 'fontSize', 'fontBold', 'fontItalic', 'textColor',
      'outlineColor', 'outlineWidth', 'paintOpacity', '_allowTextTranslation'];
    var names = ['refresh', 'drawItem', 'drawAllImages', 'drawAllTexts', 'drawAllGauges',
      'drawBasicGauge', 'drawGaugeUpgrade', 'drawIcons', 'drawActorFace', 'drawFace',
      'drawActorIconsScale', 'drawActorIconsTurns', 'drawIconScale', 'drawText',
      'drawCurrentAndMax', 'contentsWidth', 'contentsHeight', 'lineHeight'];
    var methods = {}, installed = {}, states = new WeakMap(), abandoned = new WeakSet();
    names.forEach(function(name) { methods[name] = prototype[name]; });
    var config = SRD.BattleStatusCustomizer;
    var gauges = config.gauges, texts = config.texts;
    var hpGauge = gauges[1], atbGauge = gauges[5];
    var layout = [];
    [[config, reviewedConfig], [gauges[1], reviewedGauges[1]],
      [gauges[5], reviewedGauges[5]]].forEach(function(pair) {
      Object.keys(pair[1]).forEach(function(key) {
        layout.push({ object: pair[0], key: key, value: pair[0][key] });
      });
    });
    var contentsProperty = Object.getOwnPropertyDescriptor(Window.prototype, 'contents');
    var bitmapMethods = {};
    ['clear', 'fillRect', 'gradientFillRect', 'blt', 'drawText'].forEach(function(name) {
      bitmapMethods[name] = Bitmap.prototype[name];
    });
    var paintText = master2015hp.isatSnp.b_42, fontLoader = Bitmap.prototype.loadOptionsFont;
    var atlases = new Map(), panels = new Set();
    var counters = { admissions: 0, refreshes: 0, commits: 0, paints: 0, fallbacks: 0 };
    PMJS.isatBattleHud = { diagnostics: function() {
      var bytes = 0, retained = 0;
      atlases.forEach(function(weak) {
        var entry = weak.deref();
        if (entry) bytes += entry.bitmap.width * entry.bitmap.height * 4;
      });
      panels.forEach(function(weak) { if (weak.deref()) retained++; });
      return Object.assign({ retained: retained, atlasBytes: bytes }, counters);
    } };

    function same(a, b) {
      return a && b && a.length === b.length && a.every(function(value, i) { return value === b[i]; });
    }
    function resource(bitmap) {
      return [bitmap, bitmap.width, bitmap.height, bitmap._canvas,
        bitmap._canvas && bitmap._canvas.__pmjsContentRevision,
        bitmap._image, bitmap._image && bitmap._image._nativeImage && bitmap._image._nativeImage.handle];
    }
    function opaqueAncestors(window) {
      var node = window._windowContentsSprite;
      if (node.alpha !== 1 || (node.tint !== undefined && node.tint !== 0xffffff) ||
          (node._colorTone && node._colorTone.some(Boolean)) || (node._blendColor && node._blendColor[3])) return false;
      node = window;
      while (node) {
        if ((node.alpha !== undefined && node.alpha !== 1) || node.cacheAsBitmap) return false;
        node = node.parent;
      }
      return true;
    }
    function supported(window, bitmap) {
      var context = bitmap && bitmap._context;
      return master2015hp.isatSnp.b_42 === paintText && bitmap && bitmap.loadOptionsFont === fontLoader &&
        opaqueAncestors(window) && window._actor && bitmap && bitmap.width > 0 && bitmap.width <= 160 &&
        bitmap.height > 0 && bitmap.height <= 256 && window._redrawForLoad > 4 &&
        window._useFace && window._useIcon && !window._texts.length &&
        same(window._gauges, [1, 5]) && window.lineHeight() === 36 &&
        window.contentsWidth() === bitmap.width && window.contentsHeight() === bitmap.height &&
        bitmap.paintOpacity === 255 && context && context.globalAlpha === 1 &&
        context.globalCompositeOperation === 'source-over' &&
        context._clipPaths && !context._clipPaths.length &&
        same(context._transform, [1, 0, 0, 1, 0, 0]) &&
        window.origin.x >= 0 && window.origin.y >= 0 &&
        window.origin.x <= bitmap.width && window.origin.y <= bitmap.height &&
        SRD.BattleStatusCustomizer === config && config.gauges === gauges && config.texts === texts &&
        gauges[1] === hpGauge && gauges[5] === atbGauge &&
        !gauges[1].absorb && !gauges[5].absorb && !gauges[undefined] && !texts[undefined] &&
        layout.every(function(field) { return field.object[field.key] === field.value; }) &&
        names.every(function(name) { return window[name] === installed[name]; }) &&
        Object.keys(bitmapMethods).every(function(name) { return bitmap[name] === bitmapMethods[name]; });
    }
    function dispose(state) {
      panels.delete(state.reference);
      state.guards.forEach(function(guard) {
        var context = state.context;
        if (context[guard.name] === guard.wrapper) {
          if (guard.own) context[guard.name] = guard.original;
          else delete context[guard.name];
        }
      });
      state.layers.forEach(function(layer) {
        if (layer.sprite.parent) layer.sprite.parent.removeChild(layer.sprite);
        layer.sprite.bitmap = null;
        layer.sprite.destroy();
      });
      state.layers.length = 0;
      // These surfaces belong only to this panel, never to ImageManager or the game.
      state.bitmaps.forEach(function(bitmap) { if (bitmap.destroy) bitmap.destroy(); });
      state.bitmaps.length = 0;
      state.commands = null;
    }
    function fallback(window, reason, detail, retry) {
      var state = states.get(window);
      if (!state) return;
      states.delete(window);
      if (!retry) abandoned.add(window);
      delete window.contents;
      dispose(state);
      counters.fallbacks++;
      PMJS.optimizations.reportFallback(id, reason, detail);
      methods.refresh.call(window);
    }
    function recorder(window, state) {
      var bitmap = state.bitmap;
      return new Proxy(bitmap, {
        get: function(target, name) {
          if (!state.recording) {
            if (name === 'width' || name === 'height') return target[name];
            fallback(window, 'synchronous HUD contents access');
            return Reflect.get(target, name, target);
          }
          if (name === 'clear') return function() {};
          if (name === 'fillRect' || name === 'gradientFillRect' || name === 'blt' || name === 'drawText') {
            return function() {
              var args = Array.prototype.slice.call(arguments);
              if (name === 'drawText') {
                // Keep font-selection and translation effects at the original call site.
                if (target.loadOptionsFont) target.loadOptionsFont();
                if (target._allowTextTranslation) args[0] = SRD.TranslationEngine.translate(args[0]);
              }
              var style = styles.map(function(key) { return target[key]; });
              if (name === 'drawText') {
                style[styles.indexOf('_allowTextTranslation')] = false;
                if (args[0] === '' || args[0] === undefined || args[0] === null) return;
              }
              state.commands[state.part].push({ name: name, args: args, style: style });
            };
          }
          return Reflect.get(target, name, target);
        },
        set: function(target, name, value) { target[name] = value; return true; }
      });
    }
    function record(window, state, args) {
      state.commands = [[], [], [], []];
      state.part = 0;
      state.recording = true;
      try { return methods.refresh.apply(window, args); }
      catch (error) {
        states.delete(window);
        abandoned.add(window);
        delete window.contents;
        dispose(state);
        throw error;
      }
      finally { state.recording = false; counters.refreshes++; }
    }
    // The admitted layout has two fixed gauges; evaluate their values without SRD's per-draw evals.
    function recordGauges(window) {
      var actor = window._actor, width = window.contentsWidth(), height = window.contentsHeight();
      window.drawBasicGauge(TextManager.hpA, 0, height - 42, width, 23, actor.hp, actor.mhp,
        '#CECECE', window.hpGaugeColor2(), '#000000', true);
      window._checkForRefresh.push([actor.hp, 'actor.hp']);
      window.drawBasicGauge('', 0, height - 32, width, 10, actor._atbSpeed,
        Math.max(5000, BattleManager.highestBaseAgi() * 100), '#393939', '#818181', '#000000', false);
      window._checkForRefresh.push([actor._atbSpeed, 'actor._atbSpeed']);
    }
    function recordGauge(text, x, y, width, height, current, maximum, first, second, back, numbers) {
      var window = this;
      width = width || 186;
      window.drawGaugeUpgrade(x, y, width, height, current / maximum, first, second, back);
      window.changeTextColor(window.systemColor());
      var bitmap = window.contents;
      bitmap.fontSize = 18;
      bitmap.fontFace = config.gaugeFont;
      bitmap.fontItalic = config.gaugeItalic;
      bitmap.textColor = config.gaugeTextColor;
      bitmap.outlineColor = config.gaugeOutlineColor;
      bitmap.outlineWidth = config.gaugeOutlineWidth;
      window.drawText(text, x + 4, y + 5, 44);
      if (numbers) window.drawCurrentAndMax(current, maximum, x - 4, y + 5, width,
        window.normalColor(), window.normalColor());
    }
    function key(commands) {
      var result = [];
      commands.forEach(function(command) {
        result.push(command.name);
        result.push.apply(result, command.args);
        result.push.apply(result, command.style);
        result.push.apply(result, command.name === 'blt' ? resource(command.args[0]) : []);
      });
      return result;
    }
    function paint(bitmap, commands) {
      bitmap.clear();
      commands.forEach(function(command) {
        styles.forEach(function(name, i) { bitmap[name] = command.style[i]; });
        (command.name === 'drawText' ? paintText : bitmapMethods[command.name]).apply(bitmap, command.args);
      });
      counters.paints++;
    }
    function commit(window, state) {
      if (!supported(window, state.bitmap) || contentsProperty.get.call(window) !== state.bitmap ||
          state.bitmap._context !== state.context ||
          state.bitmap._canvas.__pmjsContentRevision !== state.revision ||
          state.layers.some(function(layer) { return layer.sprite.parent !== window._windowContentsSprite; }) ||
          window._windowContentsSprite.children.some(function(child) {
            return !state.layers.some(function(layer) { return layer.sprite === child; });
          })) {
        fallback(window, 'HUD layout, ownership or contents changed', undefined, window._redrawForLoad <= 4);
        return;
      }
      if (window._actor !== state.actor) {
        fallback(window, 'HUD actor replaced');
        return;
      }
      var atb = state.commands[2];
      if (atb.length < 2 || atb.length > 3 ||
          atb[0].name !== 'fillRect' || atb[1].name !== 'fillRect' ||
          (atb[2] && atb[2].name !== 'gradientFillRect') ||
          (atb[2] && (!Number.isInteger(atb[2].args[2]) || atb[2].args[2] < 0 ||
            atb[2].args[2] > state.bitmap.width))) {
        fallback(window, 'HUD gauge outside retained range');
        return;
      }
      state.commands.forEach(function(commands, index) {
        var layer = state.layers[index];
        var next = key(commands);
        if (!same(next, layer.key)) {
          if (index === 2) {
            var gauge = commands[1].args;
            var atlasOffset = (gauge[1] - 1) % 4;
            var atlasKey = state.bitmap.width + ':' + gauge[3] + ':' + atlasOffset;
            if (!layer.atlasEntry) {
              var weak = atlases.get(atlasKey);
              var entry = weak && weak.deref();
              if (!entry) {
                var height = gauge[3] + 2;
                var atlas = new Bitmap(state.bitmap.width, (state.bitmap.width + 1) * height + atlasOffset);
                atlas.fillRect(0, 0, atlas.width, atlas.height, '#000000');
                for (var n = 0; n <= state.bitmap.width; n++) {
                  if (n) atlas.gradientFillRect(gauge[0], n * height + atlasOffset + 1, n, gauge[3],
                    '#393939', '#818181');
                }
                entry = { bitmap: atlas };
                atlases.set(atlasKey, new WeakRef(entry));
              }
              layer.atlasEntry = entry;
              layer.sprite.bitmap = entry.bitmap;
            }
          } else {
            paint(layer.bitmap, commands);
            layer.sprite.bitmap = layer.bitmap;
          }
          layer.key = next;
        }
        if (index === 2) {
          var top = commands[1].args[1] - 1;
          var crop = Math.max(0, window.origin.y - top);
          layer.sprite.y = Math.max(0, top - window.origin.y);
          layer.sprite.setFrame(window.origin.x,
            (commands[2] ? commands[2].args[2] : 0) * (commands[1].args[3] + 2) + top % 4 + crop,
            Math.min(window.contentsWidth(), state.bitmap.width - window.origin.x),
            Math.max(0, Math.min(commands[1].args[3] + 2 - crop,
              Math.min(window.contentsHeight(), state.bitmap.height - window.origin.y) - layer.sprite.y)));
        } else layer.sprite.setFrame(window.origin.x, window.origin.y,
          window.contentsWidth(), window.contentsHeight());
      });
      counters.commits++;
    }
    function flush(stage) {
      if (!stage) return;
      panels.forEach(function(reference) {
        var window = reference.deref();
        if (!window) { panels.delete(reference); return; }
        var ancestor = window;
        while (ancestor && ancestor !== stage) ancestor = ancestor.parent;
        var state = states.get(window);
        if (ancestor && state) commit(window, state);
      });
    }
    function attachRenderer(renderer) {
      if (!renderer || renderer._pmjsIsatHud) return;
      renderer._pmjsIsatHud = true;
      var render = renderer.render;
      renderer.render = function(stage) { flush(stage); return render.apply(this, arguments); };
    }
    PMJS.methods.wrap({ key: 'Graphics._createRenderer.isat-retained-hud', getTarget: function() { return Graphics; },
      method: '_createRenderer', id: 'pmjs.isat.battle-hud-render', wrap: function(create) {
        return function() { var result = create.apply(this, arguments); attachRenderer(this._renderer); return result; };
      } });
    attachRenderer(Graphics._renderer);

    // Install after the shared SRD adapter has qualified the original pipeline.
    PMJS.phases.on('beforeBoot', 'pmjs.isat.battle-hud', function() {
      var ordinaryRefresh = prototype.refresh;
      prototype.refresh = function() {
        var state = states.get(this);
        if (state) {
          if (this._actor !== state.actor || !supported(this, state.bitmap)) {
            var window = this;
            fallback(this, 'HUD actor or drawing contract changed', JSON.stringify({
              actorChanged: this._actor !== state.actor, redraw: this._redrawForLoad,
              size: [state.bitmap.width, state.bitmap.height, this.contentsWidth(), this.contentsHeight()],
              opacity: state.bitmap.paintOpacity, alpha: state.bitmap._context.globalAlpha,
              methods: names.filter(function(name) { return window[name] !== installed[name]; }) }),
              this._redrawForLoad <= 4);
            return;
          }
          return record(this, state, arguments);
        }
        var bitmap = contentsProperty.get.call(this);
        if (abandoned.has(this) || !supported(this, bitmap) ||
            this._windowContentsSprite.children.length) return ordinaryRefresh.apply(this, arguments);
        var face = ImageManager.loadFace(this._actor.faceName());
        var icons = ImageManager.loadSystem('IconSet');
        if (!face.isReady() || !icons.isReady()) return ordinaryRefresh.apply(this, arguments);
        bitmap.clear();
        state = { bitmap: bitmap, context: bitmap._context, actor: this._actor, revision: bitmap._canvas.__pmjsContentRevision,
          layers: [], bitmaps: [], guards: [], recording: false };
        state.proxy = recorder(this, state);
        for (var i = 0; i < 4; i++) {
          var surface = i === 2 ? null : new Bitmap(bitmap.width, bitmap.height), sprite = new Sprite(surface);
          if (surface) state.bitmaps.push(surface);
          state.layers.push({ bitmap: surface, sprite: sprite });
          this._windowContentsSprite.addChild(sprite);
        }
        states.set(this, state);
        state.reference = new WeakRef(this);
        panels.add(state.reference);
        ['save', 'fillRect', 'clearRect', 'drawImage', 'fill', 'stroke', 'strokeRect',
          'putImageData', 'getImageData', 'fillText', 'strokeText'].forEach(function(name) {
          var context = bitmap._context, original = context[name];
          if (typeof original !== 'function') return;
          var guard = { name: name, original: original, own: Object.hasOwn(context, name) };
          guard.wrapper = function() {
            if (!state.recording) fallback(window, 'external HUD Canvas access');
            return original.apply(this, arguments);
          };
          state.guards.push(guard);
          context[name] = guard.wrapper;
        });
        counters.admissions++;
        var window = this;
        Object.defineProperty(this, 'contents', { configurable: true,
          get: function() { return state.proxy; },
          set: function(value) {
            fallback(window, 'HUD contents replaced');
            contentsProperty.set.call(window, value);
          } });
        return record(this, state, arguments);
      };
      ['drawAllImages', 'drawAllGauges', 'drawBasicGauge', 'drawIcons'].forEach(function(name) {
        prototype[name] = function() {
          var state = states.get(this);
          if (!state || !state.recording) return methods[name].apply(this, arguments);
          var previous = state.part;
          state.part = name === 'drawAllImages' ? 0 : name === 'drawIcons' ? 3 : arguments[10] ? 1 : 2;
          try {
            if (name === 'drawAllGauges') return recordGauges(this);
            if (name === 'drawBasicGauge') return recordGauge.apply(this, arguments);
            return methods[name].apply(this, arguments);
          }
          finally { state.part = previous; }
        };
      });
      var destroy = prototype.destroy;
      if (typeof destroy === 'function') prototype.destroy = function() {
        var state = states.get(this);
        if (state) {
          states.delete(this);
          delete this.contents;
          dispose(state);
        }
        return destroy.apply(this, arguments);
      };
      names.forEach(function(name) { installed[name] = prototype[name]; });
    });
  });
})();

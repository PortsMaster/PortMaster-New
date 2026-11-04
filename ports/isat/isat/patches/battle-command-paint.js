'use strict';

(function() {
  var id = 'isat.retained-command-paint';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary command contents construction and rich text painting' });
  PMJS.phases.on('afterPlugins', 'pmjs.isat.battle-command-paint', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var prototype = globalThis.Window_ActorCommand && Window_ActorCommand.prototype;
    if (!PMJS.isatSourceQualification || !PMJS.isatSourceQualification.verified || !prototype ||
        !globalThis.VictorEngine || !VictorEngine.ControlText) {
      PMJS.optimizations.refuse(id, PMJS.isatSourceQualification && PMJS.isatSourceQualification.reason || 'unqualified command sources');
      return;
    }
    var refresh = prototype.refresh, drawText = prototype.drawText;
    var selectableRefresh = Window_Selectable.prototype.refresh;
    var crypto = __pmjsBuiltinRequire('crypto');
    var digest = PMJS.isatMethodHash;
    if (digest(refresh) !== '1d72c2c97888f2b3e29a8ab2b524e10bb9af04a3e96f42ee6e225df1953c0458' ||
        digest(selectableRefresh) !== 'dea829bcd9590ab4b5d07ed83d7848d0f320fc0370fc6661115c864b67b1e1bd') {
      PMJS.optimizations.refuse(id, 'unrecognized command refresh');
      return;
    }
    var editorMethods = {"lineHeight": "2ee012b5bd9b9485ed3db1123b1c4f504b872eb30822ebb496d824e786d13a4b", "itemTextAlign": "5a3feec836c47adc910bd4870bc78b5c67039106e12c7cb281c355fc226f0026"};
    var windowsHash = '29d30eafee854061d596074ab22f401464176ff3fcae67cd423c77ecdbbe0971';
    var editorVerified = false;
    try {
      editorVerified = crypto.createHash('sha256').update(NativeHost.fs.readText('data/Windows.json')
        .replace(/\r\n/g, '\n')).digest('hex') === windowsHash;
    } catch (_) { editorVerified = false; }
    var methodHashes = new WeakMap();
    var states = new WeakMap(), installed = {};
    var styles = ['fontFace', 'fontSize', 'fontBold', 'fontItalic', 'textColor',
      'outlineColor', 'outlineWidth', 'paintOpacity', '_allowTextTranslation'];
    var names = ['refresh', 'drawText', 'drawItem', 'drawAllItems', 'createContents',
      'itemRectForText', 'itemTextAlign', 'resetFontSettings', 'resetTextColor',
      'changePaintOpacity', 'drawIcon', 'lineHeight', 'contentsWidth', 'contentsHeight',
      'isCommandEnabled', 'commandName'];
    var counters = { paints: 0, reuses: 0, labels: 0, fallbacks: 0 };
    PMJS.isatCommandPaint = { diagnostics: function() { return Object.assign({}, counters); } };
    function resolve(text, bitmap) {
      if (typeof text !== 'string') return null;
      var match = /^\\#(?:\\i\[(\d+)\]\\#)?\\v\[(\d+)\]$/i.exec(text);
      var label = match ? String($gameVariables.value(Number(match[2]))) : text;
      if (!match && bitmap && bitmap._allowTextTranslation) label = SRD.TranslationEngine.translate(label);
      if (typeof label !== 'string' || /[\\\x1b\r\n\f<>]/.test(label)) return null;
      return { text: label, icon: match && match[1] !== undefined ? Number(match[1]) : null };
    }
    function supported(window) {
      return Window_Selectable.prototype.refresh === selectableRefresh && names.every(function(name) {
        var method = window[name];
        if (method === installed[name]) return true;
        if (!editorVerified || !editorMethods[name] || typeof method !== 'function') return false;
        if (!methodHashes.has(method)) methodHashes.set(method, digest(method));
        return methodHashes.get(method) === editorMethods[name];
      });
    }
    function ordinaryCanvas(bitmap) {
      var context = bitmap && bitmap._context;
      return context && context.globalAlpha === bitmap.paintOpacity / 255 && context.globalCompositeOperation === 'source-over' &&
        context._transform.every(function(value, i) { return value === [1,0,0,1,0,0][i]; }) &&
        !context._clipPaths.length;
    }
    prototype.drawText = function(text, x, y, width, align) {
      var label = resolve(text, this.contents);
      if (!label || !supported(this) || !ordinaryCanvas(this.contents)) return drawText.apply(this, arguments);
      var bitmap = this.contents;
      bitmap.loadOptionsFont();
      var previousTranslation = bitmap._allowTextTranslation, measured;
      bitmap.setTextTranslation(false);
      try { measured = bitmap.measureTextWidth(label.text); }
      finally { bitmap.setTextTranslation(previousTranslation); }
      if (!text.startsWith('\\#') && measured > width) return drawText.apply(this, arguments);
      var extent = measured + (label.icon === null ? 0 : Window_Base._iconWidth + 4);
      var left = x + (align === 'center' ? (width - extent) / 2 : align === 'right' ? width - extent : 0);
      if (label.icon !== null) {
        this.drawIcon(label.icon, left + 2, y + 2);
        left += Window_Base._iconWidth + 4;
      }
      var translation = bitmap._allowTextTranslation;
      bitmap.setTextTranslation(false);
      try { bitmap.drawText(label.text, left, y, Math.max(measured * 2, 1), this.lineHeight(), 'left'); }
      finally { bitmap.setTextTranslation(translation); }
      counters.labels++;
    };
    prototype.refresh = function() {
      if (!supported(this)) {
        counters.fallbacks++;
        var window = this;
        PMJS.optimizations.reportFallback(id, 'command method changed',
          names.filter(function(name) { return window[name] !== installed[name]; }).join(', '));
        states.delete(this);
        return refresh.apply(this, arguments);
      }
      // Preserve semantic construction even when the painted rows can be reused.
      this.clearCommandList();
      this.makeCommandList();
      var bitmap = this.contents;
      var rows = this._list.map(function(command, index) {
        var label = resolve(command.name, bitmap), rect = this.itemRectForText(index);
        return label && [label.text, label.icon, command.enabled,
          rect.x, rect.y, rect.width, rect.height];
      }, this);
      var iconSet = ImageManager.loadSystem('IconSet');
      var skin = this.windowskin;
      function source(value) {
        return value && [value._canvas && value._canvas.__pmjsContentRevision,
          value._image && value._image._nativeImage && value._image._nativeImage.handle,
          value.width, value.height];
      }
      var key = JSON.stringify([rows, this.contentsWidth(), this.contentsHeight(),
        this.itemTextAlign(), this.standardFontFace(), this.standardFontSize(), this.lineHeight(),
        ConfigManager.getLanguage(), ConfigManager.fontStyle, PMJS.config.fonts,
        globalThis.document && document.fonts && document.fonts.status,
        bitmap && PMJS.fonts && PMJS.fonts.resolveDescriptor(bitmap._makeFontNameText()),
        source(iconSet), source(skin)]);
      var previous = states.get(this);
      if (rows.every(Boolean) && previous && previous.bitmap === bitmap && previous.key === key &&
          previous.icons === iconSet && previous.skin === skin && ordinaryCanvas(bitmap) &&
          previous.iconCanvas === iconSet._canvas && previous.iconImage === iconSet._image &&
          previous.skinCanvas === (skin && skin._canvas) && previous.skinImage === (skin && skin._image) &&
          bitmap._canvas && bitmap._canvas.__pmjsContentRevision === previous.revision &&
          styles.every(function(name, i) { return bitmap[name] === previous.style[i]; }) &&
          iconSet.isReady() && (!skin || skin.isReady())) {
        counters.reuses++;
        return;
      }
      this.createContents();
      Window_Selectable.prototype.refresh.call(this);
      counters.paints++;
      bitmap = this.contents;
      if (rows.every(Boolean) && bitmap._canvas && iconSet.isReady() && (!skin || skin.isReady())) {
        states.set(this, { bitmap: bitmap, key: key, icons: iconSet, skin: skin,
          revision: bitmap._canvas.__pmjsContentRevision,
          iconCanvas: iconSet._canvas, iconImage: iconSet._image,
          skinCanvas: skin && skin._canvas, skinImage: skin && skin._image,
          style: styles.map(function(name) { return bitmap[name]; }) });
      } else {
        states.delete(this);
        counters.fallbacks++;
        PMJS.optimizations.reportFallback(id, 'unsupported command text or pending resources');
      }
    };
    names.forEach(function(name) { installed[name] = prototype[name]; });
  });
})();

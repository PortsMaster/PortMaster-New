'use strict';

(function() {
  var id = 'isat.choice-width-measure';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'authored choice-width measurement' });
  var outline = Bitmap.prototype._drawTextOutline;
  var body = Bitmap.prototype._drawTextBody;

  var digest = PMJS.isatMethodHash;
  function restore(object, name, descriptor) {
    if (descriptor) Object.defineProperty(object, name, descriptor);
    else delete object[name];
  }
  function replaceable(object, names) {
    return Object.isExtensible(object) && names.every(function(name) {
      var descriptor = Object.getOwnPropertyDescriptor(object, name);
      return !descriptor || descriptor.configurable && descriptor.writable;
    });
  }

  PMJS.phases.on('afterPlugins', 'pmjs.isat.choice-width', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    var prototype = Window_ChoiceList.prototype;
    var width = prototype.maxChoiceWidth, measure = prototype.textWidthEx;
    var character = prototype.processNormalCharacter;
    var glyphWidth = Bitmap.prototype.measureTextWidth;
    if (digest(width) !== '42c171dd2639b68d99e87494939375b500fc6a5978e2c36579225cafc5f54b93' ||
        digest(measure) !== '7adfd13d31747908de84772ca85ab95c7d5d29d7c10f15363343b9ad4037ff62' ||
        digest(character) !== 'f30227773727b0cde96c202ceb614e0bd40548f01562c3bad8bc95fb4a57a404') {
      PMJS.optimizations.refuse(id, 'unrecognized choice measurement composition');
      return;
    }
    prototype.maxChoiceWidth = function() {
      if (PMJS.isatSourceQualification !== qualification || this.textWidthEx !== measure || this.processNormalCharacter !== character ||
          !replaceable(this, ['textWidthEx', 'processNormalCharacter'])) {
        return width.apply(this, arguments);
      }
      var ownMeasure = Object.getOwnPropertyDescriptor(this, 'textWidthEx');
      var bounds = new Map();
      this.textWidthEx = function() {
        var window = this, contents = window.contents, saved = [], characters = 0;
        var ownCharacter = Object.getOwnPropertyDescriptor(window, 'processNormalCharacter');
        window.processNormalCharacter = function(state) {
          // The first glyph retains font selection. Prove the remaining ink is
          // outside the bitmap before skipping its discarded width and raster.
          if (++characters === 2 && window.contents === contents && !window._wordWrap &&
              typeof state.text === 'string' && !/[\\\x00-\x1f<>]/.test(state.text) &&
              contents && Number.isFinite(contents.fontSize) && contents.fontSize > 0 &&
              Number.isFinite(contents.outlineWidth) && contents.outlineWidth >= 0 &&
              state.y >= contents.height && Number.isFinite(state.height) &&
              PMJS.web.canvas.supportsNativeText(contents._context, 0, 'left') &&
              contents.measureTextWidth === glyphWidth &&
              contents._drawTextOutline === outline && contents._drawTextBody === body &&
              replaceable(contents, ['measureTextWidth', '_drawTextOutline', '_drawTextBody'])) {
            var context = contents._context, ascent = 0;
            context.save();
            try {
              var font = context.font = contents._makeFontNameText();
              // MV draws UTF-16 units separately, so shaped whole-word bounds
              // cannot establish the bounds of combining or surrogate units.
              new Set(state.text.slice(state.index).split('')).forEach(function(unit) {
                var key = font + '\0' + unit;
                if (!bounds.has(key)) {
                  var metrics = context.measureText(unit);
                  bounds.set(key, Math.max(metrics.actualBoundingBoxAscent,
                    metrics.fontBoundingBoxAscent));
                }
                ascent = Math.max(ascent, bounds.get(key));
              });
            } finally { context.restore(); }
            var baseline = Math.floor(state.y) +
              (Math.floor(state.height) + contents.fontSize * 0.7) / 2;
            if (Number.isFinite(ascent) &&
                baseline - ascent - contents.outlineWidth / 2 >= contents.height + 1) {
              ['measureTextWidth', '_drawTextOutline', '_drawTextBody'].forEach(function(name) {
                saved.push([name, Object.getOwnPropertyDescriptor(contents, name)]);
                contents[name] = function() { return 0; };
              });
            }
          }
          return character.apply(this, arguments);
        };
        try { return measure.apply(window, arguments); }
        finally {
          saved.forEach(function(entry) { restore(contents, entry[0], entry[1]); });
          restore(window, 'processNormalCharacter', ownCharacter);
        }
      };
      try { return width.apply(this, arguments); }
      finally { restore(this, 'textWidthEx', ownMeasure); }
    };
  });
})();

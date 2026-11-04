'use strict';

(function() {
  var id = 'isat.plain-word-measure';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary message-plugin word measurement' });

  // Install after the shared measurement adapter has retained its raster fallback.
  PMJS.phases.on('afterPlugins', 'pmjs.isat.plain-word-measure', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    var prototype = globalThis.Window_Base && Window_Base.prototype;
    var original = prototype && prototype.textWidthExCheck;
    var width = globalThis.VictorEngine && VictorEngine.ControlText &&
      VictorEngine.ControlText.textWidth;
    var translation = globalThis.SRD && SRD.TranslationEngine;
    var translate = translation && translation.translate;
    var hash = PMJS.isatMethodHash;
    if (!hash || ['804a24c50bf504ffbd22f3ace97615df230de185b62142f81724943769ced5e5',
      'fc1203743462afe37933f20f43c9b2cb852c9c7f65c6b61103820297f9a86759'].indexOf(hash(original)) < 0 ||
        hash(width) !== '635335e3101550eb65e6637734042672491e6f2d528af031ea11a82f1cf438b5' ||
        hash(translate) !== 'c646ad77520444a09cd56800d5c701be21662de32604ccbc39979725b5046f91') {
      PMJS.optimizations.refuse(id, 'unrecognized message-plugin measurement composition');
      return;
    }
    var controlText = /[\\\x1b\r\n\f<>]/;
    prototype.textWidthExCheck = function(text) {
      if (PMJS.isatSourceQualification !== qualification ||
          VictorEngine.ControlText.textWidth !== width || translation.translate !== translate ||
          typeof text !== 'string' || !text || controlText.test(text)) {
        return original.apply(this, arguments);
      }
      var translated = translate.call(translation, text);
      if (typeof translated !== 'string' || controlText.test(translated)) {
        return original.apply(this, arguments);
      }
      var contents = this.contents, previousWrap = this._wordWrap;
      var previousTranslation = !!contents._allowTextTranslation, total = 0;
      this._wordWrap = false;
      this.saveCurrentWindowSettings();
      this._checkWordWrapMode = true;
      contents.setTextTranslation(false);
      try {
        this.resetFontSettings();
        for (var i = 0; i < translated.length; i++) {
          // The saved character-width alias runs before drawing's font selection.
          total += width.call(this, translated.charAt(i));
          contents.loadOptionsFont();
        }
        return total;
      } finally {
        contents.setTextTranslation(previousTranslation);
        this._checkWordWrapMode = false;
        this.restoreCurrentWindowSettings();
        this.clearCurrentWindowSettings();
        this._wordWrap = previousWrap;
      }
    };

  });
})();

'use strict';

PMJS.isatSourcePatches.register('js/plugins/Olivia_AnimatedPictures.js', 'animated-picture load race', (src) => {
  const marker = '/* isat-port: bind callback to requested bitmap */';
  if (src.includes(marker)) return null;

  const newline = src.includes('\r\n') ? '\r\n' : '\n';
  const before = [
    '  if (this._isAnimatedPicture) {',
    '    this.bitmap.addLoadListener(this.updateAnimatedPictureFrame.bind(this));',
    '  } else {',
    '    this.bitmap.addLoadListener(this.resetFrame.bind(this));',
    '  }',
  ].join(newline);
  if (!src.includes(before)) return src;
  const after = [
    `  var requestedBitmap = this.bitmap; ${marker}`,
    '  requestedBitmap.addLoadListener(function () {',
    '    if (this.bitmap !== requestedBitmap) return;',
    '    if (this._isAnimatedPicture) this.updateAnimatedPictureFrame();',
    '    else this.resetFrame();',
    '  }.bind(this));',
  ].join(newline);
  return src.replace(before, after);
});

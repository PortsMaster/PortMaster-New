'use strict';

PMJS.isatSourcePatches.register('js/plugins/master2015hp_InStarTimeSnippet.js', 'pending bust choice indent', (src) => {
  const marker = '/* isat-port: pending bust keeps choice indent */';
  if (src.includes(marker)) return null;
  const before =
    'if ($gameTemp._displayingBust || (this._messageBodyBustSprite.bitmap && this._messageBodyBustSprite.alpha > 0)) {';
  if (!src.includes(before)) return src;
  const after =
    'if ($gameTemp._displayingBust || this._messageBodyBustSprite._bustName ||\n' +
    '\t\t(this._messageBodyBustSprite.bitmap && this._messageBodyBustSprite.alpha > 0)) { ' +
    marker;
  return src.replace(before, after);
});

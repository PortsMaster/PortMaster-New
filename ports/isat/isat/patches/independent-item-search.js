'use strict';

PMJS.isatSourcePatches.register('js/plugins/YEP_ItemCore.js', 'stop exhausted independent-item searches', (src) => {
  const marker = '/* isat-port: stop exhausted item search */';
  if (src.includes(marker)) return null;
  const newline = src.includes('\r\n') ? '\r\n' : '\n';
  const before = 'var target = $gameParty.getMatchingBaseItem(item, includeEquip);' + newline +
    '          if (target !== null) this.removeIndependentItem(target, includeEquip);';
  if (src.split(before).length !== 2) return src;
  return src.replace(before,
    'var target = $gameParty.getMatchingBaseItem(item, includeEquip);' + newline +
    '          if (target === null) break; ' + marker + newline +
    '          this.removeIndependentItem(target, includeEquip);');
}, 'optimization');

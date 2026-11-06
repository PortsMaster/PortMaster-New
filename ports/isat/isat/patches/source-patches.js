'use strict';

(function() {
  var patches = [], files = new Set();
  var readText = NativeHost.fs.readText;
  PMJS.isatSourcePatches = { register: function(file, label, transform, kind) {
    files.add(file);
    patches.push({ file: file, label: label, transform: transform, kind: kind });
  } };

  function patchedReadText(file) {
    var source = readText.apply(this, arguments);
    if (source === null || !files.has(file)) return source;
    var output = source;
    var changed = [];
    var stale = [];
    patches.forEach(function(patch) {
      if (patch.file !== file) return;
      var label = patch.label, transform = patch.transform, kind = patch.kind;
      if (kind === 'optimization' && (typeof PMJS.isatSourceMatches !== 'function' ||
          !PMJS.isatSourceMatches(file, source))) {
        stale.push(label + ' source');
        return;
      }
      var after = transform(output);
      if (after === null) return;
      if (after === output) stale.push(label);
      else { output = after; changed.push(label); }
    });
    // A rejected source contract must not leave a partial plugin rewrite.
    if (stale.length) {
      console.warn('[pmjs-isat] source patches skipped for ' + file +
        ': unrecognized ' + stale.join(', '));
      return source;
    }
    if (changed.length) console.log('[pmjs-isat] ' + file + ': ' + changed.join(', '));
    return output;
  }
  NativeHost.fs.readText = patchedReadText;

  PMJS.phases.on('afterGuestPlugins', 'port.isat-source-patches', function() {
    if (NativeHost.fs.readText === patchedReadText) NativeHost.fs.readText = readText;
  });
})();

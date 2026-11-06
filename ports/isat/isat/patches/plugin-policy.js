'use strict';

(function() {
  PMJS.phases.on('beforePlugins', 'port.isat-plugin-policy', function() {
    $plugins.forEach(function(plugin) {
      if (plugin.name === 'ExportMessagesToText') plugin.status = false;
      if (plugin.name === 'OrangeGreenworks') plugin.status = true;
      if (plugin.name === 'master2015hp_InStarTimeSnippet' && plugin.parameters) {
        plugin.parameters['draw pressed gamepad'] = 'false';
      }
    });
  });
})();

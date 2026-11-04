'use strict';

(function() {
  PMJS.phases.on('afterPlugins', 'pmjs.isat.intro-picture-handoff', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) return;
    var original = Game_Interpreter.prototype.command235;
    var handoff = [
      [231, [8, 'event_act1_0intro5d', 0, 0, 0, 0, 100, 100, 255, 0]],
      [230, [6]],
      [235, [7]],
      [235, [8]],
      [241, [{ name: '', volume: 90, pitch: 100, pan: 0 }]],
      [108, null],
      [223, [[0, 0, 0, 0], 1, false]],
      [245, [{ name: '000_sounds_birds', volume: 100, pitch: 100, pan: 0 }]],
      [231, [9, 'event_act1_1intro1', 0, 0, 0, 0, 100, 100, 255, 0]]
    ];
    function matches(interpreter) {
      return PMJS.isatSourceQualification === qualification &&
        interpreter._mapId === 2 && interpreter._eventId === 7 && interpreter._index === 70 &&
        interpreter._params[0] === 8 && handoff.every(function(expected, index) {
          var command = interpreter._list && interpreter._list[67 + index];
          return command && command.code === expected[0] && command.indent === 0 &&
            (expected[1] === null || JSON.stringify(command.parameters) === JSON.stringify(expected[1]));
        });
    }
    Game_Interpreter.prototype.command235 = function() {
      if (matches(this)) {
        // Keep the previous cover until the next picture can replace it in this update.
        var bitmap = ImageManager.loadPicture('event_act1_1intro1');
        if (bitmap && !(typeof bitmap.isError === 'function' && bitmap.isError()) && !bitmap.isReady()) return false;
      }
      return original.apply(this, arguments);
    };
  });
})();

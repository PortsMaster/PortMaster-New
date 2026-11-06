'use strict';

(function() {
  // Reviewed MV event methods, pinned independently for LF and CRLF source.
  var sources = {
    "executeCommand": [
        "c6a9443115bd0cea0121f5486b7c9bf0778861dee46e14f7f572f90793c3e247",
        "6af0ec2eb00d7771603675da53bbd2f47da3a6596929505ea7e0f6b2309aef6b"
    ],
    "currentCommand": [
        "900f935c4e9b987e2f42cd4ffc67bdc1a2bf3d79fffde90542102d8560623049",
        "8f1a53bf9315462d35f5209e57daf03fc7daceb1120bcec3153c81b306c3d1ad"
    ],
    "skipBranch": [
        "d46200b0393442b183a909a658ad22589e712dffd36af5a4846d5778b07a96a6",
        "b3750c22009ffbf1adc7d98559b62fe3cb568dbce85031bf280173cbe2bb2972"
    ],
    "jumpTo": [
        "fb89a37c475e17e9f6eefd4a302830950b0618a0568a94c47e29583c4dee3f36",
        "35538a7c3b4702aaa64b3bc967d9e29072f55212257ca3a15e562cb1356ec1f0"
    ],
    "nextEventCode": [
        "c7548d9583c852e91b0ffe6198cecc82fee9129ba10234aa0ee2596df05973a4",
        "1398a8626608b27cc542d528cac70cac2ef5858edcaa5d4396c9d4de5ec8eda6"
    ],
    "command108": [
        "053ffb4c0e69c4c66c18a3cf2f3764d4cf6328436c824a72477030f4898a191a",
        "fa186212b1a1fc484e5306379afdde542e8e7a7da426f186eed4b2dceed61a24"
    ],
    "command112": [
        "59d970ec76aa49dd256286168f3a2fb122e03247533834e3703df8f7590ae7ba",
        "dd342a23179cec37ba93288997a7f2a399d79c3820e2f58900c48e19b6e99af5"
    ],
    "command113": [
        "bd7c7ec73d9f35776bcd27e9cf724a24d5bede6d4a92c70a5c73b981e0fa104f",
        "74931a02ff1ec1d4048eb7157d888737b6e495aaa24a51dd25c178cba0e0c93e"
    ],
    "command115": [
        "1c9957515e9011ec37edfcb1519a9adfef6121c2f386380a3ecb4245263f3888",
        "3e75f801190c65945453790baccb88120367ab7f78f1035c921eec0f63fe8978"
    ],
    "command118": [
        "59d970ec76aa49dd256286168f3a2fb122e03247533834e3703df8f7590ae7ba",
        "dd342a23179cec37ba93288997a7f2a399d79c3820e2f58900c48e19b6e99af5"
    ],
    "command119": [
        "af7534878d04dec2710d59d994ed1d9784dd6fcfd139af23ffacbb6dcac15117",
        "a56ee71745db46cd243a62dae63ae9562e9e51ad777097302b27cdcd2b3d98b4"
    ],
    "command411": [
        "14a446c78043a1ca6c00b2531de53c3b0e29f9b37147bbc6155baf712a95a1aa",
        "0d2d6977aefe97bfadb23a566799f6b293454ddacf7b3190eb7ebe3c803a5b6b"
    ],
    "command413": [
        "cb52497e3763b41b5fccfb4c105d73452458bc3c28d02ff2d3892e1afd7b7aa7",
        "105ad7c6bce561bf339ba14e52c541d0f970c822562720e457d66730e49ea34f"
    ]
};
  // Whole-list identity establishes origin; loop slices are rechecked on entry.
  var pollingLists = [
    // Map 2, event 13, page 1: Nap.
    { map: 2, event: 13, length: 115, hash: '0ef8f8b9bb9fdb62ffc8ea0a14bf64b9ec549382eedd376939b91ee128162020',
      loops: [[9, 109, 'a3633da0c4f3b1e93896916d17e6c2b47e69f790fddeaf0e9e1605fb3271e23b']] },
    // Map 6, event 1, page 0: title.
    { map: 6, event: 1, length: 44, hash: '02f05ee7c298098f96cd825f62ea8686b4c6b26578fcff1f0abfff685c6664c8',
      loops: [[4, 23, 'fe9948990307b0a327a78faf6c8d87658467b49edb07210d875faf9c21d03b18']] },
    // Common events 18 and 216 share the same fast-skip list.
    { length: 55, hash: 'ed67855735521e6b5c4ff635184058a7879f1947fa277394296c959150b02023',
      loops: [[21, 29, '2cac4e2d59aefe33b2c59c892ac289abff621226371a9ae78d0e9bfdb1352a87']] },
    // Common event 25: two fast-skip loops.
    { length: 121, hash: '70b3886b3dfd62f46c8cb850cb3b13507f8ae42842af692bfb1e726525009433',
      loops: [[35, 43, '2cac4e2d59aefe33b2c59c892ac289abff621226371a9ae78d0e9bfdb1352a87'],
        [107, 115, '4abec658b9f24e1e6a928d091bb2ac83445e57f0a5798f1a1243497c7456e1f4']] },
    // Common event 108: teleport menu and selector.
    { length: 704, hash: '4c4c46347b06ca237b0d1eddfbb5df13cd111588d518e7ce160dbd9cddbe8a22',
      loops: [[38, 142, '6e31d3f00a223254cc2cc883d6df5b699d9f5bd83940a4a655468e6754f98d1e'],
        [449, 702, 'b36ccf82f1292f18a046e4233298ec36553a4a13f698b08fef9d90ce672d7fa7']] },
    // Common event 115: first Game Over menu.
    { length: 75, hash: '88527be598c4659ecdaf4879753d0a45ea62b4ecab083ea4dd9db02f9a4629b0',
      loops: [[25, 70, 'aecae8e6329b6ff1244499f4b8db1f316295011b44c1fc893705ee4a9fbb6754']] }
  ];
  var controls = [108, 112, 113, 115, 118, 119, 411, 413];
  var helpers = ['currentCommand', 'skipBranch', 'jumpTo', 'nextEventCode'];

  function reviewed(method, name) {
    return PMJS.methods.matchesSource(method, sources[name]);
  }

  PMJS.phases.on('afterPlugins', 'pmjs.isat.input-polling', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) return false;
    if (!globalThis.Yanfly || !Yanfly.SSV || !Yanfly.Core) return false;
    var prototype = Game_Interpreter.prototype;
    var previous = prototype.executeCommand._pmjsIsatInputPolling;
    if (previous) return prototype.update === previous.update;
    var conditionMethods = [prototype.command111, Yanfly.SSV.Game_Interpreter_command111,
      Yanfly.Core.Game_Interpreter_command111];
    var hashes = [
      '617a68b21ac021fcc91a3ab813554c244470f8283d592bd35e96619c9fa2cdff',
      '78ac10b42be74944c82a73bb27472c08a062670c0e1844e122fd01fd2c6b1a02',
      'c94f01bccefd3acac08ab3283e3a6923c6217afa61a9ea7b7064d27efe07f5d7'
    ];
    var crypto = __pmjsBuiltinRequire('node:crypto');
    if (!conditionMethods.every(function(method, index) {
      return typeof method === 'function' && crypto.createHash('sha256').update(
        Function.prototype.toString.call(method).replace(/\s/g, '')).digest('hex') === hashes[index];
    })) {
      console.warn('[pmjs-isat] input polling skipped: unrecognized conditional methods');
      return false;
    }
    var dependencies = [
      [Input, 'isPressed'], [Game_Switches.prototype, 'value'],
      [Game_Variables.prototype, 'value'], [Game_SelfSwitches.prototype, 'value'],
      [Game_Temp.prototype, 'setSelfSwVarEvent'], [Game_Temp.prototype, 'clearSelfSwVarEvent'],
      [DataManager, 'isSelfSwitch'], [DataManager, 'isSelfVariable']
    ].map(function(entry) { return [entry[0], entry[1], entry[0][entry[1]]]; });
    function acceptsCondition(parameters) {
      if (PMJS.isatSourceQualification !== qualification || prototype.command111 !== conditionMethods[0] ||
          Yanfly.SSV.Game_Interpreter_command111 !== conditionMethods[1] ||
          Yanfly.Core.Game_Interpreter_command111 !== conditionMethods[2]) return false;
      if (dependencies.some(function(entry) { return entry[0][entry[1]] !== entry[2]; })) return false;
      if ([0, 1, 11].indexOf(parameters[0]) >= 0) return true;
      if (parameters[0] !== 12 || parameters[1] !== 'RG19.OpenPS5Activity() == true') return false;
      var activity = globalThis.RG19 && RG19.OpenPS5Activity;
      return typeof activity === 'function' && Function.prototype.toString.call(activity)
        .replace(/\/\*[\s\S]*?\*\/|\/\/[^\n]*/g, '').replace(/\s/g, '') === 'function(){}';
    }
    var proto = prototype;
    if (!reviewed(proto.executeCommand, 'executeCommand')) return false;
    var methods = {};
    for (var name of helpers.concat(controls.map(function(code) { return 'command' + code; }))) {
      if (!reviewed(proto[name], name)) return false;
      methods[name] = proto[name];
    }
    var frames = new WeakMap(), lists = new WeakMap();
    function digest(value) {
      var text;
      try { text = JSON.stringify(value); }
      catch (_) { return null; }
      return crypto.createHash('sha256').update(text).digest('hex');
    }
    function ownerMatches(interpreter, contract) {
      return !contract.map || interpreter._mapId === contract.map && interpreter._eventId === contract.event;
    }
    function reviewedList(interpreter) {
      var list = interpreter._list;
      if (!Array.isArray(list)) return null;
      if (!lists.has(list)) {
        var candidates = pollingLists.filter(function(contract) { return contract.length === list.length; });
        var hash = candidates.length ? digest(list) : null;
        lists.set(list, candidates.find(function(contract) { return contract.hash === hash; }) || null);
      }
      var contract = lists.get(list);
      return contract && ownerMatches(interpreter, contract) ? contract : null;
    }
    function reset(frame, list) {
      frame.list = list;
      frame.visited.clear();
      frame.input = false;
      frame.loop = null;
    }

    var originalUpdate = proto.update;
    var originalExecute = proto.executeCommand;

    function eligible(interpreter, command, frame) {
      if (frame.refused) return false;
      var contract = reviewedList(interpreter);
      if (!contract) return false;
      var loop = contract.loops.find(function(range) { return interpreter._index >= range[0] && interpreter._index <= range[1]; });
      if (!loop) return false;
      if (frame.loop !== loop) {
        if (digest(interpreter._list.slice(loop[0], loop[1] + 1)) !== loop[2]) {
          frame.refused = true;
          return false;
        }
        frame.loop = loop;
      }
      if (interpreter.executeCommand !== execute) return false;
      for (var name of helpers) {
        if (interpreter[name] !== methods[name]) return false;
      }
      var code = command.code, method = interpreter['command' + code];
      if (code === 111) {
        return method === conditionMethods[0] && acceptsCondition(command.parameters);
      }
      if (code === 0 || code === 408 || code === 412) return method === undefined;
      return controls.includes(code) && method === methods['command' + code];
    }

    function execute() {
      var frame = frames.get(this);
      if (frame) {
        if (frame.list !== this._list) reset(frame, this._list);
        var command = this._list && this._list[this._index];
        if (!command || !eligible(this, command, frame)) {
          reset(frame, this._list);
        } else {
          if (frame.input && frame.visited.has(this._index)) return false;
          if (command.code === 111 && command.parameters[0] === 11) frame.input = true;
          if (frame.input) frame.visited.add(this._index);
        }
      }
      return originalExecute.apply(this, arguments);
    }

    function update() {
      var parent = frames.get(this);
      // Reentrant execution can change the outer interpreter's branch and index.
      if (parent) reset(parent, this._list);
      if (PMJS.isatSourceQualification !== qualification || !reviewedList(this)) return originalUpdate.apply(this, arguments);
      frames.set(this, { list: this._list, visited: new Set(), input: false });
      try {
        return originalUpdate.apply(this, arguments);
      } finally {
        if (parent) {
          reset(parent, this._list);
          frames.set(this, parent);
        } else {
          frames.delete(this);
        }
      }
    }

    proto.executeCommand = execute;
    proto.update = update;
    execute._pmjsIsatInputPolling = { update: update };
    return true;
  });
})();

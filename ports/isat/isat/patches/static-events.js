'use strict';

(function() {
  var id = 'isat.dormont-static-events';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'retain complete event updates' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.static-events', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    if (typeof Game_CharacterBase !== 'function' || typeof Game_Character !== 'function' ||
        typeof Game_Event !== 'function' || typeof Game_Map !== 'function' ||
        !globalThis.Galv || !Galv.CA || !globalThis.Yanfly || !Yanfly.ECP) {
      PMJS.optimizations.refuse(id, 'missing event update lifecycle');
      return;
    }
    var crypto = __pmjsBuiltinRequire('node:crypto');
    // The settled path replaces this particular MV and enabled-plugin composition.
    var methodHashes = {
      "Game_CharacterBase": {
        "update": "04098e3a1b7f7ba15899363ba3c55cc1feefe6634eb76fb919ffcc93f4f09bc3",
        "isStopping": "512524ace608cd7840e7d2ec7210122c5cf4bbe511e312935dffa1c9f2caaa44",
        "isMoving": "b92add69b21d4bb28627c7a80fa6d39f2a0ef7460e640fdcc8cf5faa5a3abf44",
        "isJumping": "31ded315c2d5fb64f6cd250e259a719a6816c1fd3bd03649655ece198261ffb3",
        "updateStop": "34fb2ed5b2618a05a926f67d0537f56a17063f07bd30690bc3ebdb3535f5382d",
        "updateAnimation": "a979bea93ae33b8dcab820a0bf70b105a770c5b100cbd4468a5e62e6bd35dac8",
        "updateAnimationCount": "b0b9d6d2e34b3a1b8fd9f55affc90211e825fbafa79402101564da7acf8f551f",
        "hasWalkAnime": "615f890140a07db8e7b6902ae0a9c3896fca75d22d075e42350cab0bcd82db94",
        "hasStepAnime": "d159e9e6ace144f94d91bc3eb3826ee348bc20f5ad6250641dfa90dfa38c9903",
        "animationWait": "afef201f811c50e0a33b3b62c69951a4b621fee1fa296b5ae4f68c8e4ac7ac50",
        "realMoveSpeed": "3c289bceffbdbf56ec759dd622a998b979711d60b585bfadf16cb55861adaf63",
        "pattern": "c02695471190a7154daaab964ab1acb5bf568ce4835de30e3134e3b630c4fa2f"
      },
      "Game_Character": {
        "update": "a1aef3f436ea4bd65999dc642df7ecc4a498d51273ba03915a4d4cf76cea0ff0",
        "updateStop": "289aa92502b7a5c5fdb2353b23daf033d43dd040bf8a7766613636e0ecaab272"
      },
      "Game_Event": {
        "update": "bb262f884566eca8b4309e93526215993196b1532c0b57949118834e30d74f35",
        "updateStop": "2e009ee0a6cc87d18082b3b084b14c1daaabb9c4af0c37872dd2778e6f9e4bfc",
        "updateSelfMovement": "bbdce487a7f494aba16971ab8c5c1636b877a49f7d8d9c2ccca529fb349a19d3",
        "preventSelfMovement": "3f4b63d54f9c987e1a41eba7a2f8c31f034962dc13d8e1a3a2a18b184046889a",
        "checkEventTriggerAuto": "104325ef5c20d4de6b1762d0e69a2abab2a4e6f3a36e6bd2e3b24ca3eefc6bac",
        "updateParallel": "cc6500bed6f16926a0b79a74551f7b8e501da70d3b883890a3e80cb03bb7349d",
        "updateAlert": "63891ee06f3bfc5246ed6e7a3818f638d4033da8cb3ed99e2a9ca9c0546938d4",
        "alertConditions": "58dbf09fe5aca51a1db5789af1470bc71bb9f05bad72f1fef3c26b4cad6d6096",
        "updateReturnPhase": "fcf4240ef6ee6d42fd688612e5f49fc1ae7a81ea04a86b142e20dd0443923559",
        "isOriginalPattern": "3132b9f43be2fecc1d7b7b289349bd980f210e40ca57d9f3bac9859649a9830c",
        "isDashing": "a2f71ded7151b9580dd20cd3d48f6e92b66f45f3c6d84157dc581c7812571fa8"
      }
    };
    var classes = { Game_CharacterBase: Game_CharacterBase,
      Game_Character: Game_Character, Game_Event: Game_Event };
    var watched = [];
    function digest(method) {
      return typeof method === 'function' ? crypto.createHash('sha256')
        .update(Function.prototype.toString.call(method).replace(/\s/g, '')).digest('hex') : null;
    }
    for (var className in methodHashes) {
      for (var name in methodHashes[className]) {
        var prototype = classes[className].prototype;
        var method = prototype[name];
        if (digest(method) !== methodHashes[className][name]) {
          PMJS.optimizations.refuse(id, 'unrecognized ' + className + '.' + name);
          return;
        }
        watched.push([prototype, name, method]);
      }
    }
    var base = Game_CharacterBase.prototype;
    var event = Game_Event.prototype;
    var originalUpdate = event.update;
    var mapUpdate = Game_Map.prototype.updateEvents;
    var inheritedUpdate = Galv.CA.Game_Character_update;
    var originalEvent = Yanfly.ECP.Game_Event_update;
    if (inheritedUpdate !== base.update || digest(originalEvent) !==
        'a6b05d7321af1ce2f96de01e1de90276e771f54803a7d23aa8fada5d1f7b9ddf') {
      PMJS.optimizations.refuse(id, 'unrecognized event update predecessors');
      return;
    }
    watched.push([Galv.CA, 'Game_Character_update', inheritedUpdate],
      [Yanfly.ECP, 'Game_Event_update', originalEvent]);
    var inQualifiedMapUpdate = false;
    function settled(target) {
      return Object.getPrototypeOf(target) === event && target._erased === false &&
        target._moveType === 0 && target._trigger >= 0 && target._trigger < 3 &&
        !target._interpreter && target.disableCharAnims === true &&
        target._realX === target._x && target._realY === target._y &&
        target._jumpCount === 0 && target._locked === false &&
        target._moveRouteForcing === false && target._stepAnime === false &&
        target._isDashing === false &&
        (target._pattern < 3 ? target._pattern : 1) === target._originalPattern &&
        target._animationCount >= 0 && target._animationCount < (9 - target._moveSpeed) * 3 &&
        target._chasePlayer === false && target._fleePlayer === false &&
        target._alertPlayer === false && target._returnPhase === false &&
        typeof target._stopCount === 'number' && Number.isFinite(target._stopCount) &&
        typeof target._alertLock === 'number' && Number.isFinite(target._alertLock) &&
        target.updateStop === event.updateStop && target.updateAnimation === base.updateAnimation &&
        target.updateSelfMovement === event.updateSelfMovement && target.updateAlert === event.updateAlert &&
        target.updateReturnPhase === event.updateReturnPhase && target.updateParallel === event.updateParallel &&
        target.checkEventTriggerAuto === event.checkEventTriggerAuto;
    }
    function updateSettledEvent() {
      if (inQualifiedMapUpdate && settled(this)) {
        // Both clocks advance even when this event has no other work to perform.
        this._stopCount++;
        this._alertLock--;
        return;
      }
      return originalUpdate.apply(this, arguments);
    }
    event.update = updateSettledEvent;
    for (var index = 0; index < watched.length; index++) {
      if (watched[index][0] === event && watched[index][1] === 'update') {
        watched[index][2] = updateSettledEvent;
      }
    }
    Game_Map.prototype.updateEvents = function() {
      var previous = inQualifiedMapUpdate;
      inQualifiedMapUpdate = PMJS.isatSourceQualification === qualification && this._mapId === 30;
      if (inQualifiedMapUpdate) {
        for (var index = 0; index < watched.length; index++) {
          if (watched[index][0][watched[index][1]] !== watched[index][2]) {
            inQualifiedMapUpdate = false;
            break;
          }
        }
      }
      try {
        return mapUpdate.apply(this, arguments);
      } finally {
        inQualifiedMapUpdate = previous;
      }
    };
  });
})();

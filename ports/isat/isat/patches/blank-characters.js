'use strict';

(function() {
  var id = 'isat.dormont-blank-characters';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'run the ordinary character presentation update chain' });
  PMJS.phases.on('beforeBoot', 'pmjs.isat.blank-characters', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    if (!qualification || qualification.verified !== true) {
      PMJS.optimizations.refuse(id, 'unqualified ISAT sources');
      return;
    }
    var req = typeof __pmjsBuiltinRequire === 'function' ? __pmjsBuiltinRequire : require;
    var refusals = [];
    var hashes = {
      "Sprite_Character": {
        "update": [
          "a9c8a84156f5a958c8288082830fc79b4be6cf9227259ae6e7de4c59275e6d63"
        ],
        "updateBitmap": [
          "0ad23bbdcb8599da64e6cdba9c08ee16a48be70048a458e2d6f1bbdc0feef983"
        ],
        "isImageChanged": [
          "e92423027f7224d82502c383d48e2670355d1026281124d59c4e7e09e11fac2a"
        ],
        "updateFrame": [
          "b79ffabdab714138327909a3f01d9d9afd60f63f025bfae134aad51366f052dd"
        ],
        "updateCharacterFrame": [
          "df204cc18118e6f2fda30f909d02b1ac43e161b37178ae17c888891d562f7d8f",
          "2bdf1fd784784daca14e0a7a9fc152c857a6e4c7b8cbd54a73a2c15936b8aec9"
        ],
        "updatePosition": [
          "8e809e963340dce69243818d148e91b6458d76149e001ef7fef076a7384544d8"
        ],
        "updateAnimation": [
          "9e7fee5b9e71ed5723751fc6547f5f9040bbb5a49b5d6a56802db1de4b5230f0"
        ],
        "updateOther": [
          "b3032277645e1c76020e9afc394c6c5ff88cbdc6a6b997ac6feb14e94e60a9a7"
        ],
        "updateVisibility": [
          "b086c3733259d2f3b01a886205f8e7523f4629eff2bf359f35073e14eac53e11"
        ],
        "updateBalloon": [
          "59f08aa025c126497008b3ace825544b661250d1f57b33ed89d09c15b9b5b358",
          "2cb485166e64389e7d18f40597daabc49019a6b95dcb714ac909d51f7a452f8b"
        ],
        "setupBalloon": [
          "645b2a4c7498169766bfcbb85c2aad0d6ff47a8a26e654c779a12414b55ebaba"
        ],
        "startBalloon": [
          "c73398827aceab224def201343956db8ed48e9a6bbcf147f730b02ee714084c8"
        ],
        "endBalloon": [
          "9054688d8cf5f11caca79aeca7aaad2ac94ca6cbdf9767e7ce43e8831cbde554"
        ],
        "isBalloonPlaying": [
          "10eb22c88e6e13c6dcac7a25dea27a5330655aba4452fd338d4595d44d42f51f"
        ],
        "setupAnimation": [
          "867b2cf943ca7c6417a513a2d494ec16f34fc802531a1d237d97bc04eadf9790"
        ],
        "updateHalfBodySprites": [
          "0dc95c24a4048049298b1e54559c635f82f11eb5ed780d514bfc099fdb823bc2",
          "e552fd05edff096b4868f5e1d6b05076d947dba3e2ab07b5a753d4010b45fa0b"
        ],
        "patternWidth": [
          "13e0b1e14099fc5d6678100a59b9d8d23b29f4a42cef09f25061823023846b7f"
        ],
        "patternHeight": [
          "ea8a8a66748df6a374eae65149b6269d1db0c567489eb6aaa41dd764bc3ee67d"
        ],
        "characterBlockX": [
          "69e6eac8a0bf113c16d1ef8149ec4dfa2e37cdda5e915225de234687c6fc54e8"
        ],
        "characterBlockY": [
          "cefeada8bcbff467f48b94056bacc93028b9a1095e1cc0a3a9358e85614ff6c0"
        ],
        "characterPatternX": [
          "5a47f7821e60d92a694a70ee33beb90410a52b6e0d5caf706fb95a5d2780cd17"
        ],
        "characterPatternY": [
          "834752658fb8f0416bdabaf0eed4717e79b2bdde8470c48cf1dd95bbe8786b13"
        ]
      },
      "Sprite_Base": {
        "update": [
          "b62977ff0f19215e0016fc40338cfacc02506537d8dd235800a4922741148b32"
        ],
        "updateVisibility": [
          "5a234bec04841ffd890107d71bd1ee9e4d8844bacd925c6c4274668f5b2e33fd"
        ],
        "updateAnimationSprites": [
          "9a633c703b9fcec19ba54f82616731f55a23d63ac5bf9146c0039a55ba80d924"
        ],
        "isAnimationPlaying": [
          "c8277edd3d7f795f6d62a3ec297989eff1dd7e69bf4a4da9ac5a0e2ed2a0dc68"
        ],
        "startAnimation": [
          "d6d350111544a4d79d911cc4f0ba4b93c5e256cd656b38b8485c1e050d1b71a4",
          "7f0cbb6518f86cd8d32ccdf09ae831c22dbb8792b1c021f1fecb474b3f9499e6"
        ]
      },
      "Sprite": {
        "update": [
          "2ad935d876647e3e2afa96693d068cf66f0277af063815569c2ceb156a195c63"
        ],
        "synchronizeHorrorFiltersWithSource": [
          "a4ca6324145146f9262ad7d771dce505ad03059792504aea10a402c7c5daf2b6"
        ],
        "updateHorrorEffects": [
          "37019828d61b5843e7bc754e3dfcfb80e0339d1476b535e52c8c118b371b72f0",
          "f8c3b893c3baed84440abb6c077de7e2c6a3360f37ad578b8323591ad308f00b"
        ],
        "updateHorrorNoise": [
          "8966a254c2e2b968ad9e670411c6dbc1307bfaf7371384954074394abdbbbd88"
        ],
        "updateHorrorGlitch": [
          "15144ef769079223bfe9778cc413fff04bceadae56140b24aba394d0759d03a6"
        ],
        "updateHorrorTV": [
          "6235a5c3b482674171f2e812af28210118242cd27786b915eadca721e7c50d63"
        ],
        "setFrame": [
          "d2da51b9358213d5118bf62a309a473c1a331981b3fb9d03d69a874bf3a19475",
          "724eaf2b57d0ba388ba49998b3607241e20f5f341fd1a0125ee58c32707d1634"
        ],
        "_refresh": [
          "acae7d04224dd9b3d2a4de8e94c46112ee2f75e2274c9c903610ade0acea5a20",
          "7209bd252120e363461290d1133c2e67d5a04179a3a473c1d587a338b8a0717f",
          "4030923425c2591e4913e9ada805e1bd2ecb38be5533292c6de58c0ab6f33643"
        ]
      },
      "Game_CharacterBase": {
        "tileId": [
          "ccefe0efc7932c30c5e00b57be18caacd6f7d7988d56c00dd882bad61dea1ce1"
        ],
        "characterName": [
          "8ca786b24e8cf719c998d73553551ffc0842257ea2a6cec6fdbf099b2e452855"
        ],
        "characterIndex": [
          "a17e7cf1abb34748fda7a7765a4f75bd42c477ed27315d676716c5ece87b180d"
        ],
        "animationId": [
          "1ace87bd25ad99cbb720717883900291ac7e6337a756c64fcd67c753716c37ef"
        ],
        "balloonId": [
          "e8a8dd59c0d8f1f44721add8bbe14537cc89717d0a0aaac4f4ac473a40138f4e"
        ],
        "isTransparent": [
          "dd9d9ff814140e09e00ebe29f1fc77fe8ac2e48f986d91c62b1564f4cd4a081a"
        ],
        "bushDepth": [
          "82fa43b1f107118a3f6516bb08bb17e5db4d4a58b0f3eac6cac9db51ef3edaa8"
        ],
        "opacity": [
          "e2b236216f1e597cd27fb60fe3651833aebc2465f8481137603acb01d1e4159d"
        ],
        "blendMode": [
          "8f33d005893e2219070f0f5d2bbd57e9a3dc619e575b70d0e9412d9d83069243"
        ],
        "endAnimation": [
          "d113990fdeacb4ed5d336af6ca11551616e90ca5c43a6b9c7a4cb9b0864eb4ff"
        ],
        "endBalloon": [
          "07409581d887bd39c3dc5f5de9970b217b2a1ac7e66cba966afb3101136de92a"
        ],
        "screenX": [
          "059c0871416247c9a824cacda458b53396c89210d8115f10aa9dab3c0c69d243"
        ],
        "screenY": [
          "85abaf2591c5ad7138d981be6be3c7d0bbadfd43c96242d0267c8967ffa44c0d"
        ],
        "screenZ": [
          "cd565279771a9bc2d80af789edea592d8412dcdca583feda6fa477720796529f"
        ],
        "scrolledX": [
          "ba97043a3816ffebf0be1a62f826398ac952b44217601a8bddeaeaad059b2c60"
        ],
        "scrolledY": [
          "3147a79031d994738da7e45335ae33e3b0841284e3d51436365a03be41a3221c"
        ],
        "shiftY": [
          "680db84b309bfe92aec1321b974057dac9af43e234cbda3b6aa9b0e51d078c55"
        ],
        "jumpHeight": [
          "0f24616621d4b5d1568863e9309298b1acab36be247d1bc48f3465174203c1a7"
        ],
        "pattern": [
          "c02695471190a7154daaab964ab1acb5bf568ce4835de30e3134e3b630c4fa2f"
        ],
        "direction": [
          "811fbb690e1f5ecd518866a594f39a77fc9e1fc3e52f530108a0fd3dd0deb4e9"
        ]
      }
    };
    function digest(method) {
      if (typeof method !== 'function') return '';
      var text = Function.prototype.toString.call(method).replace(/\/\*[\s\S]*?\*\/|\/\/[^\n]*/g, '').replace(/\s/g, '');
      return req('node:crypto').createHash('sha256').update(text).digest('hex');
    }
    var prototypes = { Sprite_Character: Sprite_Character.prototype, Sprite_Base: Sprite_Base.prototype,
      Sprite: Sprite.prototype, Game_CharacterBase: Game_CharacterBase.prototype };
    var captured = {};
    for (var group in hashes) {
      captured[group] = {};
      for (var name in hashes[group]) {
        var method = prototypes[group][name];
        if (hashes[group][name].indexOf(digest(method)) < 0) refusals.push(group + '.' + name);
        captured[group][name] = method;
      }
    }
    var stockSpriteUpdate = globalThis.Olivia && Olivia.HorrorEffects && Olivia.HorrorEffects.___Sprite_update___;
    if (digest(stockSpriteUpdate) !== "78532174ec735787c0a11cd2f13d202337b529b526b9f7115aefdb4d082397ca") refusals.push('Olivia.Sprite_update predecessor');
    var animationPredecessor = globalThis.master2015hp && master2015hp.isatSnp && master2015hp.isatSnp.b_2;
    var masterAnimation = digest(captured.Sprite_Base.startAnimation) !== "d6d350111544a4d79d911cc4f0ba4b93c5e256cd656b38b8485c1e050d1b71a4";
    if (masterAnimation && digest(animationPredecessor) !== "d6d350111544a4d79d911cc4f0ba4b93c5e256cd656b38b8485c1e050d1b71a4") {
      refusals.push('master2015hp.startAnimation predecessor');
    }
    var refreshRecords = PMJS.methods && PMJS.methods.dump().filter(function(record) { return record.key === 'Sprite._refresh'; }) || [];
    if (digest(captured.Sprite._refresh) === "4030923425c2591e4913e9ada805e1bd2ecb38be5533292c6de58c0ab6f33643" &&
        !refreshRecords.some(function(record) { return record.id === 'pmjs.mv.native-sprite-tint' &&
          record.state === 'installed' && record.mutations.length === 0; })) {
      refusals.push('nativeRefresh registration');
    }
    var mapUpdate = Spriteset_Map.prototype.update;
    if (["4f825e15bc3d6970d76151eac35fd9e8b2238331ec8c862377668b52ba1a82f2", "08ad8110d18bbf8c9a4f622fec172408ccae413eb632f13c47abb1b432dbfa4e"].indexOf(digest(mapUpdate)) < 0) refusals.push('Spriteset_Map.update');
    if (refusals.length) {
      PMJS.optimizations.refuse(id, 'unrecognized blank-character update graph: ' + refusals.join(', '));
      return;
    }
    var original = captured.Sprite_Character.update;
    var spriteMethods = captured.Sprite_Character, baseMethods = captured.Sprite_Base;
    var characterMethods = captured.Game_CharacterBase, horrorMethods = captured.Sprite;
    var instances = new WeakMap();
    var qualifiedUpdate = false, emptyBitmap = null, wrapper;
    var knownCharacterProtos = new Set([globalThis.Game_CharacterBase, globalThis.Game_Character, globalThis.Game_Event,
      globalThis.Game_Player, globalThis.Game_Follower, globalThis.Game_Vehicle].filter(function(type) { return typeof type === 'function'; })
      .map(function(type) { return type.prototype; }));
    var reachedCharacterProtos = new Set();
    function graphUnchanged() {
      if (PMJS.isatSourceQualification !== qualification) return false;
      for (var group in captured) for (var name in captured[group]) {
        var expected = group === 'Sprite_Character' && name === 'update' ? wrapper : captured[group][name];
        if (prototypes[group][name] !== expected) {
          var horror = PMJS.isatHorrorPresentation;
          if (group !== 'Sprite' || name !== 'update' ||
              !horror || horror.ordinaryUpdate !== captured.Sprite.update || horror.stockUpdate !== stockSpriteUpdate ||
              horror.inactiveUpdate !== Sprite.prototype.update ||
              typeof horror.isInactive !== 'function' || !horror.isInactive()) return false;
        }
      }
      for (var proto of reachedCharacterProtos) for (var name in characterMethods) {
        if (proto[name] !== characterMethods[name]) return false;
      }
      return Olivia.HorrorEffects.___Sprite_update___ === stockSpriteUpdate &&
        (!masterAnimation || master2015hp.isatSnp.b_2 === animationPredecessor);
    }
    // This is ISAT's reviewed producer/helper graph. Its authored walking code does
    // not install late own helper overrides. Unknown prototypes and instance dispatch
    // use the ordinary update; this is not a general arbitrary-mutation contract.
    function qualified(sprite, character) {
      var spriteProto = Object.getPrototypeOf(sprite), characterProto = Object.getPrototypeOf(character);
      if (spriteProto !== Sprite_Character.prototype || !knownCharacterProtos.has(characterProto)) return false;
      var record = instances.get(sprite);
      if (!record || record.character !== character || record.characterProto !== characterProto) {
        var known = true;
        for (var name in spriteMethods) if (name !== 'update' &&
            (Object.prototype.hasOwnProperty.call(sprite, name) || sprite[name] !== spriteMethods[name])) known = false;
        for (var name in baseMethods) if (name !== 'update' && name !== 'updateVisibility' &&
            (Object.prototype.hasOwnProperty.call(sprite, name) || sprite[name] !== baseMethods[name])) known = false;
        for (var name in horrorMethods) if (name !== 'update' &&
            (Object.prototype.hasOwnProperty.call(sprite, name) || sprite[name] !== horrorMethods[name])) known = false;
        for (var name in characterMethods) if (Object.prototype.hasOwnProperty.call(character, name) ||
            character[name] !== characterMethods[name]) known = false;
        record = { character: character, characterProto: characterProto, known: known };
        instances.set(sprite, record);
        if (known) reachedCharacterProtos.add(characterProto);
      }
      return record.known && sprite.updateBitmap === spriteMethods.updateBitmap &&
        sprite.updateFrame === spriteMethods.updateFrame && sprite.updatePosition === spriteMethods.updatePosition &&
        sprite.updateAnimation === spriteMethods.updateAnimation && sprite.updateBalloon === spriteMethods.updateBalloon &&
        sprite.updateOther === spriteMethods.updateOther && character.characterName === characterMethods.characterName &&
        character.tileId === characterMethods.tileId && character.animationId === characterMethods.animationId &&
        character.balloonId === characterMethods.balloonId;
    }
    Spriteset_Map.prototype.update = function() {
      var previous = qualifiedUpdate, previousEmpty = emptyBitmap;
      qualifiedUpdate = !!globalThis.$gameMap && $gameMap.mapId() === 30 &&
        Object.getPrototypeOf(this) === Spriteset_Map.prototype && graphUnchanged();
      emptyBitmap = ImageManager._imageCache.get('empty');
      try { return mapUpdate.apply(this, arguments); }
      finally { qualifiedUpdate = previous; emptyBitmap = previousEmpty; }
    };
    function active(filters) { return filters && (filters.noiseFilter || filters.glitchFilter || filters.tvFilter); }
    function eligible(sprite) {
      var character = sprite._character;
      if (!character || character._characterName !== '' || character._tileId !== 0 ||
          sprite._characterName !== '' || sprite._tileId !== 0 ||
          character._animationId !== 0 || character._balloonId !== 0 ||
          character._animationPlaying !== false || character._balloonPlaying !== false ||
          character._bushDepth !== 0 || sprite._bushDepth !== 0 || sprite._balloonSprite ||
          !sprite._animationSprites || sprite._animationSprites.length || sprite.children.length ||
          sprite._horrorFiltersSource !== character || active(character._horrorFilters) || active(sprite._horrorFilters) ||
          sprite._filters && sprite._filters.length || sprite._mask || sprite.shader || sprite._cacheAsBitmap) return false;
      if (PMJS.pixi4.bitmapPresentation && PMJS.pixi4.bitmapPresentation.has(sprite)) return false;
      // MV materializes its canonical empty Bitmap as 1x1. Character framing requests
      // fractional dimensions, which Sprite._refresh floors to a zero-area raster frame.
      var bitmap = sprite._bitmap, frame = sprite._frame, real = sprite._realFrame;
      if (!bitmap || bitmap !== emptyBitmap || bitmap.width > 1 || bitmap.height > 1 ||
          !frame || frame.width < 0 || frame.width >= 1 ||
          frame.height < 0 || frame.height >= 1 || !Number.isFinite(frame.width) || !Number.isFinite(frame.height) ||
          !real || real.width !== 0 || real.height !== 0) return false;
      return qualified(sprite, character);
    }
    wrapper = Sprite_Character.prototype.update = function() {
      if (qualifiedUpdate && eligible(this)) {
        this.visible = false;
        return;
      }
      return original.apply(this, arguments);
    };
  });
})();

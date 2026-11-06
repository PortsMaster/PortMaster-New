'use strict';

(function() {
  var id = 'isat.bourdon-enemy-sprites';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat', fallback: 'authored enemy sprite initialization' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.battle-enemy-sprites', function() {
    var qualification = PMJS.isatSourceQualification;
    if (!PMJS.optimizations.isEnabled(id) || !qualification || !qualification.verified) return;
    var prototype = Sprite_Enemy.prototype;
    var initialize = prototype.initSVSprites, updateBitmap = prototype.updateSVBitmap;
    var hash = PMJS.isatMethodHash;
    if (hash(initialize) !== 'b36405c8ac32b8f03642c5a56de546570c8043cd9b89df47316ae928a78a6a3c' ||
        hash(updateBitmap) !== '4326d2c89c6efae2b6ec40e2d1a74da12cb91be12c6ef9a84f011a3b16b6c319') {
      PMJS.optimizations.refuse(id, 'unrecognized enemy sprite producers'); return;
    }
    function eligible() {
      return PMJS.isatSourceQualification === qualification && globalThis.$gameTroop && $gameTroop._troopId === 26;
    }
    function detach(owner, node) {
      if (!node || node.parent !== owner || node.children.length || node._battler || node._actor ||
          node._animationSprites && node._animationSprites.length ||
          node.bitmap && node.alpha !== 0 && (!node._frame || node._frame.width > 0 && node._frame.height > 0)) return;
      // Replaced children can still have external owners; detach without destroying them.
      owner.removeChild(node);
    }
    prototype.initSVSprites = function() {
      var previous = eligible() && !this._battler ?
        [this._shadowSprite, this._weaponSprite, this._mainSprite, this._stateSprite] : null;
      var result = initialize.apply(this, arguments);
      if (previous) {
        var current = [this._shadowSprite, this._weaponSprite, this._mainSprite, this._stateSprite];
        for (var index = 0; index < previous.length; index++) {
          if (current.indexOf(previous[index]) < 0) detach(this, previous[index]);
        }
      }
      return result;
    };
    prototype.updateSVBitmap = function() {
      var previous = this._mainSprite;
      var result = updateBitmap.apply(this, arguments);
      if (eligible() && previous !== this._mainSprite && this._createdDummyMainSprite && !this._svBattlerEnabled) {
        detach(this, previous);
      }
      return result;
    };
  });
})();

'use strict';

(function() {
  var id = 'isat.hue-neutral-assets';
  PMJS.optimizations.register({ id: id, owner: 'pmjs-isat',
    fallback: 'ordinary Bitmap hue rotation' });
  PMJS.phases.on('afterGuestPlugins', 'pmjs.isat.hue-neutral-assets', function() {
    if (!PMJS.optimizations.isEnabled(id)) return;
    var qualification = PMJS.isatSourceQualification;
    var BitmapClass = globalThis.Bitmap, ImageClass = globalThis.Image;
    if (!qualification || qualification.verified !== true || typeof BitmapClass !== 'function' ||
        typeof ImageClass !== 'function' || globalThis.NativeImage !== ImageClass) return;
    var crypto = __pmjsBuiltinRequire('crypto');
    function hash(value) { return crypto.createHash('sha256').update(value).digest('hex'); }
    var fingerprint = PMJS.isatMethodHash;
    var asset = 'img/animations/Magic1.png';
    try {
      var bytes = NativeHost.fs.readBytes(asset);
      if (!bytes || hash(new Uint8Array(bytes)) !==
          'a932bf0576103e33997f37f997997ffd9070db0f501198f2a177e96f87844b64') return;
    } catch (_) { return; }
    var prototype = BitmapClass.prototype;
    var methodHashes = {
      rotateHue: 'd06dfb21577dc1c8bf7a9cad27445b6689889bb3114583ada6432ea073be0d01',
      _createCanvas: '15bee4d3b96e9ecffbd290f02acee911a4b641b6745ebee35ec96668329af96b',
      _renewCanvas: '083b3c1f811fb9198084bd2ae2161598b3d04b5bd15a9fdff558c6d1ff8bbc7c',
      _createBaseTexture: '5cd187aedc805d097dae62313c57989f4bd4c7b64060b63907b7808e7fa17f32',
      _setDirty: '4e5d20a25fdb0a359460013d9ad7850ff223be1b59bb14ebc04f710902b82344',
      isReady: '51bc0d4f746071640dac01a5110cfafc5c426b2e4a367c4350b762ad1d064588'
    };
    var getterHashes = {
      width: '94de8defe91abc9f05c2d402e0adb6dd9b874d5fbc7d0dd0731aa70e5f70a61f',
      height: '9ebb38011062d44b36a827d3a3bd4c2ebd71d8d61ee7c492bab569c09168c45e',
      canvas: 'fcefea08b0ad03c48e81265290f3baca1608b81cd8d52c702ab1f8116f2746d4',
      context: 'a6aba8bbd9de1eb032cf60bd2368ebcc3b3064eb5d1f3aceeb35cece70c63674',
      _canvas: '0fca035973c589507512f57e7e533cace63488b011e5d9323b021ca42bff654e',
      _context: '88e5b3d3709c8875fdc0862402dd4b137246da0d42bfa667f2ad923d495e99b9',
      baseTexture: '74fa51e660ec4e25e10b409283a0baa908d82ce56afe13aefd5334348b1b0304',
      _baseTexture: 'dc3e24a95b09996189c43686b40856ae95e29dee61bf09dd09edd40a4ada905e'
    };
    var methods = {}, descriptors = {}, name;
    for (name in methodHashes) {
      methods[name] = prototype[name];
      if (fingerprint(methods[name]) !== methodHashes[name]) return;
    }
    for (name in getterHashes) {
      var descriptor = Object.getOwnPropertyDescriptor(prototype, name);
      if (!descriptor || descriptor.set || fingerprint(descriptor.get) !== getterHashes[name]) return;
      descriptors[name] = descriptor;
    }
    var imageDescriptor = Object.getOwnPropertyDescriptor(ImageClass.prototype, 'src');
    if (!imageDescriptor || fingerprint(imageDescriptor.get) !==
        '30f798057f05d98c5459e7a0953cae3044cad215e470e164230e8df87cfe2ece' ||
        fingerprint(imageDescriptor.set) !==
        '8498aece9ece6d527f67269ce569c0a8a0ca77d2f0a983f5d643c9354f6761ca') return;
    var original = methods.rotateHue, sources = new WeakMap();
    function ownData(object, key) {
      var descriptor = object && Object.getOwnPropertyDescriptor(object, key);
      return descriptor && Object.prototype.hasOwnProperty.call(descriptor, 'value') ? descriptor.value : undefined;
    }
    function emptyData(object, key) {
      var descriptor = Object.getOwnPropertyDescriptor(object, key);
      return descriptor ? Object.prototype.hasOwnProperty.call(descriptor, 'value') && descriptor.value == null : !(key in object);
    }
    function sameDescriptor(object, key, expected) {
      var actual = Object.getOwnPropertyDescriptor(object, key);
      return actual && actual.get === expected.get && actual.set === expected.set &&
        actual.enumerable === expected.enumerable && actual.configurable === expected.configurable;
    }
    function eligible(bitmap, offset) {
      if (typeof offset !== 'number' || !Number.isFinite(offset) || !offset ||
          PMJS.isatSourceQualification !== qualification || globalThis.Bitmap !== BitmapClass ||
          globalThis.Image !== ImageClass || globalThis.NativeImage !== ImageClass ||
          Object.getPrototypeOf(bitmap) !== prototype || ownData(bitmap, '_url') !== asset ||
          ownData(bitmap, '_loadingState') !== 'loaded' || !emptyData(bitmap, '__canvas') ||
          !emptyData(bitmap, '__context')) return false;
      for (var key in methods) {
        if (Object.prototype.hasOwnProperty.call(bitmap, key) ||
            bitmap[key] !== (key === 'rotateHue' ? optimized : methods[key])) return false;
      }
      for (key in descriptors) if (Object.prototype.hasOwnProperty.call(bitmap, key) ||
          !sameDescriptor(prototype, key, descriptors[key])) return false;
      var dirty = Object.getOwnPropertyDescriptor(bitmap, '_dirty');
      if (dirty ? !Object.prototype.hasOwnProperty.call(dirty, 'value') || !dirty.writable : '_dirty' in bitmap) return false;
      var image = ownData(bitmap, '_image');
      if (!image || Object.getPrototypeOf(image) !== ImageClass.prototype ||
          Object.prototype.hasOwnProperty.call(image, 'src') ||
          !sameDescriptor(ImageClass.prototype, 'src', imageDescriptor) || ownData(image, '_src') !== asset ||
          ownData(image, 'complete') !== true || ownData(image, '_pmjsLoadFailed') !== false ||
          !emptyData(image, '_nativeCanvas') || !emptyData(image, '_pmjsCanvasOwner')) return false;
      var resource = ownData(image, '_nativeImage'), handle = ownData(resource, 'handle');
      var generation = ownData(image, '_loadGeneration');
      if (!resource || !Number.isInteger(handle) || handle <= 0 || !Number.isInteger(generation) || generation <= 0 ||
          ownData(image, 'width') !== 960 || ownData(image, 'height') !== 576 ||
          ownData(image, 'naturalWidth') !== 960 || ownData(image, 'naturalHeight') !== 576 ||
          ownData(resource, 'width') !== 960 || ownData(resource, 'height') !== 576) return false;
      var base = Object.getOwnPropertyDescriptor(bitmap, '__baseTexture');
      if (!base || !Object.prototype.hasOwnProperty.call(base, 'value') || !base.value ||
          Object.getPrototypeOf(base.value) !== PIXI.BaseTexture.prototype || ownData(base.value, 'source') !== image) return false;
      var previous = sources.get(bitmap);
      if (previous && (previous.image !== image || previous.resource !== resource ||
          previous.generation !== generation || previous.handle !== handle)) return false;
      sources.set(bitmap, { image: image, resource: resource, generation: generation, handle: handle });
      return true;
    }
    function optimized(offset) {
      var previous = sources.has(this);
      if (!eligible(this, offset)) { return original.apply(this, arguments); }
      // Every pixel, including transparent RGB, is grayscale in this exact asset.
      // Preserve both dirty notifications from first Canvas realization and rotation.
      if (!previous) this._setDirty();
      this._setDirty();
    }
    prototype.rotateHue = optimized;
  });
})();

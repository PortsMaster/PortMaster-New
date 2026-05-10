#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const vm = require('vm');

// configuration
const DISPLAY_W = parseInt(process.env.DISPLAY_WIDTH) || 640;
const DISPLAY_H = parseInt(process.env.DISPLAY_HEIGHT) || 480;
const SCREEN_W = DISPLAY_W;
const SCREEN_H = DISPLAY_H;
const FB_SIZE = DISPLAY_W * DISPLAY_H * 4;
const O_NONBLOCK = 2048;
const O_RDONLY = 0;
const O_RDWR = 2;
const FRAME_MS = 33; // 30fps - v8 is fast enough

// get game file or games directory from args
const args = process.argv.slice(2);
if (args.length < 1) {
  process.stderr.write('Usage: node main.js <game.txt | games_dir/>\n');
  process.exit(1);
}

// determine if arg is a directory (menu mode) or a file (direct play)
let gamesDir = null;
let gamesList = null;
let initialGameSource = null;

const arg0 = args[0];
try {
  const stat = fs.statSync(arg0);
  if (stat.isDirectory()) {
    gamesDir = arg0.endsWith('/') ? arg0 : arg0 + '/';
  } else {
    initialGameSource = fs.readFileSync(arg0, 'utf8');
  }
} catch(e) {
  process.stderr.write('Error: cannot read ' + arg0 + '\n');
  process.exit(1);
}

// if games directory, scan for .txt files
if (gamesDir) {
  const allFiles = fs.readdirSync(gamesDir).filter(f => f.endsWith('.txt')).sort();
  gamesList = [];
  for (const fname of allFiles) {
    const content = fs.readFileSync(gamesDir + fname, 'utf8');
    let title = fname.replace('.txt', '');
    const m = content.match(/^title\s+(.+)/im);
    if (m) title = m[1].trim();
    gamesList.push({ file: gamesDir + fname, title: title });
  }
  gamesList.sort(function(a, b) { return a.title.toLowerCase().localeCompare(b.title.toLowerCase()); });
  process.stderr.write('Found ' + gamesList.length + ' games\n');
}

// open framebuffer
let fbFd;
let useStdout = false;
if (process.env.SDL2FB === '1') {
  fbFd = 1;
  useStdout = true;
} else {
  try {
    fbFd = fs.openSync('/dev/fb0', 'r+');
  } catch(e) {
    process.stderr.write('Error: cannot open /dev/fb0\n');
    process.exit(1);
  }
  // Reset framebuffer pan to page 0 (fixes blank screen on double-buffered fb)
  try { fs.writeFileSync('/sys/class/graphics/fb0/pan', '0,0'); } catch(e) {}
}

// open input devices
function sleep(ms) {
  const end = Date.now() + ms;
  while (Date.now() < end) {}
}

if (!useStdout) sleep(500);
const inputFds = [];

// check for sdl2fb input fifo
const inputFifo = process.env.PS_INPUT_FIFO;
if (inputFifo) {
  try {
    const fd = fs.openSync(inputFifo, fs.constants.O_RDONLY | fs.constants.O_NONBLOCK);
    inputFds.push(fd);
  } catch(e) {}
}

// open /dev/input/event* (for handheld/gptokeyb)
for (let i = 0; i < 20; i++) {
  try {
    const fd = fs.openSync('/dev/input/event' + i, fs.constants.O_RDONLY | fs.constants.O_NONBLOCK);
    inputFds.push(fd);
  } catch(e) {}
}
process.stderr.write('Input devices: ' + inputFds.length + '\n');

// input reading utility
const EV_SIZE = 24;
const EV_KEY = 1;
const KEY_ESC = 1;
const KEY_ENTER = 28;
const KEY_SPACE = 57;
const KEY_UP = 103;
const KEY_DOWN = 108;
const KEY_LEFT = 105;
const KEY_RIGHT = 106;
const KEY_X = 45;
const KEY_Z = 44;
const KEY_R = 19;
const KEY_W = 17;
const KEY_A = 30;
const KEY_S = 31;
const KEY_D = 32;

const inputBuf = Buffer.alloc(EV_SIZE * 8);

function readKeys() {
  const keys = [];
  for (const fd of inputFds) {
    try {
      const n = fs.readSync(fd, inputBuf, 0, inputBuf.length, null);
      if (n > 0) {
        for (let off = 0; off + EV_SIZE <= n; off += EV_SIZE) {
          const type = inputBuf.readUInt16LE(16 + off);
          const code = inputBuf.readUInt16LE(18 + off);
          const value = inputBuf.readInt32LE(20 + off);
          if (type === EV_KEY && value === 1) {
            keys.push(code);
          }
        }
      }
    } catch(e) {
      // eagain - no data available
    }
  }
  return keys;
}

// framebuffer drawing helpers for menu
const __menuBuf = Buffer.alloc(FB_SIZE);
const __menuPx = new Uint32Array(__menuBuf.buffer, __menuBuf.byteOffset, SCREEN_W * SCREEN_H);

function menuFillRect(x, y, w, h, color) {
  const x0 = Math.max(0, x);
  const y0 = Math.max(0, y);
  const x1 = Math.min(SCREEN_W, x + w);
  const y1 = Math.min(SCREEN_H, y + h);
  for (let row = y0; row < y1; row++) {
    const off = row * SCREEN_W + x0;
    for (let col = 0; col < x1 - x0; col++) {
      __menuPx[off + col] = color;
    }
  }
}

// 4x5 font for menu (uppercase + digits + symbols)
const MENU_FONT = {
  'A':[6,9,15,9,9],'B':[14,9,14,9,14],'C':[6,9,8,9,6],'D':[14,9,9,9,14],
  'E':[15,8,14,8,15],'F':[15,8,14,8,8],'G':[7,8,11,9,7],'H':[9,9,15,9,9],
  'I':[7,2,2,2,7],'J':[1,1,1,9,6],'K':[9,10,12,10,9],'L':[8,8,8,8,15],
  'M':[9,15,15,9,9],'N':[9,13,11,9,9],'O':[6,9,9,9,6],'P':[14,9,14,8,8],
  'Q':[6,9,9,10,5],'R':[14,9,14,10,9],'S':[7,8,6,1,14],'T':[7,2,2,2,2],
  'U':[9,9,9,9,6],'V':[9,9,9,5,2],'W':[9,9,15,15,9],'X':[9,9,6,9,9],
  'Y':[5,5,2,2,2],'Z':[15,1,2,4,15],
  '0':[6,9,9,9,6],'1':[2,6,2,2,7],'2':[6,1,2,4,7],'3':[6,1,2,1,6],
  '4':[9,9,7,1,1],'5':[7,4,6,1,6],'6':[6,8,14,9,6],'7':[15,1,2,2,2],
  '8':[6,9,6,9,6],'9':[6,9,7,1,6],
  ' ':[0,0,0,0,0],'-':[0,0,7,0,0],':':[0,2,0,2,0],'.':[0,0,0,0,2],
  '!':[2,2,2,0,2],'?':[6,1,2,0,2],"'":[2,2,0,0,0],',':[0,0,0,2,4],
  '/':[1,1,2,4,4],'(':[1,2,2,2,1],')':[4,2,2,2,4],
};

function menuDrawText(str, x, y, color, scale) {
  scale = scale || 1;
  for (let i = 0; i < str.length; i++) {
    const ch = str.charAt(i).toUpperCase();
    const glyph = MENU_FONT[ch];
    if (!glyph) continue;
    for (let gy = 0; gy < 5; gy++) {
      for (let gx = 0; gx < 4; gx++) {
        if (glyph[gy] & (8 >> gx)) {
          menuFillRect(x + i * 5 * scale + gx * scale, y + gy * scale, scale, scale, color);
        }
      }
    }
  }
}

function flushDisplay(buf) {
  if (useStdout) {
    fs.writeSync(1, buf, 0, FB_SIZE);
  } else {
    fs.writeSync(fbFd, buf, 0, FB_SIZE, 0);
  }
}

function menuFlush() {
  flushDisplay(__menuBuf);
}

// game selection menu
function showMenu() {
  if (!gamesList || gamesList.length === 0) return null;

  let selection = 0;
  let scrollOffset = 0;
  const FONT_SCALE = Math.max(2, Math.floor(SCREEN_H / 200));
  const itemH = FONT_SCALE * 5 + FONT_SCALE * 3;
  const headerH = FONT_SCALE * 14;
  const visibleItems = Math.floor((SCREEN_H - headerH - 10) / itemH);
  const COL_BG = 0xFF1A1A2E;
  const COL_HEADER = 0xFF533483;
  const COL_TEXT = 0xFFCCCCCC;
  const COL_SELECTED = 0xFF00D2FF;
  const COL_HIGHLIGHT = 0xFF16213E;

  function drawMenu() {
    __menuPx.fill(COL_BG);
    menuFillRect(0, 0, SCREEN_W, headerH, COL_HEADER);
    menuDrawText('PUZZLESCRIPT', 10, FONT_SCALE * 3, 0xFFFFFFFF, FONT_SCALE + 1);
    menuDrawText(gamesList.length + ' GAMES', SCREEN_W - FONT_SCALE * 50, FONT_SCALE * 4, COL_TEXT, FONT_SCALE);

    for (let i = 0; i < visibleItems && i + scrollOffset < gamesList.length; i++) {
      const idx = i + scrollOffset;
      const y = headerH + 5 + i * itemH;
      if (idx === selection) {
        menuFillRect(0, y - 1, SCREEN_W, itemH, COL_HIGHLIGHT);
        menuDrawText('> ' + gamesList[idx].title, 8, y + FONT_SCALE, COL_SELECTED, FONT_SCALE);
      } else {
        menuDrawText('  ' + gamesList[idx].title, 8, y + FONT_SCALE, COL_TEXT, FONT_SCALE);
      }
    }

    if (gamesList.length > visibleItems) {
      const barH = Math.max(10, Math.floor(SCREEN_H * visibleItems / gamesList.length));
      const barY = headerH + Math.floor((SCREEN_H - headerH - barH) * scrollOffset / (gamesList.length - visibleItems));
      menuFillRect(SCREEN_W - 4, barY, 4, barH, COL_HEADER);
    }
    menuFlush();
  }

  drawMenu();

  while (true) {
    sleep(50);
    const keys = readKeys();
    let needsRedraw = false;
    for (const key of keys) {
      if (key === KEY_UP) {
        selection = selection > 0 ? selection - 1 : gamesList.length - 1;
        needsRedraw = true;
      } else if (key === KEY_DOWN) {
        selection = selection < gamesList.length - 1 ? selection + 1 : 0;
        needsRedraw = true;
      } else if (key === KEY_LEFT) {
        selection = Math.max(0, selection - visibleItems);
        needsRedraw = true;
      } else if (key === KEY_RIGHT) {
        selection = Math.min(gamesList.length - 1, selection + visibleItems);
        needsRedraw = true;
      } else if (key === KEY_X || key === KEY_SPACE || key === KEY_ENTER) {
        return gamesList[selection].file;
      } else if (key === KEY_ESC) {
        flushSaves();
        process.exit(0);
      }
    }
    if (needsRedraw) {
      if (selection < scrollOffset) scrollOffset = selection;
      if (selection >= scrollOffset + visibleItems) scrollOffset = selection - visibleItems + 1;
      drawMenu();
    }
  }
}

// select game
let gameSource;
let gameId;

function selectGame() {
  if (initialGameSource) {
    const src = initialGameSource;
    initialGameSource = null;
    gameId = path.basename(arg0, '.txt');
    return src;
  }
  if (!gamesList) return null;
  const selectedFile = showMenu();
  if (!selectedFile) return null;
  gameId = path.basename(selectedFile, '.txt');
  return fs.readFileSync(selectedFile, 'utf8');
}

gameSource = selectGame();
if (!gameSource) {
  process.exit(0);
}

// load puzzlescript engine
const runtimeDir = __dirname + '/';
const srcDir = runtimeDir + 'src/';
const savePath = runtimeDir + '../conf/saves.json';

// browser shims
global.globalThis = global;
global.__SCREEN_W = SCREEN_W;
global.__SCREEN_H = SCREEN_H;
global.__gameSource = gameSource;
global.__gameId = 'ps://' + gameId;
global.__savePath = savePath;

// localstorage with persistence
let _storage = {};
let _storageDirty = false;
try {
  const saved = fs.readFileSync(savePath, 'utf8');
  _storage = JSON.parse(saved);
} catch(e) {}

global.localStorage = {
  getItem: function(key) { return _storage.hasOwnProperty(key) ? _storage[key] : null; },
  setItem: function(key, value) { _storage[key] = String(value); _storageDirty = true; },
  removeItem: function(key) { delete _storage[key]; _storageDirty = true; }
};

function flushSaves() {
  if (!_storageDirty) return;
  try {
    fs.writeFileSync(savePath, JSON.stringify(_storage));
    _storageDirty = false;
  } catch(e) {}
}

// framebuffer renderer
const __framebuf = Buffer.alloc(FB_SIZE);
const __pixels = new Uint32Array(__framebuf.buffer, __framebuf.byteOffset, SCREEN_W * SCREEN_H);
global.__framebuf = __framebuf;
global.__pixels = __pixels;
global.__dirty = true;

const __colorCache = {};
function __parseColor(str) {
  if (str in __colorCache) return __colorCache[str];
  if (typeof str !== 'string') return 0xFF000000;
  let result = 0xFF000000;
  if (str.charAt(0) === '#') {
    let hex = str.slice(1);
    if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
    if (hex.length === 8) {
      const r = parseInt(hex.slice(0,2), 16);
      const g = parseInt(hex.slice(2,4), 16);
      const b = parseInt(hex.slice(4,6), 16);
      const a = parseInt(hex.slice(6,8), 16);
      if (a === 0) result = 0;
      else result = (a << 24) | (b << 16) | (g << 8) | r;
    } else if (hex.length === 6) {
      const r = parseInt(hex.slice(0,2), 16);
      const g = parseInt(hex.slice(2,4), 16);
      const b = parseInt(hex.slice(4,6), 16);
      result = 0xFF000000 | (b << 16) | (g << 8) | r;
    }
  } else if (str === 'transparent' || str === 'rgba(0,0,0,0)') {
    result = 0;
  }
  __colorCache[str] = result;
  return result;
}
global.__parseColor = __parseColor;

function __fillRect(x, y, w, h, color) {
  const x0 = x < 0 ? 0 : x;
  const y0 = y < 0 ? 0 : y;
  const x1 = x + w > SCREEN_W ? SCREEN_W : x + w;
  const y1 = y + h > SCREEN_H ? SCREEN_H : y + h;
  const rowLen = x1 - x0;
  for (let row = y0; row < y1; row++) {
    const off = row * SCREEN_W + x0;
    for (let col = 0; col < rowLen; col++) {
      __pixels[off + col] = color;
    }
  }
}

function __blitImage(img, dx, dy) {
  const iw = img.width;
  const ih = img.height;
  const src = img.__pixels;
  let hasTransparency = img.__hasTransparency;
  if (hasTransparency === undefined) {
    hasTransparency = false;
    for (let ci = 0; ci < src.length; ci++) {
      if ((src[ci] & 0xFF000000) === 0) { hasTransparency = true; break; }
    }
    img.__hasTransparency = hasTransparency;
  }
  const sx0 = dx < 0 ? -dx : 0;
  const sy0 = dy < 0 ? -dy : 0;
  const sx1 = dx + iw > SCREEN_W ? SCREEN_W - dx : iw;
  const sy1 = dy + ih > SCREEN_H ? SCREEN_H - dy : ih;
  if (!hasTransparency) {
    for (let sy = sy0; sy < sy1; sy++) {
      let srcOff = sy * iw + sx0;
      let dstOff = (dy + sy) * SCREEN_W + dx + sx0;
      const rowLen = sx1 - sx0;
      for (let rx = 0; rx < rowLen; rx++) {
        __pixels[dstOff + rx] = src[srcOff + rx];
      }
    }
  } else {
    for (let sy = sy0; sy < sy1; sy++) {
      let srcOff = sy * iw + sx0;
      let dstOff = (dy + sy) * SCREEN_W + dx + sx0;
      for (let sx = sx0; sx < sx1; sx++) {
        const px = src[srcOff];
        if ((px & 0xFF000000) !== 0) __pixels[dstOff] = px;
        srcOff++;
        dstOff++;
      }
    }
  }
}

function __makeSpriteCtx(sprite) {
  return {
    fillStyle: '#000000',
    font: '',
    textAlign: '',
    clearRect: function() { if (sprite.__pixels) sprite.__pixels.fill(0); },
    fillRect: function(x, y, w, h) {
      const color = __parseColor(this.fillStyle);
      const x0 = Math.max(0, Math.round(x));
      const y0 = Math.max(0, Math.round(y));
      const x1 = Math.min(sprite.width, Math.round(x + w));
      const y1 = Math.min(sprite.height, Math.round(y + h));
      for (let row = y0; row < y1; row++) {
        const off = row * sprite.width;
        for (let col = x0; col < x1; col++) {
          sprite.__pixels[off + col] = color;
        }
      }
    },
    drawImage: function(src, dx, dy) {
      if (src && src.__pixels) {
        for (let sy = 0; sy < src.height; sy++) {
          const dstY = sy + Math.round(dy);
          if (dstY < 0 || dstY >= sprite.height) continue;
          for (let sx = 0; sx < src.width; sx++) {
            const dstX = sx + Math.round(dx);
            if (dstX < 0 || dstX >= sprite.width) continue;
            const srcPx = src.__pixels[sy * src.width + sx];
            if ((srcPx & 0xFF000000) !== 0)
              sprite.__pixels[dstY * sprite.width + dstX] = srcPx;
          }
        }
      }
    },
    fillText: function() {}
  };
}
global.__makeSpriteCtx = __makeSpriteCtx;

// canvas 2d context shim
const __ctx = {
  fillStyle: '#000000',
  globalAlpha: 1.0,
  lineWidth: 1,
  font: '',
  textAlign: '',
  fillRect: function(x, y, w, h) {
    __fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h), __parseColor(this.fillStyle));
  },
  clearRect: function(x, y, w, h) {
    __fillRect(Math.round(x), Math.round(y), Math.round(w), Math.round(h), 0xFF000000);
  },
  drawImage: function(img, dx, dy) {
    if (img && img.__pixels && img.width > 0 && img.height > 0)
      __blitImage(img, Math.round(dx), Math.round(dy));
  },
  beginPath: function() {},
  moveTo: function() {},
  lineTo: function() {},
  stroke: function() {},
  strokeStyle: '#000000',
  fillText: function() {},
  save: function() {},
  restore: function() {}
};

global.document = {
  URL: global.__gameId,
  body: {
    classList: { contains: function() { return false; } },
    addEventListener: function() {},
    removeEventListener: function() {},
    createTextRange: function() { return { moveToElementText: function(){}, select: function(){} }; }
  },
  createElement: function() {
    return {
      style: {}, innerHTML: '', textContent: '', width: 0, height: 0,
      parentNode: { clientWidth: SCREEN_W, clientHeight: SCREEN_H },
      getContext: function() { return __ctx; },
      focus: function() {},
      offsetLeft: 0, offsetTop: 0, scrollLeft: 0, scrollTop: 0, offsetParent: null
    };
  },
  getElementById: function(id) { if (id === 'gameCanvas') return global.canvas; return null; },
  addEventListener: function() {},
  removeEventListener: function() {},
  selection: null,
  createRange: function() { return { selectNode: function(){} }; }
};

global.window = global;
global.window.requestAnimationFrame = function() {};
global.window.addEventListener = function() {};
global.window.removeEventListener = function() {};
global.window.getSelection = function() { return { removeAllRanges: function(){}, addRange: function(){} }; };
global.window.Mobile = null;
Object.defineProperty(global, 'navigator', { value: { getGamepads: function() { return []; } }, writable: true });
global.HTMLCanvasElement = { prototype: {} };

global.lastDownTarget = null;
global.canvas = global.document.createElement('canvas');
global.input = global.document.createElement('TEXTAREA');

global.consolePrint = function() {};
global.consolePrintFromRule = function() {};
global.console_print_raw = function() {};
global.consoleError = function() {};
global.consoleCacheDump = function() {};
global.addToDebugTimeline = function() {};
global.killAudioButton = function() {};
global.showAudioButton = function() {};
global.jumpToLine = function() {};
global.printLevel = function() {};
// playSound is defined by sfxr.js when engine loads
global.toggleMute = function() {};
global.makeGIF = function() {};
global.saveClick = function() {};
global.runClick = function() {};
global.rebuildClick = function() {};

// audio: real pcm generation + aplay playback
const { execFile } = require('child_process');

global.AudioContext = function() {
  return {
    state: 'running',
    resume: function() { return { then: function(){} }; },
    createBuffer: function(channels, length, sampleRate) {
      const data = new Float32Array(length);
      return {
        _data: data,
        _sampleRate: sampleRate,
        getChannelData: function() { return data; }
      };
    },
    createBufferSource: function() {
      return {
        buffer: null,
        connect: function() {},
        start: function() {
          if (this.buffer && this.buffer._data) {
            const pcm = this.buffer._data;
            const rate = this.buffer._sampleRate || 44100;
            const buf = Buffer.alloc(pcm.length * 2);
            for (let i = 0; i < pcm.length; i++) {
              let s = Math.max(-1, Math.min(1, pcm[i]));
              buf.writeInt16LE(Math.round(s * 32767), i * 2);
            }
            const proc = execFile('aplay', [
              '-f', 'S16_LE', '-r', String(rate), '-c', '1', '-q'
            ], function() {});
            if (proc && proc.stdin) {
              proc.stdin.write(buf);
              proc.stdin.end();
            }
          }
        }
      };
    },
    createBiquadFilter: function() {
      return { frequency: { value: 0 }, connect: function() {} };
    },
    destination: {}
  };
};
global.webkitAudioContext = global.AudioContext;

function prevent(e) { return false; }
global.prevent = prevent;

if (typeof performance === 'undefined') {
  global.performance = { now: function() { return Date.now(); } };
}

global.stripHTMLTags = function(html_str) {
  return html_str.replace(/<\/?[a-zA-Z][^>]*>/g, '').trim();
};

global.UnitTestingThrow = function(error) { throw error; };
global.levelString = '';
global.editor = { display: { input: { blur: function(){} } }, getValue: function() { return global.levelString; } };
global.gamepadKeys = [];

// load and run engine
const engineFiles = [
  'js/storagewrapper.js', 'js/bitvec.js', 'js/level.js', 'js/languageConstants.js',
  'js/globalVariables.js', 'js/debug.js', 'js/font.js', 'js/rng.js', 'js/riffwave.js',
  'js/sfxr.js', 'js/codemirror/stringstream.js', 'js/colors.js', 'js/engine.js',
  'js/parser.js', 'js/compiler.js', 'js/soundbar.js', 'js/graphics.js', 'js/inputoutput.js',
];

process.stderr.write('Loading engine...\n');
let combined = '';
for (const file of engineFiles) {
  combined += '\n// ---- ' + file + ' ----\n';
  combined += fs.readFileSync(srcDir + file, 'utf8') + '\n';
}

// runtime wiring
combined += `
IDE = false;
canOpenEditor = false;
levelEditorOpened = false;
canDump = false;

canvasdict = {};
makeSpriteCanvas = function(name) {
  var c;
  if (name in canvasdict) { c = canvasdict[name]; }
  else { c = { width: 0, height: 0, __pixels: null, getContext: function() { return __makeSpriteCtx(this); } }; canvasdict[name] = c; }
  c.width = cellwidth; c.height = cellheight;
  c.__pixels = new Uint32Array(cellwidth * cellheight);
  return c;
};

canvasResize = function(displaylevel) {
  displaylevel = displaylevel || level;
  canvas.width = __SCREEN_W; canvas.height = __SCREEN_H;
  canvas.parentNode = { clientWidth: __SCREEN_W, clientHeight: __SCREEN_H };
  screenwidth = displaylevel.width; screenheight = displaylevel.height;
  if (state !== undefined) {
    flickscreen = state.metadata.flickscreen !== undefined;
    zoomscreen = state.metadata.zoomscreen !== undefined;
    if (flickscreen) { screenwidth = state.metadata.flickscreen[0]; screenheight = state.metadata.flickscreen[1]; }
    else if (zoomscreen) { screenwidth = state.metadata.zoomscreen[0]; screenheight = state.metadata.zoomscreen[1]; }
  }
  if (textMode) { screenwidth = TERMINAL_WIDTH; screenheight = TERMINAL_HEIGHT; }
  cellwidth = canvas.width / screenwidth; cellheight = canvas.height / screenheight;
  var w = 5, h = 5;
  if (textMode) { w = 6; var xchar = font['X'].split('\\n').map(function(a){return a.trim();}); h = xchar.length; }
  cellwidth = w * Math.max(~~(cellwidth / w), 1);
  cellheight = h * Math.max(~~(cellheight / h), 1);
  xoffset = 0; yoffset = 0;
  if (cellwidth / w > cellheight / h) { cellwidth = cellheight * w / h; xoffset = (canvas.width - cellwidth * screenwidth) / 2; yoffset = (canvas.height - cellheight * screenheight) / 2; }
  else { cellheight = cellwidth * h / w; yoffset = (canvas.height - cellheight * screenheight) / 2; xoffset = (canvas.width - cellwidth * screenwidth) / 2; }
  cellwidth = cellwidth | 0; cellheight = cellheight | 0; xoffset = xoffset | 0; yoffset = yoffset | 0;
  if (oldcellwidth != cellwidth || oldcellheight != cellheight || oldtextmode != textMode || textMode || oldfgcolor != state.fgcolor || forceRegenImages) { forceRegenImages = false; regenSpriteImages(); }
  oldcellheight = cellheight; oldcellwidth = cellwidth; oldtextmode = textMode; oldfgcolor = state.fgcolor;
  redraw();
};

var _origRedraw = redraw;
redraw = function() { _origRedraw(); globalThis.__dirty = true; };

window.requestAnimationFrame = function() {};

titletemplate_controls.arrows = ".D-Pad to move....................";
titletemplate_controls.action = ".A to action......................";
titletemplate_controls.undorestart = ".B to undo, R1 to restart........";
titletemplate_controls.undo = ".B to undo........................";
titletemplate_controls.restart = ".R1 to restart....................";

// expose to global for new Function() generated code and external access
globalThis.playSound = playSound;
globalThis.checkKey = checkKey;
globalThis.update = update;
globalThis.compile = compile;

levelString = __gameSource;
compile(['restart'], __gameSource);
`;

// strip strict mode for global scope compatibility
combined = combined.replace(/'use strict';\n?/g, '');
combined = combined.replace(/"use strict";\n?/g, '');

// run in global context
vm.runInThisContext(combined, { filename: 'puzzlescript_engine.js' });
process.stderr.write('Engine loaded. Starting game.\n');

// game input handler
function processKey(code) {
  let keyCode = -1;
  switch (code) {
    case KEY_UP: case KEY_W: keyCode = 38; break;
    case KEY_DOWN: case KEY_S: keyCode = 40; break;
    case KEY_LEFT: case KEY_A: keyCode = 37; break;
    case KEY_RIGHT: case KEY_D: keyCode = 39; break;
    case KEY_SPACE: case KEY_ENTER: case KEY_X: keyCode = 32; break;
    case KEY_Z: keyCode = 90; break;
    case KEY_R: keyCode = 82; break;
    case KEY_ESC: return 'quit';
  }
  if (keyCode > 0) {
    global.checkKey({ keyCode: keyCode, ctrlKey: false, metaKey: false, altKey: false, preventDefault: function(){} }, true);
  }
  return null;
}

function pollInput() {
  const keys = readKeys();
  for (const code of keys) {
    const result = processKey(code);
    if (result === 'quit') return 'quit';
  }
  return null;
}

// main loop
process.stderr.write('Entering game loop\n');

while (true) {
  const start = Date.now();

  const result = pollInput();
  if (result === 'quit') break;

  global.deltatime = FRAME_MS;
  if (typeof global.update === 'function') global.update();

  if (global.__dirty) {
    flushDisplay(__framebuf);
    global.__dirty = false;
  }

  if ((start % 2000) < FRAME_MS) flushSaves();

  const elapsed = Date.now() - start;
  if (elapsed < FRAME_MS) sleep(FRAME_MS - elapsed);
}

flushSaves();
process.exit(0);

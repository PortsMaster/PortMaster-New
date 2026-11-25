// KoreanNameKeyboard.js: la pantalla del nombre con un teclado coreano, para
// escribirlo con el mando. Es del mod korean-name-input del port de Fear &
// Hunger y sirve suelto en cualquier juego de RPG Maker MV.
//
// Sustituye a la pantalla del nombre de RPG Maker (Scene_Name) y a las que
// la cambian, como la de RS_Window_KorNameEdit del parche coreano, que
// escribe con el IME del PC o del movil (en una handheld no hay, y en quixjs
// se para con un TypeError). No usa nada del parche: con el o sin el, el
// nombre se pone igual.
//
// MIT (licenses/KoreanNameKeyboard.txt). Copyright (c) 2026 lowlevel.1989
/*:
 * @plugindesc Name input with a Korean keyboard on the screen: the name is typed with the gamepad, without IME. <KoreanNameKeyboard>
 * @author lowlevel.1989
 *
 * @help
 * The name screen (Name Input Processing) gets a keyboard on the screen
 * with Hangul, ABC and abc pages. It replaces the default one and the ones
 * of other plugins, like RS_Window_KorNameEdit, that need the keyboard of a
 * PC or of a phone.
 *
 * Install: put it in js/plugins/ and turn it on in the plugin manager. The
 * order does not matter.
 *
 * Controls:
 *   Directions      move on the keyboard
 *   OK              type the letter (or ABC, abc, 한글, 확인)
 *   Cancel          delete: the last jamo of the syllable, or the last letter
 *   Page up / down  change the page: 한글, ABC, abc
 *   Shift           go to 확인
 *
 * The Korean page is 2-beolsik (두벌식): the rows of a Korean PC keyboard,
 * consonants on the left and vowels on the right. The jamo join as with an
 * IME: ㄱ ㅏ ㄱ ㅏ is 가가, ㄷ ㅏ ㄹ ㄱ is 닭, ㅗ ㅏ is ㅘ.
 *
 * The font of the game needs Hangul. If it has none, the browser uses one of
 * the system.
 */

var Imported = Imported || {};

(function () {
  'use strict';

  if (Imported.KoreanNameKeyboard) return;
  Imported.KoreanNameKeyboard = true;

  // HangulComposer: el nombre que se va escribiendo, jamo a jamo.
  //
  // El nombre es el texto ya fijo mas la silaba que se esta formando. La
  // silaba guarda sus pasos: asi Cancel quita su ultimo jamo (한 -> 하 -> ㅎ)
  // y, cuando ya no queda, la ultima letra fija.

  var CHO = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ',
    'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
  var JUNG = ['ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ', 'ㅙ',
    'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'];
  var JONG = ['', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ', 'ㄻ',
    'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ',
    'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
  var VOWEL_PAIRS = {
    'ㅗㅏ': 'ㅘ', 'ㅗㅐ': 'ㅙ', 'ㅗㅣ': 'ㅚ', 'ㅜㅓ': 'ㅝ', 'ㅜㅔ': 'ㅞ',
    'ㅜㅣ': 'ㅟ', 'ㅡㅣ': 'ㅢ'
  };
  var FINAL_PAIRS = {
    'ㄱㅅ': 'ㄳ', 'ㄴㅈ': 'ㄵ', 'ㄴㅎ': 'ㄶ', 'ㄹㄱ': 'ㄺ', 'ㄹㅁ': 'ㄻ',
    'ㄹㅂ': 'ㄼ', 'ㄹㅅ': 'ㄽ', 'ㄹㅌ': 'ㄾ', 'ㄹㅍ': 'ㄿ', 'ㄹㅎ': 'ㅀ',
    'ㅂㅅ': 'ㅄ'
  };
  var FINAL_SPLIT = {};
  Object.keys(FINAL_PAIRS).forEach(function (pair) {
    FINAL_SPLIT[FINAL_PAIRS[pair]] = [pair.charAt(0), pair.charAt(1)];
  });
  var HANGUL_BASE = 0xac00;

  function isConsonant(ch) {
    return CHO.indexOf(ch) >= 0;
  }

  function isVowel(ch) {
    return JUNG.indexOf(ch) >= 0;
  }

  function syllable(cho, jung, jong) {
    return { cho: cho || '', jung: jung || '', jong: jong || '' };
  }

  // el texto de una silaba: 한, o un jamo solo (ㅎ, ㅏ) mientras no tiene pareja
  function render(s) {
    if (!s) return '';
    if (s.cho && s.jung) {
      var code = HANGUL_BASE +
        (CHO.indexOf(s.cho) * JUNG.length + JUNG.indexOf(s.jung)) * JONG.length +
        JONG.indexOf(s.jong);
      return String.fromCharCode(code);
    }
    return s.cho || s.jung;
  }

  // Pone el jamo ch en la silaba s. Devuelve el texto que sale de la silaba
  // (commit) y las silabas nuevas: steps son sus pasos y el ultimo es la
  // silaba actual.
  function step(s, ch) {
    var empty = !s.cho && !s.jung;
    if (isConsonant(ch)) {
      if (empty) return { commit: '', steps: [syllable(ch)] };
      if (s.cho && s.jung && !s.jong && JONG.indexOf(ch) > 0) {
        return { commit: '', steps: [syllable(s.cho, s.jung, ch)] };
      }
      if (s.jong && FINAL_PAIRS[s.jong + ch]) {
        return { commit: '', steps: [syllable(s.cho, s.jung, FINAL_PAIRS[s.jong + ch])] };
      }
      return { commit: render(s), steps: [syllable(ch)] };
    }
    // una vocal
    if (empty) return { commit: '', steps: [syllable('', ch)] };
    if (s.cho && !s.jung) return { commit: '', steps: [syllable(s.cho, ch)] };
    if (!s.jong) {
      if (VOWEL_PAIRS[s.jung + ch]) {
        return { commit: '', steps: [syllable(s.cho, VOWEL_PAIRS[s.jung + ch])] };
      }
      return { commit: render(s), steps: [syllable('', ch)] };
    }
    // la consonante final pasa a la silaba nueva: 닭 + ㅏ -> 달가
    var split = FINAL_SPLIT[s.jong];
    var stay = split ? split[0] : '';
    var move = split ? split[1] : s.jong;
    return {
      commit: render(syllable(s.cho, s.jung, stay)),
      steps: [syllable(move), syllable(move, ch)]
    };
  }

  function HangulComposer(text) {
    this._committed = text || '';
    this._history = [];
  }

  HangulComposer.prototype.current = function () {
    return this._history[this._history.length - 1] || null;
  };

  HangulComposer.prototype.text = function () {
    return this._committed + render(this.current());
  };

  // Pone una letra (un jamo o cualquier otra). Devuelve false, sin cambiar
  // nada, si el nombre pasaria de maxLength.
  HangulComposer.prototype.add = function (ch, maxLength) {
    var committed = this._committed;
    var history;
    if (isConsonant(ch) || isVowel(ch)) {
      var r = step(this.current() || syllable(), ch);
      committed += r.commit;
      history = r.commit ? r.steps : this._history.concat(r.steps);
    } else {
      committed += render(this.current()) + ch;
      history = [];
    }
    var text = committed + render(history[history.length - 1]);
    if (maxLength > 0 && text.length > maxLength) return false;
    this._committed = committed;
    this._history = history;
    return true;
  };

  // Quita el ultimo jamo de la silaba, o la ultima letra. Devuelve false si
  // el nombre esta vacio.
  HangulComposer.prototype.back = function () {
    if (this._history.length > 0) {
      this._history.pop();
      return true;
    }
    if (this._committed.length > 0) {
      this._committed = this._committed.slice(0, -1);
      return true;
    }
    return false;
  };

  // Window_KoreanNameEdit: la ventana del nombre de RPG Maker con cada letra
  // del ancho de 가 (la de RPG Maker usa el de A y el hangul se monta).

  function Window_KoreanNameEdit() {
    this.initialize.apply(this, arguments);
  }

  Window_KoreanNameEdit.prototype = Object.create(Window_NameEdit.prototype);
  Window_KoreanNameEdit.prototype.constructor = Window_KoreanNameEdit;

  Window_KoreanNameEdit.prototype.charWidth = function () {
    var width = Math.max(this.textWidth('A'), this.textWidth('가'));
    // un nombre muy largo tiene que caber en la ventana
    if (this._maxLength > 0) {
      width = Math.min(width, Math.floor(this.contentsWidth() / (this._maxLength + 1)));
    }
    return width;
  };

  // Window_KoreanNameKeyboard: la rejilla de Window_NameInput con hangul.
  //
  // 90 casillas como la de RPG Maker: 9 filas de 10, la 88 cambia de pagina y
  // la 89 es OK. La primera pagina es 2-beolsik (las filas QWERTY, ASDF, ZXCV
  // y las de Shift de un teclado coreano); las otras dos son las de letras
  // latinas de RPG Maker.

  var KOREAN = [
    'ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ',
    'ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ', '',
    'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', '', '', '',
    'ㅃ', 'ㅉ', 'ㄸ', 'ㄲ', 'ㅆ', '', '', '', 'ㅒ', 'ㅖ',
    'ㅘ', 'ㅙ', 'ㅚ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅢ', '', '', '',
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
    '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', '', '',
    '', '', '', '', '', '', '', '', 'ABC', '확인'
  ];
  var LATIN_UPPER = Window_NameInput.LATIN1.slice();
  var LATIN_LOWER = Window_NameInput.LATIN2.slice();
  LATIN_UPPER[88] = 'abc';
  LATIN_LOWER[88] = '한글';
  var GRID_WIDTH = 10 * 42 + 24; // el ancho de las casillas de Window_NameInput

  function Window_KoreanNameKeyboard() {
    this.initialize.apply(this, arguments);
  }

  Window_KoreanNameKeyboard.prototype = Object.create(Window_NameInput.prototype);
  Window_KoreanNameKeyboard.prototype.constructor = Window_KoreanNameKeyboard;

  Window_KoreanNameKeyboard.prototype.initialize = function (editWindow) {
    this._composer = new HangulComposer(editWindow.name().slice(0, editWindow._maxLength));
    Window_NameInput.prototype.initialize.call(this, editWindow);
    this.updateEditWindow();
  };

  Window_KoreanNameKeyboard.prototype.table = function () {
    return [KOREAN, LATIN_UPPER, LATIN_LOWER];
  };

  // las casillas de Window_NameInput, centradas si la ventana es mas ancha
  Window_KoreanNameKeyboard.prototype.itemRect = function (index) {
    var rect = Window_NameInput.prototype.itemRect.call(this, index);
    rect.x += Math.max(0, Math.floor((this.contentsWidth() - GRID_WIDTH) / 2));
    return rect;
  };

  Window_KoreanNameKeyboard.prototype.updateEditWindow = function () {
    var editWindow = this._editWindow;
    editWindow._name = this._composer.text();
    editWindow._index = editWindow._name.length;
    editWindow.refresh();
  };

  Window_KoreanNameKeyboard.prototype.onNameAdd = function () {
    if (this._composer.add(this.character(), this._editWindow._maxLength)) {
      this.updateEditWindow();
      SoundManager.playOk();
    } else {
      SoundManager.playBuzzer();
    }
  };

  Window_KoreanNameKeyboard.prototype.processBack = function () {
    if (this._composer.back()) {
      this.updateEditWindow();
      SoundManager.playCancel();
    }
  };

  // como en RPG Maker: OK con el nombre vacio vuelve a poner el de antes
  Window_KoreanNameKeyboard.prototype.onNameOk = function () {
    var editWindow = this._editWindow;
    if (editWindow.name() === '') {
      var name = (editWindow._defaultName || '').slice(0, editWindow._maxLength);
      if (name) {
        this._composer = new HangulComposer(name);
        this.updateEditWindow();
        SoundManager.playOk();
      } else {
        SoundManager.playBuzzer();
      }
    } else {
      SoundManager.playOk();
      this.callOkHandler();
    }
  };

  // Scene_KoreanName: Scene_Name con las dos ventanas de arriba.

  function Scene_KoreanName() {
    this.initialize.apply(this, arguments);
  }

  Scene_KoreanName.prototype = Object.create(Scene_Name.prototype);
  Scene_KoreanName.prototype.constructor = Scene_KoreanName;

  Scene_KoreanName.prototype.createEditWindow = function () {
    this._editWindow = new Window_KoreanNameEdit(this._actor, this._maxLength);
    this.addWindow(this._editWindow);
  };

  Scene_KoreanName.prototype.createInputWindow = function () {
    this._inputWindow = new Window_KoreanNameKeyboard(this._editWindow);
    this._inputWindow.setHandler('ok', this.onInputOk.bind(this));
    this.addWindow(this._inputWindow);
  };

  // La pantalla del nombre, la de RPG Maker o la de un plugin (una clase hija
  // de Scene_Name, como Scene_KorName), se cambia por esta al empezar. Se
  // prepara igual (prepareNextScene(actorId, maxLength)).
  function isNameScene(sceneClass) {
    if (typeof sceneClass !== 'function') return false;
    if (sceneClass === Scene_KoreanName || sceneClass.prototype instanceof Scene_KoreanName) {
      return false;
    }
    return sceneClass === Scene_Name || sceneClass.prototype instanceof Scene_Name;
  }

  var _SceneManager_goto = SceneManager.goto;
  SceneManager.goto = function (sceneClass) {
    if (isNameScene(sceneClass)) {
      var args = Array.prototype.slice.call(arguments);
      args[0] = Scene_KoreanName;
      return _SceneManager_goto.apply(this, args);
    }
    return _SceneManager_goto.apply(this, arguments);
  };

  // para otros plugins y para los tests
  window.KoreanNameKeyboard = {
    HangulComposer: HangulComposer,
    Window_KoreanNameEdit: Window_KoreanNameEdit,
    Window_KoreanNameKeyboard: Window_KoreanNameKeyboard,
    Scene_KoreanName: Scene_KoreanName,
    KOREAN: KOREAN
  };
})();

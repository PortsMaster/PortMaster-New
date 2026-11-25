// font.js: la letra coreana del teclado, Noto Sans CJK KR (solo el hangul y
// las letras latinas, licencia OFL: licenses/NotoSansCJK.txt).
//
// La letra de Fear & Hunger no tiene hangul. Cuando a la letra de un texto le
// faltan letras, quixjs usa la primera fuente registrada que las tiene todas:
// con el parche coreano es la suya (se registra antes, con gamefont.css); sin
// el parche, esta.
(function () {
  var face = new FontFace('KoreanNameKeyboard', 'url(fonts/NotoSansKR-Hangul.otf)');
  document.fonts.add(face);
})();

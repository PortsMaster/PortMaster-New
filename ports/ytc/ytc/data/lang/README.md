# YTC UI translations

Each `<code>.json` is one language: a flat map of **string key → translated text**.
`languages.json` lists the languages shown in Settings (order matters) and maps each
to its Innertube `hl`/`gl` (which makes YouTube return localized titles/metadata).

These files are loaded at runtime — **edit them and relaunch, no rebuild needed.**

## Edit a translation
Open the language file (e.g. `es.json`) and change the value. Keep the key. UTF-8.
Anything missing falls back to English, so partial files are fine.

## Add a language
1. Copy `en.json` to `<code>.json` and translate the values.
2. Add an entry to `languages.json`:
   `{ "code": "<code>", "name": "<endonym>", "hl": "<yt-lang>", "gl": "<yt-country>" }`
3. The bundled fonts cover Latin, Cyrillic, and Greek (DejaVuSans) plus Japanese
   (`data/fonts/NotoSansCJKjp-Subset.otf`: kana + the JIS X 0208 kanji). Chinese or
   Korean need a wider CJK subset (`tools/make_cjk_font.sh`); Arabic and Indic
   scripts also need text shaping, which the renderer doesn't do.

## Keys
The keys are fixed identifiers used in the code (`i18n::Str`). English is also baked
into the binary as the ultimate fallback, so the app still works if these files are
missing. After adding new string keys, regenerate the files with:
`g++ -std=c++17 tools/dump_i18n.cpp src/i18n.cpp -o /tmp/dump_i18n && /tmp/dump_i18n data/lang`
This rewrites `en.json` with every key from the baked-in English table, and re-emits
each other language in the same key order — existing translations are kept, keys
removed from the enum are dropped (with a warning), and untranslated keys are left
out (English fallback covers them; copy the line from `en.json` to translate it).
`languages.json` is never touched. (Developers only; translators just edit values.)

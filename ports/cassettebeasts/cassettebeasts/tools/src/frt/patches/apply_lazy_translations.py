#!/usr/bin/env python3
"""Load only the current language's translations (port patch). Godot 3 loads every file of
locale/translations at start-up (Cassette Beasts: 99 files, 11 languages, ~11 MB). With
locale/lazy_translations=true, files named <name>.<locale>.translation whose language is neither the
current locale's nor the fallback's are only remembered; TranslationServer::set_locale loads them when the
game switches to their language, and get_loaded_locales() still lists them (language menus unchanged).
usage: apply_lazy_translations.py <godot dir>   (idempotent)
"""
import os, sys

G = sys.argv[1]


def edit(rel, fn):
    p = os.path.join(G, rel)
    s = open(p, encoding='utf-8').read()
    if 'LAZY-TRANSLATIONS' in s:
        print('already patched:', rel)
        return
    n = fn(s)
    assert n != s, rel
    open(p, 'w', encoding='utf-8', newline='\n').write(n)
    print('patched:', rel)


def once(s, old, new):
    assert s.count(old) == 1, old
    return s.replace(old, new)


def tr_h(s):
    return once(s, '''	bool _load_translations(const String &p_from);
''', '''	bool _load_translations(const String &p_from);
	// LAZY-TRANSLATIONS: (locale, path) of translations not loaded yet
	Vector<String> lazy_locales;
	Vector<String> lazy_paths;
	void _lazy_load_language(const String &p_lang);
''')


def tr_cpp(s):
    s = once(s, '''	if (OS::get_singleton()->get_main_loop()) {
		OS::get_singleton()->get_main_loop()->notification(MainLoop::NOTIFICATION_TRANSLATION_CHANGED);
	}

	ResourceLoader::reload_translation_remaps();
}
''', '''	_lazy_load_language(get_language_code(locale)); // LAZY-TRANSLATIONS

	if (OS::get_singleton()->get_main_loop()) {
		OS::get_singleton()->get_main_loop()->notification(MainLoop::NOTIFICATION_TRANSLATION_CHANGED);
	}

	ResourceLoader::reload_translation_remaps();
}

// LAZY-TRANSLATIONS
void TranslationServer::_lazy_load_language(const String &p_lang) {
	for (int i = lazy_paths.size() - 1; i >= 0; i--) {
		if (get_language_code(lazy_locales[i]) != p_lang) {
			continue;
		}
		Ref<Translation> tr = ResourceLoader::load(lazy_paths[i]);
		if (tr.is_valid()) {
			add_translation(tr);
		}
		lazy_paths.remove(i);
		lazy_locales.remove(i);
	}
}
''')
    s = once(s, '''		if (!locales.has(l)) {
			locales.push_back(l);
		}
	}

	locales.sort();''', '''		if (!locales.has(l)) {
			locales.push_back(l);
		}
	}
	for (int i = 0; i < lazy_locales.size(); i++) { // LAZY-TRANSLATIONS
		if (!locales.has(lazy_locales[i])) {
			locales.push_back(lazy_locales[i]);
		}
	}

	locales.sort();''')
    s = once(s, '''			PoolVector<String>::Read r = translations.read();

			for (int i = 0; i < tcount; i++) {
				Ref<Translation> tr = ResourceLoader::load(r[i]);''', '''			PoolVector<String>::Read r = translations.read();
			// LAZY-TRANSLATIONS
			bool lazy = ProjectSettings::get_singleton()->has_setting("locale/lazy_translations") && bool(ProjectSettings::get_singleton()->get("locale/lazy_translations"));
			String cur = get_language_code(locale);
			String fb = get_language_code(fallback);

			for (int i = 0; i < tcount; i++) {
				if (lazy) {
					String loc = r[i].get_basename().get_extension();
					String lang = loc.length() >= 2 ? get_language_code(standardize_locale(loc)) : String();
					if (lang != "" && is_locale_valid(standardize_locale(loc)) && lang != cur && lang != fb) {
						lazy_locales.push_back(standardize_locale(loc));
						lazy_paths.push_back(r[i]);
						continue;
					}
				}
				Ref<Translation> tr = ResourceLoader::load(r[i]);''')
    return s


edit('core/translation.h', tr_h)
edit('core/translation.cpp', tr_cpp)

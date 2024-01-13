--[[

  Copyright (c) 2014 Samuel Degrande

  This file is part of Freedroid

  Freedroid is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  Freedroid is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with Freedroid; see the file COPYING. If not, write to the
  Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
  MA  02111-1307  USA

]]--

languages{
	-- name: Language name, as displayed in the Languages Menu
	-- locale: Locale name, of the form language_territory
	--         (language is an ISO 639 language code, territory is an
	--         ISO 3166 country code)
	{ name = "Brasileiro",   locale = "pt_BR" },
	{ name = "Cestina",      locale = "cs_CZ" },
	{ name = "Deutsch",      locale = "de_DE" },
	{ name = "English (US)", locale = "en_US" },
	{ name = "Francais",     locale = "fr_FR" },
	{ name = "Italiano",     locale = "it_IT" },
	{ name = "Magyar nyelv", locale = "hu_HU" },
	{ name = "Russian",      locale = "ru_RU" },
	{ name = "Spanish",      locale = "es_ES" },
	{ name = "Svenska",      locale = "sv_SV" },
}

codesets{
	-- language: can be a simple 'language code', to define a default
	--           encoding for all the locales of that language group,
	--           or can be 'language_territory' to define a specific encoding.
	-- encoding: one of the font bitmap encoding provided by the game (see
	--           data/fonts).
	-- Note: default encoding is ASCII
	{ language = "cs", encoding = "ISO-8859-2"  },
	{ language = "de", encoding = "ISO-8859-15" },
	{ language = "en", encoding = "ISO-8859-15" },
	{ language = "es", encoding = "ISO-8859-15" },
	{ language = "fr", encoding = "ISO-8859-15" },
	{ language = "hu", encoding = "ISO-8859-2"  },
	{ language = "it", encoding = "ISO-8859-15" },
	{ language = "pt", encoding = "ISO-8859-15" },
	{ language = "ru", encoding = "ISO-8859-5"  },
	{ language = "sv", encoding = "ISO-8859-15" },
}

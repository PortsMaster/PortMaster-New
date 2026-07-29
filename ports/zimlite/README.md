## Overview

Ever wanted the whole of Wikipedia in your pocket, with no Wi-Fi, no data plan, and no compromises?
**Zimlite** turns your handheld into a pocket library. It's a fast, lightweight offline reader for **ZIM archives** — the same format used by Kiwix — so you can browse Wikipedia, Wiktionary, Wikibooks, Project Gutenberg, StackExchange dumps, and thousands of other offline archives straight from your device, no internet required.

Perfect for long trips, camping, flights, or just keeping a searchable encyclopedia handy on your favorite retro handheld.

### Features
- Read full ZIM archives completely offline
- Alphabetical article tree for browsing the entire archive's catalogue
- Click-through links between articles with back/forward history
- Built-in downloader to fetch ZIM archives directly from the Kiwix library when online

### How to use:
1. Download ZIM files (e.g. Wikipedia, Wikibooks, Wikivoyage, etc.) for free from **[library.kiwix.org](https://library.kiwix.org)**.
2. Copy the `.zim` files into the port directory:
   `/roms/ports/zimlite/`
3. Restart **Zimlite**. It will automatically detect and load the archive!

## Notes

Thanks to the [Kiwix Project](https://kiwix.org) for their work curating and distributing free offline ZIM content, and to the [openZIM project](https://wiki.openzim.org/wiki/Libzim) for the libzim library used to read it.

## Controls

| Button | Action |
|--|--| 
| D-Pad Up / Down, Left Analog Stick Y | Scroll Up / Scroll Down |
| D-Pad Left / Right, Left Analog Stick X | Select Prev Link / Select Next Link |
| A | Open selected link |
| B | Go back in history |
| X | Toggle the article tree view / search |
| Y | Go to the main page / home |
| L1 / R1 | Page Up / Page Down |
| Select + Menu | Quit |
| Menu | Open Settings |
| Start | Show Help |

## Compile

```shell
# Cross-build ARM64 binary via Docker
make dist-portmaster
# Output: dist/zimlite.zip
```

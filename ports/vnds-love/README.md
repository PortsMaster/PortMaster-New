# Port of VNDS-LOVE Engine
VNDS is a standard for very simple and easy to use Visual Novel scripts. It was originally developed for the Nintendo DS.
This port allows you to play such famous games as Tsukihime, Fate \ Stay night, Ever 17, Saya no Uta and many others.

## Controls

| Button | Action |
|--|--| 
|A|Confirm/Next|
|B|Cancel/Back|
|X|Skip to Next Choice|
|Y|Fast Forward Text|
|D-Pad (Up) |Navigation (View Previous Text)|
|Start|Toggle Menu|

## What is this?
This is a port of VNDS-LOVE (https://github.com/ajusa/VNDS-LOVE) for linux based handhelds that support Portmaster project (https://portmaster.games/).
Port does not include any VNDS visual novels but these are extremely easy to procure. More info about finding these can be found on the [VNDS wiki](https://github.com/BASLQC/vnds/wiki). 
## How do I use it? 
Place your novel folder into
```
./vnds-love/conf/love/VNDS-LOVE/novels/
```

<details>
<summary>example of folder structure</summary>

```bash
└── novels
    ├── ever17
    │   ├── background
    │   ├── default.ttf
    │   ├── foreground
    │   ├── icon-high.png
    │   ├── icon.png
    │   ├── img.ini
    │   ├── info.txt
    │   ├── script
    │   ├── sound.zip
    │   ├── thumbnail-high.jpg
    │   └── thumbnail.png
    └── Tsukihime
        ├── background.zip
        ├── ChangeLog
        ├── default.ttf
        ├── foreground.zip
        ├── icon.png
        ├── img.ini
        ├── info.txt
        ├── save1.json
        ├── script.zip
        ├── sound.zip
        └── thumbnail.png
```
</details>

then run the port and use internal launcher to select novel.

## Thanks To
VNDS-LOVE project https://github.com/ajusa/VNDS-LOVE for porting the engine to love2d.  
@JanTrueno for giving references on how to port love2d projects to Portmaster.  
@StockPainter for motivating me, testing results and supporting with other project`s stuff.  
And thanks to all Portmaster community for provided tools and documentation.


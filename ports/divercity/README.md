## Notes

Thanks to the [DiverCity team](https://github.com/Team--Rocket/divercity) at FU Berlin for DiverCity, a MicropolisJ extension that adds A* traffic simulation, universities with a research tree and new power plants to the classic Micropolis city builder.

Play a scenario opens the 25 bundled cities in `divercity/scenarios`. Your own cities are saved to `divercity/saves`, and Load previous city reopens the last one you saved or loaded.

## Controls

| Button | Action |
|--|--|
| Left Stick | Move mouse cursor |
| A | Left click |
| B | Right click (query / research) |
| X (hold) | Slow cursor |
| Y | Show / hide side panel (minimap, funds, messages) |
| D-Pad / Right Stick | Scroll map |
| L1 | Zoom out |
| R1 | Zoom in |
| L2 | Slow speed |
| R2 | Fast speed |
| Start | Pause |
| Select | Cancel (Esc) |
| Start + Select | Quit |

## Compile

```bash
sudo apt-get install -y openjdk-17-jdk-headless git
git clone https://github.com/Team--Rocket/divercity.git
cd divercity
sed -i 's/new JFileChooser()/new JFileChooser(System.getProperty("divercity.savedir"))/' src/micropolisj/gui/NewCityDialog.java src/micropolisj/gui/SplashScreen.java src/micropolisj/gui/MainWindow.java
sed -i 's|ImageIO.read(new File("graphics/\(splash[_0-9]*\.png\)"))|ImageIO.read(SplashScreen.class.getResource("/\1"))|' src/micropolisj/gui/SplashScreen.java
mkdir -p build/micropolisj stage
javac --release 11 -encoding UTF-8 -nowarn -d build $(find src -name '*.java')
cp -r resources/. build/
for f in strings/*; do case "$f" in *.utf8) cp "$f" "build/micropolisj/$(basename "${f%.utf8}").properties" ;; *) cp "$f" build/micropolisj/ ;; esac; done
(cd graphics && java -cp ../build micropolisj.build_tool.MakeTiles tiles.rc ../build/tiles.png \
  && java -Dtile_size=8 -cp ../build micropolisj.build_tool.MakeTiles tiles.rc ../build/tiles_8x8.png \
  && java -Dtile_size=32 -cp ../build micropolisj.build_tool.MakeTiles tiles.rc ../build/tiles_32x32.png \
  && java -Dtile_size=3 -cp ../build micropolisj.build_tool.MakeTiles tiles.rc ../build/tilessm.png)
cp graphics/tiles.rc build/
rm -rf build/micropolisj/build_tool
cp -r graphics/. resources/. build/. stage/
rm -rf stage/generated
find stage \( -name '*.xcf' -o -name 'Thumbs.db' \) -delete
jar cfe divercity.jar micropolisj.Main -C stage .
```

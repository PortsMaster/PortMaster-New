# Balatro

A [PortMaster](https://portmaster.games/) port of [Balatro](https://www.playbalatro.com/) — the poker-inspired roguelike deck builder — with its interface rebuilt for the small screens of Linux handhelds.

**This is not the game itself.** It is the wrapper that makes a copy you already own run on a handheld: you buy Balatro on Steam, copy one file from it onto your device, and this patches and launches it there. Nothing here works without that file, and the game is never distributed with it.

This port builds on nkahoang's original PortMaster work—thank you.

## What's different

- **Fills the screen.** The playfield takes your device's own aspect ratio and uses the whole panel, so everything is drawn noticeably larger.
- **A layout built for a small screen.** The desktop sidebar becomes a single top status bar, the shop drops its oversized animated sign so the whole storefront fits on screen, and card descriptions are larger. The clearer Nunito font is used on every device.
- **Runs lighter.** CRT, bloom, shadows, and screen shake are off, and the two full-screen shaders are trimmed. Reduced motion is on, which holds the background still, so it is drawn once into a buffer and reused until its colours change rather than recomputed every frame. The background is therefore a static image on this port, not the animated one.
- **Both of those are yours to choose.** The first launch asks whether to use the small screen layout or Balatro's original one, and whether to take the performance changes at all — so a device with frames to spare can have the game exactly as it ships.
- **Buttons that match your device.** The first launch asks you to press each button by the letter printed beside it, and takes your device's word for which is which. Handhelds print those letters in either the Xbox or the Nintendo arrangement, and what a device reports doesn't always match what it has printed on it.

In short, it's uglier, but it runs better and fits small screens better.

## Screenshots

![Blind selection](https://i.imgur.com/BwBf3np.png)
![Playing a hand](https://i.imgur.com/CC7sXXT.png)
![Cash out screen](https://i.imgur.com/6KifAYM.png)
![The shop](https://i.imgur.com/CXNEGZU.png)

## What you need

- **A handheld running [PortMaster](https://portmaster.games/).** Balatro is a PortMaster port and does not run without it. If your device doesn't have PortMaster yet, install that first.
- **Your own copy of Balatro**, bought on [Steam](https://store.steampowered.com/app/2379780/Balatro/). The Windows or the macOS build is equally fine — you copy a single file out of it.

## Installing

**1. Install Balatro from PortMaster's catalogue.**

**2. Add your game file.** Copy it into the `balatro` folder:

- **Windows:** Steam → right-click Balatro → Manage → Browse Local Files. Copy `Balatro.exe`.
- **macOS:** Steam → right-click Balatro → Manage → Browse Local Files. Right-click `Balatro.app` → Show Package Contents → `Contents/Resources`. Copy `Balatro.love`.

**3. Launch it** from your device's ports menu. The first start asks the two questions below and then builds a patched copy called `Balatro_pm`, which takes a moment. Later launches skip both.

## Display setup

The first launch asks two questions before the game starts. Move with the **D-pad** and choose with **START**; each option explains itself as you land on it.

- **Screen layout.** *Small screen* is the interface rebuilt for a handheld panel — the playfield fills the screen, the sidebar becomes one status bar, cards and text are larger, and the clearer Nunito font is used. *Original Balatro* is the desktop layout exactly as the game ships it, letterboxed to fit, with the game's own font back.
- **Performance improvements.** *On* turns CRT, bloom, shadows and screen shake off, holds the table background still, trims the two full-screen shaders and uses the small texture sheets. *Off* leaves every effect on and the background animating, exactly as on a desktop, and on a weaker device the frame rate shows it.

The two are independent: either layout can be played with the effects on or off. The layout answer only changes how the screen is arranged, and the performance answer only changes what that screen costs.

Both are saved to `balatro/saves/display-setup.txt` and used from then on. Together they decide how the patched copy is built, so changing either rebuilds it — the same moment the first launch takes.

- To be asked again, choose **Initialize Port Settings** in the in-game options menu and restart the port. That covers the buttons too. Deleting `balatro/saves/display-setup.txt`, or setting `FORCE_DISPLAY_SETUP=1` near the top of `Balatro.sh`, asks about the layout and performance only.
- Leaving it alone keeps the answers already in force: a countdown appears and it goes ahead with them.
- Balatro keeps its graphics settings in your profile, so answering *Off* after having played with the effects turned down hands them back to Balatro's own defaults on the next launch.

## Buttons

After the display setup, the first launch shows a short button check: press A, B, X, Y, then L1, L2, R1, and R2, each as it is labelled on your device. The answer is saved to `balatro/saves/controller-map.txt` and used from then on, so the letters Balatro prompts you with are the letters on your device.

- **START** saves. **SELECT** starts the questions over. Those two are the ones the check doesn't change, which is why they're the ones that answer the last screen.
- Every question waits for the button it names. If you leave it alone, a countdown appears and the check gives up on its own, keeping your device's own mapping. Pressing anything stops the countdown.
- To be asked again, choose **Initialize Port Settings** in the in-game options menu and restart the port; that asks about the layout and performance as well. Deleting `balatro/saves/controller-map.txt`, or setting `FORCE_BUTTON_SETUP=1` near the top of `Balatro.sh`, asks about the buttons only.
- If your device has no controller mapping at all — nothing responds in other ports either — the check also asks for the D-pad, Start, and Select, and builds a mapping from scratch.
- Skipping it (or leaving it alone until it times out) keeps your device's own mapping and doesn't ask again.

# SpruceChat

A tiny AI chat app that runs entirely on-device. No internet required.

## Thank you

- **Cassius Oldenburg** — original SpruceChat author
- **Sundownersport** — multi-device support and PortMaster port
- **Qwen team (Alibaba)** — Qwen2.5-0.5B-Instruct model (Apache 2.0)
- **ggerganov & llama.cpp contributors** — inference engine (MIT)

## What is this

SpruceChat runs [Qwen2.5-0.5B](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF) entirely on-device using [llama.cpp](https://github.com/ggerganov/llama.cpp). A persistent server keeps the model loaded in RAM so after the first boot (~60s), each message just... goes. Tokens stream in one by one so you can watch it think.

The AI has the personality of a spruce tree. Patient. Unhurried. Quietly amazed by everything.

## Controls

| Button | Action |
|--------|--------|
| D-pad  | Navigate keyboard / scroll chat |
| A      | Open keyboard / type selected key |
| B      | Backspace / close keyboard / quit |
| X      | Space |
| Y / START | Send message |
| L1     | Shift |
| R1     | Delete |
| SELECT | Clear chat history |
| START + SELECT | Quit (PortMaster hotkey) |

## WiFi chat

llama-server listens on `0.0.0.0:8086`. Open `http://<device-ip>:8086` in a browser on any device on the same network to chat through llama-server's built-in web UI.

## Performance

On handhelds at the lower end (e.g. H700 / RG35XX Plus):
- **Model load**: ~60s one-time at launch
- **Generation**: ~1-3 tokens/sec streaming

Not fast, but the streaming makes it feel alive. A short response takes 10-30 seconds.

## Notes

- First launch takes extra time to assemble the model from chunks and
  extract the bundled Python + SDL2 tarballs (~30s one-time).
- The port bundles its own Python 3.11 and SDL2 (~50MB compressed,
  extracted on first run), so it works without any PortMaster runtime.
- Chat history lives in `ports/sprucechat/conf/chat_history.jsonl`.

## License

SpruceChat is MIT. See `sprucechat/licenses/` for the licenses of bundled dependencies.

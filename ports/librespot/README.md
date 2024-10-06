## Notes

Credits go to JanTrueno for developing this app. Big thanks to the developers of [librespot](https://github.com/librespot-org/librespot), which is the backend of this app. 

Please note that MuOS users will need to be on the Banana release or newer.


## Compile

```shell
sudo apt update && \
sudo apt upgrade && \
sudo apt install build-essential && \
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh && \
echo 'source $HOME/.cargo/env' >> ~/.bashrc && \
source ~/.bashrc && \
rustc --version && \
rustup update
sudo apt-get install build-essential libasound2-dev
sudo apt-get install libsdl2-dev
git clone git@github.com:YOURUSERNAME/librespot.git
cargo build --no-default-features --features "sdl-backend"
```

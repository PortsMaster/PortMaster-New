FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make cmake \
        pkg-config cmake ninja-build

# SDL2 dependencies
RUN apt install -y --no-install-recommends \
 git make pkg-config cmake ninja-build gnome-desktop-testing \
 libasound2-dev libpulse-dev \
 libaudio-dev libjack-dev libsndio-dev libx11-dev libxext-dev \
 libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxss-dev \
 libxkbcommon-dev libdrm-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev \
 libegl1-mesa-dev libdbus-1-dev libibus-1.0-dev libudev-dev fcitx-libs-dev \
 libwayland-dev

RUN apt install -y --no-install-recommends \
        clang-18

WORKDIR "/root"

CMD ["bash"]

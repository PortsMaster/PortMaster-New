FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt upgrade

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

# Newer version of gcc
RUN apt install -y --no-install-recommends \
        gcc-10 g++-10

# Install all SDL dependencies, see:
# https://github.com/libsdl-org/SDL/blob/main/docs/README-linux.md
# It should be safe to install extra dependencies, only those available
# will by dynamically loaded on target system
RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake ninja-build gnome-desktop-testing \
        libasound2-dev libpulse-dev libaudio-dev libjack-dev \
        libsndio-dev libx11-dev libxext-dev libxrandr-dev \
        libxcursor-dev libxfixes-dev libxi-dev libxss-dev \
        libxkbcommon-dev libdrm-dev libgbm-dev libgl1-mesa-dev \
        libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev \
        libibus-1.0-dev libudev-dev fcitx-libs-dev

RUN apt install -y --no-install-recommends \
        libopenal-dev

# Newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

CMD ["bash"]

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils \
        nano wget curl git

RUN apt install -y --no-install-recommends \
        build-essential libphysfs-dev

# SDL2 dependencies
RUN apt install -y --no-install-recommends \
 git make pkg-config cmake ninja-build gnome-desktop-testing \
 libasound2-dev libpulse-dev \
 libaudio-dev libjack-dev libsndio-dev libx11-dev libxext-dev \
 libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxss-dev \
 libxkbcommon-dev libdrm-dev libgbm-dev libgl1-mesa-dev libgles2-mesa-dev \
 libegl1-mesa-dev libdbus-1-dev libibus-1.0-dev libudev-dev fcitx-libs-dev \
 libwayland-dev

# SDL2-mixer deps
RUN apt install -y --no-install-recommends \
 libflac-dev libmodplug-dev libfluidsynth-dev libopusfile-dev

#RUN apt install -y --no-install-recommends \
#       build-essential libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev \
#       libphysfs-dev

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

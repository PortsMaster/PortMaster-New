FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake ninja-build

RUN apt install -y --no-install-recommends \
    libsqlite3-0 libjpeg62 liblua5.3-0 \
    zlib1g libpng16-16 libglu1-mesa libcurl4 libxml2 gettext \
    libsdl2-2.0-0 libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0 libsdl2-net-2.0-0 \
    libgl1-mesa-dri \
    libsqlite3-dev libjpeg62-dev liblua5.3-dev \
    zlib1g-dev libpng-dev libglu1-mesa-dev libcurl4-openssl-dev libxml2-dev \
    libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-net-dev \
    libgl1-mesa-dev

# Optional:
RUN apt install -y --no-install-recommends \
    libxdg-basedir1 libxdg-basedir-dev libbz2-1.0 libbz2-dev \
    liblzma5 liblzma-dev

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

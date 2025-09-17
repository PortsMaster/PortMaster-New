FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        ca-certificates apt-utils nano wget \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake ninja-build

# for curl
RUN apt install -y --no-install-recommends \
	libssl-dev libbrotli-dev libzstd-dev libpsl-dev

# for sdl-compat
RUN apt install -y --no-install-recommends \
    libsdl2-dev

# other sdl-1.2 libs
RUN apt install -y --no-install-recommends \
    libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-net1.2-dev

# also required
RUN apt install -y --no-install-recommends \
    libglm-dev

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

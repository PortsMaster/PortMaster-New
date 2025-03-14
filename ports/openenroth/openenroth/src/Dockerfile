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
        libgmp-dev libmpfr-dev libmpc-dev flex \
        gcc-10 g++-10 lld

RUN apt install -y --no-install-recommends \
        libsdl2-dev libfreetype-dev

RUN apt install -y --no-install-recommends \
        libdw-dev libbfd-dev libdwarf-dev \
        libunwind-dev

RUN apt install -y --no-install-recommends \
        libopenal-dev

RUN apt install -y --no-install-recommends \
	innoextract

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

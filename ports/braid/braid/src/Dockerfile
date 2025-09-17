FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture armhf

RUN apt update

RUN apt install -y --no-install-recommends \
  ca-certificates apt-utils nano wget git make

RUN apt install -y --no-install-recommends \
  libsdl2-dev:armhf

# newer version of gcc
RUN apt install -y \
  gcc-10-arm-linux-gnueabihf g++-10-arm-linux-gnueabihf

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

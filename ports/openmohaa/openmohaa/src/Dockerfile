FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        sudo whiptail ca-certificates apt-utils nano wget curl

RUN apt install -y --no-install-recommends \
        clang-18

RUN apt install -y build-essential git make \
        libsdl2-dev libopenal-dev flex bison \
        libssl-dev lld ninja-build

# newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.31.3/cmake-3.31.3-linux-`uname -m`.sh
RUN chmod a+x ./cmake-3.31.3-linux-`uname -m`.sh
RUN ./cmake-3.31.3-linux-`uname -m`.sh --prefix=/usr/local --exclude-subdir --skip-license

WORKDIR "/root"

CMD ["bash"]

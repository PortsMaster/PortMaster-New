FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake ninja-build

RUN apt install -y --no-install-recommends \
        libsdl2-dev libsdl2-mixer-dev libsdl2-ttf-dev \
        autotools-dev autoconf automake
        
WORKDIR "/root"

CMD ["bash"]

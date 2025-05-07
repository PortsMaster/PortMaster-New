FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        ca-certificates apt-utils nano wget curl \
        sudo git m4 rsync make

RUN apt install -y --no-install-recommends \
        patch unzip bubblewrap
RUN apt install -y --no-install-recommends \
        libxcursor-dev \
        libdbus-1-dev libdrm-dev libgbm-dev libudev-dev

RUN apt install -y --no-install-recommends \
        libpcre2-dev zlib1g-dev libmbedtls-dev

RUN apt install -y --no-install-recommends \
        libipc-system-simple-perl libstring-shellquote-perl \
        neko neko-dev pkg-config libpcre3-dev

RUN apt install -y --no-install-recommends \
libgl1-mesa-dev libglu1-mesa-dev g++ \
libasound2-dev libx11-dev libxext-dev libxi-dev libxrandr-dev \
libxinerama-dev libpulse-dev xdot

WORKDIR "/root"

CMD ["bash"]

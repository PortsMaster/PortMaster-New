FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        ca-certificates apt-utils nano wget \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake ninja-build

RUN apt install -y --no-install-recommends \
  zlib1g-dev libboost1.71-all-dev libglm-dev \
  libfreetype-dev libopenal-dev \
  libsdl2-dev libepoxy-dev

RUN apt remove -y \
  libsdl2-dev

RUN apt install -y --no-install-recommends \
  innoextract

WORKDIR "/root"

CMD ["bash"]

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
        gettext libreadline-dev libboost1.67-all-dev \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev \
        fontconfig libcairo2-dev libpango1.0-dev libvorbis-dev \
        libbz2-dev zlib1g-dev libssl-dev libcurl4-openssl-dev 

RUN apt install -y --no-install-recommends \
        python3-pip

RUN python3 -m pip install meson

        WORKDIR "/root"

CMD ["bash"]

FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make \
        pkg-config cmake

RUN apt install -y --no-install-recommends \
        libsdl1.2-dev libsdl-mixer1.2-dev \
        libfreetype6-dev zlib1g-dev \
        liblua5.1-0-dev swig

        WORKDIR "/root"

CMD ["bash"]
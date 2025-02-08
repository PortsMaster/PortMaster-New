FROM ubuntu:noble

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        whiptail ca-certificates apt-utils nano wget curl \
        lsb-release

RUN apt install -y --no-install-recommends \
        build-essential git make cmake \
        pkg-config cmake ninja-build

RUN apt install -y --no-install-recommends \
        libsdl-dev

CMD ["bash"]

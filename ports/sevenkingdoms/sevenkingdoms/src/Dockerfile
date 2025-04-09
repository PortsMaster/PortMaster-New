FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y --no-install-recommends \
        sudo whiptail ca-certificates apt-utils nano wget curl

RUN apt install -y build-essential git make automake autopoint \
        libopenal-dev libenet-dev libsdl2-dev libcurl4-openssl-dev \
        gettext

WORKDIR "/root"

CMD ["bash"]

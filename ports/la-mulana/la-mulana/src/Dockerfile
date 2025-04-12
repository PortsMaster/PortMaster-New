FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

RUN dpkg --add-architecture i386

RUN apt update

RUN apt install -y --no-install-recommends \
  ca-certificates apt-utils nano wget git zip

RUN apt install -y \
  libsdl2-dev:i386 libconfig-dev:i386

RUN apt install -y \
  gcc-multilib g++-multilib

WORKDIR "/root"

CMD ["bash"]

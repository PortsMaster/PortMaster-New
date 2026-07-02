FROM ubuntu:20.04
#Arkos is based on ubuntu 19.10

# This builds wargus for an rg40xx H running muos 

# docker buildx build --platform linux/arm64 --progress=plain -t wargus-build . && docker run --platform=linux/arm64 -it --rm --name wargusbuild wargus-build bash

# If you get issues running a multiplatform build on linux try install qemu manually
# https://docs.docker.com/build/building/multi-platform/#install-qemu-manually

# when it starts up in another shell run docker cp to copy the file out of the container 
# docker cp wargusbuild:/wargus-portmaster.zip wargus-portmaster.zip

# To do a release
# in PortMaster-New dir
# if sparse check out make sure these sparse locations added
#git sparse-checkout add ports/wargus
#git sparse-checkout add releases
#git sparse-checkout add runtimes
#git sparse-checkout add tools
# docker run -it -v ${PWD}:/opt ubuntu:20.04 /bin/bash
# apt update && apt install -y python3 wget && cd /opt && tools/prepare_repo.sh && python3 tools/build_data.py && python3 tools/build_release.py --do-check && python3 tools/build_release.py
# wargus.zip will be in the releases directory

ARG DEVICE_ARCH=aarch64
ENV DEBIAN_FRONTEND=noninteractive

# -------------------------------------------------
# Enable arm64 (aarch64) multiarch
# -------------------------------------------------
#RUN dpkg --add-architecture arm64

# -------------------------------------------------
# Build + runtime dependencies
# -------------------------------------------------
RUN apt-get update && apt-get install -y \
  build-essential \
  cmake \
  ninja-build \
  git \
  pkg-config \
  python3 \
  wget \
  ca-certificates \
  zip \
  \
  gcc-aarch64-linux-gnu \
  g++-aarch64-linux-gnu \
  \
  libz-dev \
  libpng-dev \
  \
  liblua5.1-0-dev \
  lua5.1 \
  tolua++ \
  libtolua++5.1-dev \
  libbz2-dev \
  autoconf \
  automake \
  libtool \
  binutils \
  libasound2-dev \
  innoextract \
  libogg-dev \
  libtheora-dev \
  libvorbis-dev \
  \
  && rm -rf /var/lib/apt/lists/*

#  libsdl2-dev:arm64 \
#   libsdl2-mixer-dev:arm64 \
  #libsdl2-image-dev:arm64 \

# -------------------------------------------------
# Build SDL2 with fbdev (no X11 / Wayland / KMS)
# -------------------------------------------------
ARG SDL_VERSION=2.26.2

RUN apt-get update && apt-get install -y \
  autoconf \
  automake \
  libtool \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN wget https://github.com/libsdl-org/SDL/releases/download/release-${SDL_VERSION}/SDL2-${SDL_VERSION}.tar.gz && \
    tar xf SDL2-${SDL_VERSION}.tar.gz

WORKDIR /build/SDL2-${SDL_VERSION}

RUN ./configure --help | grep video

RUN ./configure \
  --host=aarch64-linux-gnu \
  --prefix=/usr/aarch64-linux-gnu \
  \
  --enable-shared \
  --disable-static \
  \
  --enable-video \
  --enable-video-opengles \
  --disable-video-x11 \
  --disable-video-wayland \
  --disable-video-rpi \
  --disable-video-vulkan \
  --disable-video-directfb \
  --disable-video-vivante \
  --disable-video-dummy \
  \
  --enable-audio \
  --enable-alsa \
  --enable-alsa-shared \
  --disable-pulseaudio \
  --disable-jack \
  --disable-oss \
  --disable-esd \
  --disable-nas \
  --disable-sndio \
  --disable-diskaudio \
  \
  --enable-libsamplerate \
  --disable-libsamplerate-shared \
  \
  --disable-haptic \
  --disable-sensor \
  --disable-ime \
  --disable-power \
  \
  --disable-x11-shared \
  --disable-wayland-shared \
  \
  CC=aarch64-linux-gnu-gcc \
  CXX=aarch64-linux-gnu-g++

RUN make -j$(nproc)
RUN make install

# sanity check: fbdev MUST appear
RUN strings /usr/aarch64-linux-gnu/lib/libSDL2-2.0.so.0 
RUN strings /usr/aarch64-linux-gnu/lib/libSDL2-2.0.so.0 | grep asound 

WORKDIR /build

RUN git clone https://github.com/libsdl-org/SDL_image.git && \
    cd SDL_image && \
    git checkout release-2.8.x && \
    ./autogen.sh && \
    ./configure \
      --host=aarch64-linux-gnu \
      --prefix=/usr/aarch64-linux-gnu \
      \
      --enable-shared \
      --disable-static \
      \
      SDL2_CONFIG=/usr/aarch64-linux-gnu/bin/sdl2-config && \
    make -j$(nproc) && \
    make install

# =========================
# Build SDL2_mixer
# =========================

WORKDIR /build

RUN git clone https://github.com/libsdl-org/SDL_mixer.git && \
    cd SDL_mixer && \
    git checkout release-2.8.x && \
    ./autogen.sh && \
    ./configure \
      --host=aarch64-linux-gnu \
      --prefix=/usr/aarch64-linux-gnu \
      \
      --enable-shared \
      --disable-static \
      \
      --disable-music-midi \
      --disable-music-midi-timidity \
      --disable-music-midi-fluidsynth \
      \
      SDL2_CONFIG=/usr/aarch64-linux-gnu/bin/sdl2-config && \
    make -j$(nproc) && \
    make install


# -------------------------------------------------
# Toolchain file for cross-compiling Stratagus
# -------------------------------------------------
RUN cat > /toolchain.cmake <<'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CMAKE_C_COMPILER   aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)

# Allow host tools (tolua++)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

WORKDIR /build

ARG WARGUS_VERSION=v3.3.2

# -------------------------------------------------
# Fetch Stratagus (recursive is REQUIRED)
# -------------------------------------------------
RUN git clone --branch ${WARGUS_VERSION} --depth 1 --recursive https://github.com/Wargus/stratagus.git

# tolua++ binary name fix
RUN ln -sf /usr/bin/tolua++5.1 /usr/bin/tolua++

#RUN ln -sf /usr/lib/aarch64-linux-gnu/libtolua++5.1.so \
#           /usr/lib/aarch64-linux-gnu/libtolua++.so

RUN find /usr/lib/aarch64-linux-gnu -name "*tolua*.so*"
RUN dpkg -L libtolua++5.1-dev:arm64

#RUN git clone https://github.com/LuaDist/toluapp.git /build/toluapp

#RUN cd /build/toluapp && \
#    mkdir build-host && cd build-host && \
#    cmake .. \
#      -DCMAKE_BUILD_TYPE=Release \
#      -DBUILD_SHARED_LIBS=ON \
#      -DLUA_INCLUDE_DIR=/usr/include/lua5.1 \
#      -DLUA_LIBRARY=/usr/lib/x86_64-linux-gnu/liblua5.1.so && \
#    make -j$(nproc) && \
#    make install

#RUN cd /build/toluapp && \
#    mkdir build-arm64 && cd build-arm64 && \
#    cmake .. \
#      -DCMAKE_SYSTEM_NAME=Linux \
#      -DCMAKE_SYSTEM_PROCESSOR=aarch64 \
#      -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc \
#      -DCMAKE_CXX_COMPILER=aarch64-linux-gnu-g++ \
#      -DCMAKE_BUILD_TYPE=Release \
#      -DBUILD_SHARED_LIBS=ON \
#      -DLUA_INCLUDE_DIR=/usr/include/lua5.1 \
#      -DLUA_LIBRARY=/usr/lib/aarch64-linux-gnu/liblua5.1.so \
#      -DCMAKE_INSTALL_PREFIX=/usr/aarch64-linux-gnu && \
#    make -j$(nproc) && \
#    make install

# -------------------------------------------------
# Configure Stratagus (cross build)
# -------------------------------------------------
RUN cmake -S stratagus -B stratagus/build \
  -DCMAKE_TOOLCHAIN_FILE=/toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-DStratagusLastModifiedDate=\\\"unknown\\\" -DStratagusLastModifiedTime=\\\"unknown\\\"" \
  \
  -DCMAKE_PREFIX_PATH=/usr/aarch64-linux-gnu \
  \
  -DENABLE_DEV=OFF \
  -DENABLE_ONLINE_SERVICE=OFF \
  -DBUILD_TESTING=OFF \
  -DBUILD_VENDORED_MEDIA_LIBS=ON \
  \
  -DTOLUA++_APP=/usr/bin/tolua++5.1 \
  -DTOLUA++_LIBRARY=/usr/lib/libtolua++5.1.a \
  -DTOLUA++_INCLUDE_DIR=/usr/include/tolua++ \
  \
  -DLUA_INCLUDE_DIR=/usr/include/lua5.1 \
  -DLUA_LIBRARIES=/usr/lib/aarch64-linux-gnu/liblua5.1.so \
  \
  -DPNG_PNG_INCLUDE_DIR=/usr/include/aarch64-linux-gnu \
  -DPNG_LIBRARY=/usr/lib/aarch64-linux-gnu/libpng16.so \
  \
  -DZLIB_INCLUDE_DIR=/usr/include \
  -DZLIB_LIBRARY=/usr/lib/aarch64-linux-gnu/libz.so \
  \
  -DOGG_INCLUDE_DIR=/usr/include/aarch64-linux-gnu \
  -DOGG_LIBRARY=/usr/lib/aarch64-linux-gnu/libogg.so \
  \
  -DTHEORA_INCLUDE_DIR=/usr/include/aarch64-linux-gnu \
  -DTHEORA_LIBRARY=/usr/lib/aarch64-linux-gnu/libtheora.so \
  -DTHEORADEC_LIBRARY=/usr/lib/aarch64-linux-gnu/libtheoradec.so



# -------------------------------------------------
# Build Stratagus
# -------------------------------------------------
RUN cmake --build stratagus/build -j$(nproc)

# -------------------------------------------------
# Fetch Wargus data (no compilation)
# -------------------------------------------------
RUN git clone --depth 1 --branch ${WARGUS_VERSION} https://github.com/Wargus/wargus.git

RUN sed -i '1i\
if(CMAKE_CROSSCOMPILING)\n\
  set(STRATAGUS_FOUND TRUE)\n\
  return()\n\
endif()\n' \
wargus/cmake/modules/FindStratagus.cmake

RUN dpkg -L libbz2-dev:arm64

#RUN sed -i '/add_executable(wartool/ a \
#target_include_directories(wartool PRIVATE /build/stratagus/src/include)' \
#wargus/CMakeLists.txt

RUN find /build/stratagus -type f -name "stratagus-gameutils.h" -print

# Build Wargus extractor (wartool) for aarch64
RUN cmake -S wargus -B wargus/build \
  -DCMAKE_TOOLCHAIN_FILE=/toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DSTRATAGUS_INCLUDE_DIR=/build/stratagus/gameheaders \
  -DSTRATAGUS=/build/stratagus/build/stratagus \
  -DPNG_PNG_INCLUDE_DIR=/usr/include/aarch64-linux-gnu \
  -DPNG_LIBRARY=/usr/lib/aarch64-linux-gnu/libpng16.so \
  -DZLIB_INCLUDE_DIR=/usr/include \
  -DZLIB_LIBRARY=/usr/lib/aarch64-linux-gnu/libz.so \
  -DBZIP2_INCLUDE_DIR=/usr/include \
  -DBZIP2_LIBRARIES=/usr/lib/aarch64-linux-gnu/libbz2.so



RUN cmake --build wargus/build -j$(nproc) --target wartool    

# -------------------------------------------------
# Assemble PortMaster layout
# -------------------------------------------------
RUN mkdir -p /pkg/wargus/data /pkg/wargus/conf /pkg/wargus/libs.${DEVICE_ARCH} /pkg/wargus/Licenses/ /pkg/wargus/gamefiles && \
    cp stratagus/build/stratagus /pkg/wargus/stratagus.${DEVICE_ARCH} && \
    for d in campaigns contrib maps scripts shaders; do \
      cp -a "wargus/$d" /pkg/wargus/data/; \
    done

RUN cp -R /pkg/wargus/data/contrib /pkg/wargus/data/ui

# -------------------------------------------------
# Copy minimal runtime libraries
# -------------------------------------------------

# My version of SDL is not working but my on device sdl works great so using libsdl from /usr/lib

#RUN mkdir -p /pkg/wargus/libs.${DEVICE_ARCH} && \
#    cp /usr/aarch64-linux-gnu/lib/libSDL2-2.0.so.0 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/aarch64-linux-gnu/lib/libSDL2_image-2.0.so.0 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/aarch64-linux-gnu/lib/libSDL2_mixer-2.0.so.0 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libpng16.so.16 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libz.so.1 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/ && \
RUN  mkdir -p /pkg/wargus/libs.${DEVICE_ARCH} && \
     cp /usr/lib/aarch64-linux-gnu/liblua5.1.so.0 \
       /pkg/wargus/libs.${DEVICE_ARCH}/



#RUN cp /usr/lib/aarch64-linux-gnu/libSDL2-2.0.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libSDL2_mixer-2.0.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libSDL2_image-2.0.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libpng16.so.16 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libz.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/liblua5.1.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libXcursor.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXrender.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXfixes.so.3 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libX11.so.6 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libxcb.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXau.so.6 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXdmcp.so.6 /pkg/wargus/libs.${DEVICE_ARCH}/ 
    
#RUN cp /usr/lib/aarch64-linux-gnu/libXi.so.6 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXext.so.6 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libXrandr.so.2 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libXrender.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libXss.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/      

#RUN cp /usr/lib/aarch64-linux-gnu/libgbm.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libwayland-egl.so.1 /pkg/wargus/libs.${DEVICE_ARCH}/ && \
#    cp /usr/lib/aarch64-linux-gnu/libwayland-client.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libwayland-cursor.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libxkbcommon.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libdecor-0.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libjpeg.so.62 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /usr/lib/aarch64-linux-gnu/libwayland-server.so.0 /pkg/wargus/libs.${DEVICE_ARCH}/

#RUN cp /lib/aarch64-linux-gnu/libasound.so.2 \
#       /pkg/wargus/libs.${DEVICE_ARCH}/

RUN cp wargus/build/wartool /pkg/wargus/wartool.${DEVICE_ARCH}

#RUN cp /usr/bin/innoextract /pkg/wargus/innoextract.${DEVICE_ARCH}
# readelf -d /usr/bin/innoextract
RUN find /usr/lib/aarch64-linux-gnu/ -name "libboost_*.*"
RUN cp /usr/lib/aarch64-linux-gnu/libboost_iostreams.so.1.67.0 /pkg/wargus/libs.${DEVICE_ARCH}/
RUN cp /usr/lib/aarch64-linux-gnu/libboost_filesystem.so.1.67.0 /pkg/wargus/libs.${DEVICE_ARCH}/
RUN cp /usr/lib/aarch64-linux-gnu/libboost_program_options.so.1.67.0 /pkg/wargus/libs.${DEVICE_ARCH}/

# -------------------------------------------------
# Create PortMaster ZIP
# -------------------------------------------------
RUN cd /pkg && zip -r /wargus-portmaster.zip .

CMD ["bash", "-lc", "ls -lh /wargus-portmaster.zip && echo 'DONE'"]

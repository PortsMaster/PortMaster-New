cmake_minimum_required (VERSION 3.5)
project(Chowdren)

set(CHOWDREN_BASE_DIR "%(base_path)s")
set(APP_NAME "%(name)s")
set(APP_VERSION "%(version)s")
set(APP_COPYRIGHT "%(copyright)s")

set(USE_DLLS %(use_dlls)s)

set(APP_PLATFORM "%(platform)s")

%(frame_srcs)s

%(event_srcs)s

%(object_srcs)s

%(extension_srcs)s

%(defines)s

include(${CHOWDREN_BASE_DIR}/CMakeLists.txt)

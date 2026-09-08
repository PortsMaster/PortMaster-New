cmake_minimum_required(VERSION 3.16)
project(NOpenGLESDrv469 C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(UT99DC_ROOT "" CACHE PATH "UT99-Android third_party/ut99dc directory")
set(UT99DC_COMPAT_ROOT "" CACHE PATH "UT99-Android app/src/main/cpp directory")
set(UT469_SDK "" CACHE PATH "Extracted OldUnreal 469e SDK directory")
set(UT469_SYSTEM "" CACHE PATH "OldUnreal 469e Linux ARM64 System directory")
set(UT99_SYSROOT "$ENV{UT99_SYSROOT}" CACHE PATH "AArch64 Linux build sysroot")
set(UT99_OUTPUT_DIR "${CMAKE_BINARY_DIR}/out" CACHE PATH "Renderer output directory")

foreach(required_path UT99DC_ROOT UT99DC_COMPAT_ROOT UT469_SDK UT469_SYSTEM UT99_SYSROOT)
  if(NOT IS_DIRECTORY "${${required_path}}")
    message(FATAL_ERROR "${required_path} must name an existing directory")
  endif()
endforeach()

find_path(SDL2_INCLUDE_DIR SDL.h
  PATHS "${UT99_SYSROOT}/usr/include/SDL2"
  NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
find_library(SDL2_LIBRARY NAMES SDL2
  PATHS "${UT99_SYSROOT}/usr/lib" "${UT99_SYSROOT}/lib"
  NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
find_library(GLES2_LIBRARY NAMES GLESv2
  PATHS "${UT99_SYSROOT}/usr/lib" "${UT99_SYSROOT}/lib"
  NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)

if(NOT SDL2_INCLUDE_DIR OR NOT SDL2_LIBRARY OR NOT GLES2_LIBRARY)
  message(FATAL_ERROR "The selected sysroot must provide SDL2 and GLESv2 development files")
endif()

add_library(NOpenGLESDrv SHARED
  "${UT99DC_ROOT}/Source/NOpenGLESDrv/NOpenGLESDrv.cpp"
  "${UT99DC_COMPAT_ROOT}/android_glad_compat/glad.c"
)

target_include_directories(NOpenGLESDrv PRIVATE
  "${CMAKE_CURRENT_LIST_DIR}"
  "${UT99DC_ROOT}/Source/NOpenGLESDrv"
  "${UT99DC_COMPAT_ROOT}/android_glad_compat"
  "${UT99DC_COMPAT_ROOT}/android_glm_compat"
  "${UT469_SDK}/Core/Inc"
  "${UT469_SDK}/Engine/Inc"
  "${UT469_SDK}/Engine/Src"
  "${UT469_SDK}/Render/Inc"
  "${UT469_SDK}/Render/Src"
  "${UT469_SDK}/SDLDrv/Inc"
  "${UT99_SYSROOT}/usr/include"
  "${SDL2_INCLUDE_DIR}"
)

target_compile_definitions(NOpenGLESDrv PRIVATE
  GPackage=LocalPackageNameNOpenGLESDrv
  NOPENGLESDRV_EXPORTS
  NOPENGLES_469_COMPAT=1
  UNICODE=1
  _UNICODE=1
  _REENTRANT=1
  HAVE_PRAGMA_PACK=1
  __LINUX_ARM__=1
  __UNIX__=1
  SDLBUILD=1
  SDL2BUILD=1
  SDL3BUILD=0
  ENGINE_ARCHITECTURE="arm64"
  OLDUNREAL_TEXTURE_COMPRESSION=0
  SDL_DISABLE_MM3DNOW_H=1
  SDL_DISABLE_IMMINTRIN_H=1
  SDL_DISABLE_MMINTRIN_H=1
  SDL_DISABLE_XMMINTRIN_H=1
  SDL_DISABLE_EMMINTRIN_H=1
  SDL_DISABLE_PMMINTRIN_H=1
)

target_compile_options(NOpenGLESDrv PRIVATE
  -fPIC
  -fsigned-char
  -fno-strict-aliasing
  "-ffile-prefix-map=${CMAKE_SOURCE_DIR}=."
  "-fmacro-prefix-map=${CMAKE_SOURCE_DIR}=."
  -Wno-inline-new-delete
)

target_link_libraries(NOpenGLESDrv PRIVATE
  "${UT469_SYSTEM}/Render.so"
  "${UT469_SYSTEM}/Engine.so"
  "${UT469_SYSTEM}/Core.so"
  "${UT469_SYSTEM}/SDLDrv.so"
  "${SDL2_LIBRARY}"
  "${GLES2_LIBRARY}"
)

set_target_properties(NOpenGLESDrv PROPERTIES
  PREFIX ""
  OUTPUT_NAME "NOpenGLESDrv"
  LIBRARY_OUTPUT_DIRECTORY "${UT99_OUTPUT_DIR}"
  BUILD_WITH_INSTALL_RPATH TRUE
  SKIP_BUILD_RPATH TRUE
  INSTALL_RPATH "\$ORIGIN"
)

target_link_options(NOpenGLESDrv PRIVATE -Wl,--strip-all)

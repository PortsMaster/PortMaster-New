cmake_minimum_required(VERSION 3.29)

option(TRACY_ENABLE "Enable Tracy" OFF)
option(MARCH_NATIVE "Enable -march=native" ON)

set(CMAKE_CXX_STANDARD 20)

project(ModernCore
    LANGUAGES C CXX
)

include(CheckCompilerFlag)
include(FindPkgConfig)
include(CPM.cmake)

file(GENERATE OUTPUT .gitignore CONTENT "*")

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    find_program(MOLD_LINKER mold)
    if(MOLD_LINKER)
        set(CMAKE_LINKER_TYPE "MOLD")
    endif()
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_compile_options(-fno-eliminate-unused-debug-types)
    endif()
endif()

set(CMAKE_COLOR_DIAGNOSTICS ON)

if(NOT TRACY_ENABLE)
    set(TRACY_OPTIONS "TRACY_STATIC ON")
endif()

CPMAddPackage(
    NAME tracy
    GITHUB_REPOSITORY wolfpld/tracy
    GIT_TAG master
    OPTIONS ${TRACY_OPTIONS}
    EXCLUDE_FROM_ALL TRUE
)

pkg_check_modules(PNG REQUIRED libpng)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_CURRENT_LIST_DIR}/src)

if(TRACY_ENABLE)
    add_definitions(-DTRACY_ENABLE)
    add_compile_options(-g -O3 -fno-omit-frame-pointer)
endif()

if(MARCH_NATIVE)
    check_compiler_flag(CXX "-march=native" HAS_MARCH_NATIVE)
    if(HAS_MARCH_NATIVE)
        add_compile_options(-march=native)
    endif()
endif()

set(SOURCES
    Application.cpp
    bc7enc.cpp
    bcdec.c
    Bitmap.cpp
    BitmapDownsampled.cpp
    BlockData.cpp
    ColorSpace.cpp
    DataProvider.cpp
    Debug.cpp
    Decode.cpp
    Dither.cpp
    Error.cpp
    mmap.cpp
    ProcessDxtc.cpp
    ProcessRGB.cpp
    System.cpp
    Tables.cpp
    TaskDispatch.cpp
    TextureHeader.cpp
    Timing.cpp
)

add_executable(etcpak ${SOURCES})
target_link_libraries(etcpak Tracy::TracyClient ${PNG_LIBRARIES})
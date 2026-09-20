if("${CMAKE_SYSTEM_NAME}" MATCHES "Linux")
    set(LINUX 1)
endif()

if (APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET "10.6" CACHE STRING "")
endif()

set(CMAKE_MODULE_PATH "${CHOWDREN_BASE_DIR}/cmake")

if (NOT CMAKE_CROSSCOMPILING)
    include_directories("${CHOWDREN_BASE_DIR}/include/desktop")
    set(CMAKE_INCLUDE_PATH "${CHOWDREN_BASE_DIR}/include/desktop"
        ${CMAKE_INCLUDE_PATH})
    include_directories("${CHOWDREN_BASE_DIR}/desktop")

    if (EMSCRIPTEN)
        set(PLATFORM_CPP "${CHOWDREN_BASE_DIR}/desktop/emscriptenplatform.cpp")
    else()
        set(PLATFORM_CPP ${CHOWDREN_BASE_DIR}/desktop/platform.cpp)
    endif()
endif()

include_directories("${CHOWDREN_BASE_DIR}/gles2-compat")
include_directories("${CHOWDREN_BASE_DIR}/include")
include_directories("${CHOWDREN_BASE_DIR}")
include_directories("${PROJECT_SOURCE_DIR}")
set(CMAKE_INCLUDE_PATH "${CHOWDREN_BASE_DIR}/include" ${CMAKE_INCLUDE_PATH})

option(USE_BOX2D "Use Box2D" OFF)
option(USE_PYTHON "Use Python" OFF)
option(USE_STEAM "Use Steam" OFF)
option(EMULATE_WIIU "Emulate Wii U features" OFF)

if (CMAKE_CROSSCOMPILING)
    set(USE_GL ON)
    set(USE_GLES2 OFF)
    set(USE_GLES1 OFF)
    set(USE_D3D OFF)
endif()

if(EMSCRIPTEN)
    add_definitions(-DCHOWDREN_IS_EMSCRIPTEN)
endif()

if (NOT CMAKE_CROSSCOMPILING)
    add_definitions(-DCHOWDREN_IS_DESKTOP)
endif()

if (USE_GL)
    add_definitions(-DCHOWDREN_USE_GL)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
add_definitions(-DCHOWDREN_TEXTURE_GC)
add_definitions(-DSHOW_STATS)
elseif (USE_D3D)
    add_definitions(-DCHOWDREN_USE_D3D)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} "d3d9.lib")
elseif (USE_GLES1)
    add_definitions(-DCHOWDREN_USE_GLES1)
elseif (USE_GLES2)
    add_definitions(-DCHOWDREN_USE_GLES2)
endif()

if (NOT CMAKE_CROSSCOMPILING OR EMSCRIPTEN)
    set(PLATFORM_SRCS
        ${CHOWDREN_BASE_DIR}/desktop/glslshader.cpp
        ${CHOWDREN_BASE_DIR}/desktop/fbo.cpp
        ${PLATFORM_SRCS}
    )
endif()

set(SRCS
    ${OBJECTSRCS}
    fonts.cpp
    lists.cpp
    ${CHOWDREN_BASE_DIR}/render.cpp
    ${CHOWDREN_BASE_DIR}/run.cpp
    ${CHOWDREN_BASE_DIR}/keyconv.cpp
    ${CHOWDREN_BASE_DIR}/image.cpp
    ${PLATFORM_CPP}
    ${CHOWDREN_BASE_DIR}/assetfile.cpp
    ${CHOWDREN_BASE_DIR}/pools.cpp
    ${CHOWDREN_BASE_DIR}/font.cpp
    ${CHOWDREN_BASE_DIR}/movement.cpp
    ${CHOWDREN_BASE_DIR}/common.cpp
    ${CHOWDREN_BASE_DIR}/media.cpp
    ${CHOWDREN_BASE_DIR}/fpslimit.cpp
    ${CHOWDREN_BASE_DIR}/broadphase.cpp
    ${CHOWDREN_BASE_DIR}/profiler.cpp
    ${CHOWDREN_BASE_DIR}/stringcommon.cpp
    ${PLATFORM_SRCS}
    ${FRAMESRCS}
    ${EVENTSRCS}
    ${EXTSRCS}
)

if (USE_STEAM)
    add_definitions(-DCHOWDREN_ENABLE_STEAM)
    include_directories("${CHOWDREN_BASE_DIR}/steam/sdk/public")
    if (WIN32)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "${CHOWDREN_BASE_DIR}/steam/sdk/redistributable_bin/steam_api.lib")
    elseif (APPLE)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "${CHOWDREN_BASE_DIR}/steam/sdk/redistributable_bin/osx32/libsteam_api.dylib")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "${CHOWDREN_BASE_DIR}/steam/sdk/redistributable_bin/linux64/libsteam_api.so")
    else()
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES}
            "${CHOWDREN_BASE_DIR}/steam/sdk/redistributable_bin/linux32/libsteam_api.so")
    endif()
endif()

if (USE_BOX2D)
    add_definitions(-DCHOWDREN_USE_BOX2D)
    set(BOX2D_DIR "${CHOWDREN_BASE_DIR}/include/Box2D")
    set(SRCS
        ${SRCS}
        ${CHOWDREN_BASE_DIR}/box2d/box2dext.cpp
        ${BOX2D_DIR}/Collision/b2BroadPhase.cpp
        ${BOX2D_DIR}/Collision/b2CollideCircle.cpp
        ${BOX2D_DIR}/Collision/b2CollidePoly.cpp
        ${BOX2D_DIR}/Collision/b2Collision.cpp
        ${BOX2D_DIR}/Collision/b2Distance.cpp
        ${BOX2D_DIR}/Collision/b2PairManager.cpp
        ${BOX2D_DIR}/Collision/b2TimeOfImpact.cpp
        ${BOX2D_DIR}/Collision/Shapes/b2CircleShape.cpp
        ${BOX2D_DIR}/Collision/Shapes/b2EdgeShape.cpp
        ${BOX2D_DIR}/Collision/Shapes/b2PolygonShape.cpp
        ${BOX2D_DIR}/Collision/Shapes/b2Shape.cpp
        ${BOX2D_DIR}/Common/b2BlockAllocator.cpp
        ${BOX2D_DIR}/Common/b2Math.cpp
        ${BOX2D_DIR}/Common/b2Settings.cpp
        ${BOX2D_DIR}/Common/b2StackAllocator.cpp
        ${BOX2D_DIR}/Dynamics/b2Body.cpp
        ${BOX2D_DIR}/Dynamics/b2ContactManager.cpp
        ${BOX2D_DIR}/Dynamics/b2Island.cpp
        ${BOX2D_DIR}/Dynamics/b2World.cpp
        ${BOX2D_DIR}/Dynamics/b2WorldCallbacks.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2CircleContact.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2Contact.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2ContactSolver.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2EdgeAndCircleContact.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2PolyAndCircleContact.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2PolyAndEdgeContact.cpp
        ${BOX2D_DIR}/Dynamics/Contacts/b2PolyContact.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2BuoyancyController.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2ConstantAccelController.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2ConstantForceController.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2Controller.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2GravityController.cpp
        ${BOX2D_DIR}/Dynamics/Controllers/b2TensorDampingController.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2DistanceJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2GearJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2Joint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2LineJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2MaxMinJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2MouseJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2PrismaticJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2PulleyJoint.cpp
        ${BOX2D_DIR}/Dynamics/Joints/b2RevoluteJoint.cpp
    )
endif()

if (EMULATE_WIIU)
    add_definitions(-DCHOWDREN_EMULATE_WIIU)
    add_definitions(-DCHOWDREN_HAS_MRT)
endif()

if(WIN32)
    if (MINGW)
        set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} imm32 version)
        set(CMAKE_LIBRARY_PATH "${CHOWDREN_BASE_DIR}/lib/mingw"
            ${CMAKE_LIBRARY_PATH})
    else()
        set(CMAKE_LIBRARY_PATH "${CHOWDREN_BASE_DIR}/lib/win32"
            ${CMAKE_LIBRARY_PATH})
    endif()
    set(CMAKE_INCLUDE_PATH "${CHOWDREN_BASE_DIR}/include/win32"
        ${CMAKE_INCLUDE_PATH})
    set(SRCS ${SRCS} resource.rc)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} winmm)
elseif(APPLE)
    set(CMAKE_LIBRARY_PATH "${CHOWDREN_BASE_DIR}/lib/osx"
        ${CMAKE_LIBRARY_PATH})
    set(CMAKE_INCLUDE_PATH "${CHOWDREN_BASE_DIR}/include/osx"
        ${CMAKE_INCLUDE_PATH})
    # for frameworks
    set(CMAKE_INCLUDE_PATH "${CHOWDREN_BASE_DIR}/lib/osx"
        ${CMAKE_INCLUDE_PATH})
    find_library(CARBON_LIBRARY Carbon)
    set(PLATFORM_LIBRARIES ${PLATFORM_LIBRARIES} ${CARBON_LIBRARY})
endif()

if(MSVC)
    if(MSVC11)
        SET(CMAKE_GENERATOR_TOOLSET "v110_xp" CACHE STRING
            "Name of generator toolset." FORCE)
    elseif(MSVC12)
        SET(CMAKE_GENERATOR_TOOLSET "v120_xp" CACHE STRING
            "Name of generator toolset." FORCE)
    endif()

    # /bigobj is required for MSVC because objects.cpp can get too big on
    # some applications
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj")
    # silence some stupid warnings
    add_definitions("/wd4244 /wd4102 /wd4305 /wd4351")
    add_definitions("-D_CRT_SECURE_NO_WARNINGS")
    add_definitions("-D_SCL_SECURE_NO_WARNINGS")
    # multicore compile
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
    # SSE2
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /arch:SSE2")
    # Disable RTTI
    STRING(REGEX REPLACE "/GR" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GR-")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /GS-")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SAFESEH:NO")
endif()

if(LINUX)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc")
endif()

if(APPLE)
    set(MACOSX_BUNDLE_ICON_FILE icon.icns)
    set(MACOSX_BUNDLE_BUNDLE_NAME ${APP_NAME})
    set(MACOSX_BUNDLE_GUI_IDENTIFIER ${APP_NAME})
    set(MACOSX_BUNDLE_INFO_STRING "${APP_NAME} - ${APP_VERSION}")
    set(MACOSX_BUNDLE_BUNDLE_VERSION "${APP_VERSION}")
    set(MACOSX_BUNDLE_COPYRIGHT "${APP_COPYRIGHT}")
    set(DATA_SRCS ${DATA_SRCS} "${CMAKE_SOURCE_DIR}/${MACOSX_BUNDLE_ICON_FILE}")
    # set(DATA_SRCS ${DATA_SRCS} "${CHOWDREN_BASE_DIR}/alsoft.conf")
endif()

# include alsoft.conf
# set(DATA_SRCS ${DATA_SRCS} "${CHOWDREN_BASE_DIR}/alsoft.conf")

if(LINUX)
    set(DATA_SRCS ${DATA_SRCS} "${CHOWDREN_BASE_DIR}/run.sh")
endif()

if (USE_PYTHON)
    add_definitions(-DCHOWDREN_USE_PYTHON)
    find_package(PythonLibs 2.7 REQUIRED)
    include_directories(${PYTHON_INCLUDE_DIRS})
endif()

# for Linux (set RPATH properly)
set(CMAKE_INSTALL_RPATH "\$ORIGIN")
set(CMAKE_SKIP_BUILD_RPATH TRUE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
set(CMAKE_INSTALL_NAME_DIR "@executable_path")

if(APPLE)
    set_source_files_properties(${DATA_SRCS} PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources)
    set(SRCS ${SRCS} ${DATA_SRCS})
endif()

add_definitions(-DBOOST_ALL_NO_LIB)
add_definitions(-DBOOST_NO_EXCEPTIONS)
add_definitions(-DBOOST_EXCEPTION_DISABLE)

include_directories(${CHOWDREN_BASE_DIR}/include/staticlibs)
if (NOT NO_STATIC_OGG)
    # libogg
    file(GLOB LIBOGG_C
         "${CHOWDREN_BASE_DIR}/staticlibs/libogg/src/*.c")
    file(GLOB LIBVORBIS_C
         "${CHOWDREN_BASE_DIR}/staticlibs/libvorbis/lib/*.c")
    set(VORBIS_INCLUDE_DIR
        "${CHOWDREN_BASE_DIR}/staticlibs/libvorbis/lib")
    set(SRCS ${LIBOGG_C} ${LIBVORBIS_C} ${SRCS})
endif()

if (USE_WEBP)
    file(GLOB WEBP_C
         "${CHOWDREN_BASE_DIR}/staticlibs/webp/*/*.c")
    set(WEBP_INCLUDE_DIR
        "${CHOWDREN_BASE_DIR}/staticlibs/webp")
    set(SRCS ${WEBP_C} ${SRCS})
endif()

if (NOT CMAKE_CROSSCOMPILING)
    find_package(SDL2 REQUIRED)
    find_package(OpenALSoft REQUIRED)
    if (USE_GL)
        find_package(OpenGL REQUIRED)
    else()
        find_package(OpenGLES2 REQUIRED)
    endif()
endif()

set(EXE_NAME "Chowdren")
add_executable(${EXE_NAME} WIN32 MACOSX_BUNDLE ${SRCS})

include_directories(${OPENALSOFT_INCLUDE_DIR} ${SDL2_INCLUDE_DIR}
    ${VORBIS_INCLUDE_DIR} ${BOX2D_INCLUDE_DIR} ${WEBP_INCLUDE_DIR})
target_link_libraries(${EXE_NAME} ${SDL2_LIBRARY} ${OPENGL_LIBRARY}
    ${OPENALSOFT_LIBRARY} ${PYTHON_LIBRARIES} ${PLATFORM_LIBRARIES}
    ${BOX2D_LIBRARY} ${OPENGLES2_LIBRARIES} ${EGL_LIBRARIES})

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/install)

set(BIN_DIR ".")
set(DATA_PATH ".")
if(APPLE)
    set(DATA_PATH "/${EXE_NAME}.app/Contents/Resources")
    set(EXE_PATH "\${CMAKE_INSTALL_PREFIX}/${EXE_NAME}.app")
elseif(WIN32)
    set(EXE_PATH "\${CMAKE_INSTALL_PREFIX}/${EXE_NAME}.exe")
    set(DLL_PATH "${CHOWDREN_BASE_DIR}/bin/win32")
else()
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(BIN_DIR "bin64")
    else()
        set(BIN_DIR "bin32")
    endif()
    set(EXE_PATH "\${CMAKE_INSTALL_PREFIX}/${BIN_DIR}/${EXE_NAME}")
endif()

if (WIN32)
    set(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION ${CMAKE_INSTALL_PREFIX})
endif()

set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_NO_WARNINGS TRUE)
include(InstallRequiredSystemLibraries)
install(TARGETS ${EXE_NAME} DESTINATION ${BIN_DIR})
install(CODE "
    function(gp_item_default_embedded_path_override item default_embedded_path_var)
        set(path \"\${\${default_embedded_path_var}}\")
        if (${LINUX})
            set(path \"@executable_path\")
        endif()
        set(\${default_embedded_path_var} \"\${path}\" PARENT_SCOPE)
    endfunction(gp_item_default_embedded_path_override)

   set(BU_CHMOD_BUNDLE_ITEMS TRUE)
   include(BundleUtilities)
   fixup_bundle(\"${EXE_PATH}\"   \"\"   \"${DLL_PATH}\")
   " COMPONENT Runtime)

if(NOT APPLE)
    install(FILES ${DATA_SRCS} DESTINATION ".")
endif()

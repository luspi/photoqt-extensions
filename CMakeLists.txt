#########################################################
# CMakeLists for PhotoQt Extensions: http://photoqt.org #
#########################################################

cmake_minimum_required(VERSION 3.16)
project(photoqt-extensions LANGUAGES C CXX)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake")

option(BUILD_CROPIMAGE          "Build extension: Crop images"            ON)
option(BUILD_EXPORTIMAGE        "Build extension: Export images"          ON)
option(BUILD_FLOATINGNAVIGATION "Build extension: Floating navigation"    ON)
option(BUILD_HISTOGRAM          "Build extension: Histogram"              ON)
option(BUILD_IMGURCOM           "Build extension: Upload to imgur.com"    ON)
option(BUILD_MAPCURRENT         "Build extension: Map (current location)" ON)
option(BUILD_QUICKACTIONS       "Build extension: Quick actions"          ON)
option(BUILD_SCALEIMAGE         "Build extension: Scale images"           ON)
option(BUILD_WALLPAPER          "Build extension: Set as wallpaper"       ON)

option(INSTALL_INTO_LIB_SUBDIR  "This installs the extensions into the lib/PhotoQt/extensions subdirectory of the install prefix" ON)

SET(STATUS_ENABLED "")
SET(STATUS_DISABLED "")

# This avoids hardcoding 'lib' as subdir for the shared libraries
include(GNUInstallDirs)
if(INSTALL_INTO_LIB_SUBDIR)
    SET(PQESUBDIR "${CMAKE_INSTALL_LIBDIR}/PhotoQt/extensions")
    message("** Extensions will be installed into ${PQESUBDIR}")
else()
    set(PQESUBDIR "")
endif()

if(BUILD_CROPIMAGE)
    list(APPEND STATUS_ENABLED "CropImage")
    add_subdirectory("CropImage/")
else()
    list(APPEND STATUS_DISABLED "CropImage")
endif()

if(BUILD_EXPORTIMAGE)
    list(APPEND STATUS_ENABLED "ExportImage")
    add_subdirectory("ExportImage/")
else()
    list(APPEND STATUS_DISABLED "ExportImage")
endif()

if(BUILD_FLOATINGNAVIGATION)
    list(APPEND STATUS_ENABLED "FloatingNavigation")
    add_subdirectory("FloatingNavigation/")
else()
    list(APPEND STATUS_DISABLED "FloatingNavigation")
endif()

if(BUILD_HISTOGRAM)
    list(APPEND STATUS_ENABLED "Histogram")
    add_subdirectory("Histogram/")
else()
    list(APPEND STATUS_DISABLED "Histogram")
endif()

if(BUILD_IMGURCOM)
    list(APPEND STATUS_ENABLED "ImgurCom")
    add_subdirectory("ImgurCom/")
else()
    list(APPEND STATUS_DISABLED "ImgurCom")
endif()

if(BUILD_MAPCURRENT)
    list(APPEND STATUS_ENABLED "MapCurrent")
    add_subdirectory("MapCurrent/")
else()
    list(APPEND STATUS_DISABLED "MapCurrent")
endif()

if(BUILD_QUICKACTIONS)
    list(APPEND STATUS_ENABLED "QuickActions")
    add_subdirectory("QuickActions/")
else()
    list(APPEND STATUS_DISABLED "QuickActions")
endif()

if(BUILD_SCALEIMAGE)
    list(APPEND STATUS_ENABLED "ScaleImage")
    add_subdirectory("ScaleImage/")
else()
    list(APPEND STATUS_DISABLED "ScaleImage")
endif()

if(BUILD_WALLPAPER)
    list(APPEND STATUS_ENABLED "Wallpaper")
    add_subdirectory("Wallpaper/")
else()
    list(APPEND STATUS_DISABLED "Wallpaper")
endif()

set(NUM_DISABLED 0)
list(LENGTH STATUS_DISABLED NUM_DISABLED)

message("")
message("** The following extensions have been enabled:")
message("")
foreach(ext IN LISTS STATUS_ENABLED)
    message("    - ${ext}")
endforeach()
message("")

if(NUM_DISABLED GREATER 0)
    message("")
    message("** The following extensions have been DISABLED:")
    message("")
    foreach(ext IN LISTS STATUS_DISABLED)
        message("    - ${ext}")
    endforeach()
    message("")
endif()


if(UNIX)
    include(GNUInstallDirs)
    install(
        FILES org.photoqt.Extensions.metainfo.xml
        DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo/
    )
endif()

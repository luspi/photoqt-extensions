cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(ExportImage)

option(WITH_IMAGEMAGICK    "Configure with support for the ImageMagick library" ON)
option(WITH_GRAPHICSMAGICK "Configure with support for the GraphicsMagick library" OFF)

if(WITH_IMAGEMAGICK)
    if(WITH_GRAPHICSMAGICK)
        set(WITH_GRAPHICSMAGICK OFF)
        message("** ImageMagick and GraphicsMagick cannot be used at the same time.")
        message("** GraphicsMagick has been automatically disabled in favour of ImageMagick.")
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui LinguistTools Widgets)

if(WITH_IMAGEMAGICK AND NOT TARGET ImageMagick::Magick++)
    find_package(ImageMagick COMPONENTS Magick++ REQUIRED)
endif()

if(WITH_GRAPHICSMAGICK)
    find_package(GraphicsMagick REQUIRED)
endif()

qt_standard_project_setup()

qt_add_library(${PROJECT_NAME} SHARED
    cplusplus/methods.cpp
    cplusplus/methods.h
    cplusplus/pqc_extensionactions.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets)

file(GLOB files "lang/*.ts")
qt_add_translations(${PROJECT_NAME} TS_FILES ${files} QM_FILES_OUTPUT_VARIABLE LANG_SRC)

if(WITH_IMAGEMAGICK)
    message("** Using ImageMagick ${ImageMagick_VERSION_STRING}")
    # These checks are necessary to "fix" compiling PhotoQt with both ImageMagick 6 and 7 available
    if(ImageMagick_VERSION_STRING MATCHES "^7")
        string(REPLACE "libMagick++-6." "libMagick++-7." ImageMagick_LIBRARIES "${ImageMagick_LIBRARIES}")
        string(REPLACE "ImageMagick-6" "ImageMagick-7" ImageMagick_INCLUDE_DIRS "${ImageMagick_INCLUDE_DIRS}")
    endif()
    target_compile_definitions(${PROJECT_NAME} PRIVATE PQEIMAGEMAGICK)
    target_link_libraries(${PROJECT_NAME} PRIVATE ImageMagick::Magick++)
else()
    message("** ImageMagick DISABLED")
endif()

if(WITH_GRAPHICSMAGICK)
    message("** Using Graphicsmagick")
    target_include_directories(${PROJECT_NAME} PRIVATE ${MAGICK++_INCLUDE_DIR})
    target_compile_definitions(${PROJECT_NAME} PRIVATE PQEGRAPHICSMAGICK)
    target_link_libraries(${PROJECT_NAME} PRIVATE "GraphicsMagick++")
else()
    message("** Graphicsmagick DISABLED")
endif()

install(TARGETS ${PROJECT_NAME} DESTINATION "${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${PROJECT_NAME}")
install(DIRECTORY img DESTINATION "${PROJECT_NAME}")
install(FILES ${LANG_SRC} DESTINATION "${PROJECT_NAME}/lang/")

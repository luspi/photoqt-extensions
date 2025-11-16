cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(ExportImage)

set(SUBFOLDER "lib/PhotoQt/extensions/" CACHE STRING "What subfolder to move the installed files to.")

option(WITH_IMAGEMAGICK    "Configure with support for the ImageMagick library" ON)
option(WITH_GRAPHICSMAGICK "Configure with support for the GraphicsMagick library" OFF)

if(WITH_IMAGEMAGICK)
    if(WITH_GRAPHICSMAGICK)
        set(WITH_GRAPHICSMAGICK OFF)
        message("** ImageMagick and GraphicsMagick cannot be used at the same time.")
        message("** GraphicsMagick has been automatically disabled in favour of ImageMagick.")
    endif()
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui LinguistTools)

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

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui)

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

install(TARGETS ${PROJECT_NAME} DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES definition.yml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${SUBFOLDER}${PROJECT_NAME})
install(DIRECTORY img DESTINATION ${SUBFOLDER}${PROJECT_NAME})
install(FILES ${LANG_SRC} DESTINATION ${SUBFOLDER}${PROJECT_NAME}/lang/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    file(COPY img DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    foreach(F ${LANG_SRC})
        get_filename_component(FileName ${F} NAME)
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${F} ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/lang/${FileName}
        )
    endforeach()
endif()

cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(Wallpaper)

set(SUBFOLDER "lib/PhotoQt/extensions/" CACHE STRING "What subfolder to move the installed files to.")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets DBus)

qt_standard_project_setup()

qt_add_library(${PROJECT_NAME} SHARED
    cplusplus/methods.cpp
    cplusplus/methods.h
    cplusplus/pqc_extensionactions.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Widgets Qt6::DBus)

install(TARGETS ${PROJECT_NAME} DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES definition.yml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
endif()

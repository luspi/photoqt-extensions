cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(MapCurrent)

set(SUBFOLDER "lib/PhotoQt/extensions/" CACHE STRING "What subfolder to move the installed files to.")

# Install the definitions and the library
install(FILES definition.yml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
endif()

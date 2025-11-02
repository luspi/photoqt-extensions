cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(Histogram)

find_package(Qt6 REQUIRED COMPONENTS Core Gui)

qt_standard_project_setup()

qt_add_library(${PROJECT_NAME} SHARED
    cplusplus/methods.cpp
    cplusplus/methods.h
    cplusplus/pqc_extensionactions.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui)

# Install the definitions and the library
install(FILES definition.yml DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)
install(TARGETS ${PROJECT_NAME} DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
endif()

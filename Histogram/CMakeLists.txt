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

install(TARGETS ${PROJECT_NAME} DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)
install(DIRECTORY qml/ DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/qml/)
install(FILES definition.yml DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)

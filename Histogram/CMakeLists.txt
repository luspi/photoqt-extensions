cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(Histogram)

find_package(Qt6 REQUIRED COMPONENTS Core Gui LinguistTools)

qt_standard_project_setup()

qt_add_library(${PROJECT_NAME} SHARED
    cplusplus/methods.cpp
    cplusplus/methods.h
    cplusplus/pqc_extensionactions.h
)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui)

file(GLOB files "lang/*.ts")
qt_add_translations(${PROJECT_NAME} TS_FILES ${files} QM_FILES_OUTPUT_VARIABLE LANG_SRC)

# Install the definitions and the library
install(TARGETS ${PROJECT_NAME} DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(DIRECTORY img DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES ${LANG_SRC} DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/lang/")

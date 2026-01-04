cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(ImgurCom)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Sql Network LinguistTools Widgets)

qt_standard_project_setup()

qt_add_library(${PROJECT_NAME} SHARED
    cplusplus/methods.cpp
    cplusplus/methods.h
    cplusplus/pqc_extensionactions.h
)

qt_add_resources(${PROJECT_NAME} imgurhistory.db)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Sql Qt6::Network Qt6::Widgets)

file(GLOB files "lang/*.ts")
qt_add_translations(${PROJECT_NAME} TS_FILES ${files} QM_FILES_OUTPUT_VARIABLE LANG_SRC)

install(TARGETS ${PROJECT_NAME} DESTINATION "${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${PROJECT_NAME}")
install(DIRECTORY img DESTINATION "${PROJECT_NAME}")
install(FILES ${LANG_SRC} DESTINATION "${PROJECT_NAME}/lang/")

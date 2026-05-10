cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(ImgurCom)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Sql Network LinguistTools Widgets)

qt_standard_project_setup()

set(SOURCES cplusplus/methods.cpp cplusplus/methods.h cplusplus/pqc_extensionactions.h)

qt_add_resources(SOURCES resources.qrc)
qt_add_library(${PROJECT_NAME} MODULE ${SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Gui Qt6::Sql Qt6::Network Qt6::Widgets)

file(GLOB files "lang/*.ts")
qt_add_translations(${PROJECT_NAME} TS_FILES ${files} QM_FILES_OUTPUT_VARIABLE LANG_SRC)

install(TARGETS ${PROJECT_NAME} DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}")
install(DIRECTORY img DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}")
install(FILES ${LANG_SRC} DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/lang/")

cmake_minimum_required(VERSION 3.26)

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
install(TARGETS ${PROJECT_NAME} DESTINATION ${PROJECT_NAME}/)
install(FILES manifest.yml DESTINATION ${PROJECT_NAME}/)
install(FILES verification.txt DESTINATION ${PROJECT_NAME}/)
install(FILES verification.txt.sig DESTINATION ${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${PROJECT_NAME}/)
install(DIRECTORY img DESTINATION ${PROJECT_NAME}/)
install(FILES ${LANG_SRC} DESTINATION ${PROJECT_NAME}/lang/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE manifest.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/manifest.yml)
    file(COPY_FILE verification.txt ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/verification.txt)
    file(COPY_FILE verification.txt.sig ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/verification.txt.sig)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    file(COPY img DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    foreach(F ${LANG_SRC})
        get_filename_component(FileName ${F} NAME)
        add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy ${F} ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/lang/${FileName}
        )
    endforeach()
endif()

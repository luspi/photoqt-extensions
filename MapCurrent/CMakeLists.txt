cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(MapCurrent)

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

set(INSTALLDESTDIR "${PROJECT_NAME}")
if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    set(INSTALLDESTDIR "lib/PhotoQt/extensions/${PROJECT_NAME}")
endif()

# Install the definitions and the library
install(FILES manifest.yml DESTINATION ${INSTALLDESTDIR}/)
install(FILES verification.txt DESTINATION ${INSTALLDESTDIR}/)
install(FILES verification.txt.sig DESTINATION ${INSTALLDESTDIR}/)
install(DIRECTORY qml DESTINATION ${INSTALLDESTDIR}/)
install(DIRECTORY img DESTINATION ${INSTALLDESTDIR}/)
install(FILES ${LANG_SRC} DESTINATION ${INSTALLDESTDIR}/lang/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE manifest.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/manifest.yml)
    file(COPY_FILE verification.txt ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/verification.txt)
    file(COPY_FILE verification.txt.sig ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/verification.txt.sig)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    file(COPY img DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    foreach(f ${LANG_SRC})
        file(COPY ${f} DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/lang/)
    endforeach()
endif()

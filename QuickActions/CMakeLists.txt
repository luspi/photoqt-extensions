cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(QuickActions)

set(SUBFOLDER "lib/PhotoQt/extensions/" CACHE STRING "What subfolder to move the installed files to.")

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

install(DIRECTORY img DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES manifest.yml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES verification.txt DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES verification.txt.sig DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES ${LANG_SRC} DESTINATION ${SUBFOLDER}${PROJECT_NAME}/lang/)

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

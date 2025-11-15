cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(QuickActions)

set(SUBFOLDER "lib/PhotoQt/extensions/" CACHE STRING "What subfolder to move the installed files to.")

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

install(DIRECTORY img DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(DIRECTORY qml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES definition.yml DESTINATION ${SUBFOLDER}${PROJECT_NAME}/)
install(FILES ${LANG_SRC} DESTINATION ${SUBFOLDER}${PROJECT_NAME}/lang/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    file(COPY img DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    foreach(f ${LANG_SRC})
        file(COPY ${f} DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/lang/)
    endforeach()
endif()

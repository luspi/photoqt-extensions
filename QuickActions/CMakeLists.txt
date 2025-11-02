cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(QuickActions)

install(DIRECTORY img/ DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/img/)
install(FILES definition.yml DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)

if(BUILD_EXTENSIONS_AS_PART_OF_PHOTOQT)
    file(COPY_FILE definition.yml ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/definition.yml)
    file(COPY qml DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
    file(COPY img DESTINATION ${CMAKE_BINARY_DIR}/extensions/${PROJECT_NAME}/)
endif()

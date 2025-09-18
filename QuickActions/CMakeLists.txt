cmake_minimum_required(VERSION 3.26)

# MODIFY THIS NAME
project(QuickActions)

install(DIRECTORY img/ DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/img/)
install(FILES definition.yml DESTINATION lib/PhotoQt/extensions/${PROJECT_NAME}/)

include(../helper.cmake)

INSTALLQML()

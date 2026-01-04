cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(QuickActions)

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

install(DIRECTORY img DESTINATION "${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${PROJECT_NAME}/")
install(FILES ${LANG_SRC} DESTINATION "${PROJECT_NAME}/lang/")

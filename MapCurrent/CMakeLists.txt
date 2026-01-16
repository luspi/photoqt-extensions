cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(MapCurrent)

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

# Install the definitions and the library
install(FILES manifest.yml DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(DIRECTORY img DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/")
install(FILES ${LANG_SRC} DESTINATION "${PQEPREFIX}/${PROJECT_NAME}/lang/")

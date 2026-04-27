cmake_minimum_required(VERSION 3.16)

# MODIFY THIS NAME
project(FloatingNavigation)

# without target, we need to provide the final qm translation files
file(GLOB LANG_SRC "lang/*.qm")

install(DIRECTORY img DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(DIRECTORY qml DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES manifest.yml DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES verification.txt DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES verification.txt.sig DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/")
install(FILES ${LANG_SRC} DESTINATION "${CMAKE_INSTALL_PREFIX}/${PQESUBDIR}/${PROJECT_NAME}/lang/")

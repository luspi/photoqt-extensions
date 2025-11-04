#########################################################
# CMakeLists for PhotoQt Extensions: http://photoqt.org #
#########################################################

cmake_minimum_required(VERSION 3.26)
project(photoqt LANGUAGES C CXX)

add_subdirectory("ExportImage/")
add_subdirectory("Histogram/")
add_subdirectory("MapCurrent/")
add_subdirectory("QuickActions/")
add_subdirectory("ScaleImage/")
add_subdirectory("Wallpaper/")

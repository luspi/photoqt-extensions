#########################################################
# CMakeLists for PhotoQt Extensions: http://photoqt.org #
#########################################################

cmake_minimum_required(VERSION 3.26)
project(photoqt LANGUAGES C CXX)

add_subdirectory("CropImage/")
add_subdirectory("ExportImage/")
add_subdirectory("FloatingNavigation/")
add_subdirectory("Histogram/")
add_subdirectory("ImgurCom/")
add_subdirectory("MapCurrent/")
add_subdirectory("QuickActions/")
add_subdirectory("ScaleImage/")
add_subdirectory("Wallpaper/")

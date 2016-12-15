project(QML)

cmake_minimum_required(VERSION 2.8.12)
set(CMAKE_MACOSX_RPATH 1)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
list(APPEND CMAKE_CXX_FLAGS "-std=c++11")
add_definitions(-DJULIA_ENABLE_THREADING)

find_package(Qt5Quick)
find_package(Qt5Core)
find_package(Qt5Widgets)
find_package(CxxWrap)

get_target_property(QtCore_location Qt5::Core LOCATION)
get_filename_component(QtCore_location ${QtCore_location} DIRECTORY)
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;${QtCore_location}")

add_library(loadqml SHARED
  loadqml.cpp
${MOC_BUILT_SOURCES} ${UI_BUILT_SOURCES} ${RESOURCES})
target_link_libraries(loadqml Qt5::Core Qt5::Quick Qt5::Widgets)

add_executable(qmlloader qmlloader.cpp)
target_link_libraries(qmlloader loadqml Qt5::Core Qt5::Quick Qt5::Widgets)

install(TARGETS
  loadqml
  qmlloader
LIBRARY DESTINATION lib
ARCHIVE DESTINATION lib
RUNTIME DESTINATION bin)

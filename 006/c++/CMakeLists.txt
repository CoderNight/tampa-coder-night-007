project(BlueHawaii)
cmake_minimum_required(VERSION 2.8)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin)

include(ExternalProject)

ExternalProject_Add(
  JsonBox_LIB
  GIT_REPOSITORY https://github.com/anhero/JsonBox
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}
)

include_directories(${CMAKE_BINARY_DIR}/include)
link_directories(${CMAKE_BINARY_DIR}/lib)

SET(LINK_LIBRARY optimized JsonBox debug JsonBox_d)

add_subdirectory(src)

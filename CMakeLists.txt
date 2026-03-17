cmake_minimum_required(VERSION 3.20)

project(goertzel VERSION 1.0.0 LANGUAGES C CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

option(GOERTZEL_BUILD_TESTS "Build Goertzel tests" ${PROJECT_IS_TOP_LEVEL})
option(GOERTZEL_BUILD_PYTHON "Build the Python extension module" ${PROJECT_IS_TOP_LEVEL})

add_library(goertzel INTERFACE)
add_library(goertzel::goertzel ALIAS goertzel)
target_compile_features(goertzel INTERFACE cxx_std_20)
target_include_directories(
  goertzel
  INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inst/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

add_library(goertzel_c src/goertzel_c.cpp)
add_library(goertzel::goertzel_c ALIAS goertzel_c)
target_compile_features(goertzel_c PUBLIC cxx_std_20)
target_include_directories(
  goertzel_c
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inst/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
target_link_libraries(goertzel_c PUBLIC goertzel)

if(GOERTZEL_BUILD_PYTHON)
  find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED)
  Python3_add_library(goertzel_python MODULE WITH_SOABI python/goertzel_module.cpp)
  target_compile_features(goertzel_python PRIVATE cxx_std_20)
  target_include_directories(goertzel_python PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/inst/include)
  target_link_libraries(goertzel_python PRIVATE Python3::Module goertzel)
  set_target_properties(goertzel_python PROPERTIES OUTPUT_NAME goertzel)
endif()

if(GOERTZEL_BUILD_TESTS)
  enable_testing()
  add_executable(goertzel_dtmf_test tests/dtmf_test.cpp)
  target_compile_features(goertzel_dtmf_test PRIVATE cxx_std_20)
  target_link_libraries(goertzel_dtmf_test PRIVATE goertzel)
  add_test(NAME dtmf_key_6 COMMAND goertzel_dtmf_test)
endif()

install(
  TARGETS goertzel goertzel_c
  EXPORT goertzelTargets)

if(TARGET goertzel_python)
  install(TARGETS goertzel_python LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
endif()

install(
  DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/inst/include/goertzel
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(
  EXPORT goertzelTargets
  FILE goertzelTargets.cmake
  NAMESPACE goertzel::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/goertzel)

configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/goertzelConfig.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/goertzelConfig.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/goertzel)

write_basic_package_version_file(
  ${CMAKE_CURRENT_BINARY_DIR}/goertzelConfigVersion.cmake
  VERSION ${PROJECT_VERSION}
  COMPATIBILITY SameMajorVersion)

install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/goertzelConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/goertzelConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/goertzel)

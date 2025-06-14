cmake_minimum_required(VERSION 3.14)

# Definirea proiectului
project(approb LANGUAGES CXX)

# Numele executabilului creat pentru aplicație
set(BINARY_NAME "approb")

# Optimizare comportamente moderne CMake
cmake_policy(VERSION 3.14...3.25)

# Dezactivare avertizări de deprecare pentru funcții nesigure (ex. strncpy)
add_definitions(-D_CRT_SECURE_NO_WARNINGS)

# Setarea Unicode pentru toate proiectele
add_definitions(-DUNICODE -D_UNICODE)

# Definirea opțiunii de configurare a build-ului
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release" CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
  endif()
endif()

# Setarea configurațiilor pentru build-ul de profil
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Adăugarea subdirectorului Flutter
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Build aplicație; vezi CMakeLists.txt din "runner"
add_subdirectory("runner")

# Reguli de generare pentru pluginuri
include(flutter/generated_plugins.cmake)

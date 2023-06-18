cmake_minimum_required(VERSION 3.22)
project(@c@ LANGUAGES C)

set(CMAKE_C_STANDARD 11)

include_directories(include)
file(GLOB_RECURSE SOURCE_FILES CONFIGURE_DEPENDS "source/*.c")

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

include(cmake/SetVersion.cmake)
cmake_minimum_required(VERSION 3.22)
project(@cpp@ LANGUAGES CXX VERSION ${VERSION})

set(CMAKE_CXX_STANDARD 20)

set(SOURCE_DIR "source")
set(INCLUDE_DIR "include")

include_directories(${INCLUDE_DIR} ${SOURCE_DIR})
file(GLOB_RECURSE SOURCE_FILES CONFIGURE_DEPENDS "${SOURCE_DIR}/*.cpp")

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

function(link_common_libraries target)
    target_link_libraries(${target}
        PRIVATE
        #ADD your libs here
    )
endfunction(link_common_libraries)

link_common_libraries(${PROJECT_NAME})
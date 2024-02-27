cmake_minimum_required(VERSION 3.22)
project(@cpp@ LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)

include_directories(include)
file(GLOB_RECURSE SOURCE_FILES CONFIGURE_DEPENDS "source/*.cpp")

add_executable(${PROJECT_NAME} ${SOURCE_FILES})

function(link_common_libraries target)
    target_link_libraries(${target}
        PRIVATE
        #ADD your libs here
    )
endfunction(link_common_libraries)

link_common_libraries(${PROJECT_NAME})
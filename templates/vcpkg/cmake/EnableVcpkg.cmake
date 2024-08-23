# Should be included only from the top level cmake and before project()
configure_file(
        ${CMAKE_SOURCE_DIR}/vcpkg.json.in
        ${CMAKE_SOURCE_DIR}/vcpkg.json
        @ONLY
)

include(FetchContent)
FetchContent_Declare(
    vcpkg
    GIT_REPOSITORY https://github.com/Microsoft/vcpkg.git
)
FetchContent_MakeAvailable(vcpkg)

set(CMAKE_TOOLCHAIN_FILE "${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "Vcpkg toolchain file")
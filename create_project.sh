#!/bin/bash -e

usage()
{
    echo "usage: $(basename $0) [options]"
    echo "options:"
    echo "-h - help"
    echo "-n <value> - project name"
    echo "-l <c|cpp> - template project language"
    echo "-p <value> - project parent directory absolute path"
    echo "-t - add googletest framework for cpp"
    echo "-g - init git repository"
    echo "-r - init git repository & push to GitHub"
    echo "-e - open in VSCode editor"
    echo "example:"
    echo "create-project -n test_project -p . -l cpp -t -g -e"
}

init_git()
{
    printf '%s\n' '# IDE files' \
        '/.idea/' \
        '/.vscode/' \
        '' \
        '# Build artifacts' \
        '/*build*/' \
        > .gitignore

    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git checkout -b dev

    echo -e "${YELLOW}Git repository initialized${NC}"
}

push_to_github()
{
    curl -H "Authorization: token ${GH_API_TOKEN}" https://api.github.com/user/repos -d '{"name": "'"${PROJECT_NAME}"'"}'
    git remote add origin https://${GH_API_TOKEN}@github.com/${GH_USER}/"${PROJECT_NAME}".git
    git push -u origin main dev -f

    echo -e "${YELLOW}Uploaded to GitHub${NC}"
}

c()
{
    mkdir -p source
    mkdir -p include
    touch include/.gitkeep

    printf '%s\n' 'cmake_minimum_required(VERSION 3.15 FATAL_ERROR)' \
        'project('${PROJECT_NAME}' VERSION 1.0 LANGUAGES C)' \
        '' \
        'set(CMAKE_C_STANDARD 11)' \
        '' \
        'include_directories(include)' \
        'file(GLOB_RECURSE sourceFiles CONFIGURE_DEPENDS "source/*.c")' \
        'file(GLOB_RECURSE headerFiles CONFIGURE_DEPENDS "include/*.h")' \
        '' \
        'add_compile_options(-Wall -Wextra -Wpedantic)' \
        'add_executable(${PROJECT_NAME} ${sourceFiles} ${headerFiles})' \
        > CMakeLists.txt

    printf '%s\n' '#include <stdio.h>'\
        '' \
        'int main() {' \
        '    printf("Hello, World!\n");' \
        '    return 0;' \
        '}' \
        > source/main.c
}

cpp()
{
    mkdir -p source
    mkdir -p include
    touch include/.gitkeep

    printf '%s\n' 'cmake_minimum_required(VERSION 3.15 FATAL_ERROR)' \
        'project('${PROJECT_NAME}' VERSION 1.0 LANGUAGES CXX)' \
        '' \
        'set(CMAKE_CXX_STANDARD 17)' \
        '' \
        'include_directories(include)' \
        'file(GLOB_RECURSE sourceFiles CONFIGURE_DEPENDS "source/*.cpp")' \
        'file(GLOB_RECURSE headerFiles CONFIGURE_DEPENDS "include/*.h")' \
        '' \
        'add_compile_options(-Wall -Wextra -Wpedantic)' \
        'add_executable(${PROJECT_NAME} ${sourceFiles} ${headerFiles})' \
        > CMakeLists.txt

    printf '%s\n' '#include <iostream>' \
        '' \
        'int main() {' \
        '    std::cout << "Hello, World!" << std::endl;' \
        '    return 0;' \
        '}' \
        > source/main.cpp
}

set_gtest()
{
    mkdir -p tests

    printf '%s\n' '' \
        'add_subdirectory(tests)' \
        >> CMakeLists.txt

    printf '%s\n' 'project('${PROJECT_NAME}'_test)' \
        '' \
        'include(FetchContent)' \
        'FetchContent_Declare(' \
        '   googletest' \
        '   GIT_REPOSITORY https://github.com/google/googletest.git' \
        ')' \
        '' \
        '# For Windows: Prevent overriding the parent project compiler/linker settings' \
        'set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)' \
        'FetchContent_MakeAvailable(googletest)' \
        '' \
        'file(GLOB_RECURSE sourceFiles CONFIGURE_DEPENDS "../source/*.cpp")' \
        'list(REMOVE_ITEM sourceFiles "${CMAKE_CURRENT_SOURCE_DIR}/../source/main.cpp")' \
        'file(GLOB_RECURSE headerFiles CONFIGURE_DEPENDS "../include/*.h")' \
        'file(GLOB_RECURSE testFiles CONFIGURE_DEPENDS "*.cpp")' \
        '' \
        'add_executable(${PROJECT_NAME} ${sourceFiles} ${headerFiles} ${testFiles})' \
        'target_link_libraries(${PROJECT_NAME} gtest gtest_main)' \
        > tests/CMakeLists.txt

    printf '%s\n' '#include "gtest/gtest.h"' \
        '/* Add your project include files here */' \
        '' \
        'TEST(TestFixtureName, TestName) {' \
        '   EXPECT_TRUE(true);' \
        '}' \
        > tests/tests.cpp
}

create_github_actions()
{
    if [ -n "${PUSH_TO_REMOTE}" ]; then
        mkdir -p .github/workflows

        printf '%s\n' 'name: Build and Run' \
            '' \
            'on:' \
            '  push:' \
            '  pull_request:' \
            '' \
            'env:' \
            '  BUILD_TYPE: Release' \
            '' \
            'jobs:' \
            '  build:' \
            '    runs-on: ubuntu-latest' \
            '' \
            '    steps:' \
            '    - uses: actions/checkout@v2' \
            '' \
            '    - name: Get repo name' \
            '      id: repo-name' \
            '      run: echo "::set-output name=value::$(echo "${{ github.repository }}" | awk -F '\''/'\'' '\''{print $2}'\'')"' \
            '' \
            '    - name: Configure' \
            '      run: cmake -B build -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=${{env.BUILD_TYPE}}' \
            '' \
            '    - name: Build' \
            '      run: cmake --build build --config ${{env.BUILD_TYPE}}' \
            '' \
            '    - name: Run' \
            '      run: ./build/${{ steps.repo-name.outputs.value }}' \
            > .github/workflows/build.yaml

        printf '%s\n' '' \
            '[![Build and Run](https://github.com/'${GH_USER}'/'${PROJECT_NAME}'/actions/workflows/build.yaml/badge.svg)](https://github.com/'${GH_USER}'/'${PROJECT_NAME}'/actions/workflows/build.yaml)' \
            >> README.md
    fi
}

create_project()
{
    cd "${PATH_TO_REPO}"
    mkdir -p "${PROJECT_NAME}" && cd "$_"

    echo "#" "${PROJECT_NAME}" > README.md

    if [ -n "${LANGUAGE}" ]; then
        ${LANGUAGE}
    fi

    if [ "${GTEST}" = "yes" ]; then
        if [ "${LANGUAGE}" = "cpp" ]; then
            set_gtest
        else
            echo -e "${L_RED}Warning: Googletest is not supported by this language. Ignoring the option${NC}"
        fi
    fi

    echo -e "${YELLOW}Project created${NC}"
}

access_github()
{
    TOKEN_FILE="/home/${USER}/.github_token"

    if [ -f "${TOKEN_FILE}" ]; then
        { IFS= read -r GH_USER && IFS= read -r GH_API_TOKEN; } < ${TOKEN_FILE}
    else
        echo -e "Provide github user name:"
        read -e -p "" GH_USER
        echo -e "Provide github token:"
        read -e -p "" GH_API_TOKEN
        echo ${GH_USER} > ${TOKEN_FILE}
        echo ${GH_API_TOKEN} >> ${TOKEN_FILE}
    fi

    create_github_actions
}

make_globally_available()
{
    EXECUTABLE="/usr/local/bin/create-project"
    if [ ! -f ${EXECUTABLE} ]; then
        sudo ln -s $(pwd)/create_project.sh ${EXECUTABLE}
        echo -e "${YELLOW}create-project is now available globally${NC}"
    fi
}

YELLOW='\033[0;33m'
RED='\033[0;31m'
L_RED='\033[0;91m'
NC='\033[0m'

while getopts "n:l:p:tgreh" OPTION;
do
    case ${OPTION} in
    n)
        PROJECT_NAME=${OPTARG}
        ;;
    l)
        LANGUAGE=${OPTARG}
        if [ "${LANGUAGE}" != "c" ] && [ "${LANGUAGE}" != "cpp" ]; then
            echo -e "${RED}Error: Language is not supported${NC}"
            usage
            exit 1
        fi
        ;;
    p)
        PATH_TO_REPO=${OPTARG}
        ;;
    t)
        GTEST="yes"
        ;;
    g)
        GIT_ENABLE="yes"
        ;;
    r)
        GIT_ENABLE="yes"
        PUSH_TO_REMOTE="yes"
        ;;
    e)
        if [ -z "$(command -v code)" ]; then
            echo -e "${RED}Error: VSCode not found${NC}"
            exit 1
        fi
        EDITOR="yes"
        ;;
    h)
        usage
        exit 0
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done
shift "$(($OPTIND -1))"

make_globally_available

if [ -z "${PROJECT_NAME}" ]; then
    echo -e "Provide a project name:"
    read PROJECT_NAME
fi

if [ -z "${PATH_TO_REPO}" ]; then
    echo -e "Provide a project parent directory absolute path:"
    read -r PATH_TO_REPO
    PATH_TO_REPO=${PATH_TO_REPO/\~/$HOME}
    PATH_TO_REPO=${PATH_TO_REPO%/}
fi

if [ "${PATH_TO_REPO}" = "." ]; then
    PATH_TO_REPO=${PWD}
fi

if [ -e "${PATH_TO_REPO}" ]; then
    create_project
else
    echo -e "${RED}Error: Wrong path was provided${NC}"
    exit 1;
fi

if [ -n "${PUSH_TO_REMOTE}" ]; then
    access_github
fi

if [ -n "${GIT_ENABLE}" ]; then
    init_git
fi

if [ -n "${PUSH_TO_REMOTE}" ]; then
    push_to_github
fi

if [ -n "${EDITOR}" ]; then
    code "${PATH_TO_REPO}/${PROJECT_NAME}"
fi

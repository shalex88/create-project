#!/bin/bash -e

function usage()
{
    echo "usage: $(basename $0) [options]"
    echo "options:"
    echo "-h - help"
    echo "-n - project name"
    echo "-l - project language"
    echo "-p - project path"
    echo "-g - git init"
    echo "-r - push to GitHub"
}

function init_git()
{
    echo -e "${YELLOW}Init Git repository${NC}"

    printf '%s\n' '# IDE files'\
        '/.idea/'\
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
}

function push_to_github()
{
    echo -e "${YELLOW}Create GitHub repository${NC}"
    curl -H "Authorization: token ${GH_API_TOKEN}" https://api.github.com/user/repos -d '{"name": "'"${project_name}"'"}'
    git remote add origin https://${GH_API_TOKEN}@github.com/${GH_USER}/"$project_name".git
    git push -u origin main dev
}

function c()
{
    mkdir -p src
    mkdir -p inc

    printf '%s\n' 'cmake_minimum_required(VERSION 3.16)'\
        'project('$project_name' C)'\
        '' \
        'set(CMAKE_C_STANDARD 11)' \
        '' \
        'include_directories(inc)' \
        'file(GLOB_RECURSE SOURCES "src/*.c")' \
        'file(GLOB_RECURSE INCLUDES "inc/*.h")' \
        '' \
        'add_compile_options(-Wall -Wextra -Wpedantic)' \
        'add_executable(${PROJECT_NAME} ${SOURCES} ${INCLUDES})' \
        > CMakeLists.txt

    printf '%s\n' '#include <stdio.h>'\
        '' \
        'int main() {' \
        '    printf("Hello, World!\n");' \
        '    return 0;' \
        '}' \
        > src/main.c
}

function cpp()
{
    mkdir -p src
    mkdir -p inc

    printf '%s\n' 'cmake_minimum_required(VERSION 3.16)'\
        'project('$project_name')'\
        '' \
        'set(CMAKE_CXX_STANDARD 20)' \
        '' \
        'include_directories(inc)' \
        'file(GLOB_RECURSE SOURCES "src/*.cpp")' \
        'file(GLOB_RECURSE INCLUDES "inc/*.h")' \
        '' \
        'add_compile_options(-Wall -Wextra -Wpedantic)' \
        'add_executable(${PROJECT_NAME} ${SOURCES} ${INCLUDES})' \
        > CMakeLists.txt

    printf '%s\n' '#include <iostream>'\
        '' \
        'int main() {' \
        '    std::cout << "Hello, World!" << std::endl;' \
        '    return 0;' \
        '}' \
        > src/main.cpp
}

function create_project()
{
    echo -e "${YELLOW}Creating project${NC}"

    cd $path_to_repo
    mkdir -p $project_name
    cd $project_name
    echo "#" "$project_name" > README.md

    if [ -n "$language" ]; then
        $language
    fi
}

function access_github()
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
}

function make_globally_available()
{
    executable="/usr/local/bin/create-project"
    if [ ! -f $executable ]; then
        sudo ln -s $(pwd)/create_project.sh $executable
    fi
}

while getopts "n:l:p:grch" OPTION;
do
    case $OPTION in
    n)
        project_name=$OPTARG
        ;;
    l)
        language=$OPTARG
        ;;
    p)
        path_to_repo=$OPTARG
        ;;
    g)
        git_enable="yes"
        ;;
    r)
        push_to_remote="yes"
        ;;
    c)
        editor="yes"
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

YELLOW='\033[0;33m'
NC='\033[0m'

make_globally_available

if [ -z "$project_name" ]; then
    echo -e "Provide a project name:"
    read project_name
fi

if [ -z "$path_to_repo" ]; then
    echo -e "Provide a project path:"
    read path_to_repo
fi

create_project

if [ -n "${git_enable}" ]; then
    init_git
fi

if [ -n "${push_to_remote}" ]; then
    access_github
    push_to_github
fi

if [ -n "${editor}" ]; then
    code $path_to_repo/$project_name
fi

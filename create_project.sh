#!/bin/bash -e

usage()
{
    echo "usage: $(basename "$0") [options]"
    echo "options:"
    echo "-h - help"
    echo "-n <value> - project name"
    echo "-l <rust|cpp> - template project language"
    echo "-p <value> - project parent directory absolute path. default: current dir"
    echo "-t - add googletest framework for cpp"
    echo "-u - add PlantUML template"
    echo "-g - init git repository & push to GitHub"
    echo "-r - add release package support"
    echo "-e - open in VSCode editor"
    echo "-v - add vcpkg support"
    echo "example:"
    echo "create-project -n test-project -p . -l cpp -gvtue"
}

uml()
{
    mkdir -p docs
    cp -r "${SCRIPT_PATH}"/templates/uml/* docs/

    OLD_PATTERN="@uml@"
    NEW_PATTERN="${PROJECT_NAME}"
    find . -type f -exec sed -i 's/'$OLD_PATTERN'/'"$NEW_PATTERN"'/g' {} \;
}

init_git()
{
    mv gitignore .gitignore

    if [ -d "github" ]; then
        mv github .github
    fi

    git init
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git checkout -b develop

    echo -e "${YELLOW}Git repository initialized${NC}"
}

push_to_github()
{
    curl -H "Authorization: token ${GH_API_TOKEN}" https://api.github.com/user/repos -d '{"name": "'"${PROJECT_NAME}"'"}'
    git remote add origin https://"${GH_API_TOKEN}"@github.com/"${GH_USER}"/"${PROJECT_NAME}".git
    git push -u origin main develop -f

    echo -e "${YELLOW}Uploaded to GitHub${NC}"
}

language()
{
    cp -r "${SCRIPT_PATH}"/templates/"${PROJ_LANGUAGE}"/* .

    OLD_PATTERN="@${PROJ_LANGUAGE}@"
    NEW_PATTERN="${PROJECT_NAME}"
    find . -type f -exec sed -i 's/'"$OLD_PATTERN"'/'"$NEW_PATTERN"'/g' {} \;
}

setup_vcpkg()
{
    mkdir -p cmake
    cp -r "${SCRIPT_PATH}"/templates/vcpkg/* .

    OLD_PATTERN="@${PROJ_LANGUAGE}@"
    NEW_PATTERN="${PROJECT_NAME}"
    find . -type f -exec sed -i 's/'"$OLD_PATTERN"'/'"$NEW_PATTERN"'/g' {} \;

    sed -i '/^cmake_minimum_required(/i include(cmake/EnableVcpkg.cmake)' CMakeLists.txt
}

set_gtest()
{
    mkdir -p tests
    cp -r "${SCRIPT_PATH}"/templates/gtest/tests/* tests/

    printf '%s\n' '' \
        'add_subdirectory(tests)' \
        >> CMakeLists.txt

    if [ "${PUSH_TO_REMOTE}" = "yes" ]; then
        cp -r "${SCRIPT_PATH}"/templates/gtest/.github* .github/

        printf '%s\n' '' \
            '[![Test](https://github.com/'"${GH_USER}"'/'"${PROJECT_NAME}"'/actions/workflows/test.yml/badge.svg)](https://github.com/'"${GH_USER}"'/'"${PROJECT_NAME}"'/actions/workflows/test.yml)' \
            '[![Coverage](https://img.shields.io/codecov/c/github/'"${GH_USER}"'/'"${PROJECT_NAME}"')](https://codecov.io/github/'"${GH_USER}"'/'"${PROJECT_NAME}"')' \
            >> README.md
    fi
}

create_release_package()
{
    mkdir -p cmake
    cp -r "${SCRIPT_PATH}"/templates/package/cmake/* cmake/
    sed -i 's/std::endl;/" " << APP_VERSION_MAJOR << "." << APP_VERSION_MINOR << "." << APP_VERSION_PATCH << std::endl;/g' src/main.cpp

    OLD_PATTERN="^project("
    NEW_PATTERN="project(${PROJECT_NAME} LANGUAGES CXX VERSION "'${VERSION}'")"
    sed -i '/'"$OLD_PATTERN"'/c\'"$NEW_PATTERN" "CMakeLists.txt"

    printf '%s\n' '' \
        'include(GNUInstallDirs)' \
        'install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})' \
        'include(cmake/CreatePackage.cmake)' \
        >> CMakeLists.txt

    if [ "${PUSH_TO_REMOTE}" = "yes" ]; then
        cp -r "${SCRIPT_PATH}"/templates/package/.github/* .github/

        printf '%s\n' \
            '[![Release](https://img.shields.io/github/v/release/'"${GH_USER}"'/'"${PROJECT_NAME}"'.svg)](https://github.com/'"${GH_USER}"'/'"${PROJECT_NAME}"'/releases/latest)' \
            >> README.md
    fi
}

create_project()
{
    cd "${PATH_TO_REPO}"
    mkdir -p "${PROJECT_NAME}" && cd "$_"

    echo "#" "${PROJECT_NAME}" > README.md

    if [ -n "${PROJ_LANGUAGE}" ]; then
        language
    fi

    if [ "${GTEST}" = "yes" ]; then
        if [ "${PROJ_LANGUAGE}" = "cpp" ]; then
            set_gtest
        else
            echo -e "${L_RED}Warning: Googletest is not supported by this language. Ignoring the option${NC}"
        fi
    fi

    if [ "${UML}" = "yes" ]; then
        uml
    fi

    if [ "${RELEASE}" = "yes" ]; then
        create_release_package
    fi

    if [ "${VCPKG}" = "yes" ]; then
        setup_vcpkg
    fi

    echo -e "${YELLOW}Project created${NC}"
}

access_github()
{
    TOKEN_FILE="/home/${USER}/.github_token"

    if [ -f "${TOKEN_FILE}" ]; then
        { IFS= read -r GH_USER && IFS= read -r GH_API_TOKEN; } < "${TOKEN_FILE}"
    else
        echo -e "Provide github user name:"
        read -r -e -p "" GH_USER
        echo -e "Provide github token:"
        read -r -e -p "" GH_API_TOKEN
        echo "${GH_USER}" > "${TOKEN_FILE}"
        echo "${GH_API_TOKEN}" >> "${TOKEN_FILE}"
    fi
}

make_globally_available()
{
    local superuser

    if [[ "$OSTYPE" == "msys" ]]; then
        EXECUTABLE="/usr/bin/create-project"
    else
        EXECUTABLE="/usr/local/bin/create-project"
        superuser="sudo"
    fi;

    if [ ! -f ${EXECUTABLE} ]; then
        ${superuser} ln -s "$(pwd)"/create_project.sh ${EXECUTABLE}
        echo -e "${YELLOW}create-project is now available globally${NC}"
    fi
}

YELLOW='\033[0;33m'
RED='\033[0;31m'
L_RED='\033[0;91m'
NC='\033[0m'
SCRIPT_PATH="$(dirname "$( readlink -f "$0" )")"

while getopts "n:l:p:tgruevh" OPTION;
do
    case ${OPTION} in
    n)
        PROJECT_NAME=${OPTARG}
        ;;
    l)
        PROJ_LANGUAGE=${OPTARG}
        ;;
    p)
        PATH_TO_REPO=${OPTARG}
        ;;
    t)
        GTEST="yes"
        ;;
    r)
        RELEASE="yes"
        ;;
    g)
        PUSH_TO_REMOTE="yes"
        ;;
    u)
        UML="yes"
        ;;
    v)
        VCPKG="yes"
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
shift "$((OPTIND - 1))"

make_globally_available

if [ -z "${PROJECT_NAME}" ]; then
    echo -e "Provide a project name:"
    read -r PROJECT_NAME
fi

if [ -z "${PROJ_LANGUAGE}" ]; then
    echo -e "Specify a project language:"
    read -r PROJ_LANGUAGE

    if [ "${PROJ_LANGUAGE}" != "rust" ] && [ "${PROJ_LANGUAGE}" != "cpp" ]; then
        echo -e "${RED}Error: Language is not supported${NC}"
        usage
        exit 1
    fi
fi

if [ -z "${PATH_TO_REPO}" ] || [ "${PATH_TO_REPO}" = "." ]; then
    PATH_TO_REPO=${PWD}
fi

if [ -n "${PUSH_TO_REMOTE}" ]; then
    access_github
fi

if [ -e "${PATH_TO_REPO}" ]; then
    create_project
else
    echo -e "${RED}Error: Wrong path was provided${NC}"
    exit 1;
fi

init_git

if [ -n "${PUSH_TO_REMOTE}" ]; then
    push_to_github
fi

if [ -n "${EDITOR}" ]; then
    code "${PATH_TO_REPO}/${PROJECT_NAME}"
fi

echo -e "${YELLOW}Finished${NC}"
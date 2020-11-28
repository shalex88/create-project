#!/bin/bash

function init_git()
{
    echo -e "${YELLOW}Init Git repository${NC}"
    git init
    echo '#' "$project_name" > README.md
    git add .
    git commit -m "Initial commit"
    git branch -M main
    git checkout -b dev
}

function push_to_github()
{
    echo -e "${YELLOW}Create GitHub repository${NC}"
    curl -H "Authorization: token $GH_API_TOKEN" https://api.github.com/user/repos -d '{"name": "'"${project_name}"'"}'
    git remote add origin https://github.com/$GH_USER/"$project_name".git
    git push -u origin main dev
}

function create_project()
{
    echo -e "${YELLOW}Create project${NC}"
    if [ -z "$1" ]; then
        echo -e "Provide a project name:"
        read project_name
    else
        project_name=$1
    fi

    echo -e "Provide a project path:"
    read -e -p "" path_to_repo
    cd $path_to_repo
    mkdir $project_name
    cd $project_name
}

function access_github()
{
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    TOKEN_FILE="$DIR/github_token"

    if [ -f "$TOKEN_FILE" ]; then
        { IFS= read -r GH_USER && IFS= read -r GH_API_TOKEN; } < $TOKEN_FILE
    else
        echo -e "Provide github user name:"
        read -e -p "" GH_USER
        echo -e "Provide github token:"
        read -e -p "" GH_API_TOKEN
        echo $GH_USER >> $TOKEN_FILE
        echo $GH_API_TOKEN >> $TOKEN_FILE
    fi
}

YELLOW='\033[0;33m'
NC='\033[0m'

create_project "$1"
access_github
init_git
push_to_github
code .

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
    git config --global credential.helper store
    curl -u 'shalex88' https://api.github.com/user/repos -d '{"name":"'$project_name'"}'
    git remote add origin https://github.com/shalex88/"$project_name".git
    git push -u origin main dev
}

function create_project()
{
    echo -e "${YELLOW}Create project${NC}"
    cd ~/Dev
    mkdir $project_name
    cd $project_name
}

YELLOW='\033[0;33m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Provide a project name:${NC}"
    read project_name
else
    project_name=$1
fi

create_project
init_git
push_to_github
code .

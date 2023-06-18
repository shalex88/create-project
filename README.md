# create-project

## Description

- Create new project directory
- Initialize git
- Create template project for C/C++ with CMake support
- Create template for PlantUML
- Create template test code with googletest framework
- Create a release package with CPack
- Upload to GitHub
- Add GitHub Actions for CI

## Setup

- ./create_project.sh
- Provide sudo permissions when running for the first time to make globally available
- Create personal access token for GitHub authentication. GitHub > Settings > Developer settings > Personal access tokens

## Usage

```bash
    usage: create-project [options]
    options:
    -h - help
    -n <value> - project name
    -l <c|cpp> - template project language
    -p <value> - project parent directory absolute path
    -t - add googletest framework for cpp
    -u - add PlantUML template
    -g - init git repository & push to GitHub
    -r - add release package support
    -e - open in VSCode editor
    example:
    create-project -n test_project -p . -l cpp -tuge
```
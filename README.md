# create-project

## Description

- Create new project directory
- Initialize git
- Create template project for C++/Rust with CMake support
- Create template for PlantUML
- Create template test code with googletest framework
- Create a release package with CPack
- Upload to GitHub
- Add GitHub Actions for CI
- Add vcpkg library manager support

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
    -l <cpp|rust> - template project language
    -p <value> - project parent directory absolute path. default: current dir
    -t - add googletest framework for cpp
    -u - add PlantUML template
    -g - init git repository & push to GitHub
    -r - add release package support
    -e - open in VSCode editor
    -v - add vcpkg support
    example:
    create-project -n test-project -p . -l cpp -vtu
```
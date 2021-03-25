# create-project
- Create new project directory
- Initialize git
- Upload to GitHub
- Create template code for C, C++ with Cmake support
## Setup
- Create personal access token for GitHub authentication. GitHub > Settings > Developer settings > Personal access tokens
- To make the script available everywhere add to ~/.bashrc:  
export PATH=$PATH$( find ~/Dev/Automation/ -type d -printf ":%p" )

## Call from Linux:
    create_project.sh

## Call from Windows:
Run create_project.ps1 with PowerShell
# create-project
Create new project folder in WSL, initialize git and upload to GitHub.
## Setup
- Create personal access token for GitHub authentication.
- To make the script available everywhere add to ~/.bashrc:  
export PATH=$PATH$( find ~/Dev/Automation/ -type d -printf ":%p" )

## Call from WSL:
    create_project.sh

## Call from Windows:
Run create_project.ps1 with PowerShell
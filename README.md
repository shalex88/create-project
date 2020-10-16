# create-project
To make the script available everywhere add to ~/.bashrc:

    export PATH=$PATH$( find ~/Dev/Automation/ -type d -printf ":%p" )

Call:

    create_project.sh my-new-project

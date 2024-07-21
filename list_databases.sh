#!/bin/bash

list_databases() {

    clear
    welcome
    echo ""
    echo "Existing Databases:"
    echo ""

    databases=($(ls -d [a-zA-Z]*/ 2>/dev/null)) 
    numberofdatabases=${#databases[@]}

    if [ $numberofdatabases -eq 0 ]; then
        echo "No Databases found."
    else
        counter=1
        for db in "${databases[@]}"; do
            echo "$counter. ${db%/}"
            counter=$((counter + 1))
        done
    fi

    echo ""
    echo "Press any key to return to the main menu..."
    read -n 1
    mainmenu
}

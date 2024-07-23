#!/bin/bash
source ./validation.sh

create_database() {
    local dbName
    while true; do
        read -p "Enter database name: " dbName
        dbName=$(is_valid_name "$dbName")

        if [[ "$dbName" == "1" ]]; then
            echo "Invalid database name. Only alphanumeric characters and underscores are allowed. Please try again."
        elif [[ -d "$dbName" ]]; then
            echo "Database '$dbName' already exists. Please try a different name."
        else
            break
        fi
    done

    
    mkdir "$dbName"
    if [[ $? -eq 0 ]]; then
        echo "Database '$dbName' created successfully."
    else
        echo "Failed to create database '$dbName'. Please check permissions and try again."
    fi

    sleep 2
    mainmenu
}

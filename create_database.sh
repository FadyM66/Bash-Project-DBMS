#!/bin/bash
source ./validation.sh

create_database() {
    read -p "Enter database name: " dbname
    dbname=$(sanitize_name "$dbname")
    if ! is_valid_name "$dbname"; then
        echo "Invalid database name. Only alphanumeric characters and underscores are allowed."
        return
    fi
    if dir_exists "$dbname"; then
        echo "Database '$dbname' already exists."
        return
    fi
    mkdir "$dbname"
    echo "Database '$dbname' created successfully."

    mainmenu
}
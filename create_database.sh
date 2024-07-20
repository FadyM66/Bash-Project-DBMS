#!/bin/bash

create_database() {
    read -p "Enter database name: " db_name
    if [ -d "$db_name" ]; then
        echo "Database already exists!"
    else
        mkdir "$db_name"
        echo "Database created successfully."
    fi
    mainmenu
}

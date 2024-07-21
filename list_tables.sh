#!/bin/bash
list_tables() {

    clear
    welcome
    echo ""
    echo "Existing tables:"
    echo ""

    local db_path=$1

    if [ ! -d "$db_path" ]; then
        echo "Invalid database path '$db_path'."
        return
    fi

    # pwd
    cd "$db_path" || { echo "Failed to navigate to database directory."; return; }
    # pwd


    tables=($(find . -maxdepth 1 -type f -name '[a-zA-Z]*' 2>/dev/null))
    numberoftables=${#tables[@]}

    if [ $numberoftables -eq 0 ]; then
        echo "No tables found."
    else
        counter=1
        for t in "${tables[@]}"; do
            echo "$counter. ${t#./}"
            counter=$((counter + 1))
        done
    fi

    cd ..

    echo ""
    echo "Press any key to return to the main menu..."
    read -n 1
    mainmenu
}
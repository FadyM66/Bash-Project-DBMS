# !/bin/bash

drop_table() {
    local DBName="$1"

    # Check if the database directory exists
    if [[ ! -d "$DBName" ]]; then
        echo "Error: Database '$DBName' not found."
        return
    fi

    local tables=($(ls -p "$DBName" | grep -v /))
    local num_tables=${#tables[@]}

    if [ $num_tables -eq 0 ]; then
        echo "No tables found in the database."
        return
    fi

    echo "Available tables in database '$DBName':"
    for i in "${!tables[@]}"; do
        echo "$((i + 1)). ${tables[$i]}"
    done

    # Prompt user to select a table to drop
    local choice
    while true; do
        read -p "Enter the number of the table to drop (or 0 to cancel): " choice

        if [[ $choice =~ ^[0-9]+$ ]] && ((choice >= 0 && choice <= num_tables)); then
            break
        else
            echo "Invalid input. Please enter a valid number."
        fi
    done

    if [ $choice -eq 0 ]; then
        echo "Drop table operation canceled."
        return
    fi

    local table_to_drop="${tables[$((choice - 1))]}"

    # echo "$table_to_drop"

    # Confirm the drop operation
    read -p "Are you sure you want to drop the table '$table_to_drop'? (y/n): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        # pwd
        rm "$DBName/$table_to_drop"
        echo "Table '$table_to_drop' has been successfully dropped."
    else
        echo "Operation canceled. Table '$table_to_drop' was not dropped."
    fi

    sleep 2
    mainmenu
}

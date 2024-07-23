#!/bin/bash

# Function to insert data into a table
insert_into_table() {
    local db_path=$1

    # Check if the provided path is a directory
    if ! dir_exists "$db_path"; then
        echo "Invalid database path '$db_path'."
        return
    fi

    cd "$db_path" || {
        echo "Failed to navigate to database directory."
        return
    }

    # List tables in the selected database
    echo "Available tables:"
    ls
    read -p "Enter the table name to insert data into: " tablename

    if ! file_exists "$tablename"; then
        echo "Table '$tablename' does not exist."
        cd ..
        return
    fi

    # Read the table schema
    local schema
    schema=$(head -n 1 "$tablename")
    IFS=';' read -r -a columns <<<"$schema"

    declare -A data
    local primary_key=""
    local primary_key_value=""

    # Identify the primary key from the schema
    for col in "${columns[@]}"; do
        if [[ "$col" == primary_key:* ]]; then
            primary_key=$(echo "$col" | cut -d: -f2)
        fi
    done

    # Prompt for data input and validate against the schema
    for col in "${columns[@]}"; do
        name=$(echo "$col" | cut -d: -f1)
        type=$(echo "$col" | cut -d: -f2)

        # Skip the primary_key indicator in schema
        if [[ "$name" == "primary_key" ]]; then
            continue
        fi

        while true; do
            read -p "Enter value for $name ($type): " value
            if validate_value "$value" "$type"; then
                if [[ "$name" == "$primary_key" ]]; then
                    primary_key_value="$value"
                    # Check if primary key value is unique
                    if cut -d';' -f1 "$tablename" | grep -q "^$primary_key_value$"; then
                        echo "Primary key value '$primary_key_value' already exists. Please enter a unique value."
                        continue
                    fi
                fi
                data["$name"]="$value"
                break
            else
                echo "Invalid value for type '$type'. Please try again."
            fi
        done
    done

    # Construct the data line to be inserted
    local dataline=""
    for col in "${columns[@]}"; do
        name=$(echo "$col" | cut -d: -f1)
        if [[ "$name" != "primary_key" ]]; then
            dataline+="${data[$name]};"
        fi
    done
    dataline=${dataline%;} # Remove the trailing semicolon

    # Append the data line to the table file
    echo "$dataline" >> "$tablename"
    echo "Data inserted successfully into '$tablename'."

    sleep 2
    cd ..
    mainmenu
}
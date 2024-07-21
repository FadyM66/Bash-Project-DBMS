#!/bin/bash

create_table() {
    local db_path=$1

    if [ ! -d "$db_path" ]; then
        echo "Invalid database path '$db_path'."
        return
    fi

    # pwd
    cd "$db_path" || { echo "Failed to navigate to database directory."; return; }
    # pwd

    read -p "Enter table name: " tablename
    tablename=$(sanitize_name "$tablename")

    if ! is_valid_name "$tablename"; then
        echo "Invalid table name. Only alphanumeric characters and underscores are allowed."
        return
    fi

    if file_exists "$tablename"; then
        echo "Table '$tablename' already exists."
        return
    fi

    read -p "Enter columns (name:type) separated by space (e.g., id:int name:string age:float): " columns
    IFS=' ' read -r -a colarray <<< "$columns"
    for col in "${colarray[@]}"; do
        name=$(echo $col | cut -d: -f1)
        type=$(echo $col | cut -d: -f2)
        if ! is_valid_name "$name"; then
            echo "Invalid column name '$name'. Only alphanumeric characters and underscores are allowed."
            return
        fi
        if [[ "$type" != "int" && "$type" != "float" && "$type" != "string" ]]; then
            echo "Invalid column type '$type'. Only 'int', 'float', and 'string' are allowed."
            return
        fi
    done

    echo "$columns" > "$tablename"
    echo "Table '$tablename' created successfully in the '$db_path' database."
}

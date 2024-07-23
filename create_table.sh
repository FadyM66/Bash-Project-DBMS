#!/bin/bash
source ./validation.sh

create_table() {
    local db_path=$1
    local oneFlag=0

    if [ ! -d "$db_path" ]; then
        echo "Invalid database path '$db_path'."
        return
    fi

    # Navigate to the database directory
    cd "$db_path" || {
        echo "Failed to navigate to the database directory."
        return
    }

    local tablename
    while true; do
        read -p "Enter table name: " tablename
        tablename=$(is_valid_name "$tablename")

        if [[ "$tablename" == "1" ]]; then
            echo "Invalid table name. Only alphanumeric characters and underscores are allowed. Please try again."
        elif file_exists "$tablename"; then
            echo "Table '$tablename' already exists. Please try again."
        else
            break
        fi
    done

    # Loop to enter each field's name, data type, and primary key status
    local field_definitions=()

    while true; do
        read -p "Enter the number of fields: " numFields

        if is_integer "$numFields"; then
            break
        else
            echo "Invalid number of fields. Please enter a valid integer."
        fi
    done

    for ((i = 1; i <= numFields; i++)); do
        while true; do
            read -p "Enter the name of field $i: " FieldName
            modifiedFieldName=$(is_valid_name "$FieldName")

            if [[ "$modifiedFieldName" != "1" ]]; then
                break
            else
                echo "Invalid column name. Only alphanumeric characters and underscores are allowed."
            fi
        done

        while true; do
            read -p "Enter the datatype of field $i (string/int): " DataType

            checkDataType=$(check_dataType "$DataType")

            if [[ "$checkDataType" != "1" ]]; then
                DataType=$(echo "$DataType" | tr '[:upper:]' '[:lower:]')
                break
            else
                echo "Invalid datatype. Please enter 'string' or 'int'."
            fi
        done

        # Check if this field should be a primary key
        if [[ $oneFlag == 0 ]]; then
            while true; do
                read -p "Is field $i a primary key? (y/n): " IsPrimaryKey
                modifiedYesNo=$(check_yesNo "$IsPrimaryKey")

                if [[ "$modifiedYesNo" != "1" ]]; then
                    if [ "$modifiedYesNo" == "y" ]; then
                        field_definitions+=("${modifiedFieldName}:${DataType}:pk")
                        oneFlag=1
                    else
                        field_definitions+=("${modifiedFieldName}:${DataType}")
                    fi
                    break
                else
                    echo "Invalid response. Please enter 'y' for yes or 'n' for no."
                fi
            done
        else
            field_definitions+=("${modifiedFieldName}:${DataType}")
        fi
    done

    # Write field definitions to the table file with the new format
    printf "# %s\n" "$(IFS=';'; echo "${field_definitions[*]}")" > "$tablename"

    echo "Table '$tablename' created successfully in the '$db_path' database."

    sleep 2
    cd ..
    mainmenu
}

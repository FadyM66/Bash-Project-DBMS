#!/bin/bash
source ./validation.sh

create_table() {
    local db_path=$1
    local oneFlag=0

    if [ ! -d "$db_path" ]; then
        echo "Invalid database path '$db_path'."
        return
    fi

    # pwd
    cd "$db_path" || {
        echo "Failed to navigate to database directory."
        return
    }
    # pwd

    local tablename
    while true; do
        read -p "Enter table name: " tablename
        tablename=$(is_valid_name "$tablename")

        if [[ "$tablename" = "1" ]]; then
            echo "Invalid table name. Only alphanumeric characters and underscores are allowed. Please try again."
        elif file_exists "$tablename"; then
            echo "Table '$tablename' already exists. Please try again."
        else
            break
        fi
    done

    # Start writing metadata
    printf "# " >>"$tablename"

    # Loop to enter each field's name and data type
    while true; do
        read -p "Enter the number of fields: " numFields

        if is_integer "$numFields"; then
            break
        else
            echo "Invalid number of fields."
        fi
    done

    for ((i = 1; i <= numFields; i++)); do
        while true; do
            read -p "Enter the name of field $i: " FieldName
            modifiedFieldName=$(is_valid_name "$FieldName")

            if [[ "$modifiedFieldName" != "1" ]]; then
                printf "$modifiedFieldName:" >>"$tablename"
                break
            else
                echo "Invalid column name."
            fi
        done

        while true; do
            read -p "Enter the datatype of field $i (string/int): " DataType

            checkDataType=$(check_dataType "$DataType")

            if [[ "$checkDataType" != "1" ]]; then
                re=$(echo "$DataType" | tr '[:upper:]' '[:lower:]')
                printf "$re:" >>"$tablename"
                break
            else
                echo "Invalid datatype."
            fi
        done

        if [[ $oneFlag == 0 ]]; then
            while true; do
                read -p "Is field $i a primary key? (y/n): " IsPrimaryKey
                modifiedYesNo=$(check_yesNo "$IsPrimaryKey")

                if [[ "$modifiedYesNo" != "1" ]]; then
                    if [ "$modifiedYesNo" == "y" ]; then
                        printf "pk " >>"$tablename"
                        oneFlag=1
                        break
                    else
                        break
                    fi
                else
                    echo "Invalid response."
                fi
            done
        fi
        printf "\n# " >>"$tablename"
    done

    echo "Table '$tablename' created successfully in the '$db_path' database."

    sleep 2
    cd ..
    mainmenu
}

#!/bin/bash
source ./validation.sh

insert_into_table() {
    local DBName="$1"

    # Check if the database directory exists
    if [[ ! -d "$DBName" ]]; then
        echo "Error: Database '$DBName' not found."
        return
    fi

    # List tables in the database
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

    # Prompt user to select a table to insert into
    local choice
    while true; do
        read -p "Enter the number of the table to insert into (or 0 to cancel): " choice

        if [[ $choice =~ ^[0-9]+$ ]] && ((choice >= 0 && choice <= num_tables)); then
            break
        else
            echo "Invalid input. Please enter a valid number."
        fi
    done

    if [ $choice -eq 0 ]; then
        echo "Insert operation canceled."
        return
    fi

    local TableName="${tables[$((choice - 1))]}"

    # Check if the selected table exists
    if [[ ! -f "$DBName/$TableName" ]]; then
        echo "Error: Table '$TableName' not found."
        return
    fi

    # Read field names, data types, and primary key information from metadata
    local metadata
    metadata=$(awk '/^# / {print $0}' "$DBName/$TableName" | sed 's/# //')
    
    # Split metadata by semicolon and populate arrays
    IFS=';' read -ra fields <<< "$metadata"
    local Name=()
    local DataType=()
    local PK=()

    for field in "${fields[@]}"; do
        IFS=':' read -r name datatype pk_flag <<< "$field"
        Name+=("$name")
        DataType+=("$datatype")
        PK+=("${pk_flag:-x}")
    done

    local numOfFields=${#Name[@]}

    # Loop to get values for each field
    for ((i = 0; i < numOfFields; i++)); do
        while true; do
            read -p "Enter value for ${Name[$i]}: " FieldName

            if [[ ${DataType[$i]} == "int" ]]; then
                checkValue=$(is_integer "$FieldName")

                if [[ $checkValue == 1 ]]; then
                    echo "Invalid input. Please enter an integer for ${Name[$i]}."
                    continue
                fi
            elif [[ ${DataType[$i]} == "string" ]]; then
                FieldName=$(is_valid_name "$FieldName")

                if [[ $FieldName == 1 ]]; then
                    echo "Invalid input. Please enter an string for ${Name[$i]}."
                    continue
                fi

            elif [[ ${DataType[$i]} == "boolean" ]]; then
                checkValue=$(is_valid_boolean "$FieldName")

                if [[ $checkValue == 1 ]]; then
                    echo "Invalid input. Please enter 'true', 'false', '1', or '0' for ${Name[$i]}."
                    continue
                fi
            fi                        

            # Handle primary key uniqueness check
            if [[ ${PK[$i]} == "pk" ]]; then
                flag=0
                values=($(awk -F: -v col=$((i + 1)) '$1 !~ /^#/ {print $col}' "$DBName/$TableName"))
                for value in "${values[@]}"; do
                    if [[ $FieldName == "$value" ]]; then
                        flag=1
                        break
                    fi
                done

                if [[ $flag == 1 ]]; then
                    echo "Error: Value for ${Name[$i]} must be unique. It is a primary key."
                    continue
                fi
            fi

            # Append field value to the table
            if [[ $i == 0 ]]; then
                echo -n "$FieldName" >>"$DBName/$TableName"
            else
                echo -n ":$FieldName" >>"$DBName/$TableName"
            fi

            break
        done
    done


    # Add a newline at the end of the record
    echo "" >>"$DBName/$TableName"
    echo "Record inserted successfully."

    sleep 2
    mainmenu
}

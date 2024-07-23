#!/bin/bash
source ./validation.sh

insert_into_table() {
    # local DBName="$1"
    # local TableName="$2"

    local DBName="db1"
    local TableName="t1"

    # Check if the database and table exist
    if [[ ! -f "$DBName/$TableName" ]]; then
        echo "Error: Database or table not found."
        return
    fi

    # Read field names, data types, and primary key information from metadata
    local metadata
    metadata=$(awk '/^# / {print $0}' "$DBName/$TableName")
    local numOfFields
    numOfFields=$(echo "$metadata" | wc -l)

    # Prepare arrays for field names, data types, and PK flags
    local Name=()
    local DataType=()
    local PK=()

    # Extract the name, data type, and primary key indicator from metadata lines
    Name=($(awk -F: '/^#/ {print $1}' "$DBName/$TableName" | sed 's/# //'))
    DataType=($(awk -F: '/^#/ {print $2}' "$DBName/$TableName"))
    PK=($(awk -F: '/^#/ {print ($3 == "" ? "x" : $3)}' "$DBName/$TableName"))

    # Loop to get values for each field
    for ((i = 0; i < numOfFields; i++)); do
        while true; do
            read -p "Enter value for ${Name[$i]}: " FieldName

            if [[ ${DataType[$i]} == "int" ]]; then
                checkValue=$(check_is_int "$FieldName")

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
}

insert_into_table

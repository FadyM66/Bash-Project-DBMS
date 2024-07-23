
#!/bin/bash

# Source other function scripts

source ./validation.sh
# source ./select_from_table.sh


# Welcome 

welcome() {
    clear
    echo "####################################################"
    echo "##                                                ##"
    echo "##    _______    ______    ___    ___    _____    ##"
    echo "##   |   __  \  |   __  ) |   \  /   |  / ____|   ##"
    echo "##   |  |  |  | |  |__) ) |    \/    | | |____    ##"
    echo "##   |  |  |  | |   __ |  |  |\  /|  |  \____ \   ##"
    echo "##   |  |__|  | |  |__) ) |  | \/ |  |  ____| |   ##"
    echo "##   |_______/  |_______) |__|    |__| |______/   ##"
    echo "##                                                ##"
    echo "##                   Welcome to                   ##"
    echo "##                      DBMS                      ##"
    echo "##                                                ##"
    echo "##               By Fady & Basmala                ##"
    echo "####################################################"
    echo
    test
}

# Warning

warning(){
    echo " ** WARNING : "
    echo "PLEASE MAKE SURE THAT YOU ARE RUNNING THE SCRIPT INSIDE THE DIRECTORY WHICH CONTAINING THE DATABASES."
    echo " ** TO AVOID ANY ERRORS DURING RUNNING THE SCRIPT"
    echo
    read -p "Enter for continue.."
}


# Main Menu

mainmenu(){
    while true
    do
        clear
        welcome
        echo "Main Menu: "
        echo ""
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect to Databases"  
        echo "4. Drop Database"
        echo 
        echo "0. Exit"
        echo 

        read -p "Enter the number of your choice: " choice
 
        case $choice in
        1) create_database;;
        2) list_databases;;
        3) connectmenu;;
        4) dropdb;;
        0) quit;continue;;
        *) echo "Invalid Input"; sleep 1;;
        esac
    done   
}


# Connect Menu

connectmenu(){
        
    existingdb
    if [[ "$choosendb" == "00" ]] 2>/dev/null ;
    then
        return
    fi
    while true
    do
        if [[ ${#choosendb[@]} -eq 0 ]];
        then
            mainmenu
        else
            clear
            welcome
            echo
            echo "Database : $choosendb "
            echo
            echo "Connect Menu: "
            echo ""
            echo "1. Create Table"
            echo "2. List Tables"
            echo "3. Drop Table"  
            echo "4. Insert into Table"
            echo "5. Select from Table"
            echo "6. Delete from Table"
            echo "7. Update Table"
            echo ""
            echo "00. Back to Main Menu"
            echo ""
            echo "0. Exit"
            echo ""

            read -p "Enter the number of your choose: " x

            case $x in
            1) welcome;create_table "$choosendb";;
            2) list_tables "$choosendb";;
            3) welcome;drop_table "$choosendb";;
            4) welcome;insert_into_table "$choosendb";;
            5) welcome;select_from_table;;
            6) welcome;delete_from_table;;
            7) welcome;update_table;;
            00) return;;
            0) quit;;
            *) echo "Invalid Input"; sleep 1;;
            esac
        fi
    done
}

choosendb=()

# Checking the existing Databases

existingdb(){

    choosendb=()

    while true
    do
        clear
        welcome 
        echo ""
        echo "Existing Database."
        echo ""
        
        databases=($(ls -d */ 2>/dev/null | grep -E '^[a-zA-Z][a-zA-Z0-9 _]*\/$'))
        counter=0
        numberofdatabases=${#databases[@]}
        
        
        case $numberofdatabases in
        0)
            echo "No Databases found "
            echo
            echo
            echo "Redirect to Main Menu"
            sleep 2
            return;;

        *)
            for i in "${databases[@]}"
            do
                echo "$((counter+1)).  ${i%?}"
                counter=$((counter+1))
            done

            echo 
            echo "00. Back to Main Menu"
            echo "0. Exit"
            echo 

            read -p "Enter the number of your Choice : " choosendb
            if [[ $choosendb -gt 0 && $choosendb -le $counter ]] 2>/dev/null;
            then
                choosendb=${databases[$((choosendb-1))]%/}
                echo "$choosendb"
                break
            elif [[ "$choosendb" == "0" ]] 2>/dev/null ;
            then        
                quit
                continue
            elif [[ "$choosendb" == "00" ]] 2>/dev/null ;
            then
                return
            else
                echo "Invalid Input"
                sleep 1
            fi ;;
        esac
    done
    
}

# Exit function

quit(){

    echo ""
    read -p "Do you want really to Exit? (y/n) " x   
    
    if [[ $x =~ ^[Yy] ]]; 
    then
        exit
    else
        echo "Continuing.."
        sleep 1
    fi
}

# Drop Database

dropdb(){
    
    existingdb
    if [[ "$choosendb" == "00" ]] 2>/dev/null ;
    then
        return
    fi
    clear
    echo
    read -p "WARNING:
        ARE YOU SURE THAT YOU WANT TO DROP  ==> $choosendb <==  DATABASE ? 
        TYPE 'YES' ALL UPPER CASE FOR CONFIRM -any key for cancel- : 
         " confirmation

    if [[ $confirmation =~ ^YES$ ]];
    then 
        
        rm -r ./$choosendb 
        echo
        echo "Database has been deleted"
        read -n 1 -p "Press any key to continue.."
        return

    else

        echo "Canceled..redirect to Main Menu"
        sleep 2
        return
    
    fi
}

# create databases


create_database() {
    local dbName
    while true; do
        welcome
        echo "DB name instructions: "
        echo
        echo "You can start the name with letters ONLY."
        echo "You can use letters, numbers and underscores."
        echo
        echo
        echo "00. Back to Main Menu"
        echo "0. Exit"
        echo
        read -p "Enter database name: " dbName
        if [[ $dbName = 0 ]];
        then 
            quit
            continue
        elif [[ $dbName = 00 ]];
        then
            return
        fi
        dbName=$(is_valid_name "$dbName")

        if [[ "$dbName" == "1" ]]; then
            echo "Invalid database name. Only alphanumeric characters and underscores are allowed. Please try again."
            echo
            read -n 1 -p "press any key to continue.. "
            continue
        elif [[ -d "$dbName" ]]; then
            echo "Database '$dbName' already exists. Please try a different name."
            echo
            read -n 1 -p "press any key to continue.. "
            continue
        else
            break
        fi
    done

    
    mkdir "$dbName"
    if [[ $? -eq 0 ]]; then
        echo "Database '$dbName' created successfully."
        echo
        echo "press any key to continue.. "
        read -n 1
    else
        echo "Failed to create database '$dbName'. Please check permissions and try again."
        echo
        read -n 1 -p "press any key to continue.. "
    fi

}

# list databases

list_databases() {

    clear
    welcome
    echo ""
    echo "Existing Databases:"
    echo ""

    databases=($(ls -d */ 2>/dev/null | grep -E '^[a-zA-Z][a-zA-Z0-9 _]*\/$')) 
    numberofdatabases=${#databases[@]}

    if [ $numberofdatabases -eq 0 ]; then
        echo "No Databases found."
    else
        counter=1
        for db in "${databases[@]}"; do
            echo "$counter. ${db%/}"
            counter=$((counter + 1))
        done
    fi
    echo
    echo "Press any key to return to the main menu..."
    read -n 1
}

# create table

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
        checkValue=$(is_integer "$numFields")
        if [[ $checkValue != 1 ]]; then
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
            read -p "Enter the datatype of field $i (string/int/boolean): " DataType

            checkDataType=$(check_dataType "$DataType")

            if [[ "$checkDataType" != "1" ]]; then
                DataType=$(echo "$DataType" | tr '[:upper:]' '[:lower:]')
                break
            else
                echo "Invalid datatype. Please enter 'string', 'int', or 'boolean'."
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
    
}

# List tables

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
    
}


# Drop Table

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
    
}

# insert into table

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

}

path="$DBName/$TableName"

# delete from table

# delimiter=";"
# maxnum=()
# valid=false

# maindeletefromtable(){
#     while true
#     do  
#         clear
#         echo "Delete from a table."
#         echo "*******************"
#         echo
#         cols
#         echo
#         echo "Operators : gt , ge , lt , le , eq , between"
#         echo
#         echo "write the codition like 'col_number,operator,value'"
#         echo "  ex: 2,between,1000,2000 .... Don't forget the , between them"
#         echo "  ex: 2,gt,1000"
#         echo
#         echo
#         validate_condition   
#         converter
#         get_rows
#         echo
#         echo
#         read -p "enter to continue"
#     done
# }

# # Utility for delete rows from table based on certain values.

# cols(){
#     header=$(head -n 1 "$path")
#     IFS="$delimiter" read -r -a columns <<< "$header"
#     maxnum="${#columns[@]}"
#     echo "Existing Columns: "
#     echo
#     for i in "${!columns[@]}"; 
#     do
#         numberofcolumn=$((i + 1))
#         nameofcolumn=${columns[$i]}
#         echo "     $numberofcolumn. $nameofcolumn"
#     done 
# }

# # Utility to validate the user conditions

# validate_condition() {
#     while true; do
#         read -p "Condition => " condition
                
#         IFS=',' read -r col_num operator value1 value2 <<< "$condition"

        
#         if [[ ! $col_num =~ ^[0-9]+$ || $col_num -gt $maxnum || $col_num -lt 1 ]]; then
#             echo "Invalid column number. Please enter a valid column number."
#             continue
#         fi
        
#         case $operator in
#             gt|ge|lt|le) 
#                 if [[ $value1 =~ ^[0-9]+$ ]];
#                 then
#                     break
#                 else 
#                     echo "values should be numbers";continue
#                 fi ;;
#             between)
#                 if [[ $value1 =~ ^[0-9]+$ && $value2 =~ ^[0-9]+$ ]]
#                 then
#                     break
#                 else
#                     echo "between takes two arguments and they should be numbers";continue
#                 fi
#                  ;;
#             eq)break;;
#             *)
#                 echo "Invalid operator. Please use one of the following: gt, ge, lt, le, eq, between[start:end]."
#                 continue
#                 ;;
#         esac
#     done    
# }

# # Utility to convert input into conditions

# converter(){
#     NRs=()
#     linenum=0
#     while IFS= read -r line
#     do
#         ((linenum++))
#         if [[ $linenum -eq 1 ]];
#         then 
#             continue
#         else
#            : 
#         fi   
#         field=$(echo "$line" | cut -d"$delimiter" -f"$col_num")
#         case $operator in
#         gt) [[ "$field" -gt "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
#         ge) [[ "$field" -ge "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
#         lt) [[ "$field" -lt "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
#         le) [[ "$field" -le "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
#         eq) [[ "$field" = "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;  
#         between) [[ "$field" -ge $value1 && "$field" -le $value2 ]] 2>/dev/null && NRs+=("$linenum") ;;
#         esac
#     done < "$path"
#     echo
#     echo "      rows matched : "${#NRs[@]}" "

# }


# # Utility to get the rows obey the conditions

# get_rows() {
#     dels=0
#     sorted_NRs=($(printf "%s\n" "${NRs[@]}" | sort -nr))
#     for r in "${sorted_NRs[@]}"; do
#         sed -i "${r}d" $path
#         ((dels++))
#     done
#     echo "      deleted rows : $dels"
# }

mainmenu

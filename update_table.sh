#!/usr/bin/bash

delimiter=""
maxnum=()
valid=false

mainupdate(){

    welcome
    local DBName="$choosendb"

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
    

    path="$DBName/$TableName"

    while true
    do
        welcome
        echo
        echo "Update table list"
        echo "-----------------"
        echo
        echo "1. select record using pk"
        # echo "2. update multiple records"
        echo
        read -p "Enter you choice's number: " update_choice
        echo
        case $update_choice in
        1) using_pk;;
        esac
    done

}


# Utility to update using pk

using_pk(){
    while true
    do
        welcome
        echo
        echo "Using pk"
        fetch_pk
        echo " Found pk column: $pkcolvalue"
        read -p "To select the record, enter the value of the pk column: " v
        valid=0
        validate_inputs
        read -p "enter to cinti"
        if [[ $valid = false ]];
        then
            continue
        fi
        echo
        find_pk_line
        read -p "enter to cont.."
        welcome
        cols
        read -p "which column you want to update. enter its number: " index
        echo "$line"
        read -p "Enter the new value: " v
        validate_inputs
        if [[ $valid = false ]];
        then
            continue
        fi
        update_record
    done
}


fetch_pk(){
    head=$(head -n 1 "$path")
    IFS=";" read -r -a arr <<< "$head"
    for i in "${!arr[@]}"
    do
        if [[ "${arr[$i]}" == *"pk"* ]]; then
            
            pk="$i"
            pkcolvalue="${arr[$i]}"
            if [[ "${arr[$i]}" == *"int"* ]]; then
            coldt="int"
            elif [[ "${arr[$i]}" == *"string"* ]]; then
            coldt="string"
            elif [[ "${arr[$i]}" == *"boolean"* ]]; then
            coldt="boolean"
            fi
            break
        fi
    done
}

# Utility for recieving inputs

validate_inputs(){
    
    str_pattern="^[a-zA-Z0-9 _]+$"
    int_pattern="^[0-9]+$"
    boolean_pattern="^(true|false|1|0)$"
    if [[ "$coldt" = "boolean" ]];
    then
        if [[ "$v" =~ $boolean_pattern ]];
        then
            return
        else
            echo "Invalid input"
            valid=false
            sleep 1
        fi
    elif [[ "$coldt" = "string" ]];
    then
        if [[ "$v" =~ $str_pattern ]];
        then
            return
        else
            echo "Invalid input"
            valid=false
            sleep 1
        fi
    elif [[ "$coldt" = "int" ]];
    then
        if [[ "$v" =~ $int_pattern ]];
        then
            return
        else
            echo "Invalid input"
            valid=false
            sleep 1
        fi
    fi
}

# Utility to find the line matches the pk input

# Utility to find the line that matches the pk input
find_pk_line() {
    l=0
    while read -r line; do
        ((l++))
        z=$((pk+1))
        kw=$(cut -d":" -f"$z" <<< "$line")
        if [[ "$kw" == "$v" ]]; then
            break
        fi
    done < "$path"
}

# update using pk

update_record() {
    z=$((pk+1))
    oldvalue=$(cut -d":" -f"$z" "$path" | sed -n "${l}p" 2>/dev/null)

    # Update the record and check if sed succeeded
    if sed -i "${l}s/${oldvalue}/${v}/" "$path" 2>/dev/null; then
        echo "Updated successfully"
        read -p "xx"
    else
        echo "Something went wrong"
        read -p "xx"
    fi
}


# # Utility to check data type

# datatype_checker(){
#     dtypes=()
#     colnames=()
#     read -r line < "$path"
#     IFS=" " read -r -a fields <<< "$line"
#     for i in "${fields[@]}"
#     do
#         dtype=$( echo "$i" | cut -d: -f2 )
#         colname=$( echo "$i" | cut -d: -f1 )
#         dtypes+=("$dtype")
#         colnames+=("$colname")
#     done
# }

# # Utility to check if inputs match or not the datatypes

# check_input_datatype(){
#     valid="false"
#     IFS=","
    
#     read -ra input_array <<< "$input"
    
#     for index in "${!input_array[@]}"; 
#     do
#         if [[ "${dtypes[$index]}" = "int" ]];
#         then
#             if [[ "${input_array[$index]}" =~ $int_pattern ]];
#             then
#                 :
#             else
#                 echo "Invalid update dataype at ${input_array[$index]} "
#                 echo "Please re-write you input and follow the order of inputs and the required datatype"
#                 echo
#                 read -p "Enter to continue.."
#                 return
#             fi
#         elif [[ "${dtypes[$index]}" == "string" ]];
#         then 
#             if [[ "${input_array[$index]}" =~ $str_pattern ]] && [[ ! "${dtypes[$index]}" =~ "^[ ]+$" ]];
#             then
#                 :
#             else
#                 echo "Invalid update dataype at ${input_array[$index]} "
#                 echo "Please re-write you input and follow the order of inputs and the required datatype"
#                 echo
#                 read -p "Enter to continue.."
#                 return
#             fi
#         else
#             :
#         fi
#     done
#     valid="true"
#     echo "Your updates are $valid"
# }

# # Utility to find the line matches the pk input

# find_pk_line(){
#     l=0
#     while read -r line 
#     do
#         ((l++))
#         kw=$(cut -d":" -f"$(pk+1)" $line)
#         if [[ "$kw" = "$v" ]];
#         then
#             break
#         fi
#     done < "$path"    
# }

# update_using_pk
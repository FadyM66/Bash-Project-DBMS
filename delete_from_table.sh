#!/usr/bin/bash

path="t2"
delimiter=";"
maxnum=()
valid=false

# Main function

main(){
    while true
    do  
        clear
        echo "Delete from a table."
        echo "*******************"
        echo
        cols
        echo
        echo "Operators : gt , ge , lt , le , eq , between"
        echo
        echo "write the codition like 'col_number,operator,value'"
        echo "  ex: 2,between,1000,2000 .... Don't forget the , between them"
        echo "  ex: 2,gt,1000"
        echo
        echo
        validate_condition   
        converter
        get_rows
        echo
        echo
        read -p "enter to continue"
    done
}

# Utility for delete rows from table based on certain values.

cols(){
    header=$(head -n 1 "$path")
    IFS="$delimiter" read -r -a columns <<< "$header"
    maxnum="${#columns[@]}"
    echo "Existing Columns: "
    echo
    for i in "${!columns[@]}"; 
    do
        numberofcolumn=$((i + 1))
        nameofcolumn=${columns[$i]}
        echo "     $numberofcolumn. $nameofcolumn"
    done 
}

# Utility to validate the user conditions

validate_condition() {
    while true; do
        read -p "Condition => " condition
                
        IFS=',' read -r col_num operator value1 value2 <<< "$condition"

        
        if [[ ! $col_num =~ ^[0-9]+$ || $col_num -gt $maxnum || $col_num -lt 1 ]]; then
            echo "Invalid column number. Please enter a valid column number."
            continue
        fi
        
        case $operator in
            gt|ge|lt|le) 
                if [[ $value1 =~ ^[0-9]+$ ]];
                then
                    break
                else 
                    echo "values should be numbers";continue
                fi ;;
            between)
                if [[ $value1 =~ ^[0-9]+$ && $value2 =~ ^[0-9]+$ ]]
                then
                    break
                else
                    echo "between takes two arguments and they should be numbers";continue
                fi
                 ;;
            eq)break;;
            *)
                echo "Invalid operator. Please use one of the following: gt, ge, lt, le, eq, between[start:end]."
                continue
                ;;
        esac
    done    
}

# Utility to convert input into conditions

converter(){
    NRs=()
    linenum=0
    while IFS= read -r line
    do
        ((linenum++))
        if [[ $linenum -eq 1 ]];
        then 
            continue
        else
           : 
        fi   
        field=$(echo "$line" | cut -d"$delimiter" -f"$col_num")
        case $operator in
        gt) [[ "$field" -gt "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
        ge) [[ "$field" -ge "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
        lt) [[ "$field" -lt "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
        le) [[ "$field" -le "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;
        eq) [[ "$field" = "$value1" ]] 2>/dev/null && NRs+=("$linenum") ;;  
        between) [[ "$field" -ge $value1 && "$field" -le $value2 ]] 2>/dev/null && NRs+=("$linenum") ;;
        esac
    done < "$path"
    echo
    echo "      rows matched : "${#NRs[@]}" "

}


# Utility to get the rows obey the conditions

get_rows() {
    dels=0
    sorted_NRs=($(printf "%s\n" "${NRs[@]}" | sort -nr))
    for r in "${sorted_NRs[@]}"; do
        sed -i "${r}d" $path
        ((dels++))
    done
    echo "      deleted rows : $dels"
}
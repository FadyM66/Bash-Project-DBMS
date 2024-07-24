#!/usr/bin/bash


delimiter=""
maxnum=()
valid=false

select_from_table(){
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
    while true;
    do
        welcome
        echo
        echo "What you want to select?"
        echo
        echo "1. Whole table"
        echo "2. Whole table -formatted-"
        echo "3. Select columns"
        echo "4. Select records based on values"
        echo "5. Select records through operations"
        echo "6. Aggregate Functions"
        echo
        echo "00. Main Menu"
        echo "0. Exit"
        echo
        read -p "Enter the number of your choose: " x
        echo 
        case $x in
        1)whole_table;;
        2)formatted_table;;
        3)select_columns;;
        4)select_based_on_values;;
        5)operations;;
        6)aggregate;;
        00)return;;
        0)quit;;
        *)echo "Invalid Input..";sleep 1;;
        esac
    done
}

# Utility for select the whole table

whole_table(){

    clear
    echo $path
    cat $path
    echo
    read -p "hit enter to back to select from table menu.."
}

# Utility for select the whole table and format it

formatted_table() {
    clear
    
    cat $path | awk -F';' 'NR == 1 {
    # Print each field in a formatted way
    for (i = 1; i <= NF; i++) {
        printf "%-15s", $i
        if (i < NF) printf "| "
    }
    print ""
    }'
    cat $path | awk -F':' 'NR > 1 {
    # Print each field in a formatted way
    for (i = 1; i <= NF; i++) {
        printf "%-15s", $i
        if (i < NF) printf "| "
    }
    print ""
    }'
    read -p "Hit enter to go back to the select from table menu.."
}


# Utility to select specific columns

select_columns(){        
    while true;
    do                
        columns
        echo
        echo "     0. Back to select Menu"
        echo
        echo "Enter the column's number you want to select"
        echo "for many columns, separate the numbers with a space"
        echo
        read -p "Column number : " selectedcolumn 
        case $selectedcolumn in
        0)return;;
        esac               
        echo                
        valid=false                
        validate_selected_columns                
        if [[ $valid == true ]] 2>/dev/null;
        then
            break
        else
            continue
        fi   
    done
    show_selected_columns
    }

# Utility to show the existing columns

columns(){
    clear
    delimiter=";"
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

# Utility for validate the selected columns by the user -for columns utility-

validate_selected_columns(){
    for i in ${selectedcolumn[@]};
        do
            if [[ "$i" =~ ^[1-9]+$ && "$i" -le "$maxnum" ]] 2>/dev/null;
            then    
                valid=true
            else
                echo "Invalid input"
                echo "Rewrite your selection"
                valid=false
                sleep 1
                break
            fi
        done
}

# Utility shows the selected columns

show_selected_columns(){
    delimiter=":"
    cols=$(echo "${selectedcolumn[*]}" | tr ' ' ',')
    cut -d"$delimiter" -f$cols $path | sed 's/"$delimiter"/\t/g' | awk -F':' '
        {
            # Print each field in a formatted way
            for (i = 1; i <= NF; i++) {
                printf "%-15s", $i
                if (i < NF) printf "| "
            }
            print ""
        }'
    
    echo "hit enter to continue.."
    read
}

# Utility to select columns based on input values

select_based_on_values(){
    columns
    header=$(head -n 1 "$path")
    delimiter=";"
    IFS="$delimiter" read -r -a columns <<< "$header"
    echo
    echo "Enter for each column, the value you want it then hit Enter -only values-"
    echo "When there is no specific value, just hit Enter"
    echo
   keys=()
    for i in "${columns[@]}"; 
    do
        read -p "   $i : " key
        if [[ -z "$key" ]] 2>/dev/null; then
            key="%*@"
        fi
        keys+=("$key")        
    done
    filter_columns
}

# Utility for selection based on values

filter_columns(){
    clear
    delimiter=":"
    regexes=()
    for i in "${keys[@]}"; do
        if [[ "$i" == "%*@" ]] 2>/dev/null; then
            regexes+=(".*")  
        else
            regexes+=("$i")
        fi
    done
    header=$(head -n 1 "$path")
    echo "$header" | awk -F';' '
        {
            # Print each field in a formatted way
            for (i = 1; i <= NF; i++) {
                printf "%-15s", $i
                if (i < NF) printf "| "
            }
            print ""
        }'
    tail -n +2 "$path" | while IFS="$delimiter" read -r -a row; do
        match=1
        for i in "${!row[@]}"; do
            if [[ ! "${row[i]}" =~ ${regexes[i]} ]] 2>/dev/null; then
                match=0
                break
            fi
        done
        if [ "$match" -eq 1 ] 2>/dev/null; then
                echo "${row[*]}" | awk -F' ' '
        {
            # Print each field in a formatted way
            for (i = 1; i <= NF; i++) {
                printf "%-15s", $i
                if (i < NF) printf "| "
            }
            print ""
        }'
        fi
    done
    read -p "hit enter to continue"
}


# Utility acts as a gate for the aggregate options

aggregate(){
    while true;
    do
        clear
        echo
        echo "1. Sum"
        echo "2. Count"
        echo "3. Avg"
        echo "4. Max"
        echo "5. Min"
        echo
        echo "0. Back to select Menu"
        echo
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Enter the number of your choice : " x
        echo
        case $x in
        1)sum;;
        2)count;;
        3)avg;;
        4)max;;
        5)min;;
        0)return;;
        *)echo "Invalid input"; sleep 1;;
        esac
    done
}

# Utility to validate the selected column -for aggregate operations-

validate_selected_col(){
    if [[ "$selectedcol" =~ ^[1-9]+$ && "$selectedcol" -le "$maxnum" ]] 2>/dev/null;
    then    
        valid=true
    else
        echo "Invalid input"
        echo "Rewrite your selection"
        valid=false
        sleep 1
    fi
}

# Utility to calculate the sum of a column

sum(){
    while true;
    do
        maxnum=()
        valid=false
        columns
        echo
        echo "Enter the column's number "
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Column number : " selectedcol        
        echo
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null;
        then
            rows=$(wc -l < "$path")
            sum=0
            delimiter=":"
            for i in $(cut -d"$delimiter" -f"$selectedcol" "$path" | tail -n "$((rows-1))");
            do
                if [[ "$i" =~ ^[0-9]+$ ]] 2>/dev/null ;
                then
                    sum=$((sum + i))
                else
                    echo "The datatype of records is not a number."
                    echo "exit function.."
                    sleep 2
                    return
                fi
            done
            echo "Sum: $sum"
            read -p "Enter to continue.."
            break
        else
            echo "Invalid input"
            sleep 1
            continue
        fi   
    done
}

# Utility for count rows in rows

count(){
    while true;
    do
        maxnum=()
        valid=false
        columns
        echo
        echo "Enter the column's number "
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Column number : " selectedcol
        echo
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null;
        then
            rows=$(wc -l < "$path")
            counter=0
            delimiter=":"
            for i in $(cut -d"$delimiter" -f"$selectedcol" "$path" | tr ' ' '+' | tail -n "$((rows-1))");
            do
                if [[ "${#i[@]}" -gt 0 ]] 2>/dev/null ;
                then
                    counter=$((counter + 1))
                else
                    continue
                fi
            done
            echo "Count: $counter"
            read -p "Enter to continue.."
            break
        else
            echo "Invalid input"
            sleep 1
            continue
        fi   
    done
}

# Utility to caculate avg of a select column

avg(){
    while true;
    do
        maxnum=()
        valid=false
        columns
        echo
        echo "Enter the column's number "
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Column number : " selectedcol
        echo
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null;
        then
            rows=$(wc -l < "$path")
            sum=0
            delimiter=":"
            counter=0
            for i in $(cut -d"$delimiter" -f"$selectedcol" "$path" | tail -n "$((rows-1))");
            do
                if [[ "$i" =~ ^[0-9]+$ ]] 2>/dev/null ;
                then
                    sum=$((sum + i))
                    if [[ "${#i[@]}" -gt 0 ]] 2>/dev/null ;
                    then
                        counter=$((counter + 1))
                    else
                        continue
                    fi
                else
                    echo "The datatype of records is not a number."
                    echo "exit function.."
                    sleep 2
                    return
                fi
            done
            echo "Avg : $((sum / counter))"
            read -p "Enter to continue.."
            break
        else
            echo "Invalid input"
            sleep 1
            continue
        fi   
    done
}

# Utility to calcualte max 

max(){
    while true;
    do        
        maxnum=()
        valid=false        
        columns
        echo
        echo "Enter the column's number "
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Column number : " selectedcol        
        echo        
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null;
        then        
            rows=$(wc -l < "$path")
            max=0
            delimiter=":"
            for i in $(cut -d"$delimiter" -f"$selectedcol" "$path" | tail -n "$((rows-1))");
            do
                if [[ "$i" =~ ^[0-9]+$ ]] 2>/dev/null ;
                then
                    if [[ $i -gt $max ]];
                    then
                        max=$i
                    else
                        continue
                    fi
                else
                    echo "The datatype of records is not a number."
                    echo "exit function.."
                    sleep 2
                    return
                fi
            done
            echo "Max : $max"
            read -p "Enter to continue.."
            break
        else
            echo "Invalid input"
            sleep 1
            continue
        fi   
    done
}

# Utility to calcualte min 

min(){
    while true;
    do        
        maxnum=()
        valid=false
        columns
        echo
        echo "Enter the column's number "
        echo "Warning: Aggregate functions used with JUST one column"
        echo
        read -p "Column number : " selectedcol        
        echo        
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null;
        then        
            rows=$(wc -l < "$path")
            min=999999999999999999999999
            delimiter=":"
            for i in $(cut -d"$delimiter" -f"$selectedcol" "$path" | tail -n "$((rows-1))");
            do
                if [[ "$i" =~ ^[0-9]+$ ]] 2>/dev/null ;
                then
                    if [[ $i -lt $min ]];
                    then
                        min=$i
                    else
                        continue
                    fi
                else
                    echo "The datatype of records is not a number."
                    echo "exit function.."
                    sleep 2
                    return
                fi
            done
            echo "Min : $min"
            read -p "Enter to continue.."
            break
        else
            echo "Invalid input"
            sleep 1
            continue
        fi   
    done
}

# Utility for select number 5 - special operations -

operations(){
    while true;
    do
        clear
        echo "Operations"
        echo
        echo "      1. gt"
        echo "      2. ge"
        echo "      3. lt"
        echo "      4. le"
        echo "      5. between"
        echo
        echo "      6. Back to select from table Menu"
        echo
        read -p "Enter the operation's number you want : " operation
        case $operation in
        1)gt;;
        2)ge;;
        3)lt;;
        4)le;;
        5)between;;
        6)break;;
        *)echo "Invalid input"; sleep 1;; 
        esac
    done
}

# Utility to select using gt

gt() {
    while true; 
    do        
        valid=false
        columns
        echo
        echo "     0. Back to aggregate operations menu"
        echo
        echo "  Be aware that these operators return nothing with any values except Numbers "
        echo
        read -p "Enter the column's number to apply the operation: " selectedcol
        case $selectedcol in
        0)return;;
        esac
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null; then
            while true; do
                echo
                read -p "Enter the required value: $selectedcol -gt " value
                clear
                if [[ $value =~ ^[0-9]+$ ]] 2>/dev/null; then
                    echo "Filtered records:"
                    echo
                    delimiter=":"
                    while IFS= read -r line; 
                    do
                        col_value=$(echo "$line" | cut -d"$delimiter" -f"$selectedcol")
                        if [[ "$col_value" -gt "$value" ]] 2>/dev/null ; then
                            echo "$line" | awk -F':' '
                                {
                                    # Print each field in a formatted way
                                    for (i = 1; i <= NF; i++) {
                                        printf "%-15s", $i
                                        if (i < NF) printf "| "
                                    }
                                    print ""
                                }'
                        fi
                    done < "$path"
                    echo
                    read -p "Press Enter to go back to the operations menu..."
                    break
                else
                    echo "Invalid input, please enter a numeric value."
                    sleep 1
                fi
            done
            break
        else
            continue
        fi
    done
}

# Utility to select using ge

ge() {
    while true; 
    do  
        valid=false
        columns
        echo
        echo "     0. Back to aggregate operations menu"
        echo
        echo "  Be aware that these operators return nothing with any values except Numbers "
        echo
        read -p "Enter the column's number to apply the operation: " selectedcol
        case $selectedcol in
        0)return;;
        esac
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null; then
            delimiter=":"
            while true; do
                echo
                read -p "Enter the required value: $selectedcol -ge " value
                clear
                if [[ $value =~ ^[0-9]+$ ]] 2>/dev/null; then
                    echo "Filtered records:"
                    echo
                    while IFS= read -r line; 
                    do
                        col_value=$(echo "$line" | cut -d"$delimiter" -f"$selectedcol")
                        if [[ "$col_value" -ge "$value" ]] 2>/dev/null ; then
                            echo "$line" | awk -F':' '
                                {
                                    # Print each field in a formatted way
                                    for (i = 1; i <= NF; i++) {
                                        printf "%-15s", $i
                                        if (i < NF) printf "| "
                                    }
                                    print ""
                                }'
                        fi
                    done < "$path"
                    echo
                    read -p "Press Enter to go back to the operations menu..."
                    break
                else
                    echo "Invalid input, please enter a numeric value."
                    sleep 1
                fi
            done
            break
        else
            continue
        fi
    done
}

# Utility to select using lt

lt() {
    while true; 
    do
        valid=false
        columns
        echo
        echo "     0. Back to aggregate operations menu"
        echo
        echo "  Be aware that these operators return nothing with any values except Numbers "
        echo
        read -p "Enter the column's number to apply the operation: " selectedcol
        case $selectedcol in
        0)return;;
        esac
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null; then
            delimiter=":"
            while true; do
                echo
                read -p "Enter the required value: $selectedcol -lt " value
                clear
                if [[ $value =~ ^[0-9]+$ ]] 2>/dev/null; then
                    echo "Filtered records:"
                    echo
                    while IFS= read -r line; 
                    do
                        col_value=$(echo "$line" | cut -d"$delimiter" -f"$selectedcol")
                        if [[ "$col_value" -lt "$value" ]] 2>/dev/null ; then
                                                        echo "$line" | awk -F':' '
                                {
                                    # Print each field in a formatted way
                                    for (i = 1; i <= NF; i++) {
                                        printf "%-15s", $i
                                        if (i < NF) printf "| "
                                    }
                                    print ""
                                }'
                        fi
                    done < "$path"
                    echo
                    read -p "Press Enter to go back to the operations menu..."
                    break
                else
                    echo "Invalid input, please enter a numeric value."
                    sleep 1
                fi
            done
            break
        else
            continue
        fi
    done
}

# Utility to select using le

le() {
    while true; 
    do
        valid=false
        columns
        echo
        echo "     0. Back to aggregate operations menu"
        echo
        echo "  Be aware that these operators return nothing with any values except Numbers "
        echo
        read -p "Enter the column's number to apply the operation: " selectedcol
        case $selectedcol in
        0)return;;
        esac
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null; then
            delimiter=":"
            while true; do
                echo
                read -p "Enter the required value: $selectedcol -le " value
                clear
                if [[ $value =~ ^[0-9]+$ ]] 2>/dev/null; then
                    echo "Filtered records:"
                    echo
                    while IFS= read -r line; 
                    do
                        col_value=$(echo "$line" | cut -d"$delimiter" -f"$selectedcol")
                        if [[ "$col_value" -le "$value" ]] 2>/dev/null ; then
                                                        echo "$line" | awk -F':' '
                                {
                                    # Print each field in a formatted way
                                    for (i = 1; i <= NF; i++) {
                                        printf "%-15s", $i
                                        if (i < NF) printf "| "
                                    }
                                    print ""
                                }'
                        fi
                    done < "$path"
                    echo
                    read -p "Press Enter to go back to the operations menu..."
                    break
                else
                    echo "Invalid input, please enter a numeric value."
                    sleep 1
                fi
            done
            break
        else
            continue
        fi
    done
}

# Utility to select using between

between() {
    while true; 
    do
        valid=false
        columns
        echo
        echo "     0. Back to aggregate operations menu"
        echo
        echo "  Be aware that these operators return nothing with any values except Numbers "
        echo
        read -p "Enter the column's number to apply the operation: " selectedcol
        case $selectedcol in
        0)return;;
        esac
        validate_selected_col
        if [[ $valid == true ]] 2>/dev/null; then
            delimiter=":"
            while true; do
                echo
                read -p "Enter the required start value: $selectedcol -ge " value1
                read -p "Enter the required end value: $selectedcol -le " value2
                clear
                if [[ $value =~ ^[0-9]+$ ]] 2>/dev/null; then
                    echo "Filtered records:"
                    echo
                    while IFS= read -r line; 
                    do
                        col_value=$(echo "$line" | cut -d"$delimiter" -f"$selectedcol")
                        if [[ "$col_value" -ge "$value1" && "$col_value" -le "$value2" ]] 2>/dev/null ; then
                                                        echo "$line" | awk -F':' '
                                {
                                    # Print each field in a formatted way
                                    for (i = 1; i <= NF; i++) {
                                        printf "%-15s", $i
                                        if (i < NF) printf "| "
                                    }
                                    print ""
                                }'
                        fi
                    done < "$path"
                    echo
                    read -p "Press Enter to go back to the operations menu..."
                    break
                else
                    continue
                fi
            done
            break
        else
            echo "Invalid column selection, please try again."
            sleep 1
        fi
    done
}



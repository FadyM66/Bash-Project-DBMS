#!/usr/bin/bash

d="t2"
delimiter=""


select_from_table(){

    clear


    echo "What you want to select?"
    echo
    echo "1. Whole table"
    echo "2. Whole table -formatted-"
    echo "3. Select columns"
    echo "4. Select records based on values"
    echo "5. Select records through operations"
    echo "6. Aggregate Functions"
    echo
    echo "7. Main Menu"
    echo
    echo "0. Exit"
    echo

    read -p "Enter the number of your choose: " x
    
    echo 

    if [[ $x -eq 1 ]] 2>/dev/null;
    then

        whole_table         
        select_from_table

    elif [[ $x -eq 2 ]] 2>/dev/null;
    then

        formatted_table
        select_from_table

    elif [[ $x -eq 3 ]] 2>/dev/null;
    then
               
        while true;
        do

            maxnum=()
            columns
            echo $maxnum

            echo
            echo "Enter the column's number you want to select"
            echo "for many columns, separate the numbers with a space"
            echo

            read selectedcolumn
            
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

    elif [[ $x -eq 4 ]] 2>/dev/null;
    then

        select_based_on_values
        select_from_table

    else

        echo "Invalid Input.."
        sleep 1
        select_from_table 
        
    fi
}


whole_table(){

    clear
    cat $d
    echo
    echo "hit enter to back to select from table menu.."
    read
}

formatted_table(){

    clear
    awk -F'$delimiter' '{OFS="\t"; $1=$1; print}' $d
    echo    
    echo "hit enter to back to select from table menu.."
    read 
}

columns(){

    clear
    header=$(head -n 1 "$d")

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

show_selected_columns(){
    
    cols=$(echo "${selectedcolumn[*]}" | tr ' ' ',')
    
    cut -d"$delimiter" -f$cols $d | sed 's/"$delimiter"/\t/g'

    echo "hit enter to continue.."
    read
}

check_delimiter(){


    head -n 1 $d | tr -d '[:alnum:]' | tr -d '[:space:]' | fold -w1 | sort | uniq -c

}

select_based_on_values(){
        
    columns

    header=$(head -n 1 "$d")

    IFS="$delimiter" read -r -a columns <<< "$header"

    echo
    echo "Enter for each column, the value you want it then hit Enter"
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
        echo "${keys[@]}"
        echo "${#keys[@]}"
        echo
    done
    filter_columns
}


filter_columns(){
    
    clear

    regexes=()
    for i in "${keys[@]}"; do
        if [[ "$i" == "%*@" ]] 2>/dev/null; then
            regexes+=(".*")  
        else
            regexes+=("$i")
        fi
    done

    header=$(head -n 1 "$d")
    echo "$header"
    
    tail -n +2 "$d" | while IFS="$delimiter" read -r -a row; do
        match=1
        for i in "${!row[@]}"; do
            if [[ ! "${row[i]}" =~ ${regexes[i]} ]] 2>/dev/null; then
                match=0
                break
            fi
        done

        if [ "$match" -eq 1 ] 2>/dev/null; then
            echo "${row[*]}"
        fi
    done
    read -p "hit enter to continue"
}


find_delimiter(){
    
    tmp=$(head -1 "$d")
        
    if echo "$tmp" | grep -q '[[:space:]]' 2>/dev/null ; then
        delimiter+=" "
    fi
    if echo "$tmp" | grep -q ',' 2>/dev/null ; then
        delimiter+=","
    fi
    if echo "$tmp" | grep -q '|' 2>/dev/null ; then
        delimiter+="|"
    fi
    if echo "$tmp" | grep -q ';' 2>/dev/null ; then
        delimiter+=";"
    fi
    
    # echo -e "$delimiter"
}

find_delimiter
select_from_table



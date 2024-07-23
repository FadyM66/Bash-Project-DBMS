#!/usr/bin/bash

path="d1/t4"
valid="false"


main(){
    while true
    do
        echo "Update table list"
        echo "-----------------"
        echo
        echo "1. update specific row -using pk/index-"
        echo "2. update mutiple rows using conditions"
        echo
        read -p "Enter you choice's number: " update_choice
        echo
        if [[ $update_choice == 1 ]];
        then
            using_pk
        elif [[ $update_choice == 2 ]];
        then
            echo "2"
        fi
    done

}


# Utility to check data type

datatype_checker(){
    dtypes=()
    colnames=()
    read -r line < "$path"
    IFS=" " read -r -a fields <<< "$line"
    for i in "${fields[@]}"
    do
        dtype=$( echo "$i" | cut -d: -f2 )
        colname=$( echo "$i" | cut -d: -f1 )
        dtypes+=("$dtype")
        colnames+=("$colname")
    done
}



# Utility to check the primary key

# pk_checker(){

    

# }

# Utility for recieving inputs

validate_inputs(){
    datatype_checker
    str_pattern="^[a-zA-Z0-9 ]+$"
    int_pattern="^[0-9]+$"
        
    echo "Using this order and datatypes, enter your inputs separated using ','"
    echo
    echo "            ${colnames[@]}"
    echo "            ${dtypes[@]}"
    echo
    read -p "New Record: " input
    echo
    echo
}

# Utility to check if inputs match or not the datatypes

check_input_datatype(){
    valid="false"
    IFS=","
    
    read -ra input_array <<< "$input"
    
    for index in "${!input_array[@]}"; 
    do
        if [[ "${dtypes[$index]}" = "int" ]];
        then
            if [[ "${input_array[$index]}" =~ $int_pattern ]];
            then
                :
            else
                echo "Invalid update dataype at ${input_array[$index]} "
                echo "Please re-write you input and follow the order of inputs and the required datatype"
                echo
                read -p "Enter to continue.."
                return
            fi
        elif [[ "${dtypes[$index]}" == "string" ]];
        then 
            if [[ "${input_array[$index]}" =~ $str_pattern ]] && [[ ! "${dtypes[$index]}" =~ "^[ ]+$" ]];
            then
                :
            else
                echo "Invalid update dataype at ${input_array[$index]} "
                echo "Please re-write you input and follow the order of inputs and the required datatype"
                echo
                read -p "Enter to continue.."
                return
            fi
        else
            :
        fi
    done
    valid="true"
    echo "Your updates are $valid"
}


# Utility to update using pk

using_pk(){
    clear
    echo
    echo "Using pk"
    echo
    read -p "Enter the pk you want to use" pk
    echo
    echo "pk you entered is : $pk"
    echo
    # pk_checker
    # select the row using pk function
    validate_inputs
    check_input_datatype
    if [[ $valid == "true" ]];
    then
        : # update the selected row using the input function
    fi
}

# Utility to apply the updates 

update_using_pk(){
    x="11,fsd,43,34,ff,43" # It's supposed to be the inputs
    x=$(echo "$x" | sed 's/,/;/g') # To change the , with ;
    while IFS=; read -r -a row
    # do
    #     echo $row
    # done < "$path"
    # sed -i "${row_number}s/.*/$new_row/" table.txt
}

# 

update_using_pk
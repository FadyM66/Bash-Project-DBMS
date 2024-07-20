#!/usr/bin/bash

# Source other function scripts
source ./create_database.sh
source ./list_databases.sh

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
    
    clear
    welcome
    echo "Main Menu: "
    echo ""
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect to Databases"  
    echo "4. Drop Database"
    echo ""
    echo "0. Exit"
    echo ""

    read -p "Enter the number of your choose: " x

    case $x in
    1) create_database;;
    2) list_databases;;
    3) welcome;connectmenu;;
    4) dropdb;;
    0) quit;mainmenu;;
    *) echo "Invalid Input"; sleep 1; mainmenu;;
    esac   
}


# Connect Menu

connectmenu(){
    
    clear
    welcome
    
    existingdb

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
        echo "8. Back to Main Menu"
        echo ""
        echo "0. Exit"
        echo ""

        read -p "Enter the number of your choose: " x

        case $x in
        1) echo "number 1";;
        2) echo "number 2";;
        3) echo "number 3";;
        4) echo "number 4";;
        5) echo "number 5";;
        6) echo "number 6";;
        7) echo "number 7";;
        8) echo "number 8"; mainmenu;;
        0) quit;;
        *) echo "Invalid Input"; sleep 1; connectmenu;;
        esac
    fi
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
    
    databases=($(ls -d [a-zA-Z]*/ 2>/dev/null)) 
    counter=0
    numberofdatabases=${#databases[@]}
    
    
    case $numberofdatabases in
    0)
        echo "No Databases found "
        echo
        echo
        echo "Redirect to Main Menu"
        sleep 2
        break;;

    *)
        for i in "${databases[@]}"
        do
        echo "$((counter+1)).  ${i%?}"
        counter=$((counter+1))
        done

        echo ""
        echo "0. Exit"
        echo ""

        read -p "Enter the number of your choice : " choosendb
        if [[ $choosendb -gt 0 && $choosendb -le $counter ]] 2>/dev/null;
        then
            choosendb=${databases[$((choosendb-1))]%/}
            break
        elif [[ $choosendb == "0" ]];
        then        
            quit
            continue
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

    if [[ ${#choosendb[@]} -eq 0 ]];
    then
        mainmenu
    else 

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
        echo "Database has been deleted.."
        echo "Redirecting to Main Menu"
        sleep 2
        mainmenu

    else

        echo "Canceled..redirect to Main Menu"
        sleep 2
        mainmenu
    
    fi
    fi
}


mainmenu

#!/usr/bin/bash

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
    1) echo "number 1";;
    2) echo "number 2";;
    3) echo "number 3"; connectmenu;;
    4) echo "number 4";;
    0) exit;;
    esac
}

connectmenu(){
    clear
    welcome
    echo ""
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
    0) exit;;
    esac
}

while true
do
mainmenu
done



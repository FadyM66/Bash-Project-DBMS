#!/bin/bash
shopt -s extglob

is_valid_name() {
    if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_[:space:]]*$ ]]; then
        echo "$1" | tr -s ' ' '_'
    else
        echo "1"
    fi
}

sanitize_name() {
    echo "$1" | tr -d '[:space:]'
}
# sanitize_name() {
#     echo "$1" | tr -cd '[:alnum:]_'
# }

dir_exists() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

is_integer() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

is_float() {
    if [[ "$1" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

is_string() {
    if [[ "$1" =~ ^[a-zA-Z0-9_[:space:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Validate if the input matches a specified type (int, float, string)
validate_value() {
    local value=$1
    local type=$2

    case $type in
    int)
        is_integer "$value"
        return $?
        ;;
    float)
        is_float "$value"
        return $?
        ;;
    string)
        is_string "$value"
        return $?
        ;;
    *)
        return 1
        ;;
    esac
}

# Validate column types (for use in create_table and insert_into_table)
validate_column_type() {
    local column_type=$1
    case $column_type in
    int | float | string)
        return 0
        ;;
    *)
        return 1
        ;;
    esac
}

# alaa function
check_name() {
    case $1 in
    [a-zA-Z_]*([a-zA-Z0-9_[:space:]]))
        # result=$(tr -s ' ' '_' <<< "$1")
        echo "$1" | tr -s ' ' '_'
        # echo $result
        ;;
    *)
        echo "1"
        ;;
    esac
}
check_dataType() {
    case $1 in
    [iI][nN][tT] | [sS][tT][rR][iI][nN][gG])
        echo "-1"
        ;;
    *)
        echo "1"
        ;;
    esac
}
check_yesNo() {
    #y n
    case $1 in
    [yY] | [yY][eE][sS])
        echo "y"
        ;;
    [nN] | [nN][oO])
        echo "n"
        ;;
    *)
        echo "1"
        ;;
    esac
}
check_is_int() {
    case $1 in
    *[0-9])
        echo "-1"
        ;;
    *)
        echo "1"
        ;;
    esac

}

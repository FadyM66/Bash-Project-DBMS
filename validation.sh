#!/bin/bash

# Utility function to check for valid names
is_valid_name() {
    if [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Utility function to sanitize names
sanitize_name() {
    echo "$1" | tr -d '[:space:]'
}

# Utility function to check if a directory exists
dir_exists() {
    if [ -d "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Utility function to check if a file exists
file_exists() {
    if [ -f "$1" ]; then
        return 0
    else
        return 1
    fi
}

# Utility function to check if a value is an integer
is_integer() {
    if [[ "$1" =~ ^-?[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Utility function to check if a value is a float
is_float() {
    if [[ "$1" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Utility function to check if a value is a string
is_string() {
    if [[ "$1" =~ ^[a-zA-Z0-9_[:space:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}
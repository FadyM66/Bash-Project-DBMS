#!/bin/bash

is_valid_name() {
    if [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        return 1
    fi
}

sanitize_name() {
    echo "$1" | tr -d '[:space:]'
}

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
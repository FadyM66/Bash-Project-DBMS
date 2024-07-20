#!/bin/bash

list_databases() {
    databases=(*/)
    if [ ${#databases[@]} -eq 0 ]; then
        echo "No databases yet."
    else
        echo "Databases:"
        for db in "${databases[@]}"; do
            echo "${db%/}"
        done
    fi
}

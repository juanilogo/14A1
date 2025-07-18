#!/bin/bash

# Buscar el ejecutable llamado "main" (que tenga permisos de ejecución)
MAIN_PATH=$(find . -type f -name main -executable | head -n 1)

if [ -z "$MAIN_PATH" ]; then
    echo "Error: ejecutable 'main' no encontrado."
    exit 1
fi

"$MAIN_PATH" > output.txt

if grep -q "Hello, Embedded Linux World!" output.txt; then
    echo "Test passed."
    exit 0
else
    echo "Test failed."
    exit 1
fi

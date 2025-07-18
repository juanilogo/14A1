#!/bin/bash
../main > output.txt
if grep -q "Hello, Embedded Linux World!" output.txt; then
    echo "Test passed."
    exit 0
else
    echo "Test failed."
    exit 1
fi

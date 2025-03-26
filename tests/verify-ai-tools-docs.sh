#!/bin/bash

# Check if README.md exists
if [ ! -f "README.md" ]; then
    echo "README.md not found. Exiting..."
    exit 1
fi

# Check if Aider documentation exists
if ! grep -q "Aider" "README.md"; then
    echo "Aider documentation not found in README.md"
    exit 1
fi

# Check if Goose documentation exists
if ! grep -q "Goose" "README.md"; then
    echo "Goose documentation not found in README.md"
    exit 1
fi

# Check if Repomix documentation exists
if ! grep -q "Repomix" "README.md"; then
    echo "Repomix documentation not found in README.md"
    exit 1
fi

echo "AI tools documentation verification passed!"
exit 0

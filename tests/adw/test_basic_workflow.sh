#!/bin/bash

# Test script for basic_workflow
# Description: basic

set -e  # Exit on error

echo "Testing basic_workflow..."

# Navigate to target directory
cd "/Users/dylansheffer/Projects/dotfiles" || { echo "Failed to navigate to directory"; exit 1; }

# Run basic validation
echo "Running basic validation..."

# Add specific tests here based on workflow goals

if [ $? -eq 0 ]; then
    echo "✅ Test passed!"
    exit 0
else
    echo "❌ Test failed!"
    exit 1
fi

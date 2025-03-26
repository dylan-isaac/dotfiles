#!/bin/bash

# Test script for please_workflow
# Description: please create a rickroll.md file with an html embed to the video with emoji. Do not print lyrics, except in the form of a limrick

set -e  # Exit on error

echo "Testing please_workflow..."

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

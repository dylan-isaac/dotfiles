#!/bin/bash

# Test script for weather_readme_workflow
# Description: Tests the creation of a weather app README with specific requirements

set -e  # Exit on error

echo "Testing weather_readme_workflow..."

# Setup test environment
TEST_DIR="/tmp/test-workflow"
rm -rf "$TEST_DIR"  # Clean up any existing directory
mkdir -p "$TEST_DIR"
touch "$TEST_DIR/README.md"  # Create empty file

# Run the workflow
echo "Running workflow..."
if ! ai-workflow weather_readme_workflow; then
    echo "❌ Workflow failed"
    rm -rf "$TEST_DIR"  # Clean up
    exit 1
fi

# Verify results
echo "Verifying results..."
if [ ! -f "$TEST_DIR/README.md" ]; then
    echo "❌ README.md was not created"
    rm -rf "$TEST_DIR"  # Clean up
    exit 1
fi

# Check for required content
if ! grep -q "Weather App" "$TEST_DIR/README.md"; then
    echo "❌ README.md does not contain 'Weather App'"
    rm -rf "$TEST_DIR"  # Clean up
    exit 1
fi

if ! grep -q "🌤" "$TEST_DIR/README.md"; then
    echo "❌ README.md does not contain weather emoji"
    rm -rf "$TEST_DIR"  # Clean up
    exit 1
fi

if ! grep -q "\`" "$TEST_DIR/README.md"; then
    echo "❌ README.md does not contain code blocks"
    rm -rf "$TEST_DIR"  # Clean up
    exit 1
fi

# Cleanup
echo "Cleaning up..."
rm -rf "$TEST_DIR"

echo "✅ Test passed!"
exit 0 
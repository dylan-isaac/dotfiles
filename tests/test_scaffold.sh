#!/bin/bash

# Test script for scaffold.sh functionality
# ==========================================

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TEST_COUNT=0

# Helper functions
function log_info() {
  echo -e "${YELLOW}INFO:${NC} $1"
}

function log_success() {
  echo -e "${GREEN}✓ PASS:${NC} $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

function log_failure() {
  echo -e "${RED}✗ FAIL:${NC} $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

function log_warn() {
  echo -e "${YELLOW}WARN:${NC} $1"
}

function run_test() {
  TEST_COUNT=$((TEST_COUNT + 1))
  TEST_NAME=$1
  echo -e "\nTest $TEST_COUNT: $TEST_NAME"
  echo "-------------------------"
}

function cleanup() {
  log_info "Cleaning up test directories"
  if [ -d "$TEST_PATH" ]; then
    rm -rf "$TEST_PATH"
  fi
}

# Setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCAFFOLD_SCRIPT="$DOTFILES_ROOT/scripts/scaffold.sh"
TEST_PATH="/tmp/scaffold-test-$$"

# Ensure cleanup on exit
trap cleanup EXIT

# Begin tests
echo "=== Testing scaffold.sh ==="

# Test 1: Script exists and is executable
run_test "Script exists and is executable"
if [ -x "$SCAFFOLD_SCRIPT" ]; then
  log_success "scaffold.sh exists and is executable"
else
  log_failure "scaffold.sh does not exist or is not executable"
  exit 1
fi

# Test 1b: Symlink exists in PATH
run_test "Symlink exists in PATH"
if command -v scaffold &>/dev/null; then
  log_success "scaffold command is available in PATH"
else
  log_warn "scaffold command is not in PATH, using direct path instead"
fi

# Test 2: Missing type parameter
run_test "Missing type parameter"
OUTPUT=$("$SCAFFOLD_SCRIPT" --path "$TEST_PATH" 2>&1 || true)
if [[ "$OUTPUT" == *"Scaffold type is required"* ]]; then
  log_success "Correctly detected missing type parameter"
else
  log_failure "Failed to detect missing type parameter, output: $OUTPUT"
fi

# Test 3: Invalid type parameter
run_test "Invalid type parameter"
OUTPUT=$("$SCAFFOLD_SCRIPT" --type nonexistent --path "$TEST_PATH" 2>&1 || true)
if [[ "$OUTPUT" == *"Scaffold type 'nonexistent' not recognized"* ]]; then
  log_success "Correctly detected invalid type parameter"
else
  log_failure "Failed to detect invalid type parameter, output: $OUTPUT"
fi

# Test 4: MCP scaffold creation
run_test "MCP scaffold creation"
mkdir -p "$TEST_PATH"
"$SCAFFOLD_SCRIPT" --type mcp --path "$TEST_PATH" > /dev/null

# Verify files were created
if [ -d "$TEST_PATH/mcp-tool" ] && 
   [ -f "$TEST_PATH/mcp-tool/README.md" ] && 
   [ -f "$TEST_PATH/mcp-tool/.gitignore" ] && 
   [ -d "$TEST_PATH/mcp-tool/src" ] && 
   [ -d "$TEST_PATH/mcp-tool/tests" ] && 
   [ -f "$TEST_PATH/mcp-tool/src/main.py" ]; then
  log_success "MCP scaffold created successfully"
else
  log_failure "MCP scaffold creation failed"
  ls -la "$TEST_PATH"
fi

# Test 5: Custom path parameter works
run_test "Custom path parameter"
CUSTOM_PATH="/tmp/scaffold-custom-$$"
mkdir -p "$CUSTOM_PATH"

"$SCAFFOLD_SCRIPT" --type mcp --path "$CUSTOM_PATH" > /dev/null

if [ -d "$CUSTOM_PATH/mcp-tool" ]; then
  log_success "Custom path parameter works"
  rm -rf "$CUSTOM_PATH"
else
  log_failure "Custom path parameter doesn't work"
fi

# Summary
echo -e "\n=== Test Summary ==="
echo "Tests passed: $TESTS_PASSED/$TEST_COUNT"
echo "Tests failed: $TESTS_FAILED/$TEST_COUNT"

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed.${NC}"
  exit 1
fi 
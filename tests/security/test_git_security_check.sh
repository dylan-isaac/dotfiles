#!/bin/zsh

# Test script for git-security-check.sh
# Tests the ability to detect sensitive information in git changes

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Determine the base directory
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_DIR="$BASE_DIR/tests/security/temp_test_dir"
SCRIPT_PATH="$BASE_DIR/bin/git-security-check.sh"

echo "🧪 Testing git-security-check.sh"
echo "==============================="

# Make sure the script exists
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo -e "${RED}❌ Test FAILED: Script not found at $SCRIPT_PATH${NC}"
    exit 1
fi

# Make sure the script is executable
if [[ ! -x "$SCRIPT_PATH" ]]; then
    echo -e "${RED}❌ Test FAILED: Script is not executable${NC}"
    exit 1
fi

# Create a temporary test directory
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Initialize a test git repository
git init --quiet
# Configure git user for the test
git config user.email "test@example.com"
git config user.name "Test User"

# Create a clean file and commit it
echo "# Clean test file" > clean_file.txt
git add clean_file.txt
git commit -m "Initial commit" --quiet

# Test 1: Clean file should pass the check
echo "Test 1: Testing with clean file..."
$SCRIPT_PATH
TEST1_RESULT=$?
if [[ $TEST1_RESULT -eq 0 ]]; then
    echo -e "${GREEN}✅ Test 1 PASSED: Script correctly found no issues${NC}"
else
    echo -e "${RED}❌ Test 1 FAILED: Script reported issues in clean file${NC}"
    exit 1
fi

# Test 2: File with API key should be detected
echo "Test 2: Testing with sensitive API key..."
echo "const API_KEY='abcdef1234567890abcdef1234567890'" > sensitive_file.js
TEST2_OUTPUT=$($SCRIPT_PATH 2>&1)
TEST2_RESULT=$?
if [[ $TEST2_RESULT -eq 1 && "$TEST2_OUTPUT" == *"Potential sensitive information found"* ]]; then
    echo -e "${GREEN}✅ Test 2 PASSED: Script correctly detected API key${NC}"
else
    echo -e "${RED}❌ Test 2 FAILED: Script did not detect the API key${NC}"
    echo "$TEST2_OUTPUT"
    exit 1
fi

# Test 3: File with AWS key should be detected
echo "Test 3: Testing with AWS key..."
echo "const awsKey = 'AKIAIOSFODNN7EXAMPLE'" > aws_file.js
TEST3_OUTPUT=$($SCRIPT_PATH 2>&1)
TEST3_RESULT=$?
if [[ $TEST3_RESULT -eq 1 && "$TEST3_OUTPUT" == *"Potential sensitive information found"* ]]; then
    echo -e "${GREEN}✅ Test 3 PASSED: Script correctly detected AWS key${NC}"
else
    echo -e "${RED}❌ Test 3 FAILED: Script did not detect the AWS key${NC}"
    echo "$TEST3_OUTPUT"
    exit 1
fi

# Test 4: Placeholder values should be detected
echo "Test 4: Testing with placeholder values..."
echo "OPENAI_API_KEY=your_openai_api_key_here" > env_file
TEST4_OUTPUT=$($SCRIPT_PATH 2>&1)
TEST4_RESULT=$?
if [[ $TEST4_RESULT -eq 1 && "$TEST4_OUTPUT" == *"Potential sensitive information found"* ]]; then
    echo -e "${GREEN}✅ Test 4 PASSED: Script correctly detected placeholder${NC}"
else
    echo -e "${RED}❌ Test 4 FAILED: Script did not detect placeholder${NC}"
    echo "$TEST4_OUTPUT"
    exit 1
fi

# Test 5: False positives should be ignored
echo "Test 5: Testing false positive handling..."
echo "cask \"1password\" # Password manager" > brewfile
TEST5_OUTPUT=$($SCRIPT_PATH 2>&1)
TEST5_RESULT=$?
if [[ $TEST5_RESULT -eq 0 ]]; then
    echo -e "${GREEN}✅ Test 5 PASSED: Script correctly ignored false positive${NC}"
else
    echo -e "${RED}❌ Test 5 FAILED: Script detected false positive${NC}"
    echo "$TEST5_OUTPUT"
    exit 1
fi

# Clean up
cd "$BASE_DIR"
rm -rf "$TEST_DIR"

echo ""
echo -e "${GREEN}✅ All tests PASSED!${NC}"
exit 0 
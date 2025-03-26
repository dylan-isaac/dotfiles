#!/bin/bash

# ADW System Test
# This script tests the AI Developer Workflow system

DOTFILES_DIR="$HOME/Projects/dotfiles"
BIN_DIR="$DOTFILES_DIR/bin"
ADW_DIR="$DOTFILES_DIR/config/adw"
TEST_WORKFLOW_NAME="test_workflow"
TEST_WORKFLOW_FILE="$ADW_DIR/${TEST_WORKFLOW_NAME}.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "info") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "success") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "warn") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Cleanup function
cleanup() {
    log "info" "Cleaning up test files..."
    rm -f "$TEST_WORKFLOW_FILE"
}

# Register cleanup on script exit
trap cleanup EXIT

# Test 1: Check if director.py exists
test_director_exists() {
    log "info" "Testing if director.py exists..."
    if [ -f "$BIN_DIR/director.py" ]; then
        log "success" "✅ director.py exists"
        return 0
    else
        log "error" "❌ director.py does not exist"
        return 1
    fi
}

# Test 2: Check if ai-workflow wrapper exists
test_ai_workflow_exists() {
    log "info" "Testing if ai-workflow exists..."
    if [ -f "$BIN_DIR/ai-workflow" ]; then
        log "success" "✅ ai-workflow exists"
        return 0
    else
        log "error" "❌ ai-workflow does not exist"
        return 1
    fi
}

# Test 3: Check if we can create a workflow file
test_workflow_creation() {
    log "info" "Testing workflow creation..."
    
    # Create a simple test workflow file
    cat > "$TEST_WORKFLOW_FILE" << EOF
prompt: |
  This is a test workflow.
  It doesn't do anything, but tests if the system can read workflow files.
coder_model: "gpt-4o"
evaluator_model: "gpt-4o"
execution_command: "echo 'Test execution successful'"
context_editable: []
context_read_only: []
EOF
    
    if [ -f "$TEST_WORKFLOW_FILE" ]; then
        log "success" "✅ Test workflow created successfully"
        
        # Verify we can read the file with Python/YAML
        if python -c "import yaml; yaml.safe_load(open('$TEST_WORKFLOW_FILE'))" &>/dev/null; then
            log "success" "✅ Test workflow is valid YAML"
            return 0
        else
            log "error" "❌ Test workflow is not valid YAML"
            return 1
        fi
    else
        log "error" "❌ Failed to create test workflow"
        return 1
    fi
}

# Test 4: Check if run-repomix.sh exists
test_run_repomix_exists() {
    log "info" "Testing if run-repomix.sh exists..."
    if [ -f "$BIN_DIR/run-repomix.sh" ]; then
        log "success" "✅ run-repomix.sh exists"
        return 0
    else
        log "error" "❌ run-repomix.sh does not exist"
        return 1
    fi
}

# Test 5: Check if adw-create.py exists and can parse args
test_adw_create_exists() {
    log "info" "Testing if adw-create.py exists and parses args..."
    if [ -f "$BIN_DIR/adw-create.py" ]; then
        log "success" "✅ adw-create.py exists"
        
        # Test if it handles the --help flag
        if python "$BIN_DIR/adw-create.py" --help &>/dev/null; then
            log "success" "✅ adw-create.py parses arguments correctly"
            return 0
        else
            log "error" "❌ adw-create.py does not parse arguments correctly"
            return 1
        fi
    else
        log "error" "❌ adw-create.py does not exist"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    local failed=0
    
    test_director_exists || failed=$((failed+1))
    test_ai_workflow_exists || failed=$((failed+1))
    test_workflow_creation || failed=$((failed+1))
    test_run_repomix_exists || failed=$((failed+1))
    test_adw_create_exists || failed=$((failed+1))
    
    # Print summary
    echo ""
    echo "=========================================="
    echo "ADW SYSTEM TEST SUMMARY"
    echo "=========================================="
    
    if [ $failed -eq 0 ]; then
        log "success" "All ADW system tests passed!"
        return 0
    else
        log "error" "$failed test(s) failed"
        return 1
    fi
}

# Run all tests
run_all_tests
exit $? 
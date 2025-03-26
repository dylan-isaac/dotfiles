#!/bin/zsh

# Set script to exit on error
set -e

# Test runner for dotfiles system integrity
# =========================================
# This script runs tests to verify the dotfiles system is functioning correctly.

# Text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
CATEGORY="all"
VERBOSE=false
DOTFILES_DIR="$HOME/Projects/dotfiles"

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --category=*) CATEGORY="${1#*=}" ;;
        --verbose) VERBOSE=true ;;
        --help) 
            echo "Usage: ./run_tests.sh [options]"
            echo "Options:"
            echo "  --category=CATEGORY    Run tests for specific category (config, scripts, profiles, all)"
            echo "  --verbose              Show detailed test output"
            echo "  --help                 Show this help message"
            exit 0
            ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
    esac
    shift
done

# Log function with timestamps
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

# Test results tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    TESTS_RUN=$((TESTS_RUN+1))
    
    log "info" "Running test: $test_name"
    if $VERBOSE; then
        echo "----------------------------------------"
        echo "TEST: $test_name"
        echo "COMMAND: $test_cmd"
        echo "----------------------------------------"
    fi
    
    if eval "$test_cmd"; then
        TESTS_PASSED=$((TESTS_PASSED+1))
        log "success" "✅ PASSED: $test_name"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED+1))
        log "error" "❌ FAILED: $test_name"
        return 1
    fi
}

# Function to discover and run all tests in a directory
run_tests_in_dir() {
    local dir="$1"
    
    if [ ! -d "$dir" ]; then
        log "warn" "Test directory not found: $dir"
        return 0
    fi
    
    log "info" "Running tests in $dir"
    
    for test_file in "$dir"/*.sh; do
        if [ -f "$test_file" ] && [ "$test_file" != "$0" ]; then
            test_name=$(basename "$test_file" .sh)
            run_test "$test_name" "bash '$test_file'"
        fi
    done
}

# Configuration tests
run_config_tests() {
    log "info" "Running configuration tests..."
    
    # Test .zshrc syntax
    run_test "zshrc syntax" "zsh -n '$DOTFILES_DIR/config/.zshrc'"
    
    # Test .gitconfig syntax
    run_test "gitconfig syntax" "git config --file '$DOTFILES_DIR/config/.gitconfig' --list >/dev/null"
    
    # Test profile YAML files
    for profile_file in "$DOTFILES_DIR/config/profiles"/*.yaml; do
        if [ -f "$profile_file" ]; then
            profile_name=$(basename "$profile_file" .yaml)
            run_test "profile $profile_name syntax" "python -c \"import yaml; yaml.safe_load(open('$profile_file'))\" 2>/dev/null"
        fi
    done
    
    # Run additional config tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/config"
}

# Script tests
run_script_tests() {
    log "info" "Running script tests..."
    
    # Test install.sh syntax
    run_test "install.sh syntax" "zsh -n '$DOTFILES_DIR/install.sh'"
    
    # Test macos.sh syntax
    run_test "macos.sh syntax" "zsh -n '$DOTFILES_DIR/scripts/macos.sh'"
    
    # Run additional script tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/scripts"
}

# Profile tests
run_profile_tests() {
    log "info" "Running profile tests..."
    
    # Test profile generation script
    if [ -f "$DOTFILES_DIR/bin/generate_config.py" ]; then
        run_test "profile generator syntax" "python -m py_compile '$DOTFILES_DIR/bin/generate_config.py'"
        
        # Test profile list
        run_test "profile list" "python '$DOTFILES_DIR/bin/generate_config.py' --list 2>/dev/null"
    else
        log "warn" "Profile generator not found, skipping tests"
    fi
    
    # Run additional profile tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/profiles"
}

# AI workflow tests
run_ai_tests() {
    log "info" "Running AI workflow tests..."
    
    # Test director.py syntax if it exists
    if [ -f "$DOTFILES_DIR/bin/director.py" ]; then
        run_test "director.py syntax" "python -m py_compile '$DOTFILES_DIR/bin/director.py'"
    else
        log "warn" "Director script not found, skipping tests"
    fi
    
    # Run additional AI tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/ai"
}

# Main function to run all tests
main() {
    log "info" "Starting dotfiles system tests..."
    
    # Get total test count for progress tracking
    if [ "$CATEGORY" = "all" ]; then
        echo "Running all test categories"
        
        run_config_tests
        run_script_tests
        run_profile_tests
        run_ai_tests
    else
        case "$CATEGORY" in
            "config") run_config_tests ;;
            "scripts") run_script_tests ;;
            "profiles") run_profile_tests ;;
            "ai") run_ai_tests ;;
            *) log "error" "Unknown test category: $CATEGORY"; exit 1 ;;
        esac
    fi
    
    # Print test summary
    echo ""
    echo "=========================================="
    echo "TEST SUMMARY"
    echo "=========================================="
    echo "Total tests: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed: $TESTS_FAILED${NC}"
        exit 1
    else
        log "success" "All tests passed!"
        exit 0
    fi
}

# Run the main function
main 
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
        -h|--help)
            echo "Dotfiles Test Runner"
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -c, --category CATEGORY   Run tests in specific category"
            echo "                            (config, profile, scripts, ai, docs, security, browser)"
            echo "  -q, --quiet               Run with minimal output"
            echo "  -v, --verbose             Run with verbose output"
            echo "  --no-color                Disable colored output"
            echo "  -h, --help                Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                        Run all tests"
            echo "  $0 -c config              Run only config tests"
            echo "  $0 -c security -v         Run security tests with verbose output"
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
        log "info" "Extracting director.py from ADW.md..."
        if [ -f "$DOTFILES_DIR/contexts/ADW.md" ]; then
            # Extract director.py from ADW.md
            sed -n '/```python:director.py/,/```/p' "$DOTFILES_DIR/contexts/ADW.md" | sed '1d;$d' > "$DOTFILES_DIR/bin/director.py"
            chmod +x "$DOTFILES_DIR/bin/director.py"
            log "success" "Extracted director.py from ADW.md"
            run_test "director.py syntax" "python -m py_compile '$DOTFILES_DIR/bin/director.py'"
        else
            log "warn" "ADW.md not found, cannot extract director.py"
        fi
    fi
    
    # Test adw-create.py syntax
    if [ -f "$DOTFILES_DIR/bin/adw-create.py" ]; then
        run_test "adw-create.py syntax" "python -m py_compile '$DOTFILES_DIR/bin/adw-create.py'"
    else
        log "warn" "adw-create.py not found, skipping test"
    fi
    
    # Run ADW system test if it exists
    if [ -f "$DOTFILES_DIR/tests/adw/test_adw_system.sh" ]; then
        run_test "ADW system" "bash '$DOTFILES_DIR/tests/adw/test_adw_system.sh'"
    else
        log "warn" "ADW system test not found, skipping"
    fi
    
    # Run AI tools integration test
    if [ -f "$DOTFILES_DIR/tests/ai_tools_test.sh" ]; then
        run_test "AI tools integration" "bash '$DOTFILES_DIR/tests/ai_tools_test.sh'"
    else
        log "warn" "AI tools integration test not found, skipping"
    fi
    
    # Run additional AI tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/ai"
    run_tests_in_dir "$DOTFILES_DIR/tests/adw"
}

# Documentation tests
run_doc_tests() {
    log "info" "Running documentation tests..."
    
    # Test README existence
    run_test "main README exists" "[ -f '$DOTFILES_DIR/README.md' ]"
    
    # Test directory READMEs existence
    for dir in bin config contexts examples packages scripts tests; do
        if [ -d "$DOTFILES_DIR/$dir" ]; then
            run_test "$dir README exists" "[ -f '$DOTFILES_DIR/$dir/README.md' ]"
        fi
    done
    
    # Test README references
    run_test "READMEs cross-references" "grep -q 'README' '$DOTFILES_DIR/README.md'"
    
    # Test CHANGELOG exists
    run_test "CHANGELOG exists" "[ -f '$DOTFILES_DIR/CHANGELOG.md' ]"
    
    # Run additional documentation tests if they exist
    run_tests_in_dir "$DOTFILES_DIR/tests/docs"
}

# Function to run security tests
run_security_tests() {
    log_section "Security Tests"
    
    # Check if test directory exists
    if [ ! -d "$TEST_DIR/security" ]; then
        log_warn "Security tests directory not found. Skipping security tests."
        return 0
    fi
    
    # Run git security check test
    if [ -f "$TEST_DIR/security/test_git_security_check.sh" ]; then
        log_info "Running Git security check test..."
        $TEST_DIR/security/test_git_security_check.sh
        if [ $? -eq 0 ]; then
            log_success "Git security check test passed"
        else
            log_error "Git security check test failed"
            FAILED_TESTS=$((FAILED_TESTS+1))
        fi
    else
        log_warn "Git security check test not found"
    fi
    
    log_info "Security tests completed"
}

# Function to run browser tests
run_browser_tests() {
    log_section "Browser Integration Tests"
    
    # Check if test directory exists
    if [ ! -d "$TEST_DIR/browser" ]; then
        log_warn "Browser tests directory not found. Skipping browser tests."
        return 0
    fi
    
    # Run GitHub stars extension test
    if [ -f "$TEST_DIR/browser/test_github_stars.sh" ]; then
        log_info "Running GitHub Stars extension test..."
        $TEST_DIR/browser/test_github_stars.sh
        if [ $? -eq 0 ]; then
            log_success "GitHub Stars extension test passed"
        else
            log_error "GitHub Stars extension test failed"
            FAILED_TESTS=$((FAILED_TESTS+1))
        fi
    else
        log_warn "GitHub Stars extension test not found"
    fi
    
    log_info "Browser tests completed"
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
        run_doc_tests
        run_security_tests
        run_browser_tests
    else
        case "$CATEGORY" in
            "config") run_config_tests ;;
            "scripts") run_script_tests ;;
            "profiles") run_profile_tests ;;
            "ai") run_ai_tests ;;
            "docs") run_doc_tests ;;
            "security") run_security_tests ;;
            "browser") run_browser_tests ;;
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
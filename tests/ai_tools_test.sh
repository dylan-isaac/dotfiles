#!/bin/zsh

# AI Tools Integration Test Script
# This script runs automated tests for AI tools integration

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

# Test if the tools are available
test_tools_available() {
    log "info" "Testing if AI tools are available..."
    local all_available=true
    
    # Test aider
    if command -v aider &>/dev/null; then
        log "success" "✅ Aider is available: $(aider --version 2>/dev/null || echo 'unknown version')"
    else
        log "error" "❌ Aider is not available"
        all_available=false
    fi
    
    # Test goose
    if command -v goose &>/dev/null || [ -f "$HOME/.goose/bin/goose" ]; then
        log "success" "✅ Goose is available"
    else
        log "error" "❌ Goose is not available"
        all_available=false
    fi
    
    # Test repomix (could be through npx)
    if command -v repomix &>/dev/null || npm list -g repomix &>/dev/null; then
        log "success" "✅ Repomix is available"
    else
        log "error" "❌ Repomix is not available"
        all_available=false
    fi
    
    # Test ai-workflow
    if command -v ai-workflow &>/dev/null || [ -f "$DOTFILES_DIR/bin/ai-workflow" ]; then
        log "success" "✅ ai-workflow is available"
    else
        log "error" "❌ ai-workflow is not available"
        all_available=false
    fi
    
    # Test pai-workflow
    if command -v pai-workflow &>/dev/null || [ -f "$DOTFILES_DIR/bin/pai-workflow" ]; then
        log "success" "✅ pai-workflow is available"
    else
        log "error" "❌ pai-workflow is not available"
        all_available=false
    fi
    
    if $all_available; then
        return 0
    else
        return 1
    fi
}

# Test ai-workflow list functionality
test_ai_workflow_list() {
    log "info" "Testing ai-workflow --list functionality..."
    
    local ai_workflow_cmd="ai-workflow"
    if ! command -v ai-workflow &>/dev/null && [ -f "$DOTFILES_DIR/bin/ai-workflow" ]; then
        ai_workflow_cmd="$DOTFILES_DIR/bin/ai-workflow"
    fi
    
    local output=$($ai_workflow_cmd --list 2>/dev/null)
    
    if [[ "$output" == *"workflow"* || "$output" == *"Available workflows"* ]]; then
        log "success" "✅ ai-workflow --list shows workflows"
        return 0
    else
        log "error" "❌ ai-workflow --list does not show workflows or failed"
        log "error" "Output: $output"
        return 1
    fi
}

# Test pai-workflow list functionality
test_pai_workflow_list() {
    log "info" "Testing pai-workflow --list functionality..."
    
    local pai_workflow_cmd="pai-workflow"
    if ! command -v pai-workflow &>/dev/null && [ -f "$DOTFILES_DIR/bin/pai-workflow" ]; then
        pai_workflow_cmd="python $DOTFILES_DIR/bin/pai-workflow"
    fi
    
    local output=$($pai_workflow_cmd --list 2>/dev/null)
    
    if [[ "$output" == *"workflow"* || "$output" == *"Available workflows"* ]]; then
        log "success" "✅ pai-workflow --list shows workflows"
        return 0
    else
        log "error" "❌ pai-workflow --list does not show workflows or failed"
        log "error" "Output: $output"
        return 1
    fi
}

# Test repomix basic functionality
test_repomix_basic() {
    log "info" "Testing basic Repomix functionality..."
    
    # Create a temporary directory
    local temp_dir=$(mktemp -d)
    local output_file="$temp_dir/repo.md"
    
    # Run repomix with minimal example
    cd "$HOME/Projects/dotfiles"
    
    # Use npx if direct command not available
    if command -v repomix &>/dev/null; then
        repomix --include="README.md" --output="$output_file" &>/dev/null
    else
        npx repomix --include="README.md" --output="$output_file" &>/dev/null
    fi
    
    # Check if output file exists and has content
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        log "success" "✅ Repomix successfully created output file"
        rm -rf "$temp_dir"
        return 0
    else
        log "error" "❌ Repomix failed to create output file"
        rm -rf "$temp_dir"
        return 1
    fi
}

# Test MCP server status for Repomix
test_repomix_mcp_server() {
    log "info" "Testing Repomix MCP server status..."
    
    # Check if MCP server is running
    if pgrep -f "repomix --mcp" &>/dev/null; then
        log "success" "✅ Repomix MCP server is running"
        return 0
    else
        log "warn" "⚠️ Repomix MCP server is not running"
        log "info" "You can start it with: launchctl load ~/Library/LaunchAgents/com.repomix.mcp.plist"
        return 1
    fi
}

# Test error handling with invalid arguments
test_error_handling() {
    log "info" "Testing error handling with invalid arguments..."
    
    # Run ai-workflow with invalid flag
    output=$(ai-workflow --invalid-flag 2>&1)
    
    # Check if error message is helpful
    if echo "$output" | grep -q "Unknown parameter\|--help\|Usage"; then
        log "success" "✅ ai-workflow provides helpful error message for invalid flags"
        return 0
    else
        log "error" "❌ ai-workflow does not provide helpful error message"
        log "error" "Output: $output"
        return 1
    fi
}

# Test profile system
test_profile_system() {
    log "info" "Testing profile system..."
    
    # Get current profile
    current_profile=$(dotfiles-profile show 2>/dev/null | grep -o 'Current profile: .*' | cut -d' ' -f3)
    
    # List available profiles
    profiles=$(dotfiles-profile list 2>/dev/null)
    
    if [ -n "$current_profile" ] && [ -n "$profiles" ]; then
        log "success" "✅ Profile system is working. Current profile: $current_profile"
        log "info" "Available profiles: $profiles"
        return 0
    else
        log "error" "❌ Profile system test failed"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    local passed=0
    local failed=0
    
    # Run tests
    test_tools_available || failed=$((failed+1)) && passed=$((passed+1))
    test_ai_workflow_list || failed=$((failed+1)) && passed=$((passed+1))
    test_pai_workflow_list || failed=$((failed+1)) && passed=$((passed+1))
    test_repomix_basic || failed=$((failed+1)) && passed=$((passed+1))
    test_repomix_mcp_server || failed=$((failed+1)) && passed=$((passed+1))
    test_error_handling || failed=$((failed+1)) && passed=$((passed+1))
    test_profile_system || failed=$((failed+1)) && passed=$((passed+1))
    
    # Print summary
    echo "------------------------------------"
    echo "AI TOOLS TEST SUMMARY"
    echo "------------------------------------"
    log "info" "Tests passed: $passed"
    log "info" "Tests failed: $failed"
    
    if [ $failed -eq 0 ]; then
        log "success" "All tests passed!"
        return 0
    else
        log "error" "$failed test(s) failed"
        return 1
    fi
}

# Run all tests
run_all_tests
exit $? 
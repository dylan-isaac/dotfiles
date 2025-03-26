#!/bin/bash

# verify_features.sh
# Script to verify that features documented in READMEs are properly implemented

DOTFILES_DIR="$HOME/Projects/dotfiles"
REPORT_FILE="$DOTFILES_DIR/tests/feature_verification_report.md"

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

# Create report header
create_report_header() {
    log "info" "Creating feature verification report..."
    
    cat > "$REPORT_FILE" << EOF
# Feature Verification Report

Generated on: $(date)

This report compares documented features with actual implementation.

## Summary

EOF
}

# Verify profile system
verify_profile_system() {
    log "info" "Verifying profile system..."
    
    echo "### Profile System" >> "$REPORT_FILE"
    
    # Check if profile system is mentioned in README
    if grep -q "profile" "$DOTFILES_DIR/README.md"; then
        echo "✅ Profile system is documented in main README" >> "$REPORT_FILE"
    else
        echo "❌ Profile system is not documented in main README" >> "$REPORT_FILE"
    fi
    
    # Check if generate_config.py exists
    if [ -f "$DOTFILES_DIR/bin/generate_config.py" ]; then
        echo "✅ Profile generator script exists" >> "$REPORT_FILE"
        
        # Check if it can list profiles
        if python "$DOTFILES_DIR/bin/generate_config.py" --list &>/dev/null; then
            echo "✅ Profile generator can list profiles" >> "$REPORT_FILE"
        else
            echo "❌ Profile generator cannot list profiles" >> "$REPORT_FILE"
        fi
    else
        echo "❌ Profile generator script does not exist" >> "$REPORT_FILE"
    fi
}

# Verify AI workflow system
verify_ai_workflow() {
    log "info" "Verifying AI workflow system..."
    
    echo "### AI Workflow System" >> "$REPORT_FILE"
    
    # Check if AI workflow is mentioned in README
    if grep -q "ai-workflow" "$DOTFILES_DIR/README.md" || grep -q "ADW" "$DOTFILES_DIR/README.md"; then
        echo "✅ AI workflow is documented in main README" >> "$REPORT_FILE"
    else
        echo "❌ AI workflow is not documented in main README" >> "$REPORT_FILE"
    fi
    
    # Check if director.py exists
    if [ -f "$DOTFILES_DIR/bin/director.py" ]; then
        echo "✅ AI workflow director script exists" >> "$REPORT_FILE"
    else
        echo "❌ AI workflow director script does not exist" >> "$REPORT_FILE"
    fi
    
    # Check if ai-workflow exists
    if [ -f "$DOTFILES_DIR/bin/ai-workflow" ]; then
        echo "✅ AI workflow wrapper script exists" >> "$REPORT_FILE"
    else
        echo "❌ AI workflow wrapper script does not exist" >> "$REPORT_FILE"
    fi
    
    # Check if ADW.md exists
    if [ -f "$DOTFILES_DIR/contexts/ADW.md" ]; then
        echo "✅ AI workflow documentation exists" >> "$REPORT_FILE"
    else
        echo "❌ AI workflow documentation does not exist" >> "$REPORT_FILE"
    fi
}

# Verify shell setup
verify_shell_setup() {
    log "info" "Verifying shell setup..."
    
    echo "### Shell Setup" >> "$REPORT_FILE"
    
    # Check if shell setup is mentioned in README
    if grep -q "shell" "$DOTFILES_DIR/README.md"; then
        echo "✅ Shell setup is documented in main README" >> "$REPORT_FILE"
    else
        echo "❌ Shell setup is not documented in main README" >> "$REPORT_FILE"
    fi
    
    # Check if .zshrc exists
    if [ -f "$DOTFILES_DIR/config/.zshrc" ]; then
        echo "✅ .zshrc configuration exists" >> "$REPORT_FILE"
    else
        echo "❌ .zshrc configuration does not exist" >> "$REPORT_FILE"
    fi
    
    # Check if modern CLI tools are mentioned in README and .zshrc
    if grep -q "eza" "$DOTFILES_DIR/README.md" && grep -q "eza" "$DOTFILES_DIR/config/.zshrc"; then
        echo "✅ Modern CLI tools are documented and implemented" >> "$REPORT_FILE"
    else
        echo "❌ Modern CLI tools are not fully documented or implemented" >> "$REPORT_FILE"
    fi
}

# Verify all documented features
verify_all_features() {
    create_report_header
    verify_profile_system
    verify_ai_workflow
    verify_shell_setup
    
    # Add final recommendations
    echo -e "\n## Recommendations\n" >> "$REPORT_FILE"
    echo "Based on the verification results, consider the following improvements:" >> "$REPORT_FILE"
    
    # If we found any missing features (look for ❌ marks)
    if grep -q "❌" "$REPORT_FILE"; then
        echo "1. Implement missing features or update documentation to reflect actual implementation" >> "$REPORT_FILE"
        echo "2. Run ADW workflow to update documentation based on changes" >> "$REPORT_FILE"
        echo "3. Update tests to ensure comprehensive coverage" >> "$REPORT_FILE"
    else
        echo "All documented features appear to be properly implemented!" >> "$REPORT_FILE"
    fi
    
    log "success" "Feature verification complete. Report generated at $REPORT_FILE"
}

# Run verification
verify_all_features

# Exit with success
exit 0 
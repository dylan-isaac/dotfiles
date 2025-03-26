#!/bin/zsh

# Git Security Check
# This script scans git changes for potential security issues
# such as hardcoded API keys, passwords, and other sensitive information.

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define base directory
DOTFILES_DIR="$HOME/Projects/dotfiles"

echo "🔒 Git Security Check"
echo "====================="
echo "Scanning for potential security issues in git changes..."

# Function to check for sensitive patterns in changes
check_for_sensitive_patterns() {
    local diff_content=$1
    local issue_found=false
    
    # Regular expressions for common sensitive information
    local patterns=(
        # API keys and tokens (variable assignments)
        "api[-_]?key[=\"':][A-Za-z0-9_\-]{20,}"
        "access[-_]?token[=\"':][A-Za-z0-9_\.\-]{20,}"
        "secret[-_]?key[=\"':][A-Za-z0-9_\.\-]{20,}"
        "auth[-_]?token[=\"':][A-Za-z0-9_\.\-]{20,}"
        
        # Passwords (avoid common false positives)
        "password[=\"':][A-Za-z0-9_\.\-\$]{8,}"
        
        # AWS specific
        "AKIA[0-9A-Z]{16}"
        
        # Private keys
        "BEGIN (\w+ )?PRIVATE KEY"
        
        # Environment placeholders that weren't properly filled
        "your_[a-z_]+_key_here"
        "your_[a-z_]+_token_here"
        "your_[a-z_]+_secret_here"
        "your_[a-z_]+_password_here"
    )
    
    # Define patterns to ignore (prevent false positives)
    local ignore_patterns=(
        "cask \"1password\""
        "name of 1password"
        "LastPass"
        "# Password"
        "# API key"
    )
    
    for pattern in "${patterns[@]}"; do
        local matches=$(echo "$diff_content" | grep -E "$pattern" || true)
        
        # Filter out ignored patterns
        if [[ -n "$matches" ]]; then
            for ignore_pattern in "${ignore_patterns[@]}"; do
                matches=$(echo "$matches" | grep -v "$ignore_pattern" || true)
            done
        fi
        
        if [[ -n "$matches" ]]; then
            issue_found=true
            echo -e "${RED}⚠️ Potential sensitive information found:${NC}"
            echo "$matches" | while read -r line; do
                # Show the line but mask the actual sensitive content
                masked=$(echo "$line" | sed -E "s/($pattern)/\1 [POTENTIALLY SENSITIVE]/")
                echo -e "  ${YELLOW}$masked${NC}"
            done
            echo ""
        fi
    done
    
    if [[ "$issue_found" == false ]]; then
        echo -e "${GREEN}✅ No obvious sensitive information detected${NC}"
    fi
    
    if [[ "$issue_found" == true ]]; then
        return 1
    else
        return 0
    fi
}

# Check unstaged changes
echo "🔎 Checking unstaged changes..."
unstaged_diff=$(git diff 2>/dev/null || echo "")
if [[ -n "$unstaged_diff" ]]; then
    check_for_sensitive_patterns "$unstaged_diff"
    unstaged_result=$?
else
    echo -e "${GREEN}✅ No unstaged changes to check${NC}"
    unstaged_result=0
fi

echo ""

# Check staged changes
echo "🔎 Checking staged changes..."
staged_diff=$(git diff --cached 2>/dev/null || echo "")
if [[ -n "$staged_diff" ]]; then
    check_for_sensitive_patterns "$staged_diff"
    staged_result=$?
else
    echo -e "${GREEN}✅ No staged changes to check${NC}"
    staged_result=0
fi

echo ""

# Check for unsynced commits
echo "🔎 Checking unsynced commits for sensitive data..."
unsynced_commits=$(git log --pretty=format:"%h %s" @{u}.. 2>/dev/null || echo "")
if [[ -n "$unsynced_commits" ]]; then
    echo "Found unsynced commits:"
    echo "$unsynced_commits"
    
    # Check content of unsynced commits
    unsynced_diff=$(git diff @{u}.. 2>/dev/null || echo "")
    check_for_sensitive_patterns "$unsynced_diff"
    unsynced_result=$?
else
    echo -e "${GREEN}✅ No unsynced commits to check${NC}"
    unsynced_result=0
fi

echo ""
echo "🔒 Git Security Check Complete"

# Return overall status
if [[ $unstaged_result -eq 0 && $staged_result -eq 0 && $unsynced_result -eq 0 ]]; then
    echo -e "${GREEN}✅ No security issues detected${NC}"
    exit 0
else
    echo -e "${RED}⚠️ Potential security issues detected. Please review and fix before committing/pushing.${NC}"
    exit 1
fi 
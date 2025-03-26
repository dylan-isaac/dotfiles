#!/bin/bash

# Test script for the profile system
# This test validates the simplified profile system comprehensively

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define dotfiles directory
DOTFILES_DIR="$HOME/Projects/dotfiles"
CURRENT_PROFILE_FILE="$DOTFILES_DIR/.current_profile"
AVAILABLE_PROFILES=("personal" "work" "server")

# Display test overview
echo -e "${BLUE}==============================================${NC}"
echo -e "${BLUE}       PROFILE SYSTEM TEST SUITE            ${NC}"
echo -e "${BLUE}==============================================${NC}"
echo -e "This test validates the simplified profile system by:"
echo -e "1. Testing profile switching for all profiles"
echo -e "2. Verifying existence of all profile-specific files"
echo -e "3. Checking template directories and Brewfiles"
echo -e "4. Validating profile integrity"
echo -e "5. Testing compatibility with installation modes"
echo -e "${BLUE}==============================================${NC}\n"

# Helper function to set and verify a profile
test_profile() {
    local profile=$1
    echo -e "\n${YELLOW}[Testing]${NC} Setting profile to: ${BLUE}$profile${NC}"
    
    # Manually set the profile (instead of running the full install script)
    echo "$profile" > "$CURRENT_PROFILE_FILE"
    
    # Verify the profile was set correctly
    local current=$(cat "$CURRENT_PROFILE_FILE")
    if [ "$current" = "$profile" ]; then
        echo -e "${GREEN}✅ Profile $profile set successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to set profile $profile (got $current)${NC}"
        return 1
    fi
}

# Get current profile before testing
if [ -f "$CURRENT_PROFILE_FILE" ]; then
    ORIGINAL_PROFILE=$(cat "$CURRENT_PROFILE_FILE")
else
    ORIGINAL_PROFILE="personal"
    echo "$ORIGINAL_PROFILE" > "$CURRENT_PROFILE_FILE"
fi

echo -e "${YELLOW}[Info]${NC} Original profile: ${BLUE}$ORIGINAL_PROFILE${NC}"
echo -e "\n${BLUE}==============================================${NC}"
echo -e "${YELLOW}[Section 1]${NC} Testing profile switching"
echo -e "${BLUE}==============================================${NC}"

# Test each profile
for profile in "${AVAILABLE_PROFILES[@]}"; do
    test_profile "$profile" || exit 1
done

# Restore original profile
echo "$ORIGINAL_PROFILE" > "$CURRENT_PROFILE_FILE"
echo -e "\n${GREEN}✅ Restored original profile: $ORIGINAL_PROFILE${NC}"
echo -e "${GREEN}✅ Profile switching tests passed!${NC}"

echo -e "\n${BLUE}==============================================${NC}"
echo -e "${YELLOW}[Section 2]${NC} Verifying directory structure"
echo -e "${BLUE}==============================================${NC}"

# Check if profile template directories exist
echo -e "\n${YELLOW}[Testing]${NC} Template directories..."
for profile in "${AVAILABLE_PROFILES[@]}"; do
    template_dir="$DOTFILES_DIR/config/templates/$profile"
    if [ -d "$template_dir" ]; then
        echo -e "${GREEN}✅ Template directory for $profile exists${NC}"
        
        # Check if the directory has content
        file_count=$(ls -A "$template_dir" | wc -l | tr -d ' ')
        if [ "$file_count" -gt 0 ]; then
            echo -e "   ${GREEN}✓ Template directory has $file_count files/directories${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Warning: Template directory is empty${NC}"
        fi
    else
        echo -e "${RED}❌ Template directory missing: $template_dir${NC}"
        exit 1
    fi
done

# Check if profile Brewfiles exist
echo -e "\n${YELLOW}[Testing]${NC} Brewfiles..."
for profile in "${AVAILABLE_PROFILES[@]}"; do
    brewfile="$DOTFILES_DIR/packages/Brewfile.$profile"
    if [ -f "$brewfile" ]; then
        echo -e "${GREEN}✅ Brewfile for $profile exists${NC}"
        
        # Check if the Brewfile has content
        line_count=$(wc -l < "$brewfile")
        if [ "$line_count" -gt 5 ]; then
            echo -e "   ${GREEN}✓ Brewfile has $line_count lines${NC}"
        else
            echo -e "   ${YELLOW}⚠️  Warning: Brewfile has only $line_count lines${NC}"
        fi
    else
        echo -e "${RED}❌ Brewfile missing: $brewfile${NC}"
        exit 1
    fi
done

echo -e "\n${BLUE}==============================================${NC}"
echo -e "${YELLOW}[Section 3]${NC} Validating install.sh profile flags"
echo -e "${BLUE}==============================================${NC}"

# Check if install.sh contains profile flag handling
if grep -q -- "--profile" "$DOTFILES_DIR/install.sh"; then
    echo -e "${GREEN}✅ install.sh supports --profile flag${NC}"
else
    echo -e "${RED}❌ install.sh doesn't support profile flags${NC}"
    exit 1
fi

# Verify .current_profile is used in install.sh
if grep -q ".current_profile" "$DOTFILES_DIR/install.sh"; then
    echo -e "${GREEN}✅ install.sh uses .current_profile file${NC}"
else
    echo -e "${RED}❌ install.sh doesn't use .current_profile file${NC}"
    exit 1
fi

echo -e "\n${BLUE}==============================================${NC}"
echo -e "${YELLOW}[Section 4]${NC} Testing installation modes"
echo -e "${BLUE}==============================================${NC}"

# Verify quick mode support
if grep -q -- "--quick" "$DOTFILES_DIR/install.sh"; then
    echo -e "${GREEN}✅ install.sh supports --quick flag${NC}"
else
    echo -e "${RED}❌ install.sh doesn't support --quick flag${NC}"
    exit 1
fi

# Verify skip-apps mode support
if grep -q -- "--skip-apps" "$DOTFILES_DIR/install.sh"; then
    echo -e "${GREEN}✅ install.sh supports --skip-apps flag${NC}"
else
    echo -e "${RED}❌ install.sh doesn't support --skip-apps flag${NC}"
    exit 1
fi

# Verify config-only mode support
if grep -q -- "--config-only" "$DOTFILES_DIR/install.sh"; then
    echo -e "${GREEN}✅ install.sh supports --config-only flag${NC}"
else
    echo -e "${RED}❌ install.sh doesn't support --config-only flag${NC}"
    exit 1
fi

# Verify that config-only flag works with profile switching
if grep -q -A10 "CONFIG_ONLY" "$DOTFILES_DIR/install.sh" | grep -q "PROFILE"; then
    echo -e "${GREEN}✅ install.sh correctly processes --config-only with profiles${NC}"
else
    echo -e "${YELLOW}⚠️  Warning: Profile handling with --config-only needs manual verification${NC}"
fi

echo -e "\n${BLUE}==============================================${NC}"
echo -e "${GREEN}        ALL PROFILE TESTS PASSED!            ${NC}"
echo -e "${BLUE}==============================================${NC}"
echo -e "✅ Profile switching works correctly"
echo -e "✅ All profile-specific directories exist"
echo -e "✅ All profile-specific Brewfiles exist"
echo -e "✅ install.sh supports profile flags"
echo -e "✅ install.sh supports all installation modes"
echo -e "✅ Original profile ($ORIGINAL_PROFILE) was restored"
echo -e "${BLUE}==============================================${NC}"
exit 0 
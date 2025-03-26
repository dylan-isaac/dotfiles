#!/bin/bash

# Test script for the profile system
# This test validates that the profile switching functionality works correctly

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define dotfiles directory
DOTFILES_DIR="$HOME/Projects/dotfiles"
GENERATE_CONFIG="$DOTFILES_DIR/bin/generate_config.py"

echo -e "${BLUE}Testing profile system...${NC}"

# Check if generate_config.py exists
if [ ! -f "$GENERATE_CONFIG" ]; then
    echo -e "${RED}Error: generate_config.py not found at $GENERATE_CONFIG${NC}"
    exit 1
fi

# List available profiles
echo -e "${BLUE}Listing available profiles...${NC}"
python "$GENERATE_CONFIG" --list

# Get current profile
CURRENT_PROFILE=$(cat "$DOTFILES_DIR/config/.current_profile" 2>/dev/null || echo "personal")
echo "Current profile: $CURRENT_PROFILE"

# Test switching to a different profile temporarily
TEST_PROFILE="work"
if [ "$CURRENT_PROFILE" = "work" ]; then
    TEST_PROFILE="personal"
fi

echo -e "${BLUE}Temporarily switching to $TEST_PROFILE profile...${NC}"
python "$GENERATE_CONFIG" --profile "$TEST_PROFILE" --apply

# Verify the switch happened
NEW_PROFILE=$(cat "$DOTFILES_DIR/config/.current_profile" 2>/dev/null || echo "")
if [ "$NEW_PROFILE" = "$TEST_PROFILE" ]; then
    echo -e "${GREEN}✅ Profile switch succeeded${NC}"
else
    echo -e "${RED}❌ Profile switch failed, expected $TEST_PROFILE but got $NEW_PROFILE${NC}"
    exit 1
fi

# Switch back to original profile
echo -e "${BLUE}Switching back to $CURRENT_PROFILE profile...${NC}"
python "$GENERATE_CONFIG" --profile "$CURRENT_PROFILE" --apply

# Verify the switch back happened
FINAL_PROFILE=$(cat "$DOTFILES_DIR/config/.current_profile" 2>/dev/null || echo "")
if [ "$FINAL_PROFILE" = "$CURRENT_PROFILE" ]; then
    echo -e "${GREEN}✅ Profile switch back succeeded${NC}"
else
    echo -e "${RED}❌ Profile switch back failed, expected $CURRENT_PROFILE but got $FINAL_PROFILE${NC}"
    exit 1
fi

echo -e "${GREEN}All profile system tests passed!${NC}"
exit 0 
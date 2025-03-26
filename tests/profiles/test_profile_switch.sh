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
PROFILE_SCRIPT="$DOTFILES_DIR/bin/dotfiles-profile"
CURRENT_PROFILE_FILE="$DOTFILES_DIR/config/.current_profile"

echo -e "${BLUE}Testing profile system...${NC}"

# Check if dotfiles-profile exists
if [ ! -f "$PROFILE_SCRIPT" ]; then
    echo -e "${RED}Error: dotfiles-profile not found at $PROFILE_SCRIPT${NC}"
    exit 1
fi

# List available profiles
echo -e "${BLUE}Listing available profiles...${NC}"
"$PROFILE_SCRIPT" list

# Get current profile
if [ -f "$CURRENT_PROFILE_FILE" ]; then
    CURRENT_PROFILE=$(cat "$CURRENT_PROFILE_FILE")
else
    CURRENT_PROFILE="personal"
    echo "$CURRENT_PROFILE" > "$CURRENT_PROFILE_FILE"
fi

echo "Current profile: $CURRENT_PROFILE"

# Test switching to a different profile temporarily
TEST_PROFILE="work"
if [ "$CURRENT_PROFILE" = "work" ]; then
    TEST_PROFILE="personal"
fi

echo -e "${BLUE}Temporarily switching to $TEST_PROFILE profile...${NC}"
"$PROFILE_SCRIPT" set "$TEST_PROFILE"

# Sleep to allow file changes to be written
sleep 1

# Verify the switch happened
if [ -f "$CURRENT_PROFILE_FILE" ]; then
    NEW_PROFILE=$(cat "$CURRENT_PROFILE_FILE")
else
    NEW_PROFILE=""
fi

if [ "$NEW_PROFILE" = "$TEST_PROFILE" ]; then
    echo -e "${GREEN}✅ Profile switch succeeded${NC}"
else
    echo -e "${RED}❌ Profile switch failed, expected $TEST_PROFILE but got $NEW_PROFILE${NC}"
    echo -e "${RED}File contents: $(cat "$CURRENT_PROFILE_FILE" 2>&1)${NC}"
    echo -e "${RED}File exists: $(test -f "$CURRENT_PROFILE_FILE" && echo "Yes" || echo "No")${NC}"
    exit 1
fi

# Switch back to original profile
echo -e "${BLUE}Switching back to $CURRENT_PROFILE profile...${NC}"
"$PROFILE_SCRIPT" set "$CURRENT_PROFILE"

# Sleep to allow file changes to be written
sleep 1

# Verify the switch back happened
if [ -f "$CURRENT_PROFILE_FILE" ]; then
    FINAL_PROFILE=$(cat "$CURRENT_PROFILE_FILE")
else
    FINAL_PROFILE=""
fi

if [ "$FINAL_PROFILE" = "$CURRENT_PROFILE" ]; then
    echo -e "${GREEN}✅ Profile switch back succeeded${NC}"
else
    echo -e "${RED}❌ Profile switch back failed, expected $CURRENT_PROFILE but got $FINAL_PROFILE${NC}"
    exit 1
fi

echo -e "${GREEN}All profile system tests passed!${NC}"
exit 0 
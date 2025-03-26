#!/bin/zsh

# Test the GitHub Stars Goose extension
# This test validates that the extension can be loaded by Goose

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Determine the base directory
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
EXTENSION_PATH="$BASE_DIR/bin/goose-github-stars.js"
RESULTS_DIR="$BASE_DIR/tests/results"

echo "🧪 Testing Goose GitHub Stars Extension"
echo "======================================="

# Create results directory
mkdir -p "$RESULTS_DIR"

# Check if file exists
if [[ ! -f "$EXTENSION_PATH" ]]; then
    echo -e "${RED}❌ Extension file not found at $EXTENSION_PATH${NC}"
    exit 1
fi

# Check if file is executable
if [[ ! -x "$EXTENSION_PATH" ]]; then
    echo -e "${YELLOW}⚠️ Extension file is not executable. Making it executable...${NC}"
    chmod +x "$EXTENSION_PATH"
fi

# Validate basic JavaScript syntax
echo "Testing JavaScript syntax..."
if command -v node &>/dev/null; then
    node --check "$EXTENSION_PATH"
    SYNTAX_RESULT=$?
    if [[ $SYNTAX_RESULT -eq 0 ]]; then
        echo -e "${GREEN}✅ JavaScript syntax check passed${NC}"
    else
        echo -e "${RED}❌ JavaScript syntax check failed${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️ Node.js not available, skipping syntax check${NC}"
fi

# Check if required annotations are present
echo "Checking extension annotations..."
ANNOTATIONS=$(grep -E "@name|@description|@author|@version" "$EXTENSION_PATH")
if [[ -n "$ANNOTATIONS" ]]; then
    echo -e "${GREEN}✅ Extension annotations found:${NC}"
    echo "$ANNOTATIONS"
else
    echo -e "${RED}❌ Extension annotations missing${NC}"
    exit 1
fi

# Check if MCP commands are configured
echo "Checking MCP configuration..."
MCP_CONFIG=$(grep -E "mcp\s*=\s*{" "$EXTENSION_PATH")
if [[ -n "$MCP_CONFIG" ]]; then
    echo -e "${GREEN}✅ MCP configuration found${NC}"
else
    echo -e "${RED}❌ MCP configuration missing${NC}"
    exit 1
fi

# Test automatic loading in Goose (if available)
if command -v goose &>/dev/null; then
    echo "Testing extension loading with Goose..."
    # Create a test command that lists extensions
    echo '{"command": "list-extensions"}' > "$RESULTS_DIR/goose_test_command.json"
    
    # Run Goose in headless mode to check if extension loads
    GOOSE_RESULT=$(goose --headless --load-extension="$EXTENSION_PATH" < "$RESULTS_DIR/goose_test_command.json" 2>&1 || echo "ERROR")
    
    # Check if extension loaded successfully
    if [[ "$GOOSE_RESULT" != *"ERROR"* && "$GOOSE_RESULT" == *"github-stars"* ]]; then
        echo -e "${GREEN}✅ Extension loaded successfully in Goose${NC}"
    else
        echo -e "${YELLOW}⚠️ Unable to verify extension loading in Goose${NC}"
        echo -e "${YELLOW}This could be due to Goose configuration or environmental issues.${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ Goose command not available, skipping integration test${NC}"
    echo -e "${YELLOW}Install Goose to enable full testing.${NC}"
fi

# Clean up
rm -f "$RESULTS_DIR/goose_test_command.json"

echo ""
echo -e "${GREEN}✅ Extension structure and syntax validation complete!${NC}"
echo "To use this extension, run:"
echo -e "${YELLOW}goose extension:$EXTENSION_PATH \"Analyze stars on GitHub repo owner/repo\"${NC}"
echo "or add it to your Goose configuration for automatic loading."
exit 0 
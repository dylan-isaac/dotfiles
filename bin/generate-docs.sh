#!/bin/zsh

# Generate Documentation using Repomix
# This script uses Repomix to create comprehensive documentation for dotfiles components

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
DOTFILES_DIR="$HOME/Projects/dotfiles"
TARGET_DIR=""
OUTPUT_FILE=""
TEMPLATE_FILE="$DOTFILES_DIR/config/repomix/doc_template.md"
MODEL="claude-3-opus-20240229"
USE_CLIPBOARD=false
INCLUDE_PATTERN=""
EXCLUDE_PATTERN="node_modules|.git|.venv|__pycache__|.DS_Store"

# Function to display usage
usage() {
  echo "Usage: generate-docs [OPTIONS] <target_directory>"
  echo ""
  echo "Generate comprehensive documentation for a dotfiles component using Repomix."
  echo ""
  echo "Options:"
  echo "  -o, --output FILE         Write output to specified file (default: README.md in target dir)"
  echo "  -t, --template FILE       Use specified template file"
  echo "  -m, --model MODEL         Use specified AI model (default: claude-3-opus-20240229)"
  echo "  -c, --clipboard           Copy result to clipboard instead of saving to file"
  echo "  -i, --include PATTERN     Only include files matching pattern"
  echo "  -e, --exclude PATTERN     Exclude files matching pattern"
  echo "  -h, --help                Display this help message"
  echo ""
  echo "Examples:"
  echo "  generate-docs bin                # Generate documentation for bin directory"
  echo "  generate-docs --output=docs.md config/profiles  # Save output to docs.md"
  echo "  generate-docs --clipboard tests  # Copy result to clipboard"
  exit 1
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -o=*|--output=*) OUTPUT_FILE="${1#*=}" ;;
    -o|--output) OUTPUT_FILE="$2"; shift ;;
    -t=*|--template=*) TEMPLATE_FILE="${1#*=}" ;;
    -t|--template) TEMPLATE_FILE="$2"; shift ;;
    -m=*|--model=*) MODEL="${1#*=}" ;;
    -m|--model) MODEL="$2"; shift ;;
    -c|--clipboard) USE_CLIPBOARD=true ;;
    -i=*|--include=*) INCLUDE_PATTERN="${1#*=}" ;;
    -i|--include) INCLUDE_PATTERN="$2"; shift ;;
    -e=*|--exclude=*) EXCLUDE_PATTERN="${1#*=}" ;;
    -e|--exclude) EXCLUDE_PATTERN="$2"; shift ;;
    -h|--help) usage ;;
    *) 
      if [[ -z "$TARGET_DIR" ]]; then
        TARGET_DIR="$1"
      else
        echo -e "${RED}Error: Unexpected argument: $1${NC}"
        usage
      fi
      ;;
  esac
  shift
done

# Check for required arguments
if [[ -z "$TARGET_DIR" ]]; then
  echo -e "${RED}Error: Target directory is required${NC}"
  usage
fi

# Resolve full path for target directory
if [[ "$TARGET_DIR" = /* ]]; then
  TARGET_PATH="$TARGET_DIR"
else
  TARGET_PATH="$DOTFILES_DIR/$TARGET_DIR"
fi

# Verify target directory exists
if [[ ! -d "$TARGET_PATH" ]]; then
  echo -e "${RED}Error: Target directory does not exist: $TARGET_PATH${NC}"
  exit 1
fi

# Set default output file if not specified
if [[ -z "$OUTPUT_FILE" && "$USE_CLIPBOARD" = false ]]; then
  OUTPUT_FILE="$TARGET_PATH/README.md"
  echo -e "${BLUE}Output will be written to: $OUTPUT_FILE${NC}"
fi

# Check if template file exists
if [[ ! -f "$TEMPLATE_FILE" ]]; then
  echo -e "${YELLOW}Warning: Template file does not exist: $TEMPLATE_FILE${NC}"
  echo -e "${YELLOW}Creating a default template...${NC}"
  
  # Create template directory if it doesn't exist
  mkdir -p "$(dirname "$TEMPLATE_FILE")"
  
  # Create a default template
  cat > "$TEMPLATE_FILE" << EOF
# {{dirname}} Documentation

## Overview

{{overview}}

## Directory Structure

\`\`\`
{{directory_structure}}
\`\`\`

## Key Components

{{components}}

## Usage Examples

{{examples}}

## Configuration

{{configuration}}

## Extending

{{extending}}
EOF

  echo -e "${GREEN}Created default template at: $TEMPLATE_FILE${NC}"
fi

# Prepare Repomix command
REPOMIX_CMD="npx repomix"

# Set up Repomix arguments
REPOMIX_ARGS=()
REPOMIX_ARGS+=("--root=$TARGET_PATH")

if [[ -n "$INCLUDE_PATTERN" ]]; then
  REPOMIX_ARGS+=("--include=$INCLUDE_PATTERN")
fi

if [[ -n "$EXCLUDE_PATTERN" ]]; then
  REPOMIX_ARGS+=("--exclude=$EXCLUDE_PATTERN")
fi

REPOMIX_ARGS+=("--model=$MODEL")
REPOMIX_ARGS+=("--output-format=markdown")

# Build the instruction for Repomix
INSTRUCTION="You are an expert documentation writer. Create comprehensive documentation for the ${TARGET_DIR} directory in a dotfiles system. Follow this template structure:\n\n$(cat "$TEMPLATE_FILE")\n\nMake the documentation helpful, accurate, and concise. Include examples of how to use the components."

echo -e "${BLUE}Generating documentation for: $TARGET_PATH${NC}"
echo -e "${BLUE}Using model: $MODEL${NC}"

# Run Repomix with the instruction
if [[ "$USE_CLIPBOARD" = true ]]; then
  echo -e "${BLUE}Generating documentation and copying to clipboard...${NC}"
  echo -e "$INSTRUCTION" | $REPOMIX_CMD "${REPOMIX_ARGS[@]}" | pbcopy
  echo -e "${GREEN}Documentation has been copied to clipboard!${NC}"
else
  echo -e "${BLUE}Generating documentation and saving to $OUTPUT_FILE...${NC}"
  mkdir -p "$(dirname "$OUTPUT_FILE")"
  echo -e "$INSTRUCTION" | $REPOMIX_CMD "${REPOMIX_ARGS[@]}" > "$OUTPUT_FILE"
  echo -e "${GREEN}Documentation has been saved to: $OUTPUT_FILE${NC}"
  echo -e "${BLUE}Preview the first few lines:${NC}"
  head -n 10 "$OUTPUT_FILE"
fi

echo -e "${GREEN}Done!${NC}" 
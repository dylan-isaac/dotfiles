#!/bin/bash

# run-repomix.sh
# Script to run repomix after ADW workflows and store the results

DOTFILES_DIR="$HOME/Projects/dotfiles"
REPOMIX_DIR="$DOTFILES_DIR/repomix"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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

# Parse command line arguments
WORKFLOW_NAME=""
OUTPUT_FILE=""
INCLUDE_DIRS=()
DOCS_TEMPLATE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --workflow=*) WORKFLOW_NAME="${1#*=}" ;;
        --output=*) OUTPUT_FILE="${1#*=}" ;;
        --include=*) INCLUDE_DIRS+=("${1#*=}") ;;
        --docs) DOCS_MODE=true ;;
        --template=*) DOCS_TEMPLATE="${1#*=}" ;;
        --help) 
            echo "Usage: ./run-repomix.sh [options]"
            echo "Options:"
            echo "  --workflow=NAME   Name of the ADW workflow that was run"
            echo "  --output=FILE     Output file for repomix content (default: auto-generated)"
            echo "  --include=DIR     Directory to include (can be specified multiple times)"
            echo "  --docs            Generate documentation instead of compact representation"
            echo "  --template=FILE   Custom documentation template for Repomix (requires --docs)"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
    esac
    shift
done

# Set default output file if not specified
if [ -z "$OUTPUT_FILE" ]; then
    if [ -n "$WORKFLOW_NAME" ]; then
        if [ "$DOCS_MODE" = true ]; then
            OUTPUT_FILE="$REPOMIX_DIR/${WORKFLOW_NAME}_docs.md"
        else
            OUTPUT_FILE="$REPOMIX_DIR/${WORKFLOW_NAME}_${TIMESTAMP}.md"
        fi
    else
        if [ "$DOCS_MODE" = true ]; then
            OUTPUT_FILE="$REPOMIX_DIR/repomix_docs.md"
        else
            OUTPUT_FILE="$REPOMIX_DIR/repomix_${TIMESTAMP}.md"
        fi
    fi
fi

# Create repomix directory if it doesn't exist
mkdir -p "$REPOMIX_DIR"

# Prepare include directories
INCLUDE_ARGS=""
if [ ${#INCLUDE_DIRS[@]} -eq 0 ]; then
    # Default directories to include if none specified
    INCLUDE_ARGS="--include=bin --include=config --include=contexts --include=scripts --include=tests"
else
    for dir in "${INCLUDE_DIRS[@]}"; do
        INCLUDE_ARGS="$INCLUDE_ARGS --include=$dir"
    done
fi

# Run repomix
if [ "$DOCS_MODE" = true ]; then
    log "info" "Generating documentation using Repomix..."
    log "info" "Output will be saved to: $OUTPUT_FILE"
    
    repomix_cmd="npx repomix $INCLUDE_ARGS --output=$OUTPUT_FILE --docs"
    if [ -n "$DOCS_TEMPLATE" ]; then
        repomix_cmd="$repomix_cmd --template=$DOCS_TEMPLATE"
    fi
else
    log "info" "Running repomix to create compact representation..."
    log "info" "Output will be saved to: $OUTPUT_FILE"
    
    repomix_cmd="npx repomix $INCLUDE_ARGS --output=$OUTPUT_FILE"
fi

log "info" "Executing: $repomix_cmd"

if eval "$repomix_cmd"; then
    if [ "$DOCS_MODE" = true ]; then
        log "success" "Documentation generated successfully and saved to $OUTPUT_FILE"
    else
        log "success" "Repomix completed successfully and saved output to $OUTPUT_FILE"
    fi
    
    # Get file size
    size=$(du -h "$OUTPUT_FILE" | cut -f1)
    log "info" "Generated file size: $size"
    
    # Add workflow info to output file
    if [ -n "$WORKFLOW_NAME" ]; then
        # Create temporary file
        temp_file=$(mktemp)
        
        # Add header with workflow info
        cat > "$temp_file" << EOF
# Repomix $(if [ "$DOCS_MODE" = true ]; then echo "Documentation"; else echo "Compact Representation"; fi)
- Generated after workflow: $WORKFLOW_NAME
- Timestamp: $(date)
- Size: $size

EOF
        
        # Append original content
        cat "$OUTPUT_FILE" >> "$temp_file"
        
        # Replace original file
        mv "$temp_file" "$OUTPUT_FILE"
        log "info" "Added workflow metadata to output file"
    fi
    
    exit 0
else
    if [ "$DOCS_MODE" = true ]; then
        log "error" "Documentation generation failed"
    else
        log "error" "Repomix failed to run"
    fi
    exit 1
fi

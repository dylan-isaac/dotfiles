#!/bin/bash

set -e

# Default values
TYPE=""
PROJECT_PATH="$HOME/Projects"

# Usage instruction
function usage() {
  echo "Usage: scaffold --type <type> [--path <path>]"
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --type) TYPE="$2"; shift ;;
    --path) PROJECT_PATH="$2"; shift ;;
    *) usage; exit 1 ;;
  esac
  shift

done

# Check if TYPE is provided
if [ -z "$TYPE" ]; then
  echo "Scaffold type is required."
  usage
  exit 1
fi

# Get the real path of the script, resolving symlinks
SCRIPT_PATH="$0"
if [ -L "$SCRIPT_PATH" ]; then
  # It's a symlink, resolve it
  SCRIPT_PATH=$(readlink "$SCRIPT_PATH")
fi

# Get the directory of the real script
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

# If it's a relative path, make it absolute
if [[ "$SCRIPT_DIR" != /* ]]; then
  SCRIPT_DIR="$(pwd)/$SCRIPT_DIR"
fi

# If the script is in the bin directory, we need to find the scaffold-scripts in scripts directory
if [[ "$SCRIPT_DIR" == *"/bin" ]]; then
  # We're in the bin directory, the scaffold-scripts are in the parent directory's scripts/scaffold-scripts
  SCAFFOLD_SCRIPTS_DIR="$(dirname "$SCRIPT_DIR")/scripts/scaffold-scripts"
else
  # We're directly in the scripts directory
  SCAFFOLD_SCRIPTS_DIR="$SCRIPT_DIR/scaffold-scripts"
fi

# Find and Run the specific scaffold script
case "$TYPE" in
  mcp)
    "$SCAFFOLD_SCRIPTS_DIR/scaffold-mcp.sh" --path "$PROJECT_PATH"
    ;;
  *)
    echo "Scaffold type '$TYPE' not recognized."
    usage
    exit 1
    ;;
esac

echo "Scaffold for '$TYPE' created at '$PROJECT_PATH'." 
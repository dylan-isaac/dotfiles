#!/bin/bash

set -e

# Default path to create the project
PROJECT_PATH="$HOME/Projects"

# Usage instruction
function usage() {
  /bin/echo "Usage: scaffold-mcp [--path <path>]"
}

# Parse command-line arguments for path
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --path) PROJECT_PATH="$2"; shift ;;
    *) usage; exit 1 ;;
  esac
  shift
done

# Set up directories and files for MCP tool
TOOL_PATH="$PROJECT_PATH/mcp-tool"
/bin/mkdir -p "$TOOL_PATH/src" "$TOOL_PATH/tests"
/bin/echo "# MCP Tool" > "$TOOL_PATH/README.md"
/bin/echo "venv/" > "$TOOL_PATH/.gitignore"
/bin/cat <<EOF > "$TOOL_PATH/src/main.py"
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("MyTool")

@mcp.tool()
def example_tool(param: str) -> str:
    return f"Hello, {param}!"

if __name__ == "__main__":
    mcp.run()
EOF

/bin/echo "MCP tool scaffold created at '$TOOL_PATH'"

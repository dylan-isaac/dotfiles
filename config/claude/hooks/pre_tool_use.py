#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
PreToolUse hook - security guard for dangerous commands.
Exit code 2 blocks the command, 0 allows it.
"""

import json
import re
import sys
from datetime import datetime
from pathlib import Path


LOG_FILE = Path.home() / ".claude" / "logs" / "tool_use.jsonl"

# Patterns that should be blocked (exit code 2)
DANGEROUS_PATTERNS = [
    r"rm\s+(-[rf]+\s+)*/$",             # rm on root directory
    r"rm\s+-[rf]*r[rf]*\s+~",           # rm -r ~ (recursive on home)
    r"rm\s+-[rf]*r[rf]*\s+\$HOME",      # rm -r $HOME
    r"rm\s+-[rf]*r[rf]*\s+/Users/\w+/?$",  # rm -r /Users/name (entire home)
    r"rm\s+-rf\s+\*",                   # rm -rf *
    r"sudo\s+rm",                       # sudo rm anything
    r"chmod\s+777",                     # world-writable
    r">\s*/dev/sd",                     # write to disk devices
    r"mkfs\.",                          # format filesystem
    r"dd\s+if=.*of=/dev",               # dd to devices
]

# Patterns that should warn but allow (exit code 0 with message)
WARN_PATTERNS = [
    (r"rm\s+-rf", "Destructive rm -rf command - verify path is correct"),
    (r"git\s+push\s+.*--force", "Force push detected - this rewrites history"),
    (r"git\s+reset\s+--hard", "Hard reset - uncommitted changes will be lost"),
]


def log_tool_use(data: dict, decision: str, reason: str = "") -> None:
    """Log tool usage for audit."""
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": datetime.now().isoformat(),
        "tool": data.get("tool_name", "unknown"),
        "decision": decision,
        "reason": reason,
        "input": data.get("tool_input", {}),
    }
    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")


def check_bash_command(command: str) -> tuple[bool, str]:
    """
    Check if a bash command is dangerous.
    Returns (is_blocked, reason).
    """
    for pattern in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, f"Blocked: matches dangerous pattern '{pattern}'"

    for pattern, warning in WARN_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return False, warning

    return False, ""


def check_claude_json_read(file_path: str) -> str | None:
    """
    Check if reading ~/.claude.json and provide jq guidance.
    Returns guidance message or None.
    """
    claude_json = str(Path.home() / ".claude.json")
    if Path(file_path).resolve() == Path(claude_json).resolve():
        return """
~/.claude.json is too large to read directly. Use jq to query specific values:

  jq 'keys' ~/.claude.json                           # Top-level keys
  jq '.mcpServers' ~/.claude.json                    # Global MCP servers
  jq '.projects | keys[]' ~/.claude.json             # List project paths
  jq '.projects | length' ~/.claude.json             # Count projects
  jq '.projects["/path/to/project"]' ~/.claude.json  # Specific project settings

Common keys: mcpServers, projects, tipsHistory, userID, numStartups, autoUpdates
"""
    return None


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)  # Allow on parse error

    tool_name = data.get("tool_name", "")
    tool_input = data.get("tool_input", {})

    # Check for ~/.claude.json reads
    if tool_name == "Read":
        file_path = tool_input.get("file_path", "")
        guidance = check_claude_json_read(file_path)
        if guidance:
            log_tool_use(data, "blocked", "~/.claude.json - use jq instead")
            print(guidance, file=sys.stderr)
            sys.exit(2)
        sys.exit(0)

    # Only check Bash commands below this point
    if tool_name != "Bash":
        log_tool_use(data, "allowed", "Not a Bash command")
        sys.exit(0)

    command = tool_input.get("command", "")
    is_blocked, reason = check_bash_command(command)

    if is_blocked:
        log_tool_use(data, "blocked", reason)
        # Exit code 2 = blocking error, stderr goes to Claude
        print(reason, file=sys.stderr)
        sys.exit(2)

    if reason:  # Warning but allowed
        log_tool_use(data, "warned", reason)
        # Print warning as stdout (shown in verbose mode)
        print(json.dumps({"reason": reason}))

    log_tool_use(data, "allowed")
    sys.exit(0)


if __name__ == "__main__":
    main()

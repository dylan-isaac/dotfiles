#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
PostToolUse hook - logs all tool completions for audit/review.
"""

import json
import sys
from datetime import datetime
from pathlib import Path


LOG_FILE = Path.home() / ".claude" / "logs" / "tool_completions.jsonl"


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

    entry = {
        "timestamp": datetime.now().isoformat(),
        "tool": data.get("tool_name", "unknown"),
        "input": data.get("tool_input", {}),
        "output_preview": str(data.get("tool_output", ""))[:500],  # First 500 chars
    }

    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")

    sys.exit(0)


if __name__ == "__main__":
    main()

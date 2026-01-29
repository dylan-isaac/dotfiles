#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Minimal status line for Claude Code.
Shows: git branch | agent name | model | session info
"""

import json
import os
import subprocess
import sys
from pathlib import Path


def get_git_branch() -> str:
    """Get current git branch name."""
    try:
        result = subprocess.run(
            ["git", "branch", "--show-current"],
            capture_output=True,
            text=True,
            timeout=2,
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except Exception:
        pass
    return ""


def get_session_data(session_id: str) -> dict:
    """Load session data from Claude's session files."""
    if not session_id:
        return {}

    session_file = Path.home() / ".claude" / "data" / "sessions" / f"{session_id}.json"
    if session_file.exists():
        try:
            with open(session_file) as f:
                return json.load(f)
        except Exception:
            pass
    return {}


def get_token_usage_from_transcript(transcript_path: str) -> int:
    """Extract total token usage from transcript file."""
    if not transcript_path:
        return 0

    try:
        path = Path(transcript_path).expanduser()
        if not path.exists():
            return 0

        total_tokens = 0
        with open(path) as f:
            for line in f:
                try:
                    entry = json.loads(line.strip())
                    # Look for usage data - can be at top level or nested in message
                    usage = entry.get("usage", {})
                    if not usage:
                        usage = entry.get("message", {}).get("usage", {})

                    if usage:
                        # Context = input_tokens + cache tokens (what's in context window)
                        input_tokens = usage.get("input_tokens", 0)
                        cache_creation = usage.get("cache_creation_input_tokens", 0)
                        cache_read = usage.get("cache_read_input_tokens", 0)
                        # Total context is all input tokens
                        context = input_tokens + cache_creation + cache_read
                        if context > total_tokens:
                            total_tokens = context
                except json.JSONDecodeError:
                    continue

        return total_tokens
    except Exception:
        return 0


def get_compact_tracker(session_id: str) -> dict:
    """Load compaction tracker for this session."""
    if not session_id:
        return {"compact_count": 0, "total_tokens_before_compacts": 0}

    tracker_file = Path(f"/tmp/claude_compact_tracker_{session_id}.json")
    if tracker_file.exists():
        try:
            with open(tracker_file) as f:
                return json.load(f)
        except Exception:
            pass
    return {"compact_count": 0, "total_tokens_before_compacts": 0}


def get_context_percentage(data: dict) -> tuple[int, str, int, int]:
    """Calculate context window usage percentage.

    Returns: (percentage, context_str, compact_count, estimated_total_tokens)
    """
    # Try to get token count from transcript
    transcript_path = data.get("transcript_path", "")
    context_length = get_token_usage_from_transcript(transcript_path)

    # Fallback to context_length in data
    if not context_length:
        context_length = data.get("context_length", 0)

    # Get compaction data
    session_id = data.get("session_id", "")
    tracker = get_compact_tracker(session_id)
    compact_count = tracker.get("compact_count", 0)
    tokens_before_compacts = tracker.get("total_tokens_before_compacts", 0)

    # Estimated total = current window + what was lost to compactions
    # After compaction, context resets to ~10-20k (summary size)
    # So we estimate: tokens_before_compacts represents what was "spent"
    estimated_total = context_length + tokens_before_compacts

    if not context_length and not tokens_before_compacts:
        return 0, "", 0, 0

    # Context limits by model (tokens)
    # Opus 4.5 and Sonnet 4.5 have 200k context
    max_context = 200_000

    percentage = min(100, int((context_length / max_context) * 100)) if context_length else 0
    return percentage, f"{context_length // 1000}k/{max_context // 1000}k", compact_count, estimated_total


def format_status_line(data: dict) -> str:
    """Format the status line output."""
    parts = []

    # Context percentage (yellow/orange/red based on usage)
    pct, ctx_str, compact_count, estimated_total = get_context_percentage(data)
    if pct > 0 or compact_count > 0:
        if pct >= 80:
            color = "\033[91m"  # Red
        elif pct >= 60:
            color = "\033[33m"  # Yellow
        else:
            color = "\033[32m"  # Green

        # Build context display
        ctx_display = f"{color}📊 {pct}%"

        # Add compaction info if any compacts have occurred
        if compact_count > 0:
            # Show estimated total tokens and compact count
            est_k = estimated_total // 1000
            ctx_display += f" (~{est_k}k total, {compact_count}x 📦)"

        ctx_display += "\033[0m"
        parts.append(ctx_display)

    # Git branch (cyan)
    branch = get_git_branch()
    if branch:
        parts.append(f"\033[36m{branch}\033[0m")

    # Agent name (red) - from session data
    session_id = data.get("session_id", "")
    session_data = get_session_data(session_id)
    agent_name = session_data.get("agent_name", "")
    if agent_name:
        parts.append(f"\033[91m{agent_name}\033[0m")

    # Model (blue)
    model_data = data.get("model", {})
    if isinstance(model_data, dict):
        model = model_data.get("display_name", "") or model_data.get("id", "")
    else:
        model = str(model_data)
    if model:
        # Shorten model name
        short_model = model.replace("claude-", "").replace("Claude ", "").split("-202")[0]
        parts.append(f"\033[34m{short_model}\033[0m")

    # Cost (green) - if available
    cost_data = data.get("cost", {})
    total_cost = cost_data.get("total_cost_usd", 0)
    if total_cost > 0:
        parts.append(f"\033[32m${total_cost:.2f}\033[0m")

    # Session indicator with thread emoji - show full ID for --resume
    if session_id:
        parts.append(f"\033[90m🧵 {session_id}\033[0m")

    return " | ".join(parts) if parts else ""


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}

    status = format_status_line(data)
    if status:
        print(status)


if __name__ == "__main__":
    main()

#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
PreCompact hook: tracks compaction events and saves context before compaction.
Stores data in /tmp/claude_compact_tracker_{session_id}.json
"""

import json
import sys
from pathlib import Path


def get_token_usage_from_transcript(transcript_path: str) -> int:
    """Extract current max token usage from transcript file."""
    if not transcript_path:
        return 0

    try:
        path = Path(transcript_path).expanduser()
        if not path.exists():
            return 0

        max_tokens = 0
        with open(path) as f:
            for line in f:
                try:
                    entry = json.loads(line.strip())
                    usage = entry.get("usage", {})
                    if not usage:
                        usage = entry.get("message", {}).get("usage", {})

                    if usage:
                        input_tokens = usage.get("input_tokens", 0)
                        cache_creation = usage.get("cache_creation_input_tokens", 0)
                        cache_read = usage.get("cache_read_input_tokens", 0)
                        context = input_tokens + cache_creation + cache_read
                        if context > max_tokens:
                            max_tokens = context
                except json.JSONDecodeError:
                    continue

        return max_tokens
    except Exception:
        return 0


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return

    session_id = data.get("session_id", "unknown")
    transcript_path = data.get("transcript_path", "")
    trigger = data.get("trigger", "unknown")  # "auto" or "manual"

    # Get current token usage before compaction
    current_tokens = get_token_usage_from_transcript(transcript_path)

    # Load existing tracker or create new
    tracker_file = Path(f"/tmp/claude_compact_tracker_{session_id}.json")
    tracker = {"compact_count": 0, "total_tokens_before_compacts": 0, "compacts": []}

    if tracker_file.exists():
        try:
            with open(tracker_file) as f:
                tracker = json.load(f)
        except Exception:
            pass

    # Update tracker
    tracker["compact_count"] += 1
    tracker["total_tokens_before_compacts"] += current_tokens
    tracker["compacts"].append(
        {"trigger": trigger, "tokens_at_compact": current_tokens}
    )
    # Store current tokens as the baseline - after compaction, context resets to ~15%
    # We'll estimate post-compact size as ~30k tokens (summary size)
    tracker["last_compact_baseline"] = current_tokens

    # Save tracker
    with open(tracker_file, "w") as f:
        json.dump(tracker, f)

    # Output for logging (goes to stderr so it doesn't affect hook result)
    print(
        f"Compaction #{tracker['compact_count']} ({trigger}): {current_tokens:,} tokens",
        file=sys.stderr,
    )


if __name__ == "__main__":
    main()

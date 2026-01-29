#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["claude-agent-sdk", "anyio"]
# ///
"""
Stop hook - TTS announcement when Claude finishes.
Reads final message directly if short, summarizes with Haiku if long.
"""

import json
import subprocess
import sys
import anyio
from datetime import datetime
from pathlib import Path

from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock


LOG_FILE = Path.home() / ".claude" / "logs" / "stop.jsonl"
WORD_THRESHOLD = 100
FALLBACK_MESSAGE = "Hey Dylan, Claude has finished."


def speak(message: str, voice: str = "Samantha", rate: int = 225) -> None:
    """
    Use macOS say command for TTS.

    Runs in background so it doesn't block the hook timeout.
    User can interrupt with: pkill say
    """
    try:
        subprocess.Popen(
            ["say", "-v", voice, "-r", str(rate), message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except Exception:
        pass


def log_stop(data: dict, tts_message: str, method: str) -> None:
    """Append stop event to log file."""
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": datetime.now().isoformat(),
        "session_id": data.get("session_id", ""),
        "tts_message": tts_message,
        "method": method,  # "direct" or "summarized"
    }
    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")


def parse_transcript(transcript_path: str) -> tuple[str, str]:
    """
    Parse JSONL transcript to get last user message and last assistant message.
    Returns (user_message, assistant_message).
    """
    user_message = ""
    assistant_message = ""

    try:
        path = Path(transcript_path).expanduser()
        if not path.exists():
            return "", ""

        with open(path) as f:
            lines = f.readlines()

        # Parse each line as JSON and extract messages
        for line in reversed(lines):
            try:
                entry = json.loads(line.strip())

                # Handle different transcript formats
                msg_type = entry.get("type", "")
                role = entry.get("role", "")

                # Get assistant message
                if not assistant_message:
                    if msg_type == "assistant" or role == "assistant":
                        content = entry.get("message", {}).get("content", [])
                        if isinstance(content, list):
                            text_parts = []
                            for block in content:
                                if isinstance(block, dict) and block.get("type") == "text":
                                    text_parts.append(block.get("text", ""))
                            assistant_message = " ".join(text_parts)
                        elif isinstance(content, str):
                            assistant_message = content

                # Get user message
                if not user_message:
                    if msg_type == "human" or role == "user":
                        content = entry.get("message", {}).get("content", "")
                        if isinstance(content, str):
                            user_message = content
                        elif isinstance(content, list):
                            text_parts = []
                            for block in content:
                                if isinstance(block, dict) and block.get("type") == "text":
                                    text_parts.append(block.get("text", ""))
                            user_message = " ".join(text_parts)

                # Stop once we have both
                if user_message and assistant_message:
                    break

            except json.JSONDecodeError:
                continue

    except Exception:
        pass

    return user_message, assistant_message


def word_count(text: str) -> int:
    """Count words in text."""
    return len(text.split())


async def summarize_with_haiku(user_message: str, assistant_message: str) -> str:
    """Use Claude Haiku to generate a brief spoken summary."""

    prompt = f"""Summarize what Claude just completed in 1-2 sentences for a spoken notification.
Be specific about what was done. Address Dylan naturally.
No quotes, asterisks, or special characters.

IMPORTANT: If you don't have enough context, just respond with:
"Hey Dylan, Claude has finished."
Do not explain why you lack context.

User's request:
{user_message[:500] if user_message else "(not available)"}

Claude's response:
{assistant_message[:2000] if assistant_message else "(not available)"}

Just output the spoken message, nothing else."""

    options = ClaudeAgentOptions(
        model="haiku",
        max_turns=1,
        allowed_tools=[],
    )

    response_text = ""
    try:
        async for message in query(prompt=prompt, options=options):
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        response_text = block.text.strip()
                        break
    except Exception:
        response_text = FALLBACK_MESSAGE

    return response_text or FALLBACK_MESSAGE


async def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}

    transcript_path = data.get("transcript_path", "")

    # TTS disabled - skip all processing
    # Parse transcript to get messages
    # user_message, assistant_message = parse_transcript(transcript_path)

    # Determine method based on word count
    # words = word_count(assistant_message)

    # if not assistant_message:
    #     # No message found - use fallback
    #     tts_message = FALLBACK_MESSAGE
    #     method = "fallback"
    # elif words <= WORD_THRESHOLD:
    #     # Short enough to read directly
    #     tts_message = assistant_message
    #     method = "direct"
    # else:
    #     # Too long - summarize with Haiku
    #     tts_message = await summarize_with_haiku(user_message, assistant_message)
    #     method = "summarized"

    # Log and speak
    # log_stop(data, tts_message, method)
    # speak(tts_message)  # Commented out - disable TTS


if __name__ == "__main__":
    anyio.run(main)

#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["claude-agent-sdk", "anyio"]
# ///
"""
Notification hook - generates context-aware TTS using Claude Haiku.
Summarizes what Claude is doing and why it needs attention.
"""

import json
import subprocess
import sys
import anyio
from datetime import datetime
from pathlib import Path

from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock


LOG_FILE = Path.home() / ".claude" / "logs" / "notifications.jsonl"
SESSIONS_DIR = Path.home() / ".claude" / "data" / "sessions"


def speak(message: str, voice: str = "Samantha", rate: int = 225) -> None:
    """
    Use macOS say command for TTS.

    Runs in background so it doesn't block the hook timeout.
    User can interrupt with: pkill say
    """
    try:
        # Run detached so hook can exit while speech continues
        # Rate 200 is slightly faster than default (175-190) to avoid cutoff
        subprocess.Popen(
            ["say", "-v", voice, "-r", str(rate), message],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,  # Detach from parent process
        )
    except Exception:
        pass


def log_notification(data: dict, context: str, tts_message: str) -> None:
    """Append notification to log file."""
    LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
    entry = {
        "timestamp": datetime.now().isoformat(),
        "data": data,
        "context": context,
        "tts_message": tts_message,
    }
    with open(LOG_FILE, "a") as f:
        f.write(json.dumps(entry) + "\n")


def get_recent_session_context() -> str:
    """Try to get context from the most recent session file."""
    try:
        if not SESSIONS_DIR.exists():
            return ""

        # Find most recent session file
        session_files = list(SESSIONS_DIR.glob("*.json"))
        if not session_files:
            return ""

        latest = max(session_files, key=lambda f: f.stat().st_mtime)

        with open(latest) as f:
            session = json.load(f)

        # Extract recent context
        context_parts = []

        # Get recent prompts
        prompts = session.get("prompts", [])
        if prompts:
            recent_prompt = prompts[-1] if isinstance(prompts[-1], str) else str(prompts[-1])
            context_parts.append(f"Recent task: {recent_prompt[:200]}")

        # Get agent name if any
        agent = session.get("agent_name", "")
        if agent:
            context_parts.append(f"Agent: {agent}")

        return "; ".join(context_parts)
    except Exception:
        return ""


async def generate_tts_message(notification_data: dict, session_context: str) -> str:
    """Use Claude Haiku to generate a brief, context-aware notification."""

    # Build full context
    context_parts = []

    # Notification message
    msg = notification_data.get("message", "")
    if msg:
        context_parts.append(f"Notification: {msg}")

    # Tool requesting permission
    tool = notification_data.get("tool_name", "")
    tool_input = notification_data.get("tool_input", {})
    if tool:
        context_parts.append(f"Tool: {tool}")
        if isinstance(tool_input, dict):
            # Prefer description (human-readable) over raw command/path
            if "description" in tool_input:
                context_parts.append(f"Action: {tool_input['description']}")
            elif "command" in tool_input:
                context_parts.append(f"Command: {tool_input['command'][:100]}")
            elif "file_path" in tool_input:
                context_parts.append(f"File: {tool_input['file_path']}")

    # Session context
    if session_context:
        context_parts.append(session_context)

    full_context = "\n".join(context_parts) if context_parts else "Claude needs user input"

    prompt = f"""Generate a brief spoken notification (10-20 words) for Dylan about what Claude is doing.

Context:
{full_context}

Requirements:
- Summarize WHAT Claude is trying to do (not just "needs permission")
- Be specific about the action (e.g., "wants to run a git command" or "wants to edit the config file")
- Address Dylan naturally
- No quotes, asterisks, or special characters

IMPORTANT: If you don't have enough context, just respond with:
"Hey Dylan, Claude needs your attention."
Do not explain why you lack context.

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
    except Exception as e:
        # Fallback with basic context
        if tool:
            response_text = f"Hey Dylan, Claude wants to use {tool}"
        else:
            response_text = "Hey Dylan, Claude needs your attention"

    return response_text or "Hey Dylan, Claude needs your attention"


async def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        data = {}

    # TTS disabled - skip all processing
    # Get session context for richer notifications
    # session_context = get_recent_session_context()

    # Generate context-aware TTS message
    # tts_message = await generate_tts_message(data, session_context)

    # Log and speak
    # log_notification(data, session_context, tts_message)
    # speak(tts_message)  # Commented out - disable TTS


if __name__ == "__main__":
    anyio.run(main)

---
name: gobbler-claude
description: Interact with Claude.ai through browser automation. Use when user wants to "ask browser Claude", "query Claude.ai", "talk to my other Claude", or have agents communicate with Claude web instances.
---

# Claude.ai Integration

Query Claude.ai conversations directly from the command line. Send messages and receive responses from your browser-based Claude sessions.

## Quick Start

```bash
# List available Claude.ai tabs
gobbler claude list

# Send a query and get response
gobbler claude query "What have we been discussing?"

# Get the last response
gobbler claude last

# View chat history
gobbler claude history --count 10
```

## Prerequisites

Claude.ai integration requires:
1. **Relay server running** - bridges CLI to browser
2. **Gobbler browser extension** - installed and connected
3. **Claude.ai tab in "Gobbler" group** - conversation must be open and grouped

### Setup

```bash
# 1. Start the relay server
gobbler relay start

# 2. Verify connection
gobbler relay status
```

**Browser Setup:**
1. Open Claude.ai in your browser (claude.ai)
2. Open a new or existing conversation
3. Create a tab group named "Gobbler"
4. Move the Claude tab into that group
5. Verify with `gobbler claude list`

## Commands Reference

### `gobbler claude list`
List Claude.ai tabs in the Gobbler group.

```bash
gobbler claude list
```

### `gobbler claude info`
Get conversation metadata (messages, URL).

```bash
# Default (first Claude tab)
gobbler claude info

# Specific tab
gobbler claude info --tab 12345
```

### `gobbler claude query`
Send a message and wait for Claude's response.

```bash
# Basic query
gobbler claude query "Summarize our conversation so far"

# Specific conversation (by tab ID)
gobbler claude query "What was the main point we discussed?" --tab 12345

# Extended timeout for complex queries
gobbler claude query "Write a detailed analysis" --timeout 120
```

### `gobbler claude last`
Retrieve the last response (useful after long queries or timeouts).

```bash
gobbler claude last

# From specific tab
gobbler claude last --tab 12345
```

### `gobbler claude history`
Get recent chat messages.

```bash
# Last 5 messages (default)
gobbler claude history

# Last 10 messages
gobbler claude history --count 10

# All messages
gobbler claude history --all

# From specific tab
gobbler claude history --tab 12345 --count 20
```

## Use Cases

### Agent-to-Agent Communication
Have OpenCode or other CLI agents communicate with browser Claude:

```bash
# Ask browser Claude about context it has
gobbler claude query "What's top of mind based on our conversations?"

# Cross-reference information
gobbler claude query "What did we decide about the project architecture?"
```

### Conversation Continuity
Pick up where you left off:

```bash
# Check recent context
gobbler claude history --count 5

# Continue the thread
gobbler claude query "Let's continue from where we left off"
```

### Multi-Instance Collaboration
Work with multiple Claude conversations:

```bash
# List all Claude tabs
gobbler claude list

# Query specific conversation
gobbler claude query "Your question" --tab 12345

# Get history from another
gobbler claude history --tab 12346
```

## Workflow Example

**Asking browser Claude about recent topics:**

```bash
# 1. Ensure relay is running
gobbler relay start

# 2. In your browser:
#    - Open Claude.ai with an existing conversation
#    - Move tab to "Gobbler" group

# 3. Verify connection
gobbler claude list

# 4. Query the conversation
gobbler claude query "What have been the main topics we've discussed recently?"

# 5. Save the response
gobbler claude last > notes.md
```

## Timeouts

Complex queries may take longer. Default timeout is 60 seconds.

```bash
# For lengthy responses
gobbler claude query "Write a comprehensive summary" --timeout 120

# For quick questions
gobbler claude query "What was that link?" --timeout 30
```

## Multiple Conversations

If you have multiple Claude tabs open:

```bash
# List all conversations
gobbler claude list

# Query specific conversation by tab ID
gobbler claude query "Your question" --tab 12345
```

Without `--tab`, commands default to the first Claude tab found.

## Troubleshooting

### "Relay server is not running"

```bash
gobbler relay start
gobbler relay status
```

### "No browser extension connected"

1. Check Gobbler extension is installed
2. Refresh the extension (disable/re-enable)
3. Restart relay: `gobbler relay restart`

### "No Claude tabs found in Gobbler group"

1. Open Claude.ai in your browser
2. Right-click the tab -> "Add to group" -> "New group"
3. Name the group "Gobbler"
4. Verify: `gobbler claude list`

### "Could not find Claude input textarea"

The Claude UI may have changed, or the page hasn't fully loaded:
1. Ensure the conversation is fully loaded
2. Make sure you're on a chat page (not the home/new page without a conversation)
3. Try refreshing the Claude tab

### "Timeout waiting for response"

Claude is taking too long:
```bash
# Increase timeout
gobbler claude query "Your question" --timeout 120
```

Or check:
- Is Claude actually processing? (look at the browser tab)
- Network issues?
- Try a simpler query first

### Response is partial or cut off

The response may still be streaming:
```bash
# Wait and get the full response
sleep 10
gobbler claude last
```

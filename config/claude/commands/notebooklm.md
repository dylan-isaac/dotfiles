# NotebookLM Connection

Connect to NotebookLM via the Gobbler browser extension and interact with notebooks.

## Prerequisites Check

1. First, check if the Gobbler relay is running:
   ```bash
   curl -s http://localhost:4625/health
   ```

2. If the relay is NOT running (connection refused), start it:
   ```bash
   cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run src/gobbler_relay/relay.py --daemon
   ```

3. Verify browser extension connection:
   ```bash
   cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run skills/gobbler-browser/scripts/browser_api.py check
   ```

## List Available NotebookLM Tabs

Run this to see all NotebookLM tabs in the Gobbler tab group:
```bash
cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run skills/gobbler-browser/scripts/notebooklm.py list
```

## User Request

$ARGUMENTS

## Instructions for Queries

If the user wants to query a NotebookLM notebook:

1. Use the `query` command with an appropriate timeout (120-180 seconds for complex questions):
   ```bash
   cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run skills/gobbler-browser/scripts/notebooklm.py query --tab-id <TAB_ID> --timeout 180 "<QUESTION>"
   ```

2. If the response appears truncated, get the full response with:
   ```bash
   cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run skills/gobbler-browser/scripts/notebooklm.py last --tab-id <TAB_ID>
   ```

3. For guaranteed complete content, use history:
   ```bash
   cd /Users/dylanisaac/.claude/plugins/cache/gobbler-marketplace/gobbler/1.0.0 && uv run skills/gobbler-browser/scripts/notebooklm.py history --tab-id <TAB_ID>
   ```

## Available Commands Reference

| Command | Purpose |
|---------|---------|
| `list` | List NotebookLM tabs in Gobbler group |
| `info --tab-id <ID>` | Get notebook metadata |
| `query --tab-id <ID> "<question>"` | Ask a question |
| `last --tab-id <ID>` | Get last response (more reliable) |
| `history --tab-id <ID>` | Get full chat history |

## Response Handling

- Always use `--timeout 180` for complex queries
- If responses are cut off, follow up with the `last` command
- Report findings back to the user clearly

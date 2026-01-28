---
name: gobbler-notebooklm
description: Query Google NotebookLM notebooks through browser automation. Use when user wants to "ask NotebookLM", "query my notebook", "get insights from sources", or interact with their NotebookLM research.
---

# NotebookLM Integration

Query Google NotebookLM notebooks directly from the command line. Send questions and receive AI-synthesized responses based on your uploaded sources.

## Quick Start

```bash
# List available NotebookLM tabs
gobbler notebooklm list

# Send a query and get response
gobbler notebooklm query "What are the main themes in these documents?"

# Get the last response
gobbler notebooklm last

# View chat history
gobbler notebooklm history --count 10
```

## Prerequisites

NotebookLM integration requires:
1. **Relay server running** - bridges CLI to browser
2. **Gobbler browser extension** - installed and connected
3. **NotebookLM tab in "Gobbler" group** - notebook must be open and grouped

### Setup

```bash
# 1. Start the relay server
gobbler relay start

# 2. Verify connection
gobbler relay status
```

**Browser Setup:**
1. Open NotebookLM in your browser (notebooklm.google.com)
2. Open a notebook with your sources
3. Create a tab group named "Gobbler"
4. Move the NotebookLM tab into that group
5. Verify with `gobbler notebooklm list`

## Commands Reference

### `gobbler notebooklm list`
List NotebookLM tabs in the Gobbler group.

```bash
gobbler notebooklm list
```

### `gobbler notebooklm info`
Get notebook metadata (sources, messages, URL).

```bash
# Default (first NotebookLM tab)
gobbler notebooklm info

# Specific tab
gobbler notebooklm info --tab 12345
```

### `gobbler notebooklm query`
Send a question and wait for the AI response.

```bash
# Basic query
gobbler notebooklm query "Summarize the key findings"

# Specific notebook (by tab ID)
gobbler notebooklm query "What does the author say about X?" --tab 12345

# Extended timeout for complex queries
gobbler notebooklm query "Create a comprehensive outline" --timeout 120
```

### `gobbler notebooklm last`
Retrieve the last response (useful after long queries).

```bash
gobbler notebooklm last

# From specific tab
gobbler notebooklm last --tab 12345
```

### `gobbler notebooklm history`
Get recent chat messages.

```bash
# Last 5 messages (default)
gobbler notebooklm history

# Last 10 messages
gobbler notebooklm history --count 10

# All messages
gobbler notebooklm history --all

# From specific tab
gobbler notebooklm history --tab 12345 --count 20
```

## Use Cases

### Research Assistant
Query your uploaded papers, documents, or notes:

```bash
# Synthesize across sources
gobbler notebooklm query "What are the common themes across all documents?"

# Extract specific information
gobbler notebooklm query "What methodology did the authors use?"

# Generate summaries
gobbler notebooklm query "Create a one-paragraph summary of each source"
```

### Book Notes
For notebooks with book excerpts or full texts:

```bash
# Character analysis
gobbler notebooklm query "Describe the protagonist's character arc"

# Theme exploration
gobbler notebooklm query "What are the main themes and how do they develop?"

# Quote finding
gobbler notebooklm query "Find quotes about [topic]"
```

### Meeting Notes
For notebooks with meeting transcripts or notes:

```bash
# Action items
gobbler notebooklm query "List all action items and who is responsible"

# Decision summary
gobbler notebooklm query "What decisions were made in these meetings?"

# Topic extraction
gobbler notebooklm query "What topics were discussed most frequently?"
```

## Workflow Example

**Querying research sources:**

```bash
# 1. Ensure relay is running
gobbler relay start

# 2. In your browser:
#    - Open NotebookLM and your notebook
#    - Add sources (PDFs, docs, websites)
#    - Move tab to "Gobbler" group

# 3. Verify connection
gobbler notebooklm list

# 4. Query your sources
gobbler notebooklm query "What are the three most important insights from these sources?"

# 5. Save the response
gobbler notebooklm last > insights.md
```

## Timeouts

Complex queries may take longer. Default timeout is 60 seconds.

```bash
# For comprehensive analysis
gobbler notebooklm query "Create a detailed outline" --timeout 120

# For quick lookups
gobbler notebooklm query "When was X published?" --timeout 30
```

## Multiple Notebooks

If you have multiple NotebookLM tabs open:

```bash
# List all notebooks
gobbler notebooklm list

# Query specific notebook by tab ID
gobbler notebooklm query "Your question" --tab 12345
```

Without `--tab`, commands default to the first NotebookLM tab found.

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

### "No NotebookLM tabs found in Gobbler group"

1. Open NotebookLM in your browser
2. Right-click the tab -> "Add to group" -> "New group"
3. Name the group "Gobbler"
4. Verify: `gobbler notebooklm list`

### "Could not find NotebookLM input textarea"

The NotebookLM UI may have changed, or the page hasn't fully loaded:
1. Ensure the notebook is fully loaded
2. Make sure you're on a notebook page (not the home page)
3. Try refreshing the NotebookLM tab

### "Timeout waiting for response"

NotebookLM is taking too long:
```bash
# Increase timeout
gobbler notebooklm query "Your question" --timeout 120
```

Or check:
- Is NotebookLM actually processing? (look at the browser tab)
- Network issues?
- Try a simpler query first

### Response is partial or cut off

The response may still be streaming:
```bash
# Wait and get the full response
sleep 10
gobbler notebooklm last
```

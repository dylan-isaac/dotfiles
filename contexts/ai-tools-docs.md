# AI Tools Documentation

This document provides comprehensive documentation for the AI tools integrated in this dotfiles system: Aider, Goose, and Repomix. Each section covers installation, usage, and configuration specific to how these tools are used in this environment.

## Aider

[Aider](https://aider.chat/) is an AI pair programming tool that runs in your terminal. It allows you to have a conversation with AI models to edit code in your local git repository.

### Installation

Aider is automatically installed during the dotfiles setup process. The installation script uses Python's pip to install Aider:

```bash
# The dotfiles installer runs this automatically
python -m pip install aider-chat
```

You can verify your installation by running:

```bash
aider --version
```

### Usage

The basic usage of Aider involves starting a chat session in your project directory:

```bash
# Change to your project directory
cd /path/to/your/project

# Start Aider with your preferred model
aider --model sonnet  # For Claude Sonnet
aider --model gpt-4o  # For GPT-4o
```

#### Key Commands

- Add files to the chat session:
  ```bash
  aider file1.py file2.js
  ```

- In-chat commands:
  - `/add <file>` - Add a file to the chat
  - `/drop <file>` - Remove a file from the chat
  - `/help` - Show help information
  - `/run <command>` - Run a shell command
  - `/diff` - Show git diff of changes
  - `/commit` - Commit changes to git

#### Chat Modes

Aider supports different chat modes for different tasks:

- **Code Mode** (default): Edit and discuss your code
- **Architect Mode**: High-level system design and planning
- **Ask Mode**: Ask questions without editing files

Switch modes using:
```bash
aider --mode architect
```

### Configuration

Your Aider configuration is stored in:
- `~/.aider.conf.yml` (symlinked from `config/local/ai/aider.conf.yml`)
- `~/.env` (symlinked from `config/local/ai/.env`)

The key settings include:

```yaml
# Model aliases in aider.conf.yml
alias:
  - "fast:gpt-4o-mini"
  - "smart:gpt-4o"
  - "opus:claude-3-opus-20240229"
  - "sonnet:claude-3-sonnet-20240229"
```

```bash
# API keys in .env
OPENAI_API_KEY=your_key_here
ANTHROPIC_API_KEY=your_key_here

# Editor configuration
AIDER_EDITOR=cursor --wait
```

## Goose

[Goose](https://block.github.io/goose/) is an on-machine AI agent that automates engineering tasks. It can build projects, write and execute code, debug failures, and interact with external APIs - autonomously.

### Installation

Goose is automatically installed during the dotfiles setup process via a download script:

```bash
# The dotfiles installer runs this automatically
curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash
```

You can verify your installation by running:

```bash
goose --version
```

### Usage

The basic usage of Goose involves running a command with a natural language instruction:

```bash
# Run Goose with a task
goose "Create a simple React component that displays a counter"

# Run with a specific model
goose --model claude-3-opus-20240229 "Optimize this function for performance"
```

#### Common Options

- `--model <model>` - Specify the model to use
- `--provider <provider>` - Specify the provider (anthropic, openai, etc.)
- `--no-approve` - Run without asking for approval for actions
- `--headless` - Run in headless mode without UI
- `--save <name>` - Save conversation to a file
- `--load <name>` - Load a saved conversation

### Extensions

Goose is configured with several extensions in your dotfiles:

```yaml
# From config/goose/config.yaml
extensions:
  mcp-server-fetch:
    enabled: true
    # ...configuration...
  mcp-server-git:
    enabled: true
    # ...configuration...
  mcp-server-puppeteer:
    enabled: true
    # ...configuration...
  repomix:
    enabled: true
    # ...configuration...
  # ...other extensions...
```

**Note:** The documentation in your README incorrectly shows using `--load-extension`. The correct way to use extensions is through the configuration file or with the proper Goose commands.

### MCP Integration

Goose supports the Model Context Protocol (MCP), which allows it to delegate tasks to specialized servers. Your dotfiles configure multiple MCP servers, including:

- Git operations
- Web browsing (via Puppeteer)
- Repository analysis (via Repomix)
- Time-based operations

## Repomix

[Repomix](https://github.com/yamadashy/repomix) (formerly Repopack) is a tool that packs your entire repository into a single, AI-friendly file for use with LLMs.

### Installation

Repomix is installed globally with npm during the dotfiles setup:

```bash
# The dotfiles installer runs this automatically
npm install -g repomix
```

You can verify your installation by running:

```bash
repomix --version
```

### Usage

The basic usage involves running Repomix in your project directory:

```bash
# Run in your project directory
cd /path/to/your/project
repomix

# Generate output in a specific format
repomix --format=xml

# Include only specific files or directories
repomix --include="src/**/*.js"

# Exclude certain patterns
repomix --exclude="node_modules,dist"
```

Your dotfiles include a convenient alias for using Repomix:

```bash
# From config/.aliases
alias ai-context='run-repomix xml'
```

#### Key Options

- `--format=<format>` - Output format (markdown, xml, json)
- `--output=<file>` - Output file path
- `--include=<pattern>` - Glob patterns to include
- `--exclude=<pattern>` - Glob patterns to exclude
- `--compress` - Use code compression to reduce token count
- `--mcp` - Run as an MCP server (for integration with other tools)

### MCP Server

Repomix can run as an MCP server, which is configured in your dotfiles to start automatically at login. This allows other AI tools to analyze your code repositories on demand.

The MCP server configuration is in:
- `~/Library/LaunchAgents/com.repomix.mcp.plist`

Your dotfiles configure both Claude Desktop and VS Code (via Cline extension) to access the Repomix MCP server.

## Using AI Tools Together

The dotfiles system integrates these tools for a comprehensive AI development workflow:

1. Use **Aider** for interactive pair programming sessions
2. Use **Goose** for autonomous task execution
3. Use **Repomix** to provide codebase context to any LLM

Additionally, the [AI Developer Workflow (ADW)](ADW.md) system enables creating custom workflows that combine these tools for specific tasks. 
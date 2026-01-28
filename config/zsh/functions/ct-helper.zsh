#!/usr/bin/env zsh
# Claude Terminal Helper - Simple wrapper for Claude Code with custom contexts

# ============================================================================
# CONFIGURATION - Edit these paths and settings
# ============================================================================

# Common directories accessible to all helpers
CLAUDE_COMMON_DIRS=(
    "$HOME"
)

# MCP server configurations (space-separated list or JSON file path)
CLAUDE_MCP_SERVERS=""  # Example: "servers.json" or leave empty

# ============================================================================
# CT - General Terminal Helper
# ============================================================================

# Additional directories for ct
CT_ADDITIONAL_DIRS=(
    "$(pwd)"  # Current directory
)

# System prompt for ct
CT_SYSTEM_PROMPT='You are CT (Claude Terminal), a command-line assistant specifically configured to help with terminal and development tasks.

## Your Context
- You are running on a macOS system
- The user invoked you with the "ct" command from their terminal
- Current working directory: You have full access
- Home directory: You have full access (including .zshrc for PATH management)

## Your Capabilities
You have access to these tools:
- Bash: Execute shell commands
- Read/Write/Edit: File operations
- Grep/Glob: Search operations

## Expected Behavior
- Be concise and practical - focus on actionable solutions
- Assume the user wants quick terminal help
- Prefer showing commands they can run
- When modifying PATH or configs, explain what you are doing
- Remember this is a quick helper tool, not a long conversation

## User Preferences
- Use brew for package installations on macOS
- Prefer simple, direct solutions over complex ones'

# The ct function with model selection
ct() {
    local model="sonnet"  # Default model

    # Check for model flag
    if [[ "$1" == "-m" ]] || [[ "$1" == "--model" ]]; then
        shift
        case "$1" in
            s|sonnet)
                model="sonnet"
                ;;
            o|opus)
                model="opus"
                ;;
            h|haiku)
                model="haiku"
                ;;
            *)
                echo "Unknown model: $1 (use h/haiku, s/sonnet, o/opus)"
                return 1
                ;;
        esac
        shift
    fi

    local prompt="$*"

    # Show which model is being used
    echo "[CT using Claude $model]" >&2

    # Build the add-dir arguments
    local dir_args=()
    for dir in "${CLAUDE_COMMON_DIRS[@]}" "${CT_ADDITIONAL_DIRS[@]}"; do
        dir_args+=(--add-dir "$dir")
    done

    # Add MCP servers if configured
    local mcp_args=()
    if [[ -n "$CLAUDE_MCP_SERVERS" ]]; then
        mcp_args+=(--mcp-config "$CLAUDE_MCP_SERVERS")
    fi

    claude \
        --model "$model" \
        "${dir_args[@]}" \
        "${mcp_args[@]}" \
        --dangerously-skip-permissions \
        --allowedTools "Bash,Read,Edit,Write,Grep,Glob" \
        --append-system-prompt "$CT_SYSTEM_PROMPT" \
        "$prompt"
}

# ============================================================================
# CE - Enablement Engineering Assistant
# ============================================================================

# Directories for enablement engineering
CE_PROJECT_DIRS=(
    "/Users/dylanisaac/enablement-hub"
    "/Users/dylanisaac/Desktop/Enablement Engineering Inbox"
)

# System prompt for ce
CE_SYSTEM_PROMPT='You are CE (Claude Enablement), an engineering assistant specifically configured for Enablement Engineering tasks.

## Your Context
- You are running on a macOS system
- The user invoked you with the "ce" command for Enablement Engineering work
- Primary project: /Users/dylanisaac/enablement-hub
- Inbox folder: /Users/dylanisaac/Desktop/Enablement Engineering Inbox
- You have full access to these directories and the home directory

## Your Role
You are an Enablement Engineering assistant focused on:
- Building and maintaining enablement tools and systems
- Creating documentation and training materials
- Developing automation and workflows
- Managing the enablement-hub project
- Processing items from the Enablement Engineering Inbox

## Your Capabilities
You have access to these tools:
- Bash: Execute shell commands
- Read/Write/Edit: File operations
- Grep/Glob: Search operations

## Expected Behavior
- Focus on enablement engineering best practices
- Help organize and process inbox items efficiently
- Maintain clear documentation
- Suggest automation opportunities
- Be thorough but concise in explanations

## Project Context
- The enablement-hub is the main project repository
- The Inbox contains items to be processed, organized, or integrated
- Prioritize maintainability and scalability in solutions'

# The ce function - Enablement Engineering assistant
ce() {
    local model="opus"  # Default to opus for complex engineering tasks

    # Check for model flag (optional override)
    if [[ "$1" == "-m" ]] || [[ "$1" == "--model" ]]; then
        shift
        case "$1" in
            s|sonnet)
                model="sonnet"
                ;;
            o|opus)
                model="opus"
                ;;
            h|haiku)
                model="haiku"
                ;;
            *)
                echo "Unknown model: $1 (use h/haiku, s/sonnet, o/opus)"
                return 1
                ;;
        esac
        shift
    fi

    local prompt="$*"

    # Show which model is being used
    echo "[CE using Claude $model for Enablement Engineering]" >&2

    # Build the add-dir arguments
    local dir_args=()
    for dir in "${CLAUDE_COMMON_DIRS[@]}" "${CE_PROJECT_DIRS[@]}"; do
        dir_args+=(--add-dir "$dir")
    done

    # Add MCP servers if configured
    local mcp_args=()
    if [[ -n "$CLAUDE_MCP_SERVERS" ]]; then
        mcp_args+=(--mcp-config "$CLAUDE_MCP_SERVERS")
    fi

    # Set working directory to enablement-hub
    cd /Users/dylanisaac/enablement-hub

    claude \
        --model "$model" \
        "${dir_args[@]}" \
        "${mcp_args[@]}" \
        --dangerously-skip-permissions \
        --allowedTools "Bash,Read,Edit,Write,Grep,Glob" \
        --append-system-prompt "$CE_SYSTEM_PROMPT" \
        "$prompt"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Quick edit function to modify this file
ct-edit() {
    ${EDITOR:-nano} ~/.oh-my-zsh/custom/ct-helper.zsh
    source ~/.oh-my-zsh/custom/ct-helper.zsh
    echo "✓ ct and ce helpers reloaded"
}
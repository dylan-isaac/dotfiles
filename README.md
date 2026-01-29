# Dotfiles

Personal macOS configuration files and setup automation.

## Quick Setup

```bash
cd ~/dotfiles
./install.sh
```

## What's Included

- **Terminal**: Starship prompt, essential utilities
- **Shell**: Zsh with VI mode, custom functions
- **Tools**: fzf, eza, zoxide, atuin, carapace, ralphy
- **Apps**: Comprehensive Brewfile with all applications
- **Configs**: Ghostty, Git, Claude Code, OpenCode preferences

## Directory Structure

```
config/
├── zsh/           # Shell configuration
├── starship/      # Prompt configuration
├── ghostty/       # Terminal emulator
├── git/           # Git configuration
├── claude/        # Claude Code CLI configuration
│   ├── CLAUDE.md      # Global instructions
│   ├── settings.json  # Model, hooks, plugins config
│   ├── commands/      # Custom slash commands
│   ├── hooks/         # Python hooks (security, notifications, etc.)
│   ├── output-styles/ # Custom output styles
│   ├── status_lines/  # Status line script
│   └── scripts/       # Automation scripts
└── opencode/      # OpenCode AI tool configuration
    ├── opencode.json  # Global config (MCP servers, plugins)
    └── skills/        # Global skills (Anthropic Skills Spec)

scripts/
├── symlink.sh     # Create symlinks
└── macos.sh       # macOS system preferences

backup/            # Original config backups
```

## Manual Steps After Install

1. Set Ghostty as default terminal
2. Configure VI mode: `set -o vi` in shell
3. Import browser bookmarks and extensions
4. Set up SSH keys and Git credentials
5. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
6. Install Claude Code plugins from the marketplace (run `claude`, then install: `taches-cc-resources`, `context7`, `gobbler`, `ralph-wiggum`, `swift-lsp`)

## npm Global Packages

Installed automatically by `install.sh`:

- **`@anthropic-ai/claude-code`** - Anthropic's agentic CLI for Claude
- **`ralphy-cli`** - Autonomous AI coding loop (runs tasks from PRDs, YAML, JSON, or GitHub issues)

## Essential Commands

```bash
# Quick directory navigation
z project-name     # Jump to project (zoxide)

# Better file listing
eza --tree --git-ignore    # Tree view with git status

# Fuzzy search everything
fzf                # Interactive file finder
atuin search       # History search

# Claude helpers
ct help me with this command     # General terminal help
ce process inbox items          # Enablement engineering tasks
```

## Utilities Overview

- **fzf**: Fuzzy finder for files, history, processes
- **eza**: Modern ls replacement with colors and git status
- **zoxide**: Smart cd that learns your patterns
- **atuin**: Shell history with search and sync
- **carapace**: Advanced shell completions
- **starship**: Fast, customizable prompt

## OpenCode Configuration

OpenCode is configured via `~/.config/opencode/` which symlinks to this repo.

### Global Config (`config/opencode/opencode.json`)

- **Plugins**: `opencode-skills` for Anthropic Skills Specification support
- **MCP servers**: `todoist`, `google-calendar`
- **Tools enabled**: `todoist_*`, `google-calendar_*`

### Skills (`config/opencode/skills/`)

Global skills available in all projects. Create a subdirectory with `SKILL.md`:

```
skills/
└── my-skill/
    └── SKILL.md    # YAML frontmatter: name, description (20+ chars)
```

Skills are discovered in priority order (lowest to highest):
1. `~/.config/opencode/skills/` - Global (symlinked from dotfiles)
2. `.opencode/skills/` - Project-local (overrides global)

### Secrets

Keep these local (not in dotfiles):
- `~/.config/opencode/gcp-oauth.keys.json` - Google Calendar OAuth credentials

## Claude Code Configuration

Claude Code (`~/.claude/`) is configured via symlinks to `config/claude/`.

### What's Synced

| Path | Description |
|------|-------------|
| `CLAUDE.md` | Global instructions (package manager rules) |
| `settings.json` | Model, hooks, enabled plugins |
| `commands/` | Custom slash commands (`/notebooklm`) |
| `hooks/` | Python hooks (security guard, notifications, compaction tracker) |
| `output-styles/` | Output styles (concise, teaching, tts-summary) |
| `status_lines/` | Status line script (git branch, model, context %, cost) |
| `scripts/` | Automation scripts (Gobbler e2e tests) |

### Not Synced (local/runtime)

- `settings.local.json` - Machine-specific permissions (auto-generated as you grant permissions)
- `plugins/` - Plugin cache (auto-managed by marketplace)
- `cache/`, `logs/`, `history.jsonl`, etc. - Runtime data

### Manual Setup

1. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
2. Plugins must be installed from within Claude Code (not symlinked). Current plugins: `taches-cc-resources`, `context7`, `gobbler`, `ralph-wiggum`, `swift-lsp`
3. MCP servers are configured per-project in each project's `.claude/settings.json`

## Restoration

To restore this setup on a new machine:

1. Clone this repo to `~/dotfiles`
2. Run `./install.sh`
3. Restart terminal
4. Configure any manual steps above

Last updated: $(date)
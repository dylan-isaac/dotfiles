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
- **Tools**: fzf, eza, zoxide, atuin, carapace
- **Apps**: Comprehensive Brewfile with all applications
- **Configs**: Ghostty, Git, OpenCode preferences

## Directory Structure

```
config/
├── zsh/           # Shell configuration
├── starship/      # Prompt configuration
├── ghostty/       # Terminal emulator
├── git/           # Git configuration
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

## Restoration

To restore this setup on a new machine:

1. Clone this repo to `~/dotfiles`
2. Run `./install.sh`
3. Restart terminal
4. Configure any manual steps above

Last updated: $(date)
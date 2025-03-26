# Work Profile Goose Configuration

This directory contains the Goose configuration specific to the work environment profile.

## Overview

The work profile uses OpenAI as the AI provider instead of Anthropic, which is useful in work environments where Anthropic API access may not be available.

## Configuration Details

The key differences in this configuration compared to the default:

- `GOOSE_PROVIDER: openai` (default uses `anthropic`)
- `GOOSE_MODEL: gpt-4o` (default uses Claude models)

## Usage

When you install the dotfiles with the work profile, this configuration will automatically be symlinked to `~/.config/goose/config.yaml`:

```bash
# Full installation with work profile
./install.sh --profile=work

# Configuration-only update with work profile
./install.sh --config-only --profile=work
```

## Troubleshooting

If the work profile configuration isn't being applied correctly:

1. Check that the symlink is pointing to the correct file:
   ```bash
   ls -la ~/.config/goose/config.yaml
   ```
   
   It should point to: `~/Projects/dotfiles/config/templates/work/goose/config.yaml`

2. If not, you can manually update the symlink:
   ```bash
   ln -sf ~/Projects/dotfiles/config/templates/work/goose/config.yaml ~/.config/goose/config.yaml
   ```

3. Verify the configuration is correct:
   ```bash
   cat ~/.config/goose/config.yaml | grep -E "GOOSE_PROVIDER|GOOSE_MODEL"
   ```
   
   You should see `GOOSE_PROVIDER: openai` and `GOOSE_MODEL: gpt-4o` 
# Work Profile Templates

This directory contains configuration templates specific to the work environment profile.

## Purpose

The work profile is designed for professional setups without entertainment apps. It uses specific configurations that are appropriate for work environments, such as using OpenAI instead of Anthropic for AI tools.

## Contents

- **goose/**: Configuration files for the Goose AI agent
  - `config.yaml`: Uses OpenAI's GPT-4o model instead of Anthropic
- **zshrc.local.template**: Template for machine-specific Zsh configuration
- **.zshrc.local**: Additional Zsh configuration for work environments

## Usage

Apply the work profile using:

```bash
# Full installation with work profile
./install.sh --profile=work

# Configuration-only update with work profile
./install.sh --config-only --profile=work
```

## Customization

When customizing templates for your work environment:

1. Edit the files in this directory to match your work requirements
2. Run `./install.sh --config-only --profile=work` to apply changes
3. Changes only affect symlinked configuration files, not installed applications

## Goose Configuration

The work profile includes a special Goose configuration that uses OpenAI models instead of Anthropic. This is useful in work environments where Anthropic API access may not be available.

Key differences in the work profile Goose configuration:
- `GOOSE_PROVIDER: openai` instead of `anthropic`
- `GOOSE_MODEL: gpt-4o` instead of Claude models 
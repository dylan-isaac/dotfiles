# Goose Configuration

This directory contains configuration files for the [Goose](https://block.github.io/goose/) AI agent.

## Overview

Goose is an AI agent for software development that can be used from the command line. The configuration in this directory determines which AI provider (Anthropic or OpenAI) and model to use.

## Default Configuration

The default configuration (`config.yaml`) uses Anthropic as the AI provider, which is suitable for personal use.

## Profile-Specific Configuration

The dotfiles support different configurations for different environments (personal, work, server) through the profile system. Profile-specific Goose configurations are stored in:

```
config/templates/<profile>/goose/config.yaml
```

For example:
- Personal profile (default): Uses Anthropic models
- Work profile: Uses OpenAI models (useful in work environments where Anthropic access may not be available)

## Usage

When you install your dotfiles with a specific profile, the appropriate Goose configuration will be automatically symlinked:

```bash
# Install with the default personal profile
./install.sh

# Install with the work profile (uses OpenAI instead of Anthropic)
./install.sh --profile=work
```

You can also update just the configuration files without reinstalling everything:

```bash
# Update only the configuration files with the work profile
./install.sh --config-only --profile=work
```

## Creating Custom Profiles

To create a custom profile-specific Goose configuration:

1. Create a directory for your profile if it doesn't exist:
   ```bash
   mkdir -p config/templates/my-profile/goose
   ```

2. Copy and customize the Goose configuration:
   ```bash
   cp config/goose/config.yaml config/templates/my-profile/goose/config.yaml
   ```

3. Edit the configuration to use your preferred AI provider and model

4. Install with your custom profile:
   ```bash
   ./install.sh --profile=my-profile
   ``` 
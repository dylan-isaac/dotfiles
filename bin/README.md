# Scripts and Utilities

This directory contains executable scripts and utilities that enhance the dotfiles system with various functionality.

## Core Scripts

| Script | Description |
|--------|-------------|
| `ai-workflow` | Classic Director pattern for running AI Developer Workflows |
| `pai-workflow` | PydanticAI-based implementation for running structured AI workflows |
| `generate_config.py` | Profile system generator that applies configurations based on profiles |
| `director.py` | Implementation of the Director pattern for AI workflows |
| `install-analyzer.sh` | AI-powered installation analyzer and diagnostics tool |
| `brew-manager.sh` | Tool for managing Homebrew taps and packages |

## AI Tools

| Script | Description |
|--------|-------------|
| `run_adw.py` | Backend script for AI Developer Workflows |
| `adw-create.py` | Creates new ADW workflows from templates |
| `goose-github-stars.js` | Goose extension for analyzing GitHub repository stars |
| `run-repomix.sh` | Helper script for using Repomix with different options |

## Maintenance Tools

| Script | Description |
|--------|-------------|
| `generate-docs.sh` | Generates documentation for various components |
| `git-security-check.sh` | Checks for sensitive information in git repositories |
| `install-analyzer.sh` | AI-powered installation diagnostics and troubleshooting |

## Installation Analyzer

The Installation Analyzer is an AI-powered diagnostic tool that analyzes the output of the dotfiles installation process and provides remediation plans for any issues.

### Basic Usage

The simplest way to use the installation analyzer is to run it with default options:

```bash
./bin/install-analyzer.sh
```

This will:
1. Run the installation script with default settings
2. Capture all output to a log file
3. Use PydanticAI (default) to analyze the installation results
4. Display a detailed analysis with any issues found
5. Provide a remediation plan if issues are detected

### Options and Customization

You can customize the analyzer behavior with these options:

```bash
# Choose which AI engine to use
./bin/install-analyzer.sh --ai=goose     # Use Goose for analysis (requires Goose)
./bin/install-analyzer.sh --ai=pydantic  # Use PydanticAI (default option)

# See installation output in real-time
./bin/install-analyzer.sh --verbose

# Pass arguments to the installation script
./bin/install-analyzer.sh --profile=work --skip-apps
./bin/install-analyzer.sh --quick --verbose
```

### Understanding Results

The analyzer produces several important files:

1. **Installation Log**: Raw output from the installation process  
   Location: `/tmp/dotfiles-install-YYYYMMDD-HHMMSS/install.log`

2. **Analysis**: Structured analysis of installation issues  
   Location: `/tmp/dotfiles-install-YYYYMMDD-HHMMSS/analysis.md`

The analysis includes:
- Overall installation status (success, partial success, or failure)
- List of detected issues with severity levels
- Specific components that had problems
- Step-by-step remediation plan
- Verification steps to confirm fixes worked

### Testing the Analyzer

You can run a test of the analyzer without performing a real installation:

```bash
./tests/test_install_analyzer.sh
```

This creates a mock installation log with common issues and runs the analyzer on it to verify functionality.

### Troubleshooting

If the analyzer doesn't work as expected:

1. Make sure the AI engine you chose is installed and working
   - For Goose: Run `goose --version` to verify
   - For PydanticAI: Check that `./bin/pai-workflow --list` works

2. Check permissions: The script must be executable
   ```bash
   chmod +x ./bin/install-analyzer.sh
   ```

3. When using Goose, ensure Node.js is installed for the file reader extension

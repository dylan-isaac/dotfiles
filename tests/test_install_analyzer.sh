#!/bin/zsh

# Test script for install-analyzer.sh
# This script creates a mock installation log with common issues
# and then runs the install analyzer on it

# Set script to exit on error
set -e

# Text formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/Projects/dotfiles}"
TEMP_DIR="/tmp/dotfiles-install-test-$(date +%Y%m%d-%H%M%S)"
MOCK_LOG_FILE="${TEMP_DIR}/mock-install.log"
ANALYZER="${DOTFILES_DIR}/bin/install-analyzer.sh"

# Log function with timestamps
log() {
    local level="$1"
    local message="$2"
    
    case "$level" in
        "info") echo -e "${BLUE}[INFO]${NC} $message" ;;
        "success") echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        "warn") echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        "error") echo -e "${RED}[ERROR]${NC} $message" ;;
    esac
}

# Create mock installation log
create_mock_log() {
    log "info" "Creating mock installation log with common issues..."
    
    mkdir -p "$TEMP_DIR"
    
    # Create a realistic installation log with some intentional issues
    cat > "$MOCK_LOG_FILE" << EOF
[INFO] Starting dotfiles installation...
[INFO] Running in quick mode - will skip installations that are already complete
[INFO] Configuring for personal environment
[INFO] Backup directory created at /Users/user/.dotfiles.backup.20240326_123456
[INFO] Checking system requirements...
[SUCCESS] Command Line Tools are installed
[INFO] Setting up Homebrew...
[SUCCESS] Homebrew is already installed
[INFO] Updating Homebrew...
[WARN] Failed to update Homebrew, continuing anyway
[WARN] Homebrew has issues that may affect installation.
Warning: You have unlinked kegs in your Cellar.
Leaving kegs unlinked can lead to build-trouble and cause formulae to brew incorrectly.

  1password-cli
  uv
  python@3.11

Run \`brew link <formula>\` on these:
  1password-cli

[INFO] Found unlinked kegs: 1password-cli
[INFO] Attempting to link unlinked kegs automatically...
[INFO] Linking 1password-cli...
Error: Could not link 1password-cli.
Please can someone manually run: brew unlink 1password-cli; brew link 1password-cli

[WARN] Failed to link 1password-cli, continuing anyway
[INFO] Finished linking kegs
[INFO] Installing core development tools...
[SUCCESS] Git is already installed
[SUCCESS] Python is already installed: Python 3.11.5
[SUCCESS] pyenv is already installed
[SUCCESS] Core development tools installed successfully
[INFO] Setting up UV package manager...
[INFO] Installing UV via pip...
ERROR: Command errored out with exit status 1:
    command: /usr/local/bin/python3.11 -c 'import io, os, sys, setuptools, tokenize; sys.argv[0] = '"'"'/tmp/pip-install-3fy8eub9/uv_46e3a5c7a2dd4dd390e71350fa8c2db0/setup.py'"'"'; __file__='"'"'/tmp/pip-install-3fy8eub9/uv_46e3a5c7a2dd4dd390e71350fa8c2db0/setup.py'"'"';f = getattr(tokenize, '"'"'open'"'"', open)(__file__) if os.path.exists(__file__) else io.StringIO('"'"'from setuptools import setup; setup()'"'"');code = f.read().replace('"'"'\r\n'"'"', '"'"'\n'"'"');f.close();exec(compile(code, __file__, '"'"'exec'"'"'))' egg_info
        cwd: /tmp/pip-install-3fy8eub9/uv_46e3a5c7a2dd4dd390e71350fa8c2db0/
   Complete output (6 lines):
   Traceback (most recent call last):
     File "<string>", line 1, in <module>
     File "/tmp/pip-install-3fy8eub9/uv_46e3a5c7a2dd4dd390e71350fa8c2db0/setup.py", line 2, in <module>
       from setuptools_rust import RustExtension
   ModuleNotFoundError: No module named 'setuptools_rust'
   ----------------------------------------
ERROR: Command errored out with exit status 1: python setup.py egg_info Check the logs for full command output.

[WARN] Failed to install UV via pip, trying backup installation methods
[INFO] Trying Homebrew installation method for UV...
==> Downloading https://ghcr.io/v2/homebrew/core/uv/manifests/0.1.11
==> Fetching uv
==> Downloading https://ghcr.io/v2/homebrew/core/uv/blobs/sha256:d1a39f75f6b65a17bea89858a6c7bd6d17e7a3296ebff8fde9cc06dae7d51ef1
==> Pouring uv--0.1.11.arm64_sonoma.bottle.tar.gz
🍺  /opt/homebrew/Cellar/uv/0.1.11: 8 files, 36.2MB
[SUCCESS] UV installed successfully: uv 0.1.11
[INFO] Setting up shell environment...
[SUCCESS] Oh My Zsh is already installed
[INFO] Installing zsh-autosuggestions plugin...
fatal: destination path '/Users/user/.oh-my-zsh/custom/plugins/zsh-autosuggestions' already exists and is not an empty directory.
[WARN] Failed to install zsh-autosuggestions
[INFO] Setting up AI development tools...
[INFO] Installing Aider...
[WARN] Official Aider install script failed, trying alternative methods...
[INFO] Trying UV installation method...
[SUCCESS] Aider installed successfully
[INFO] Installing Goose...
Install Goose CLI (stable) using curl
Download URL: https://github.com/block/goose/releases/download/stable/goose-darwin-arm64
Error: Checksum verification failed!
Expected: 3ff8dec03f9f51b81a15821112312ada48ded64c0cb4c5a2dc1495c03f0f7fed
Actual: e897c2b4b5c7ebda1bb79f2ab5a33be5fcbc5a4f31b3e9e8b3e1f981ee7cbda1
[WARN] Goose installation via official script failed
[WARN] Goose installation may have failed. Please check manually.
[INFO] Setting up Repomix...
[INFO] Installing Repomix globally with NPM...
npm WARN deprecated string-similarity@4.0.4: Package no longer supported. Contact Support at https://www.npmjs.com/support for more info.
npm WARN deprecated semver-regex@4.0.5: Regular Expressions that use the global flag/g have a severe performance penalty
npm WARN deprecated request-promise-native@1.0.9: request-promise-native has been deprecated because it extends the now deprecated request package, see https://github.com/request/request/issues/3142
npm WARN deprecated har-validator@5.1.5: this library is no longer supported

added 351 packages, and audited 352 packages in 20s

15 packages are looking for funding
  run `npm fund` for details

10 vulnerabilities (5 moderate, 5 high)

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
[SUCCESS] Repomix installed successfully
[INFO] Setting up Repomix global configuration...
[INFO] No dependent packages found, untapping 1password/tap...
Error: Refusing to untap 1password/tap because the following formulae were installed from it:
1password-cli

If you want to untap anyway run:
  brew untap --force 1password/tap
  
[INFO] Successfully uninstalled packages and untapped 1password/tap
[INFO] Setting up Repomix MCP configuration...
[INFO] Setting up Repomix MCP for Cline (VS Code extension)...
[SUCCESS] Created Cline MCP configuration for Repomix
[INFO] Claude Desktop not found, skipping MCP configuration
[INFO] Setting up autostart for Repomix MCP server...
[INFO] Loading Repomix MCP LaunchAgent...
[WARN] Failed to load Repomix MCP LaunchAgent
[INFO] Setting up AI tool configuration files...
[INFO] Using personal environment configuration for AI tools
[INFO] Creating Aider configuration...
[SUCCESS] Created Aider configuration from template
[INFO] Creating Aider .env file...
[SUCCESS] Created Aider .env file from template
[INFO] Remember to update your API keys in config/local/.zshrc.local and config/local/ai/.env
[INFO] Linking configuration files...
[INFO] Using profile system to generate configurations...
[INFO] User 'personal' (Dylan Sheffer) with work=False
Couldn't find VS Code settings path: /Users/user/Library/Application Support/Code/User/settings.json
[INFO] Applied configuration profile: personal
[INFO] Setting up machine-specific configuration...
[INFO] Configuring for personal environment
[INFO] Created /Users/user/Projects/dotfiles/config/local/.zshrc.local - remember to add your API keys!
[INFO] Configuring macOS defaults...
[INFO] Setting macOS defaults...
[WARN] Failed to set some macOS defaults. This might require administrative privileges.
[INFO] Verifying installation...
[SUCCESS] brew is available: Homebrew 4.2.4
[SUCCESS] git is available: git version 2.43.0
[SUCCESS] python3 is available: Python 3.11.5
[SUCCESS] UV is available: uv 0.1.11
[INFO] Testing UV functionality...
[SUCCESS] UV can create virtual environments
[SUCCESS] aider is available
[WARN] goose not found in PATH. Check installation or restart your terminal
[SUCCESS] Repomix is available globally
[SUCCESS] Profile system is available
[INFO] Current profile: personal
[WARN] Found 1 issues with the installation
[INFO] You may need to restart your terminal or run 'source ~/.zshrc' to complete the setup
[SUCCESS] Installation complete!
[INFO] Configuration summary:
[INFO]   • Environment: Personal
[INFO]   • Profile: personal
[INFO]   • Quick mode: Enabled
[INFO]   • App installation: Skipped
[INFO]   • Backup directory: /Users/user/.dotfiles.backup.20240326_123456
[INFO] AI tools:
[SUCCESS]   • Aider: Installed and available (aider 0.33.0)
[WARN]   • Goose: Not installed or not found
[SUCCESS]   • Machine-specific: Created at /Users/user/Projects/dotfiles/config/local/.zshrc.local
[SUCCESS]   • Linked to: /Users/user/.zshrc.local
[INFO] Applying changes by sourcing ~/.zshrc...
[WARN] Not running in zsh. Please restart your terminal or run 'source ~/.zshrc' manually.
EOF
    
    log "success" "Created mock installation log with common issues"
}

# Run the install analyzer on the mock log
run_analyzer() {
    local ai_engine="$1"
    
    log "info" "Running install analyzer (using $ai_engine) on mock installation log..."
    
    # Modify the LOG_FILE variable in the analyzer script to use our mock log
    if [ ! -f "$ANALYZER" ]; then
        log "error" "Install analyzer script not found at $ANALYZER"
        exit 1
    fi
    
    # Create a temporary analyzer script with modified LOG_FILE
    cat "$ANALYZER" | sed "s|LOG_FILE=.*|LOG_FILE=\"$MOCK_LOG_FILE\"|" > "${TEMP_DIR}/install-analyzer-test.sh"
    chmod +x "${TEMP_DIR}/install-analyzer-test.sh"
    
    # Run the modified analyzer
    ${TEMP_DIR}/install-analyzer-test.sh --ai="$ai_engine"
}

# Main function
main() {
    log "info" "Starting install analyzer test..."
    
    # Create the mock installation log
    create_mock_log
    
    # Run the install analyzer with Goose
    if command -v goose &>/dev/null; then
        run_analyzer "goose"
    else
        log "warn" "Goose not found, skipping Goose test"
    fi
    
    # Run the install analyzer with PydanticAI
    if [ -f "${DOTFILES_DIR}/bin/pai-workflow" ]; then
        run_analyzer "pydantic"
    else
        log "warn" "PydanticAI not found, skipping PydanticAI test"
    fi
    
    log "info" "Test completed. Mock log available at: $MOCK_LOG_FILE"
}

# Run the main function
main 
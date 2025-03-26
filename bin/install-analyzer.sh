#!/bin/zsh

# Install Analyzer
# ================
# This script wraps the installation process and feeds the output to an AI agent
# to verify installation success and create a recovery plan if needed.

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
INSTALL_SCRIPT="${DOTFILES_DIR}/install.sh"
TEMP_DIR="/tmp/dotfiles-install-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${TEMP_DIR}/install.log"
ANALYSIS_FILE="${TEMP_DIR}/analysis.md"
RECOVERY_PLAN="${TEMP_DIR}/recovery-plan.md"

# Create persistent directory for analysis reports
REPORTS_DIR="${DOTFILES_DIR}/config/adw/logs/install-reports"
mkdir -p "$REPORTS_DIR" 2>/dev/null || true

# Create timestamped report file names
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
PERSISTENT_LOG="${REPORTS_DIR}/install-${TIMESTAMP}.log"
PERSISTENT_ANALYSIS="${REPORTS_DIR}/analysis-${TIMESTAMP}.md"

# Default options
AI_ENGINE="pydantic" # Options: "goose" or "pydantic"
VERBOSE=true        # Default to verbose mode for better usability
INSTALL_ARGS=()
USE_CACHE=false     # Whether to use cached analysis if available

# Parse command line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --ai=*)
                AI_ENGINE="${1#*=}"
                if [[ ! "$AI_ENGINE" =~ ^(goose|pydantic)$ ]]; then
                    echo -e "${RED}Error: AI engine must be 'goose' or 'pydantic'${NC}"
                    exit 1
                fi
                ;;
            --quiet)
                VERBOSE=false  # Add a quiet option to disable verbose if needed
                ;;
            --verbose)
                VERBOSE=true
                ;;
            --use-cache)
                USE_CACHE=true
                ;;
            --no-cache)
                USE_CACHE=false
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                # Capture all other args to pass to install.sh
                INSTALL_ARGS+=("$1")
                ;;
        esac
        shift
    done
}

# Show help message
show_help() {
    echo "Install Analyzer - A wrapper for dotfiles installation with AI analysis"
    echo ""
    echo "Usage: install-analyzer.sh [options] [install.sh options]"
    echo ""
    echo "Options:"
    echo "  --ai=<engine>     AI engine to use (goose or pydantic) [default: pydantic]"
    echo "  --verbose         Show verbose output from the installation process [default: enabled]"
    echo "  --quiet           Disable verbose output"
    echo "  --use-cache       Use cached analysis if available for similar installations"
    echo "  --no-cache        Always perform fresh analysis"
    echo "  --help            Show this help message"
    echo ""
    echo "Any other options will be passed directly to install.sh"
    echo ""
    echo "Examples:"
    echo "  install-analyzer.sh --ai=goose"
    echo "  install-analyzer.sh --ai=pydantic --profile=work --skip-apps"
    echo "  install-analyzer.sh --use-cache --verbose"
    echo ""
}

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

# Progress spinner to indicate background activity
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local message=$2
    
    tput civis  # Hide cursor
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] %s " "$spinstr" "$message"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r\033[K"
    done
    tput cnorm  # Show cursor
    printf "\r\033[K"
}

# Display AI analysis progress with step indicators
show_ai_progress() {
    local pid=$1
    local steps=("Reading installation logs" "Analyzing for errors" "Identifying warnings" "Checking configurations" "Creating remediation plan" "Formatting results")
    local step_delay=5  # seconds between "steps"
    local current_step=0
    local max_steps=${#steps[@]}
    
    tput civis  # Hide cursor
    while [ "$(ps a | awk '{print $1}' | grep -w $pid)" ]; do
        # Determine which step to show
        local step_idx=$((current_step % max_steps))
        local message="${steps[$step_idx]}"
        
        # Show progress bar
        printf "\r\033[K"
        printf "AI Analysis: %-30s [" "$message"
        
        # Progress bar, 20 characters wide
        local progress=$((step_idx * 20 / max_steps))
        for ((i=0; i<20; i++)); do
            if [ $i -lt $progress ]; then
                printf "="
            else
                printf " "
            fi
        done
        printf "] %d%%" $(( step_idx * 100 / max_steps ))
        
        sleep $step_delay
        current_step=$((current_step + 1))
    done
    tput cnorm  # Show cursor
    printf "\r\033[K"
    printf "AI Analysis: Completed                  [====================] 100%%\n"
}

# Run the installation script and capture output
run_installation() {
    log "info" "Starting dotfiles installation with arguments: ${INSTALL_ARGS[*]}"
    
    # Create temp directory for logs
    mkdir -p "$TEMP_DIR"
    
    # Run the install script and capture all output
    if [ "$VERBOSE" = true ]; then
        # Run installation with output shown but also captured to log file
        log "info" "Running installation with real-time output..."
        "$INSTALL_SCRIPT" "${INSTALL_ARGS[@]}" 2>&1 | tee "$LOG_FILE"
        exit_code=${PIPESTATUS[0]}
    else
        # Run installation with output captured to log file but not shown
        log "info" "Installation running silently... (use --verbose to see real-time output)"
        "$INSTALL_SCRIPT" "${INSTALL_ARGS[@]}" > "$LOG_FILE" 2>&1
        exit_code=$?
    fi
    
    # Check if installation completed successfully
    if [ "$exit_code" -eq 0 ]; then
        log "success" "Installation completed with exit code 0"
        return 0
    else
        log "error" "Installation failed with exit code $exit_code"
        return $exit_code
    fi
}

# Cache functions
generate_cache_key() {
    # Generate a cache key based on the installation log contents
    # We use md5 for simplicity, but any hash function would work
    if [ -f "$LOG_FILE" ]; then
        md5sum "$LOG_FILE" | cut -d' ' -f1
    else
        echo "no-log-file"
    fi
}

check_cached_analysis() {
    local cache_key=$(generate_cache_key)
    local cache_file="${REPORTS_DIR}/cache/${cache_key}.md"
    
    if [ -f "$cache_file" ]; then
        log "info" "Found cached analysis for this installation pattern"
        return 0
    else
        return 1
    fi
}

use_cached_analysis() {
    local cache_key=$(generate_cache_key)
    local cache_file="${REPORTS_DIR}/cache/${cache_key}.md"
    
    if [ -f "$cache_file" ]; then
        cp "$cache_file" "$ANALYSIS_FILE"
        cp "$cache_file" "$PERSISTENT_ANALYSIS"
        log "success" "Using cached analysis from previous run"
        return 0
    else
        return 1
    fi
}

save_analysis_to_cache() {
    if [ -f "$ANALYSIS_FILE" ]; then
        # Create cache directory if it doesn't exist
        mkdir -p "${REPORTS_DIR}/cache"
        
        # Generate cache key and save the analysis
        local cache_key=$(generate_cache_key)
        cp "$ANALYSIS_FILE" "${REPORTS_DIR}/cache/${cache_key}.md"
        log "info" "Analysis cached for future runs"
    fi
}

# Analyze installation using PydanticAI
analyze_with_pydantic() {
    log "info" "Analyzing installation with PydanticAI ADW..."
    
    # Check if we can use cached analysis
    if [ "$USE_CACHE" = true ] && check_cached_analysis; then
        if use_cached_analysis; then
            # Display the cached analysis
            echo ""
            log "info" "===== CACHED INSTALLATION ANALYSIS ====="
            echo ""
            cat "$ANALYSIS_FILE"
            echo ""
            log "info" "======================================"
            return 0
        fi
    fi
    
    log "info" "Starting AI analysis - this may take several minutes..."
    
    # Create a workflow definition for the PydanticAI ADW
    mkdir -p "${DOTFILES_DIR}/config/adw/install-analyzer" 2>/dev/null || true
    
    # Create workflow.py file (existing code)
    cat > "${DOTFILES_DIR}/config/adw/install-analyzer/workflow.py" << EOF
"""
Installation Analyzer Workflow

This workflow analyzes the output of a dotfiles installation process
and creates a remediation plan for any issues encountered.
"""

from typing import List, Optional
from pydantic import BaseModel, Field


class InstallationIssue(BaseModel):
    """An issue encountered during installation"""
    component: str = Field(..., description="The component or step where the issue occurred")
    severity: str = Field(..., description="Severity level: error, warning, or info")
    message: str = Field(..., description="Description of the issue")
    line_number: Optional[int] = Field(None, description="Line number in the log file where the issue was detected")
    remediation: str = Field(..., description="Suggested steps to resolve the issue")


class InstallationAnalysis(BaseModel):
    """Analysis of the installation process"""
    status: str = Field(..., description="Overall status: success, partial_success, or failure")
    issues: List[InstallationIssue] = Field(default_factory=list, description="List of detected issues")
    summary: str = Field(..., description="Summary of the installation process")
    environment_notes: Optional[str] = Field(None, description="Notes about the environment that may be relevant")


class RemediationPlan(BaseModel):
    """A plan to address installation issues"""
    steps: List[str] = Field(..., description="Ordered list of steps to resolve issues")
    verification: List[str] = Field(..., description="Steps to verify the fixes worked")
    resources: List[str] = Field(default_factory=list, description="Helpful resources or documentation")


class InstallAnalyzerResult(BaseModel):
    """The complete result of the installation analysis"""
    analysis: InstallationAnalysis = Field(..., description="Detailed analysis of the installation")
    remediation_plan: Optional[RemediationPlan] = Field(None, description="Plan to resolve issues, if any were found")


steps = [
    "Read and understand the dotfiles project from README.md",
    "Analyze the installation log for errors, warnings, and success indicators",
    "Determine overall installation status",
    "Identify specific issues and their root causes",
    "Create a detailed remediation plan for any issues",
    "Format the analysis and remediation plan as a helpful report"
]

# The workflow will be executed with these steps
workflow_output_type = InstallAnalyzerResult
EOF

    # Create a prompt for PydanticAI ADW
    cat > "${TEMP_DIR}/pydantic-prompt.txt" << EOF
Your task is to analyze the output of a dotfiles installation process and determine 
if it completed successfully. If there were any errors or warnings, identify them 
and create a detailed remediation plan.

First, read the installation log at: ${LOG_FILE}

Next, understand the dotfiles project by reading: ${DOTFILES_DIR}/README.md

Then, analyze the installation results to determine:
1. If the installation was successful, partially successful, or failed
2. Any specific components that had errors or warnings
3. The root causes of any issues
4. A step-by-step plan to resolve each issue

IMPORTANT: Document your entire analysis process and decision-making in the report.
Explain how you identified each issue, why you classified its severity level,
and why you believe each suggested fix will resolve the problem.

Be thorough and specific in your analysis. Pay special attention to:
- Exit codes and explicit success/failure messages
- Error and warning messages
- Missing dependencies or tools
- Configuration issues
- Permission problems

Your output should be well-structured, clear, and actionable.
EOF

    # Run PydanticAI ADW to analyze the installation
    if [ -f "${DOTFILES_DIR}/bin/pai-workflow" ]; then
        # Run PydanticAI workflow with correct arguments and show progress indicator
        log "info" "Starting PydanticAI analysis..."
        echo ""
        log "info" "Phase 1/3: Reading installation logs"
        
        # Use prompt as the direct prompt argument instead of input-file
        "${DOTFILES_DIR}/bin/pai-workflow" install-analyzer \
            --prompt "${TEMP_DIR}/pydantic-prompt.txt" > "$ANALYSIS_FILE" &
        
        # Get process ID and show progress
        pai_pid=$!
        echo ""
        log "info" "AI analysis in progress (this may take 5-10 minutes)"
        echo ""
        
        # Use the AI progress display
        show_ai_progress $pai_pid
        
        # Wait for process to complete
        wait $pai_pid
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            echo ""
            log "success" "PydanticAI analysis completed successfully!"
            # Display the analysis
            echo ""
            log "info" "===== INSTALLATION ANALYSIS REPORT ====="
            echo ""
            cat "$ANALYSIS_FILE"
            echo ""
            log "info" "======================================"
            log "info" "Full analysis saved to: $ANALYSIS_FILE"
            
            # Save successful analysis to cache
            if [ "$USE_CACHE" = true ]; then
                save_analysis_to_cache
            fi
            
            return 0
        else
            log "error" "PydanticAI analysis failed with exit code $exit_code"
            
            # Fallback to direct execution with Claude model if PydanticAI workflow fails
            log "info" "Trying alternate analysis method..."
            if command -v goose &>/dev/null; then
                analyze_with_goose
                return $?
            else
                log "error" "No alternate analysis methods available."
                return 1
            fi
        fi
    else
        log "error" "PydanticAI not found. Please install PydanticAI or use Goose."
        return 1
    fi
}

# Analyze installation using Goose
analyze_with_goose() {
    log "info" "Analyzing installation with Goose..."
    
    # Check if we can use cached analysis
    if [ "$USE_CACHE" = true ] && check_cached_analysis; then
        if use_cached_analysis; then
            # Display the cached analysis
            echo ""
            log "info" "===== CACHED INSTALLATION ANALYSIS ====="
            echo ""
            cat "$ANALYSIS_FILE"
            echo ""
            log "info" "======================================"
            return 0
        fi
    fi
    
    log "info" "Starting AI analysis - this may take a few minutes..."
    
    # Create a prompt for Goose
    cat > "${TEMP_DIR}/goose-prompt.txt" << EOF
Analyze the output of a dotfiles installation process and determine if it completed successfully. 
If there were any errors or warnings, identify them and create a remediation plan.

Here's what you need to do:
1. Read the installation log: ${LOG_FILE}
2. Read the README.md to understand the dotfiles project: ${DOTFILES_DIR}/README.md
3. Determine if the installation was successful
4. Identify any errors or warnings
5. Create a step-by-step remediation plan for any issues

Your analysis should be thorough and include:
- Overall installation status (success/partial/failure)
- List of detected issues (if any)
- Specific components that failed or had warnings
- A detailed, step-by-step recovery plan
- Any environment-specific considerations

Please format your response as Markdown with clear headings and code blocks where appropriate.
EOF

    # Create a custom extension for file reading
    mkdir -p "${TEMP_DIR}/extensions"
    cat > "${TEMP_DIR}/extensions/file-reader.js" << EOF
// File Reader - Goose Extension
// This extension allows reading files for better analysis

/**
 * @name file-reader
 * @description Read file contents from the filesystem
 * @author Installation Analyzer
 * @version 1.0.0
 */

import fs from 'fs';
import path from 'path';

/**
 * Main function to handle file reading
 * @param {object} context - The Goose context object
 * @returns {Promise<object>} - Result object with file contents
 */
export default async function fileReader(context) {
  const { input } = context;
  
  // Extract file path from the input
  const readFileRegex = /(?:read file|get contents of|show file|display file)\s+(.+)/i;
  const match = input.match(readFileRegex);
  
  if (!match) {
    return {
      error: "Please specify a file path to read",
      example: "Read file /path/to/file.txt"
    };
  }
  
  const filePath = match[1].trim();
  
  try {
    // Check if file exists
    if (!fs.existsSync(filePath)) {
      return {
        error: \`File not found: \${filePath}\`
      };
    }
    
    // Read file contents
    const fileContents = fs.readFileSync(filePath, 'utf8');
    
    // Get file stats
    const stats = fs.statSync(filePath);
    
    return {
      filePath,
      fileName: path.basename(filePath),
      size: stats.size,
      lastModified: stats.mtime,
      contents: fileContents
    };
  } catch (error) {
    return {
      error: \`An error occurred: \${error.message}\`,
      filePath
    };
  }
}

// Enable MCP command registration for Goose
fileReader.mcp = {
  commands: [
    {
      name: "read-file",
      description: "Read contents of a file",
      async run(input) {
        return fileReader({ input });
      }
    }
  ]
};

// Provide additional help information
fileReader.help = {
  examples: [
    "Read file /tmp/dotfiles-install/install.log",
    "Get contents of README.md",
    "Show file config/adw/install-analyzer.yaml"
  ]
};
EOF

    # Run Goose with the developer extension to analyze the installation
    if command -v goose &>/dev/null; then
        # Run Goose and capture the output with progress indicator
        log "info" "Running Goose with extensions..."
        
        # Use the file-reader extension and developer extension
        GOOSE_EXTENSIONS_DIR="${TEMP_DIR}/extensions" goose \
            --with-extension file-reader \
            --with-extension developer \
            "${TEMP_DIR}/goose-prompt.txt" > "$ANALYSIS_FILE" 2>/dev/null &
        
        # Get process ID and show spinner
        goose_pid=$!
        log "info" "AI analysis in progress"
        spinner $goose_pid "Goose analysis"
        
        # Wait for process to complete
        wait $goose_pid
        exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log "success" "Goose analysis completed"
            # Display the analysis
            echo ""
            log "info" "===== INSTALLATION ANALYSIS REPORT ====="
            echo ""
            cat "$ANALYSIS_FILE"
            echo ""
            log "info" "======================================"
            
            # Save successful analysis to cache
            if [ "$USE_CACHE" = true ]; then
                save_analysis_to_cache
            fi
            
            return 0
        else
            log "error" "Goose analysis failed with exit code $exit_code"
            return 1
        fi
    else
        log "error" "Goose not found. Please install Goose or use PydanticAI."
        return 1
    fi
}

# Main function
main() {
    # Parse command line arguments
    parse_args "$@"
    
    # Print banner
    echo "┌───────────────────────────────────────┐"
    echo "│    🧠 DOTFILES INSTALLATION ANALYZER   │"
    echo "└───────────────────────────────────────┘"
    log "info" "Starting dotfiles installation analyzer"
    log "info" "Using AI engine: $AI_ENGINE"
    log "info" "Verbose mode: $([ "$VERBOSE" = true ] && echo "enabled" || echo "disabled")"
    
    # Run the installation script
    run_installation
    install_status=$?
    
    # Copy the log to the persistent location
    cp "$LOG_FILE" "$PERSISTENT_LOG"
    log "info" "Installation log saved to $PERSISTENT_LOG"
    
    echo ""
    log "info" "Installation phase complete, beginning AI analysis..."
    echo ""
    
    # Analyze the installation based on the selected AI engine
    if [ "$AI_ENGINE" = "goose" ]; then
        analyze_with_goose
    else
        analyze_with_pydantic
    fi
    analysis_status=$?
    
    # Copy the analysis to the persistent location if it exists
    if [ -f "$ANALYSIS_FILE" ]; then
        cp "$ANALYSIS_FILE" "$PERSISTENT_ANALYSIS"
        log "info" "Analysis saved to: $PERSISTENT_ANALYSIS"
    fi
    
    log "success" "Install analyzer completed"
    log "info" "If you need to see the raw installation log, it's available at: $PERSISTENT_LOG"
    
    # If analysis succeeded but installation failed, return installation status
    # If analysis failed, return analysis status
    if [ $analysis_status -eq 0 ]; then
        return $install_status
    else
        return $analysis_status
    fi
}

# Run the main function with all arguments
main "$@" 
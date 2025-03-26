# Installation Analyzer

This workflow analyzes the output of a dotfiles installation process and determines if it was successful. If there were errors or warnings, it identifies them and creates a detailed remediation plan.

## Purpose

The Installation Analyzer serves as an AI-powered diagnostic tool that:

1. Understands the structure and purpose of the dotfiles system
2. Interprets installation logs to identify any issues
3. Provides a contextually relevant recovery plan
4. Helps troubleshoot complex installation problems

## Usage

Run this workflow via the installation analyzer script:

```bash
./bin/install-analyzer.sh
```

Or run it directly with the pai-workflow command:

```bash
pai-workflow install-analyzer --input-file [path/to/installation/log]
```

## Outputs

The workflow produces a structured analysis containing:

1. Overall installation status (success, partial success, or failure)
2. Detailed list of identified issues with severity ratings
3. **Decision-making process and reasoning for each identified issue**
4. Potential root causes for each issue
5. Step-by-step remediation instructions
6. Verification steps to confirm fixes worked

## Analysis Requirements

Your analysis MUST include a clear trace of your decision-making process:
1. Document how you identified each issue in the logs
2. Explain your reasoning for the severity classification
3. Detail why you believe each suggested fix will work
4. Document any alternative approaches you considered

This traceability is critical for understanding the analysis and building trust in the remediation plan.

## Example Analysis

```
# Installation Analysis

## Status: Partial Success

## Analysis Process
I analyzed the installation log by:
1. First looking for explicit error messages and exit codes
2. Then examining warnings that didn't halt installation
3. Finally checking for expected success indicators

## Issues Found

1. **Missing Python Dependencies** (Severity: Warning)
   - Component: UV Package Manager
   - Message: Failed to install UV with pip
   - Log evidence: Line 142 shows "ERROR: Failed building wheel for uv"
   - Reasoning: This is a warning rather than error because the installation continued
   - Remediation: Install required build dependencies

2. **Configuration File Collision** (Severity: Error)
   - Component: Zsh Configuration
   - Message: Could not symlink .zshrc due to existing file
   - Log evidence: Line 203 shows "Failed to symlink: /Users/user/.zshrc already exists"
   - Reasoning: This is an error because it prevents proper shell configuration
   - Remediation: Manually back up and remove existing .zshrc

## Remediation Plan

1. Install required Python dependencies:
   ```bash
   brew install gcc python-dev
   ```

2. Resolve configuration file collision:
   ```bash
   mv ~/.zshrc ~/.zshrc.backup
   ./install.sh
   ```

## Verification Steps

1. Run `which uv` to verify UV is installed
2. Check `ls -la ~/.zshrc` to confirm symlink 
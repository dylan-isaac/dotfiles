# Manual Testing Guide

This guide provides comprehensive instructions for manually testing all AI-powered tools in the dotfiles repository, with a focus on ADW (AI Developer Workflows) and AI CLI tools.

## 1. Testing AI Developer Workflows (ADW)

ADW enables autonomous AI-driven development workflows using two implementations:

### 1.1 Classic Director Pattern (`ai-workflow`)

#### Setup

```bash
# List available workflows
ai-workflow --list
```

#### Test Cases

1. **Basic Workflow Execution**
   - **Command**: `ai-workflow basic`
   - **Success Case**: Workflow executes and logs appear in `config/adw/logs/basic.log`
   - **Failure Case**: Error message appears or no log file is created

2. **Custom Prompt Workflow**
   - **Command**: `ai-workflow "Fix the bug in this function"`
   - **Success Case**: Custom prompt is used to create and run a new workflow
   - **Failure Case**: Error in workflow creation or execution

3. **File Context Workflow**
   - **Command**: `ai-workflow "Update error handling" --files bin/director.py`
   - **Success Case**: Workflow creates and executes with director.py as editable context
   - **Failure Case**: File not included in context or workflow fails

4. **Workflow With Test Command**
   - **Command**: `ai-workflow "Improve security checks" --test="./tests/security/test_git_security_check.sh"`
   - **Success Case**: Workflow uses provided test command for evaluation
   - **Failure Case**: Test command not properly executed during workflow

### 1.2 PydanticAI-based Implementation (`pai-workflow`)

#### Setup

```bash
# List available workflows
pai-workflow --list
```

#### Test Cases

1. **Basic Workflow Execution**
   - **Command**: `pai-workflow basic`
   - **Success Case**: Workflow executes with typed models and structured evaluation
   - **Failure Case**: Error in PydanticAI models or execution failure

2. **Structured Evaluation Workflow**
   - **Command**: `pai-workflow update-docs`
   - **Success Case**: Workflow produces structured evaluation with security check and metrics
   - **Failure Case**: Missing or incomplete structured evaluation

3. **Custom Context Workflow**
   - **Command**: `pai-workflow basic --context=/path/to/context`
   - **Success Case**: Workflow uses the provided context directory
   - **Failure Case**: Context not properly loaded or used

4. **Failure Analysis**
   - **Command**: `pai-workflow verify-features`
   - **Success Case**: On failure, provides comprehensive debugging information
   - **Failure Case**: Missing or uninformative failure analysis

## 2. Testing Aider

[Aider](https://aider.chat/) is an AI pair programming tool that runs in the terminal.

### Setup

```bash
# Verify installation
aider --version
```

#### Test Cases

1. **Basic Chat Session**
   - **Command**: `cd ~/Projects/test-project && aider --model sonnet file.py`
   - **Success Case**: Chat session opens with file loaded in context
   - **Failure Case**: Error connecting to API or loading file

2. **Model Selection**
   - **Command**: `aider --model gpt-4o` (or other available model alias)
   - **Success Case**: Model is properly selected and used
   - **Failure Case**: Default model is used instead or connection error

3. **Multi-file Editing**
   - **Command**: `aider file1.py file2.py`
   - **Success Case**: Both files are loaded and editable
   - **Failure Case**: Files not properly loaded or editable

4. **In-chat Commands**
   - **Command**: Within aider session: `/add another_file.py`
   - **Success Case**: New file is added to the session
   - **Failure Case**: Command fails or file not added

## 3. Testing Goose

[Goose](https://block.github.io/goose/) is an on-machine AI agent for software development tasks.

### Setup

```bash
# Verify installation
goose --version
```

#### Test Cases

1. **Basic Command Execution**
   - **Command**: `goose "Create a simple hello world script in Python"`
   - **Success Case**: Goose generates and executes code to create the script
   - **Failure Case**: Errors in understanding or executing the task

2. **Browser Automation**
   - **Command**: `goose extension:bin/goose-github-stars.js "Analyze stars on GitHub repo octocat/Spoon-Knife"`
   - **Success Case**: Goose opens a browser, scrapes GitHub stars, and returns analysis
   - **Failure Case**: Browser automation fails or data extraction error

3. **Model Selection**
   - **Command**: `goose --model claude-3-opus-20240229 "Optimize this algorithm"`
   - **Success Case**: Task is executed using the specified model
   - **Failure Case**: Default model is used or API error

4. **Headless Mode**
   - **Command**: `goose --headless "Generate a test plan"`
   - **Success Case**: Task executes without UI prompts
   - **Failure Case**: Still prompts for approval or execution fails

## 4. Testing Repomix

[Repomix](https://github.com/yamadashy/repomix) is a tool that packs your repository into a single AI-friendly file.

### Setup

```bash
# Verify installation
repomix --version
```

#### Test Cases

1. **Basic Repository Packing**
   - **Command**: `cd ~/Projects/test-project && repomix`
   - **Success Case**: Creates a single file with repository content
   - **Failure Case**: Error in processing repository or empty output

2. **Output Format Options**
   - **Command**: `repomix --format=xml`
   - **Success Case**: Output in specified format (XML)
   - **Failure Case**: Format not applied or conversion error

3. **File Pattern Filtering**
   - **Command**: `repomix --include="src/**/*.js" --exclude="node_modules"`
   - **Success Case**: Only matching files included, exclusions applied
   - **Failure Case**: Filtering not applied correctly

4. **MCP Server Operation**
   - **Steps**:
     1. Check if server is running: `ps aux | grep "repomix --mcp"`
     2. Stop server: `launchctl unload ~/Library/LaunchAgents/com.repomix.mcp.plist`
     3. Start server: `launchctl load ~/Library/LaunchAgents/com.repomix.mcp.plist`
   - **Success Case**: Server starts, stops, and restarts successfully
   - **Failure Case**: Server fails to start or respond to commands

## 5. Testing Installation Analyzer

The Installation Analyzer is an AI-powered diagnostic tool that analyzes the output of the dotfiles installation process and provides remediation plans for any issues.

### Setup

```bash
# Verify the script is executable
ls -la bin/install-analyzer.sh
```

#### Test Cases

1. **Basic Analysis with Default AI Engine (PydanticAI)**
   - **Command**: `./bin/install-analyzer.sh --quick --skip-apps`
   - **Success Case**: Installation runs, logs are captured, and PydanticAI provides analysis
   - **Failure Case**: Script fails to run or AI analysis not produced

2. **Analysis with Goose AI Engine**
   - **Command**: `./bin/install-analyzer.sh --ai=goose --quick --skip-apps`
   - **Success Case**: Goose successfully analyzes installation log
   - **Failure Case**: Goose fails to analyze or can't access logs

3. **Verbose Output Mode**
   - **Command**: `./bin/install-analyzer.sh --verbose --quick`
   - **Success Case**: Installation output is displayed in real-time while also being captured
   - **Failure Case**: Output not shown or not properly captured

4. **Mock Installation Testing**
   - **Command**: `./tests/test_install_analyzer.sh`
   - **Success Case**: Script generates mock logs and runs analysis on predefined issues
   - **Failure Case**: Test fails or doesn't analyze the mock logs

5. **Accessibility Check**
   - **Test With**: Screen reader or high-contrast terminal
   - **Success Case**: Log output and analysis have sufficient contrast and are properly structured
   - **Failure Case**: Critical information has poor contrast or is not screen reader friendly

### Verification

After running the analyzer, check:
1. The timestamped directory in `/tmp/dotfiles-install-*` contains both raw logs and AI analysis
2. The analysis correctly identifies actual installation issues
3. Remediation steps are clear, specific, and relevant to the identified issues
4. Verify that both Goose and PydanticAI engines produce useful results

## 6. Integration Testing

These tests verify that the tools work together effectively.

### Test Cases

1. **ADW with Repomix Context**
   - **Command**: `ai-workflow "Analyze code quality" --context=$(repomix --output=/tmp/repo.md)`
   - **Success Case**: Workflow uses Repomix output as context
   - **Failure Case**: Context not properly passed or utilized

2. **Aider with Generated Files**
   - **Steps**:
     1. Use Goose to generate a file: `goose "Create a basic React component"` 
     2. Edit with Aider: `aider Component.jsx`
   - **Success Case**: Seamless handoff between tools
   - **Failure Case**: Incompatibility or errors between tools

3. **Profile Switching and Tool Configuration**
   - **Steps**:
     1. Switch profile: `dotfiles-profile set work`
     2. Verify tool settings changed: `cat ~/.config/aider/aider.conf.yml`
   - **Success Case**: Tool configurations update based on profile
   - **Failure Case**: Configuration not properly updated

## 7. Accessibility Testing

These tests ensure the tools are accessible for different users and situations.

### Test Cases

1. **Color Contrast in Terminal Output**
   - **Command**: `ai-workflow --list`
   - **Success Case**: Text is readable with sufficient contrast
   - **Failure Case**: Text colors have poor contrast against background

2. **Screen Reader Compatibility**
   - **Test With**: VoiceOver on macOS
   - **Success Case**: Terminal output is properly read by screen reader
   - **Failure Case**: Important information is not conveyed audibly

3. **Keyboard Navigation**
   - **Command**: Within aider session, navigate and select options using keyboard
   - **Success Case**: All functions accessible via keyboard
   - **Failure Case**: Some functions require mouse interaction

## 8. Error Handling Testing

These tests verify that tools handle errors gracefully.

### Test Cases

1. **Missing API Keys**
   - **Steps**: Temporarily remove API keys from environment and run tools
   - **Success Case**: Clear error message explaining the issue
   - **Failure Case**: Cryptic error or silent failure

2. **Network Connectivity Issues**
   - **Steps**: Temporarily disable network and run tools
   - **Success Case**: Graceful error handling with recovery suggestions
   - **Failure Case**: Unhandled exceptions or crash

3. **Invalid Arguments**
   - **Command**: `ai-workflow --invalid-flag`
   - **Success Case**: Helpful error message with usage instructions
   - **Failure Case**: Confusing error or crash

## 9. Additional Resources

- Run automated tests: `./tests/run_tests.sh`
- Review test results in: `tests/results/`
- Extend tests by adding new test scripts to relevant test directories

## 10. Contributing Test Cases

When adding new test cases:

1. Update this manual testing guide
2. Add automated tests where possible
3. Include both success and failure scenarios
4. Consider accessibility implications
5. Document expected outcomes clearly 
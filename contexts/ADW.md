
# AI Developer Workflow Director Pattern Implementation

Below is a complete implementation of the Director pattern that AI can use as a foundation for creating AI Developer Workflows in any codebase.

```python:director.py
import argparse
import json
import os
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Literal, Optional, Union

import yaml
from aider.coders import Coder
from aider.io import InputOutput
from aider.models import Model
from pydantic import BaseModel, Field

# Set up environment variables if .env file exists
if Path(".env").exists():
    from dotenv import load_dotenv
    load_dotenv()

class EvaluationResult(BaseModel):
    """Result of evaluating the execution output."""
    success: bool
    feedback: Optional[str] = None

class DirectorConfig(BaseModel):
    """Configuration for the Director pattern."""
    prompt: str
    coder_model: str
    evaluator_model: str
    max_iterations: int = Field(default=5)
    execution_command: str
    context_editable: List[str]
    context_read_only: List[str] = Field(default_factory=list)
    evaluator: Literal["default", "unittest", "pytest", "custom"] = "default"
    log_file: str = "director_log.txt"

class Director:
    """
    Self-Directed AI Coding Assistant
    
    The Director pattern is an agentic workflow that enables AI to autonomously:
    1. Generate code based on specifications
    2. Execute the code using a validation command
    3. Evaluate the results
    4. Provide feedback for refinement if needed
    5. Repeat until success or max iterations reached
    """

    def __init__(self, config_path: str):
        """Initialize the Director with a configuration file."""
        self.config = self.load_config(config_path)
        self.setup_llm_client()
        self.clear_log_file()

    def load_config(self, config_path: str) -> DirectorConfig:
        """Load and validate the configuration from a YAML file."""
        config_path = Path(config_path)
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_path}")

        with open(config_path) as f:
            config_dict = yaml.safe_load(f)

        # If prompt points to a file, load its contents
        if config_dict["prompt"].endswith((".md", ".txt")):
            prompt_path = Path(config_dict["prompt"])
            if not prompt_path.exists():
                raise FileNotFoundError(f"Prompt file not found: {prompt_path}")
            with open(prompt_path) as f:
                config_dict["prompt"] = f.read()

        # Validate file paths exist
        for category in ["context_editable", "context_read_only"]:
            if category in config_dict:
                for path in config_dict[category]:
                    if not Path(path).exists():
                        raise FileNotFoundError(f"File not found: {path}")

        return DirectorConfig(**config_dict)

    def setup_llm_client(self):
        """Set up the language model client based on the evaluator model."""
        if "gpt" in self.config.evaluator_model.lower():
            from openai import OpenAI
            self.llm_client = OpenAI()
        elif "claude" in self.config.evaluator_model.lower():
            from anthropic import Anthropic
            self.llm_client = Anthropic()
        else:
            # Default to OpenAI
            from openai import OpenAI
            self.llm_client = OpenAI()

    def clear_log_file(self):
        """Clear the log file at the start of a new run."""
        with open(self.config.log_file, "w") as f:
            f.write(f"Director Pattern Log\n{'='*50}\n\n")

    def log(self, message: str, print_to_console: bool = True):
        """Log a message to both the console and log file."""
        if print_to_console:
            print(message)
        with open(self.config.log_file, "a") as f:
            f.write(f"{message}\n")

    def create_prompt(self, iteration: int, evaluation: Optional[EvaluationResult] = None) -> str:
        """
        Create a prompt for the AI coding assistant based on iteration number and previous evaluation.
        
        Args:
            iteration: Current iteration number (0-based)
            evaluation: Result of previous iteration evaluation
            
        Returns:
            A prompt string for the AI coding assistant
        """
        if iteration == 0:
            return self.config.prompt
        
        execution_output = self.last_execution_output if hasattr(self, "last_execution_output") else ""
        
        return f"""
# Task Iteration {iteration+1}

## Original Task Specification
{self.config.prompt}

## Previous Execution Output
```
{execution_output}
```

## Feedback from Previous Attempt
{evaluation.feedback}

## Instructions
Please address the feedback above and make the necessary changes to solve the task.
You have {self.config.max_iterations - iteration} attempts remaining.

Remember to focus on passing the execution command: `{self.config.execution_command}`
"""

    def execute_ai_code(self, prompt: str) -> bool:
        """
        Execute the AI coding assistant with the given prompt.
        
        Args:
            prompt: The prompt for the AI coding assistant
            
        Returns:
            True if successful, False otherwise
        """
        self.log(f"🤖 Running AI Coding Assistant (model: {self.config.coder_model})")
        self.log(f"📝 Prompt:\n{prompt}", print_to_console=False)
        
        try:
            model = Model(self.config.coder_model)
            coder = Coder.create(
                main_model=model,
                io=InputOutput(yes=True),
                fnames=self.config.context_editable,
                read_only_fnames=self.config.context_read_only,
                auto_commits=False,
                suggest_shell_commands=False,
            )
            coder.run(prompt)
            return True
        except Exception as e:
            self.log(f"❌ Error executing AI code: {str(e)}")
            return False

    def run_execution_command(self) -> str:
        """
        Run the execution command and capture its output.
        
        Returns:
            The combined stdout and stderr from the execution
        """
        self.log(f"💻 Executing command: {self.config.execution_command}")
        
        try:
            result = subprocess.run(
                self.config.execution_command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=300  # 5-minute timeout
            )
            output = result.stdout + result.stderr
            self.last_execution_output = output
            self.log(f"📋 Execution output:\n{output}", print_to_console=False)
            return output
        except subprocess.TimeoutExpired:
            self.log("⚠️ Execution timed out after 5 minutes")
            return "ERROR: Execution timed out after 5 minutes"
        except Exception as e:
            self.log(f"⚠️ Execution error: {str(e)}")
            return f"ERROR: {str(e)}"

    def evaluate_result(self, execution_output: str) -> EvaluationResult:
        """
        Evaluate the execution output using the specified evaluator.
        
        Args:
            execution_output: The output from the execution command
            
        Returns:
            An EvaluationResult with success status and feedback
        """
        if self.config.evaluator == "default":
            return self._default_evaluator(execution_output)
        elif self.config.evaluator == "unittest":
            return self._unittest_evaluator(execution_output)
        elif self.config.evaluator == "pytest":
            return self._pytest_evaluator(execution_output)
        else:
            self.log(f"⚠️ Unknown evaluator: {self.config.evaluator}, using default")
            return self._default_evaluator(execution_output)

    def _default_evaluator(self, execution_output: str) -> EvaluationResult:
        """
        Default evaluator using an LLM to assess success based on execution output.
        
        Args:
            execution_output: The output from the execution command
            
        Returns:
            An EvaluationResult with success status and feedback
        """
        # Build file context
        editable_files = {}
        readonly_files = {}
        
        for path in self.config.context_editable:
            try:
                with open(path, 'r') as f:
                    editable_files[path] = f.read()
            except Exception as e:
                self.log(f"⚠️ Could not read file {path}: {str(e)}", print_to_console=False)
        
        for path in self.config.context_read_only:
            try:
                with open(path, 'r') as f:
                    readonly_files[path] = f.read()
            except Exception as e:
                self.log(f"⚠️ Could not read file {path}: {str(e)}", print_to_console=False)

        # Create evaluation prompt
        evaluation_prompt = f"""
Your task is to evaluate if the code changes have successfully addressed the requirements.

## Task Requirements
{self.config.prompt}

## Execution Command
`{self.config.execution_command}`

## Execution Output
```
{execution_output}
```

## Editable Files
{json.dumps(editable_files, indent=2)}

## Read-Only Reference Files
{json.dumps(readonly_files, indent=2)}

## Evaluation Instructions
1. Determine if the execution output indicates success
2. Check if all requirements in the task have been met
3. Identify any errors or issues that need to be fixed

Return a JSON object with the following format:
{{
  "success": true/false,
  "feedback": "Detailed feedback explaining what works and what needs improvement"
}}
"""

        self.log("🔍 Evaluating results...")
        
        # Try with the specified model
        try:
            # OpenAI models
            if "gpt" in self.config.evaluator_model:
                response = self.llm_client.chat.completions.create(
                    model=self.config.evaluator_model,
                    messages=[{"role": "user", "content": evaluation_prompt}],
                    response_format={"type": "json_object"}
                )
                response_text = response.choices[0].message.content
            # Anthropic models
            elif "claude" in self.config.evaluator_model:
                response = self.llm_client.messages.create(
                    model=self.config.evaluator_model,
                    max_tokens=1000,
                    messages=[{"role": "user", "content": evaluation_prompt}]
                )
                response_text = response.content[0].text
            else:
                raise ValueError(f"Unsupported model: {self.config.evaluator_model}")
                
            # Extract JSON from response
            if "```json" in response_text:
                json_str = response_text.split("```json")[1].split("```")[0].strip()
            elif "```" in response_text:
                json_str = response_text.split("```")[1].split("```")[0].strip()
            else:
                json_str = response_text.strip()
                
            result = json.loads(json_str)
            return EvaluationResult(success=result["success"], feedback=result["feedback"])
            
        except Exception as e:
            self.log(f"⚠️ Error in evaluation: {str(e)}")
            self.log("⚠️ Falling back to simple evaluation")
            
            # Simple fallback evaluation
            if "error" in execution_output.lower() or "fail" in execution_output.lower():
                return EvaluationResult(
                    success=False,
                    feedback=f"Execution failed with errors: {execution_output}"
                )
            else:
                return EvaluationResult(
                    success=True,
                    feedback="Execution completed without obvious errors."
                )

    def _unittest_evaluator(self, execution_output: str) -> EvaluationResult:
        """Evaluator specifically for unittest output."""
        if "FAILED" in execution_output or "ERROR" in execution_output:
            return EvaluationResult(
                success=False,
                feedback=f"Tests failed. Please fix the following issues:\n{execution_output}"
            )
        elif "OK" in execution_output:
            return EvaluationResult(success=True, feedback="All tests passed successfully.")
        else:
            return EvaluationResult(
                success=False,
                feedback=f"Unable to determine test results. Output:\n{execution_output}"
            )

    def _pytest_evaluator(self, execution_output: str) -> EvaluationResult:
        """Evaluator specifically for pytest output."""
        if "failed" in execution_output.lower():
            return EvaluationResult(
                success=False,
                feedback=f"Tests failed. Please fix the following issues:\n{execution_output}"
            )
        elif "passed" in execution_output.lower() and "failed" not in execution_output.lower():
            return EvaluationResult(success=True, feedback="All tests passed successfully.")
        else:
            return EvaluationResult(
                success=False,
                feedback=f"Unable to determine test results. Output:\n{execution_output}"
            )

    def direct(self) -> bool:
        """
        Run the director pattern to completion.
        
        Returns:
            True if successful, False otherwise
        """
        self.log(f"🚀 Starting Director Pattern with max {self.config.max_iterations} iterations")
        self.log(f"📂 Editable files: {', '.join(self.config.context_editable)}")
        self.log(f"📚 Read-only files: {', '.join(self.config.context_read_only)}")
        
        evaluation = None
        success = False
        
        for iteration in range(self.config.max_iterations):
            self.log(f"\n{'='*50}")
            self.log(f"📌 Iteration {iteration+1}/{self.config.max_iterations}")
            
            # Create prompt based on iteration and previous evaluation
            prompt = self.create_prompt(iteration, evaluation)
            
            # Run AI coding assistant
            if not self.execute_ai_code(prompt):
                self.log("❌ Failed to execute AI coding assistant")
                break
                
            # Run execution command
            execution_output = self.run_execution_command()
            
            # Evaluate results
            evaluation = self.evaluate_result(execution_output)
            
            # Log evaluation results
            if evaluation.success:
                self.log(f"✅ Success: {evaluation.feedback}")
                success = True
                break
            else:
                self.log(f"❌ Failed: {evaluation.feedback}")
        
        if success:
            self.log("\n🎉 Director completed successfully!")
        else:
            self.log("\n⚠️ Director completed without success after all iterations")
            
        return success

def main():
    parser = argparse.ArgumentParser(description="AI Developer Workflow Director")
    parser.add_argument("-c", "--config", required=True, help="Path to configuration YAML file")
    args = parser.parse_args()
    
    director = Director(args.config)
    success = director.direct()
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
```

# Multi-Shot Examples for Teaching AI to Use the Director Pattern

## Example 1: Creating a New Chart Type

### 1.1 Configuration File (radial_chart.yaml)

```yaml
prompt: "specs/radial_chart_spec.md"
coder_model: "claude-3-haiku"
evaluator_model: "gpt-4o"
max_iterations: 3
execution_command: "pytest -xvs tests/test_charts.py"
context_editable:
  - "src/aider_has_a_secret/charts.py"
  - "src/aider_has_a_secret/visualization.py"
  - "tests/test_charts.py"
context_read_only:
  - "specs/new-chart-type.md"
  - "adw/new_chart.py"
evaluator: "pytest"
```

### 1.2 Specification File (radial_chart_spec.md)

```markdown
# Radial Chart Implementation

## High-Level Objective
Implement a new radial chart type for visualizing word frequency data, providing a circular representation that highlights key words.

## Implementation Details

1. Update `charts.py` to add a new `RadialChart` class that inherits from the base `Chart` class
2. Add a new visualization function in `visualization.py` called `create_radial_chart`
3. Update tests in `test_charts.py` to verify the new chart type works correctly

## Technical Requirements

1. The radial chart should:
   - Display words in a circular pattern
   - Use word frequency to determine distance from center (more frequent = further out)
   - Use different colors for different frequency ranges
   - Include a legend

2. The implementation should:
   - Use matplotlib's polar projection
   - Support customization of colors and title
   - Handle empty data gracefully
   - Include proper docstrings and type hints

## Reference
See `adw/new_chart.py` for an example of how previous chart types were implemented.
```

### 1.3 Running the Director

```bash
python director.py -c radial_chart.yaml
```

### 1.4 Expected Workflow

1. **Iteration 1:**
   - AI examines existing chart implementations
   - Implements RadialChart class and visualization function
   - Creates initial tests
   - Some tests may fail due to edge cases

2. **Iteration 2:**
   - AI fixes issues identified in the evaluation
   - Improves error handling
   - Updates tests
   - Most tests pass but may have styling issues

3. **Iteration 3:**
   - AI refines chart styling
   - Adds final polish
   - All tests pass
   - Director completes successfully

## Example 2: Adding a New Output Format Type

### 2.1 Configuration File (json_output_format.yaml)

```yaml
prompt: "specs/json_output_format_spec.md"
coder_model: "claude-3-sonnet"
evaluator_model: "gpt-4o"
max_iterations: 2
execution_command: "pytest -xvs tests/test_output_format.py"
context_editable:
  - "src/aider_has_a_secret/output_format.py"
  - "src/aider_has_a_secret/main.py"
  - "tests/test_output_format.py"
context_read_only:
  - "adw/new_output_type.py"
evaluator: "pytest"
```

### 2.2 Specification File (json_output_format_spec.md)

```markdown
# JSON Output Format Implementation

## High-Level Objective
Add a new JSON output format to the transcript analytics system that provides structured data for API integrations.

## Implementation Details

1. Update `output_format.py` to add support for JSON output
2. Add file extension trigger `.json` to the main processing function
3. Update tests to verify JSON output format works correctly

## Technical Requirements

1. The JSON output should include:
   - Transcript metadata (title, date, duration)
   - Word frequency data (top N words with counts)
   - Sentence count and average sentence length
   - Formatted timestamps for key sections

2. The implementation should:
   - Use Python's json module for formatting
   - Be properly indented for readability
   - Include a schema version field
   - Handle special characters correctly

## Reference
See `adw/new_output_type.py` for an example of how previous output formats were implemented.
```

## Example 3: Automated Versioning System

### 3.1 Configuration File (versioning_system.yaml)

```yaml
prompt: "specs/versioning_system_spec.md"
coder_model: "claude-3-opus"
evaluator_model: "gpt-4o"
max_iterations: 4
execution_command: "./run_versioning_tests.sh"
context_editable:
  - "src/aider_has_a_secret/version.py"
  - "src/aider_has_a_secret/__init__.py"
  - "tests/test_version.py"
  - "run_versioning_tests.sh"
context_read_only:
  - "adw/versioning.py"
  - "adw/versioning.sh"
evaluator: "default"
```

### 3.2 Specification File (versioning_system_spec.md)

```markdown
# Automated Versioning System

## High-Level Objective
Implement an automated versioning system that manages semantic versioning for the project and provides utilities for version comparison and bumping.

## Implementation Details

1. Create a `version.py` module with:
   - Version parsing utilities
   - Version comparison functionality
   - Version increment methods (patch, minor, major)
   
2. Update `__init__.py` to expose version information
3. Create comprehensive tests for versioning functionality
4. Create a shell script to test the versioning system

## Technical Requirements

1. The versioning system should:
   - Follow semantic versioning (MAJOR.MINOR.PATCH)
   - Support pre-release versions (alpha, beta, rc)
   - Support build metadata
   - Provide comparison operators (>, <, ==, >=, <=)

2. The implementation should:
   - Use a class-based approach
   - Include type hints and docstrings
   - Have 90%+ test coverage
   - Handle edge cases gracefully

## Reference
See `adw/versioning.py` and `adw/versioning.sh` for examples of how versioning systems work.
```

# Teaching Guide: How to Apply the Director Pattern

## Step 1: Understand the Codebase Structure

Before creating an AI Developer Workflow:

1. **Identify key modules**: Locate the main components of the codebase
2. **Understand dependencies**: Map relationships between modules
3. **Review existing patterns**: Look for established coding patterns
4. **Check testing structure**: Note how tests are organized and run

## Step 2: Create a Specification Document

Write a detailed spec in Markdown format:

1. **High-level objective**: Clearly state what needs to be accomplished
2. **Implementation details**: Break down specific components to be created/modified
3. **Technical requirements**: Provide specific technical constraints and goals
4. **References**: Link to examples or documentation that provide context

## Step 3: Configure the Director Pattern

Create a YAML configuration file with:

1. **Prompt**: Path to your specification document
2. **Models**: Select appropriate AI coding and evaluation models
3. **Context**: List editable and read-only files
4. **Execution**: Define how to validate the implementation
5. **Iterations**: Set an appropriate maximum iteration count

## Step 4: Run the Director

Execute the pattern and monitor progress:

1. **Initial run**: `python director.py -c your_config.yaml`
2. **Monitor logs**: Review the director_log.txt for insights
3. **Analyze iterations**: See how the AI refines its approach

## Step 5: Verify and Refine the Results

After completion:

1. **Review changes**: Examine code modifications
2. **Run additional tests**: Verify beyond the execution command
3. **Refine if needed**: Make manual adjustments or run again with updated specs

# Best Practices for Creating Effective AI Developer Workflows

1. **Start with complete specifications**: Clearly define what success looks like
2. **Provide relevant context files**: Include examples and related code
3. **Design tests first**: Create tests that validate your requirements
4. **Use appropriate models**: Match model capabilities to task complexity
5. **Set realistic iteration limits**: Complex tasks may need more iterations
6. **Include reference implementations**: Show similar patterns the AI can learn from
7. **Be specific about technical constraints**: Explicitly state requirements
8. **Create small, focused workflows**: Break complex changes into manageable pieces

# Troubleshooting the Director Pattern

## Common Issues and Solutions

1. **AI generates incomplete code**
   - Solution: Provide more detailed specifications
   - Solution: Include more context files
   - Solution: Increase maximum iterations

2. **Tests fail consistently**
   - Solution: Review test requirements for clarity
   - Solution: Provide example test implementations
   - Solution: Check if tests have dependencies not in context

3. **Director reaches max iterations without success**
   - Solution: Simplify the task into smaller workflows
   - Solution: Use a more capable model
   - Solution: Provide more explicit implementation guidance

4. **Execution command times out**
   - Solution: Simplify the execution command
   - Solution: Ensure dependencies are installed
   - Solution: Increase timeout in the director implementation

## Debugging Strategy

1. Review the `director_log.txt` file for insights
2. Check each iteration's feedback and responses
3. Run the execution command manually to verify behavior
4. Try breaking the task into smaller, more focused workflows

---

By applying these examples and guidelines, you'll be able to effectively use the Director Pattern to create autonomous AI Developer Workflows for a wide variety of software development tasks. The pattern is highly flexible and can be adapted to different codebases, languages, and development requirements.

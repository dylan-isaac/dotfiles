#!/usr/bin/env python3
"""
Director Pattern Implementation for AI Developer Workflows

This is the core implementation of the Director pattern for autonomous AI coding workflows.
"""

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
        
        # Ensure logs directory exists and update log file path
        logs_dir = Path("config/adw/logs")
        logs_dir.mkdir(parents=True, exist_ok=True)
        
        # Handle log file paths - support both absolute and relative paths
        if "log_file" in config_dict:
            log_path = Path(config_dict["log_file"])
            
            # If it's a relative path without directory components and not absolute
            if not log_path.is_absolute() and "/" in config_dict["log_file"]:
                # It's a relative path with directory components
                # Check if it's relative to config/adw
                if not (Path("config/adw") / log_path).exists():
                    # Make sure the directory exists
                    log_path.parent.mkdir(parents=True, exist_ok=True)
            elif not log_path.is_absolute() and "/" not in config_dict["log_file"]:
                # It's just a filename - place it in the logs directory
                config_dict["log_file"] = str(logs_dir / config_dict["log_file"])
        else:
            # No log_file specified, use default
            workflow_name = Path(config_path).stem
            config_dict["log_file"] = str(logs_dir / f"{workflow_name}.log")

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
        # Ensure log file directory exists
        log_path = Path(self.config.log_file)
        log_path.parent.mkdir(parents=True, exist_ok=True)
        
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
"""
PydanticAI-based implementation of the AI Developer Workflow pattern.

This module provides a PydanticAI agent that implements the AI Developer Workflow
pattern with iteration-aware prompting, tool execution, and structured evaluation.
"""

import asyncio
import logging
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Dict, List, Optional, Union, cast

import pydantic_ai
from pydantic_ai import Agent, RunContext

from .models import (
    ExecutionContext,
    FailureAnalysis,
    SecurityCheck,
    StructuredEvaluation,
    WorkflowDependencies,
)

# Set up logging
logger = logging.getLogger("adw")
logger.setLevel(logging.INFO)


class WorkflowAgent:
    """
    PydanticAI-based implementation of the AI Developer Workflow pattern.
    
    This agent orchestrates the workflow execution using PydanticAI's agent system
    with iteration-aware prompting and structured evaluation.
    """
    
    def __init__(self, deps: WorkflowDependencies):
        """Initialize the workflow agent with dependencies."""
        self.deps = deps
        
        # Initialize the coder agent
        self.coder_agent = Agent(
            deps.config.coder_model,
            deps_type=WorkflowDependencies,
        )
        
        # Initialize the evaluator agent
        self.evaluator_agent = Agent(
            deps.config.evaluator_model,
            deps_type=WorkflowDependencies,
            result_type=StructuredEvaluation,
        )
        
        # Register system prompts
        self._register_prompts()
        
        # Register tools
        self._register_tools()
        
        # Set up logging
        self._setup_logging()
    
    def _register_prompts(self):
        """Register system prompts for the coder and evaluator agents."""
        
        @self.coder_agent.system_prompt
        async def coder_system_prompt(ctx: RunContext[WorkflowDependencies]) -> str:
            """
            Generate a system prompt for the coder agent based on the current iteration.
            """
            deps = ctx.deps
            config = deps.config
            
            # Base system prompt
            base_prompt = f"""
# AI Developer Workflow: {config.name}

You are an expert coding assistant working on an AI Developer Workflow.
Your task is to implement the requirements as specified.

## Task Description
{config.prompt}

## Guidelines
- Focus on making the necessary code changes to satisfy the requirements
- Follow existing code conventions and patterns
- Write clean, well-documented code
- Consider security best practices
- Test your changes thoroughly

## Editable Files
{self._format_file_list(config.context_editable)}

## Reference Files (Read-Only)
{self._format_file_list(config.context_read_only)}

## Execution Command
```
{config.execution_command}
```
"""
            
            # Add iteration-specific context if not the first iteration
            if deps.current_iteration > 0 and deps.last_evaluation:
                last_eval = deps.last_evaluation
                
                # Add feedback from previous iteration
                iteration_context = f"""
## Previous Iteration Results (Iteration {deps.current_iteration}/{config.max_iterations})

### Execution Output
```
{deps.last_execution_output[:2000]}{'...' if len(deps.last_execution_output) > 2000 else ''}
```

### Evaluation Feedback
Success: {'✅' if last_eval.success else '❌'}
Task Completion: {last_eval.task_completion * 100:.1f}%
Security: {last_eval.security_check.risk_level.upper()} risk
Feedback: {last_eval.feedback}

### Issues To Address
{self._format_list(last_eval.security_check.issues) if not last_eval.security_check.passed else "No security issues found."}

### Next Steps
{self._format_list(last_eval.next_steps)}
"""
                
                # If this is the last attempt, emphasize the urgency
                if deps.current_iteration == config.max_iterations - 1:
                    iteration_context += """
## ⚠️ FINAL ATTEMPT ⚠️
This is your final opportunity to complete this task successfully.
Focus on addressing critical issues first and ensuring the execution command runs successfully.
"""
            else:
                iteration_context = "\n## First Attempt\nThis is your first attempt at solving this task."
            
            return base_prompt + iteration_context
        
        @self.evaluator_agent.system_prompt
        async def evaluator_system_prompt(ctx: RunContext[WorkflowDependencies]) -> str:
            """
            Generate a system prompt for the evaluator agent.
            """
            deps = ctx.deps
            config = deps.config
            
            return f"""
# AI Developer Workflow Evaluator

You are an expert evaluator for AI Developer Workflows. Your job is to provide detailed,
structured feedback on the results of workflow execution.

## Task Description
{config.prompt}

## Execution Command
```
{config.execution_command}
```

## Execution Output
```
{deps.last_execution_output}
```

## Evaluation Guidelines
1. Assess success objectively based on the execution output
2. Provide a completion percentage (0.0 to 1.0) representing how much of the task was completed
3. Check for security issues in the changes made
4. Analyze the test results if present in the output
5. Summarize all changes made
6. Provide actionable feedback and next steps

Your evaluation will be used to guide further iterations of this workflow.
Iteration: {deps.current_iteration + 1}/{config.max_iterations}

You MUST provide your response in the structured format expected by the system.
"""
    
    def _register_tools(self):
        """Register tools with the coder agent."""
        
        @self.coder_agent.tool
        async def run_command(ctx: RunContext[WorkflowDependencies], command: str) -> str:
            """
            Run a shell command and return its output.
            
            Args:
                ctx: The run context with workflow dependencies
                command: The shell command to run
                
            Returns:
                The combined stdout and stderr output of the command
            """
            logger.info(f"Running command: {command}")
            
            start_time = time.time()
            try:
                result = subprocess.run(
                    command,
                    shell=True,
                    capture_output=True,
                    text=True,
                    timeout=300,  # 5-minute timeout
                )
                output = result.stdout + result.stderr
                self.deps.execution_context.command_output = output
                self.deps.execution_context.exit_code = result.returncode
            except subprocess.TimeoutExpired:
                output = "ERROR: Command timed out after 5 minutes"
                self.deps.execution_context.command_output = output
                self.deps.execution_context.exit_code = -1
            except Exception as e:
                output = f"ERROR: {str(e)}"
                self.deps.execution_context.command_output = output
                self.deps.execution_context.exit_code = -1
            
            self.deps.execution_context.execution_time = time.time() - start_time
            return output
        
        @self.coder_agent.tool
        async def read_file(ctx: RunContext[WorkflowDependencies], file_path: str) -> str:
            """
            Read the contents of a file.
            
            Args:
                ctx: The run context with workflow dependencies
                file_path: Path to the file to read
                
            Returns:
                The contents of the file
            """
            logger.info(f"Reading file: {file_path}")
            
            path = Path(file_path)
            try:
                with open(path, "r") as f:
                    return f.read()
            except Exception as e:
                return f"ERROR: Could not read file {file_path}: {str(e)}"
        
        @self.coder_agent.tool
        async def write_file(ctx: RunContext[WorkflowDependencies], file_path: str, content: str) -> str:
            """
            Write content to a file.
            
            Args:
                ctx: The run context with workflow dependencies
                file_path: Path to the file to write
                content: Content to write to the file
                
            Returns:
                Success message or error
            """
            logger.info(f"Writing to file: {file_path}")
            
            # Check if the file is in the editable files list
            path = Path(file_path)
            editable_files = [Path(p) for p in self.deps.config.context_editable]
            
            if not any(path.is_relative_to(p) if hasattr(path, "is_relative_to") else path == p for p in editable_files):
                return f"ERROR: {file_path} is not in the list of editable files"
            
            try:
                # Create any missing parent directories
                path.parent.mkdir(parents=True, exist_ok=True)
                
                with open(path, "w") as f:
                    f.write(content)
                return f"Successfully wrote to {file_path}"
            except Exception as e:
                return f"ERROR: Could not write to file {file_path}: {str(e)}"
    
    def _setup_logging(self):
        """Set up logging for the workflow execution."""
        log_file = self.deps.config.log_file
        
        # Create log directory if it doesn't exist
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        # Configure file handler
        file_handler = logging.FileHandler(log_file)
        file_handler.setLevel(logging.INFO)
        file_handler.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
        
        # Add file handler to logger
        logger.addHandler(file_handler)
        
        # Log initial message
        logger.info(f"Starting AI Developer Workflow: {self.deps.config.name}")
        logger.info(f"Max iterations: {self.deps.config.max_iterations}")
        logger.info(f"Coder model: {self.deps.config.coder_model}")
        logger.info(f"Evaluator model: {self.deps.config.evaluator_model}")
    
    def _format_file_list(self, file_list: List[Path]) -> str:
        """Format a list of files for display in the system prompt."""
        if not file_list:
            return "None"
        return "\n".join(f"- {file}" for file in file_list)
    
    def _format_list(self, items: List[str]) -> str:
        """Format a list of items for display in the system prompt."""
        if not items:
            return "None"
        return "\n".join(f"- {item}" for item in items)
    
    async def run_execution_command(self) -> str:
        """Run the configured execution command and capture its output."""
        logger.info(f"Running execution command: {self.deps.config.execution_command}")
        
        start_time = time.time()
        try:
            result = subprocess.run(
                self.deps.config.execution_command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=300,  # 5-minute timeout
            )
            output = result.stdout + result.stderr
            self.deps.execution_context.command_output = output
            self.deps.execution_context.exit_code = result.returncode
        except subprocess.TimeoutExpired:
            output = "ERROR: Execution timed out after 5 minutes"
            self.deps.execution_context.command_output = output
            self.deps.execution_context.exit_code = -1
        except Exception as e:
            output = f"ERROR: {str(e)}"
            self.deps.execution_context.command_output = output
            self.deps.execution_context.exit_code = -1
        
        self.deps.execution_context.execution_time = time.time() - start_time
        self.deps.last_execution_output = output
        
        logger.info(f"Execution completed in {self.deps.execution_context.execution_time:.2f}s with exit code {self.deps.execution_context.exit_code}")
        return output
    
    async def analyze_failure(self) -> FailureAnalysis:
        """
        Analyze the reasons for workflow failure and provide debugging information.
        
        Returns:
            A FailureAnalysis object with root causes and suggested fixes
        """
        logger.info("Analyzing workflow failure")
        
        # Create a special agent for failure analysis
        failure_agent = Agent(
            self.deps.config.evaluator_model,
            deps_type=WorkflowDependencies,
            result_type=FailureAnalysis,
        )
        
        @failure_agent.system_prompt
        async def failure_analysis_prompt(ctx: RunContext[WorkflowDependencies]) -> str:
            deps = ctx.deps
            config = deps.config
            
            return f"""
# AI Developer Workflow Failure Analysis

The workflow "{config.name}" has failed after {deps.current_iteration}/{config.max_iterations} iterations.
Your job is to analyze the reasons for failure and provide debugging information.

## Task Description
{config.prompt}

## Last Execution Command
```
{config.execution_command}
```

## Last Execution Output
```
{deps.last_execution_output}
```

## Last Evaluation
{deps.last_evaluation.json(indent=2) if deps.last_evaluation else "No evaluation available"}

## Editable Files
{self._format_file_list(config.context_editable)}

## Reference Files (Read-Only)
{self._format_file_list(config.context_read_only)}

Analyze the failure and provide:
1. Root causes of the failure
2. Files that need to be modified to fix the issues
3. Suggested fixes for each issue
4. Any additional debugging information that would be helpful

Your analysis will be provided to the user as a debugging aid.
"""
        
        # Run the failure analysis
        result = await failure_agent.run(
            "Please analyze the workflow failure and provide debugging information",
            deps=self.deps,
        )
        
        # Update the logs_location field to point to the current log file
        failure_analysis = cast(FailureAnalysis, result.data)
        failure_analysis.logs_location = str(self.deps.config.log_file)
        
        # Log the failure analysis
        logger.info(f"Failure analysis completed: {failure_analysis.json(indent=2)}")
        
        return failure_analysis
    
    async def run(self) -> bool:
        """
        Run the workflow to completion or until max iterations is reached.
        
        Returns:
            True if successful, False otherwise
        """
        config = self.deps.config
        
        logger.info(f"Starting workflow: {config.name}")
        logger.info(f"Prompt: {config.prompt}")
        
        success = False
        
        for iteration in range(config.max_iterations):
            logger.info(f"Starting iteration {iteration + 1}/{config.max_iterations}")
            
            # Update current iteration
            self.deps.current_iteration = iteration
            
            # Run the coder agent
            logger.info(f"Running coder agent with model: {config.coder_model}")
            
            try:
                await self.coder_agent.run(
                    "Please implement the requirements as specified in the system prompt",
                    deps=self.deps,
                )
            except Exception as e:
                logger.error(f"Error running coder agent: {str(e)}")
                # Try to continue with execution
            
            # Run the execution command
            execution_output = await self.run_execution_command()
            
            # Store the execution output
            self.deps.last_execution_output = execution_output
            
            # Run the evaluator agent
            logger.info(f"Running evaluator agent with model: {config.evaluator_model}")
            
            try:
                result = await self.evaluator_agent.run(
                    "Please evaluate the results of the workflow execution",
                    deps=self.deps,
                )
                
                # Store the evaluation result
                evaluation = cast(StructuredEvaluation, result.data)
                self.deps.last_evaluation = evaluation
                
                logger.info(f"Evaluation: success={evaluation.success}, task_completion={evaluation.task_completion:.2f}")
                
                if evaluation.success:
                    logger.info("Workflow completed successfully!")
                    success = True
                    break
                else:
                    logger.info(f"Iteration {iteration + 1} failed, trying again...")
            except Exception as e:
                logger.error(f"Error running evaluator agent: {str(e)}")
                # Continue to next iteration
        
        if not success and self.deps.last_evaluation:
            # If we've reached max iterations without success, run failure analysis
            failure_analysis = await self.analyze_failure()
            
            logger.info("Workflow failed after all iterations")
            logger.info(f"Root causes: {failure_analysis.root_causes}")
            logger.info(f"Affected files: {failure_analysis.affected_files}")
            logger.info(f"Logs available at: {failure_analysis.logs_location}")
            
            # Print failure information to stdout for user feedback
            self._print_failure_information(failure_analysis)
        
        return success
    
    def _print_failure_information(self, failure_analysis: FailureAnalysis):
        """Print failure information to stdout for user feedback."""
        print("\n" + "=" * 80)
        print("📋 AI DEVELOPER WORKFLOW FAILURE REPORT")
        print("=" * 80)
        print(f"The workflow '{self.deps.config.name}' did not complete successfully.")
        print("\n🔍 ROOT CAUSES:")
        for cause in failure_analysis.root_causes:
            print(f"  • {cause}")
        
        print("\n📄 AFFECTED FILES:")
        for file in failure_analysis.affected_files:
            print(f"  • {file}")
        
        print("\n💡 SUGGESTED FIXES:")
        for fix in failure_analysis.suggested_fixes:
            print(f"  • {fix}")
        
        print("\n🔎 NEXT STEPS:")
        print(f"  • Review the log file at: {failure_analysis.logs_location}")
        print("  • Make the suggested changes manually")
        print("  • Or run the workflow again with modifications")
        print("=" * 80)
        print("To open the log file in your editor:")
        print(f"  code {failure_analysis.logs_location}")
        print("=" * 80) 
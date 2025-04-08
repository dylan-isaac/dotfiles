# AI Developer Workflow (ADW)

## Definition
An AI Developer Workflow (ADW) is a structured, executable pattern for AI-assisted software development that defines how AI models, tools, and human developers collaborate throughout the development process. It provides a repeatable, standardized approach to solving programming problems through the orchestration of AI capabilities, execution environments, and evaluation criteria.

## Key Components

1. **Specification**: Clear definitions of the task, acceptance criteria, and constraints
2. **Generation Phase**: Using AI to generate or modify code based on the specification
3. **Execution Phase**: Running, testing, or otherwise validating the generated code
4. **Evaluation Phase**: Assessing the results against success criteria
5. **Feedback Loop**: Passing evaluation results back for refinement
6. **Completion Criteria**: Clear conditions to determine when the workflow is successfully completed

## Example Implementation

### Basic ADW Configuration (YAML)

```yaml
# adw-config.yaml
name: "User Authentication Feature Implementation"
description: "Implements user registration, login, and profile management"
version: "1.0.0"

phases:
  - name: "preparation"
    description: "Set up project structure and dependencies"
    tools:
      - "npm init"
      - "npm install express mongoose bcrypt jsonwebtoken"
    completion:
      - "package.json exists"
      - "node_modules directory exists"

  - name: "implementation"
    description: "Implement authentication features"
    tools:
      - "aider --model gpt-4o --architect"
    context:
      - "specs/auth-requirements.md"
      - "src/app.js"
    tasks:
      - "Create user model with proper validation"
      - "Implement registration endpoint with password hashing"
      - "Implement login endpoint with JWT token generation"
      - "Add middleware for authentication verification"
    completion:
      - "src/models/user.js exists"
      - "src/routes/auth.js exists"
      - "src/middleware/auth.js exists"

  - name: "testing"
    description: "Write and run tests for authentication"
    tools:
      - "npm install --save-dev jest supertest"
      - "npx jest"
    completion:
      - "tests pass with 80% coverage"
      - "All authentication endpoints return proper status codes"

  - name: "refinement"
    description: "Improve code quality and fix issues"
    tools:
      - "aider --model claude-3-sonnet-20240620 --ask"
      - "npm run lint"
    completion:
      - "No lint errors"
      - "Code review complete"

accessibility:
  level: "AA"
  requirements:
    - "All form inputs must have proper labels"
    - "Error messages must be clear and descriptive"
    - "Form validation must be accessible to screen readers"
    - "Color contrast must meet WCAG 2.1 AA standards"
  testing:
    - "Run axe-core accessibility tests"
    - "Test with screen readers"
    - "Verify keyboard navigation"
```

### Python Implementation of ADW using Aider

```python
import os
import yaml
import json
import subprocess
from typing import Dict, List, Any, Optional

class AIDevWorkflow:
    """
    Implementation of an AI Developer Workflow using Aider
    """
    
    def __init__(
        self, 
        config_path: str,
        working_dir: str = "./",
        verbose: bool = True
    ):
        self.config_path = config_path
        self.working_dir = working_dir
        self.verbose = verbose
        self.logs = []
        
        # Load configuration
        with open(config_path, 'r') as f:
            self.config = yaml.safe_load(f)
        
        self.name = self.config.get('name', 'Unnamed ADW')
        self.description = self.config.get('description', '')
        self.phases = self.config.get('phases', [])
        self.accessibility = self.config.get('accessibility', {})
        
    def log(self, phase: str, message: str) -> None:
        """Log a message with timestamp"""
        import datetime
        timestamp = datetime.datetime.now().isoformat()
        log_entry = {
            "timestamp": timestamp,
            "phase": phase,
            "message": message
        }
        self.logs.append(log_entry)
        
        if self.verbose:
            print(f"[{timestamp}] {phase}: {message}")
        
        # Also write to log file
        with open("adw_log.txt", "a") as f:
            f.write(f"[{timestamp}] {phase}: {message}\n")
    
    def run(self) -> Dict[str, Any]:
        """Run the entire AI Developer Workflow"""
        self.log("START", f"Starting ADW: {self.name}")
        self.log("INFO", f"Description: {self.description}")
        
        results = []
        
        # Run each phase in sequence
        for phase in self.phases:
            phase_name = phase.get('name', 'unnamed')
            phase_description = phase.get('description', '')
            
            self.log(phase_name.upper(), f"Starting phase: {phase_description}")
            
            # Run phase tools/commands
            phase_result = self._run_phase(phase)
            results.append(phase_result)
            
            # Check completion criteria
            completion_criteria = phase.get('completion', [])
            completion_result = self._check_completion(phase_name, completion_criteria)
            
            if not completion_result['success']:
                self.log("ERROR", f"Phase {phase_name} failed to complete")
                self.log("ERROR", f"Failed criteria: {', '.join(completion_result['failed_criteria'])}")
                
                # Break workflow if a phase fails
                return {
                    "success": False,
                    "name": self.name,
                    "logs": self.logs,
                    "results": results,
                    "failed_phase": phase_name,
                    "failed_criteria": completion_result['failed_criteria']
                }
        
        # Run accessibility checks if configured
        if self.accessibility:
            a11y_result = self._run_accessibility_checks()
            results.append(a11y_result)
            
            if not a11y_result.get('success', False):
                self.log("WARNING", "Accessibility checks failed")
                return {
                    "success": False,
                    "name": self.name,
                    "logs": self.logs,
                    "results": results,
                    "failed_phase": "accessibility",
                    "failed_criteria": a11y_result.get('failed_criteria', [])
                }
        
        self.log("COMPLETE", f"ADW {self.name} completed successfully")
        
        return {
            "success": True,
            "name": self.name,
            "logs": self.logs,
            "results": results
        }
    
    def _run_phase(self, phase: Dict[str, Any]) -> Dict[str, Any]:
        """Run a single phase of the workflow"""
        phase_name = phase.get('name', 'unnamed')
        tools = phase.get('tools', [])
        context = phase.get('context', [])
        tasks = phase.get('tasks', [])
        
        results = []
        
        # Process context files
        for context_file in context:
            self.log(phase_name, f"Loading context: {context_file}")
            if os.path.exists(os.path.join(self.working_dir, context_file)):
                with open(os.path.join(self.working_dir, context_file), 'r') as f:
                    content = f.read()
                self.log(phase_name, f"Loaded context file: {context_file}")
            else:
                self.log("WARNING", f"Context file not found: {context_file}")
        
        # Run each tool
        for tool in tools:
            self.log(phase_name, f"Running tool: {tool}")
            
            try:
                # Special handling for aider
                if tool.startswith("aider"):
                    # If we have tasks, run aider for each task
                    if tasks and "--architect" in tool:
                        for task in tasks:
                            aider_cmd = f"{tool} --input \"{task}\""
                            result = self._run_command(aider_cmd)
                            results.append({
                                "tool": aider_cmd,
                                "success": result['returncode'] == 0,
                                "output": result['stdout'][:500] + "..." if len(result['stdout']) > 500 else result['stdout']
                            })
                    else:
                        # Run aider normally
                        result = self._run_command(tool)
                        results.append({
                            "tool": tool,
                            "success": result['returncode'] == 0,
                            "output": result['stdout'][:500] + "..." if len(result['stdout']) > 500 else result['stdout']
                        })
                else:
                    # Run other commands
                    result = self._run_command(tool)
                    results.append({
                        "tool": tool,
                        "success": result['returncode'] == 0,
                        "output": result['stdout'][:500] + "..." if len(result['stdout']) > 500 else result['stdout']
                    })
            except Exception as e:
                self.log("ERROR", f"Tool execution failed: {str(e)}")
                results.append({
                    "tool": tool,
                    "success": False,
                    "error": str(e)
                })
        
        return {
            "phase": phase_name,
            "results": results
        }
    
    def _run_command(self, command: str) -> Dict[str, Any]:
        """Run a shell command and return results"""
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.working_dir
            )
            
            return {
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
        except Exception as e:
            self.log("ERROR", f"Command execution error: {str(e)}")
            return {
                "returncode": -1,
                "stdout": "",
                "stderr": str(e)
            }
    
    def _check_completion(self, phase_name: str, criteria: List[str]) -> Dict[str, Any]:
        """Check if completion criteria are met"""
        self.log(phase_name, f"Checking completion criteria: {criteria}")
        
        failed_criteria = []
        
        for criterion in criteria:
            # File existence check
            if "exists" in criterion:
                file_path = criterion.split(" exists")[0].strip()
                if not os.path.exists(os.path.join(self.working_dir, file_path)):
                    failed_criteria.append(criterion)
                    self.log(phase_name, f"Criterion failed: {criterion}")
            
            # Directory existence check
            elif "directory exists" in criterion:
                dir_path = criterion.split(" directory exists")[0].strip()
                if not os.path.isdir(os.path.join(self.working_dir, dir_path)):
                    failed_criteria.append(criterion)
                    self.log(phase_name, f"Criterion failed: {criterion}")
            
            # Test pass check
            elif "tests pass" in criterion:
                # This would need to parse test results
                # Simplified for this example
                if "npm run test" in str(self.logs):
                    last_test_run = [log for log in self.logs if "npm run test" in log.get("message", "")]
                    if last_test_run and "FAIL" in last_test_run[-1].get("message", ""):
                        failed_criteria.append(criterion)
                        self.log(phase_name, f"Criterion failed: {criterion}")
            
            # No lint errors check
            elif "No lint errors" in criterion:
                if "npm run lint" in str(self.logs):
                    last_lint_run = [log for log in self.logs if "npm run lint" in log.get("message", "")]
                    if last_lint_run and "error" in last_lint_run[-1].get("message", "").lower():
                        failed_criteria.append(criterion)
                        self.log(phase_name, f"Criterion failed: {criterion}")
            
            # For other criteria, we'd need more specific checks
            # This is a simplified implementation
            
            self.log(phase_name, f"Criterion passed: {criterion}")
        
        return {
            "success": len(failed_criteria) == 0,
            "failed_criteria": failed_criteria
        }
    
    def _run_accessibility_checks(self) -> Dict[str, Any]:
        """Run accessibility checks on the project"""
        a11y_level = self.accessibility.get('level', 'AA')
        requirements = self.accessibility.get('requirements', [])
        testing = self.accessibility.get('testing', [])
        
        self.log("ACCESSIBILITY", f"Running accessibility checks for WCAG {a11y_level}")
        self.log("ACCESSIBILITY", f"Requirements: {requirements}")
        
        # Check if we have axe-core installed
        axe_installed = os.path.exists(os.path.join(self.working_dir, "node_modules", "axe-core"))
        if not axe_installed:
            self.log("ACCESSIBILITY", "Installing axe-core for accessibility testing")
            self._run_command("npm install --save-dev axe-core")
        
        failed_criteria = []
        
        # Run specified accessibility tests
        for test in testing:
            self.log("ACCESSIBILITY", f"Running test: {test}")
            
            if "axe-core" in test:
                # Run axe-core tests
                result = self._run_command("npx axe --exit .")
                if result['returncode'] != 0:
                    failed_criteria.append(f"axe-core tests failed: {result['stderr']}")
            
            # Other test types would need specific implementations
        
        # Generate accessibility report
        report_path = os.path.join(self.working_dir, "accessibility-report.md")
        report_content = f"""# Accessibility Report for {self.name}

## Overview
- WCAG Level: {a11y_level}
- Date: {import datetime; datetime.datetime.now().strftime('%Y-%m-%d')}

## Requirements
{os.linesep.join(['- ' + req for req in requirements])}

## Test Results
{os.linesep.join(['- [{"✅" if test not in failed_criteria else "❌"}] ' + test for test in testing])}

## Issues Found
{os.linesep.join(['- ' + issue for issue in failed_criteria]) if failed_criteria else "No issues found."}
"""
        
        with open(report_path, 'w') as f:
            f.write(report_content)
        
        self.log("ACCESSIBILITY", f"Generated accessibility report: {report_path}")
        
        return {
            "success": len(failed_criteria) == 0,
            "level": a11y_level,
            "report_path": report_path,
            "failed_criteria": failed_criteria
        }


# Example usage
if __name__ == "__main__":
    workflow = AIDevWorkflow(
        config_path="adw-config.yaml",
        working_dir="./my-auth-project"
    )
    
    result = workflow.run()
    
    print("\n=== AI DEVELOPER WORKFLOW SUMMARY ===")
    print(f"Workflow: {result['name']}")
    print(f"Success: {result['success']}")
    
    if not result['success']:
        print(f"\n❌ Workflow failed in phase: {result.get('failed_phase', 'unknown')}")
        print("Failed criteria:")
        for criterion in result.get('failed_criteria', []):
            print(f"- {criterion}")
    else:
        print("\n✅ Workflow completed successfully!")
```

### Executable Spec-Based ADW Example (User Authentication)

```markdown
# AI Developer Workflow Specification

## Feature: User Authentication System

### Objectives
1. Create a secure user authentication system with registration and login
2. Implement password hashing and JWT token generation
3. Add middleware for protected routes
4. Create user profile management
5. Implement accessibility best practices

### Implementation Notes
- Use Express.js for the backend framework
- Use MongoDB with Mongoose for data storage
- Use bcrypt for password hashing
- Use jsonwebtoken for JWT handling
- Follow RESTful API design principles

### Context Files
- src/app.js (Express application setup)
- src/models/ (Database models directory)
- src/routes/ (API routes directory)
- src/middleware/ (Middleware functions)
- src/controllers/ (Business logic)

### Low-Level Tasks
1. Create User model with name, email, password fields
2. Implement user registration endpoint (/api/users/register)
3. Implement login endpoint (/api/users/login)
4. Create authentication middleware
5. Add user profile endpoint (/api/users/profile)
6. Implement password reset functionality
7. Add input validation and error handling
8. Implement rate limiting for login attempts

### Accessibility Requirements
1. Ensure form inputs have proper labels and ARIA attributes
2. Provide clear error messages with proper ARIA roles
3. Support keyboard navigation for all interactive elements
4. Maintain color contrast ratio of at least 4.5:1
5. Add focus management for modal dialogs and forms

### Acceptance Criteria
1. Users can register with email, password, and name
2. Users can log in and receive a JWT token
3. Protected routes require valid JWT token
4. Password is properly hashed in the database
5. User profile can be viewed and updated
6. All accessibility requirements are met
7. API endpoints return appropriate status codes and error messages
8. Tests pass with at least 80% coverage
```

## Related Terms
- **Director Pattern**: A specific implementation of ADW focused on autonomous code generation and evaluation
- **Spec-Based AI Coding**: A development approach where detailed specifications drive AI code generation
- **Aider**: An AI coding assistant commonly used in ADW implementations
- **Architect Mode**: A mode in some AI assistants focused on planning before implementation
- **Autonomous Agent Workflows**: Multi-agent systems that can complete complex tasks with minimal supervision

## References
- See `docs/paic/07-let-the-code-write-itself.md` for detailed explanation of ADW concepts
- See `glossary/DirectorPattern.md` for information on the Director Pattern implementation
- See `docs/aider/chatmodes.md` for details on Aider's different interaction modes
- See `docs/aider/yaml-config.md` for Aider configuration options 
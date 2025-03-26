"""
Pydantic models for the AI Developer Workflow (ADW) pattern.
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Any, Dict, List, Literal, Optional, Union

from pydantic import BaseModel, Field, field_validator


class RiskLevel(str, Enum):
    """Risk level for security checks."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class ChangeType(str, Enum):
    """Type of change made to a file."""
    ADD = "add"
    MODIFY = "modify"
    DELETE = "delete"


class SecurityCheck(BaseModel):
    """Security check results."""
    passed: bool
    issues: List[str] = Field(default_factory=list)
    risk_level: RiskLevel = RiskLevel.LOW
    recommendations: List[str] = Field(default_factory=list)


class TestResult(BaseModel):
    """Results from running tests."""
    passed: bool
    total_tests: int
    passed_tests: int
    failed_tests: int
    error_messages: List[str] = Field(default_factory=list)
    coverage: Optional[float] = None


class ChangesetItem(BaseModel):
    """A single change made during the workflow."""
    file: str
    change_type: ChangeType
    description: str
    lines_changed: Optional[int] = None


class WorkflowChangeset(BaseModel):
    """Set of changes made during the workflow execution."""
    changes: List[ChangesetItem] = Field(default_factory=list)
    summary: str = ""


class ExecutionContext(BaseModel):
    """Context for execution of the workflow."""
    working_directory: str
    environment_variables: Dict[str, str] = Field(default_factory=dict)
    command_output: str = ""
    exit_code: int = 0
    execution_time: float = 0.0


class StructuredEvaluation(BaseModel):
    """Structured evaluation of the workflow execution."""
    success: bool
    task_completion: float  # 0.0 to 1.0
    security_check: SecurityCheck = Field(default_factory=SecurityCheck)
    test_results: Optional[TestResult] = None
    changeset: WorkflowChangeset = Field(default_factory=WorkflowChangeset)
    feedback: str = ""
    next_steps: List[str] = Field(default_factory=list)
    
    @field_validator('task_completion')
    @classmethod
    def validate_completion_percentage(cls, v):
        """Validate that task completion is between 0.0 and 1.0."""
        if v < 0.0 or v > 1.0:
            raise ValueError("Task completion must be between 0.0 and 1.0")
        return v


class WorkflowConfig(BaseModel):
    """Configuration for an AI Developer Workflow."""
    name: str
    prompt: str
    coder_model: str
    evaluator_model: str
    max_iterations: int = Field(default=5)
    execution_command: str
    context_editable: List[Path]
    context_read_only: List[Path] = Field(default_factory=list)
    evaluator: Literal["default", "unittest", "pytest", "structured"] = "structured"
    log_file: Path = Field(default=Path("logs/workflow.log"))

    @field_validator('context_editable', 'context_read_only', mode='before')
    @classmethod
    def validate_paths(cls, v):
        """Convert string paths to Path objects and validate they exist."""
        if isinstance(v, list):
            return [Path(p) if isinstance(p, str) else p for p in v]
        return v


@dataclass
class WorkflowDependencies:
    """Dependencies for an AI Developer Workflow."""
    config: WorkflowConfig
    current_iteration: int = 0
    max_iterations: int = 5
    last_execution_output: str = ""
    last_evaluation: Optional[StructuredEvaluation] = None
    working_directory: Path = field(default_factory=Path.cwd)
    execution_context: ExecutionContext = field(default_factory=lambda: ExecutionContext(working_directory=str(Path.cwd())))


class FailureAnalysis(BaseModel):
    """Analysis of why a workflow failed."""
    root_causes: List[str]
    affected_files: List[str]
    suggested_fixes: List[str]
    debug_information: Dict[str, Any] = Field(default_factory=dict)
    logs_location: Optional[str] = None 
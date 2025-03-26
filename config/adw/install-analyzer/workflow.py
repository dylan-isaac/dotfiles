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

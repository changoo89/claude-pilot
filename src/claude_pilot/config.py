"""
Configuration constants for claude-pilot.

This module contains all configuration values including version info,
repository URLs, and managed file lists.
"""

from __future__ import annotations

import importlib.resources
from pathlib import Path
from typing import Any

# Version information
VERSION = "3.1.0"
VERSION_FILE = ".claude/.pilot-version"

# Remote repository URLs
REPO_BASE = "https://raw.githubusercontent.com/changoo89/claude-pilot/main"
REPO_RAW = REPO_BASE

# Request timeout (seconds)
REQUEST_TIMEOUT = 30

# PyPI API timeout (seconds)
PYPI_TIMEOUT = 5

# PyPI API endpoint
PYPI_API_URL = "https://pypi.org/pypi/claude-pilot/json"

# Managed files - synced with install.sh MANAGED_FILES array
# Format: (source_path, dest_path)
MANAGED_FILES: list[tuple[str, str]] = [
    # Commands (0x and 9x prefix only - claude-pilot core)
    (".claude/commands/00_plan.md", ".claude/commands/00_plan.md"),
    (".claude/commands/01_confirm.md", ".claude/commands/01_confirm.md"),
    (".claude/commands/02_execute.md", ".claude/commands/02_execute.md"),
    (".claude/commands/03_close.md", ".claude/commands/03_close.md"),
    (".claude/commands/90_review.md", ".claude/commands/90_review.md"),
    (".claude/commands/91_document.md", ".claude/commands/91_document.md"),
    (".claude/commands/92_init.md", ".claude/commands/92_init.md"),
    # Templates
    (".claude/templates/CONTEXT.md.template", ".claude/templates/CONTEXT.md.template"),
    (
        ".claude/templates/CONTEXT-tier2.md.template",
        ".claude/templates/CONTEXT-tier2.md.template",
    ),
    (
        ".claude/templates/CONTEXT-tier3.md.template",
        ".claude/templates/CONTEXT-tier3.md.template",
    ),
    (".claude/templates/SKILL.md.template", ".claude/templates/SKILL.md.template"),
    # Hooks
    (".claude/scripts/hooks/typecheck.sh", ".claude/scripts/hooks/typecheck.sh"),
    (".claude/scripts/hooks/lint.sh", ".claude/scripts/hooks/lint.sh"),
    (".claude/scripts/hooks/check-todos.sh", ".claude/scripts/hooks/check-todos.sh"),
    (".claude/scripts/hooks/branch-guard.sh", ".claude/scripts/hooks/branch-guard.sh"),
    # Version file
    (".claude/.pilot-version", ".claude/.pilot-version"),
    # Rules (new - Claude Code official pattern)
    (".claude/rules/core/workflow.md", ".claude/rules/core/workflow.md"),
    (".claude/rules/documentation/tier-rules.md", ".claude/rules/documentation/tier-rules.md"),
    # Guides (new - methodology documentation)
    (".claude/guides/tdd-methodology.md", ".claude/guides/tdd-methodology.md"),
    (".claude/guides/ralph-loop.md", ".claude/guides/ralph-loop.md"),
    (".claude/guides/vibe-coding.md", ".claude/guides/vibe-coding.md"),
    (".claude/guides/prp-framework.md", ".claude/guides/prp-framework.md"),
    (".claude/guides/review-checklist.md", ".claude/guides/review-checklist.md"),
    (".claude/guides/gap-detection.md", ".claude/guides/gap-detection.md"),
    (".claude/guides/3tier-documentation.md", ".claude/guides/3tier-documentation.md"),
    (".claude/guides/test-environment.md", ".claude/guides/test-environment.md"),
]

# User-owned files (never overwritten)
USER_FILES: list[str] = [
    "CLAUDE.md",
    # "AGENTS.md",  # REMOVED - moved to DEPRECATED_FILES (not Claude Code official)
    ".pilot",
    ".claude/settings.json",
    ".claude/local",
]

# Deprecated files (removed in newer versions)
DEPRECATED_FILES: list[str] = [
    ".claude/templates/PRP.md.template",
    "AGENTS.md",  # ADDED - will be auto-deleted on update (not Claude Code official)
]


def get_target_dir() -> Path:
    """
    Get the target directory for operations.

    Returns the current working directory as a Path object.
    """
    return Path.cwd()


def get_version_file_path(target_dir: Path | None = None) -> Path:
    """
    Get the path to the version file.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        Path to the .pilot-version file.
    """
    if target_dir is None:
        target_dir = get_target_dir()
    return target_dir / VERSION_FILE


def get_templates_path() -> Any:
    """
    Get the path to the bundled templates directory.

    Returns:
        Traversable path to the templates directory in the package.
    """
    return importlib.resources.files("claude_pilot") / "templates"


def get_template_path(template_name: str) -> Any:
    """
    Get the path to a specific template file.

    Args:
        template_name: Name of the template file (e.g., ".claude/commands/00_plan.md")

    Returns:
        Traversable path to the template file.
    """
    return get_templates_path() / template_name

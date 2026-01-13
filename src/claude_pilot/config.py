"""
Configuration constants for claude-pilot.

This module contains all configuration values including version info,
repository URLs, and managed file lists.
"""

from __future__ import annotations

from pathlib import Path

# Version information
VERSION = "1.7.0"
VERSION_FILE = ".claude/.pilot-version"

# Remote repository URLs
REPO_BASE = "https://raw.githubusercontent.com/changoo89/claude-pilot/main"
REPO_RAW = REPO_BASE

# Request timeout (seconds)
REQUEST_TIMEOUT = 30

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
]

# User-owned files (never overwritten)
USER_FILES: list[str] = [
    "CLAUDE.md",
    "AGENTS.md",
    ".pilot",
    ".claude/settings.json",
    ".claude/local",
]

# Deprecated files (removed in newer versions)
DEPRECATED_FILES: list[str] = [
    ".claude/templates/PRP.md.template",
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

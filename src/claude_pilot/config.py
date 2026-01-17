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
VERSION = "4.0.5"
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
    # Commands CONTEXT file (curated subset)
    (".claude/commands/CONTEXT.md", ".claude/commands/CONTEXT.md"),
    # Agents (new - context isolation architecture)
    (".claude/agents/*.md", ".claude/agents/"),
    (".claude/agents/CONTEXT.md", ".claude/agents/CONTEXT.md"),
    # Skills (new - progressive disclosure knowledge)
    (".claude/skills/**/SKILL.md", ".claude/skills/"),
    (".claude/skills/**/REFERENCE.md", ".claude/skills/"),
    # Skills CONTEXT file (curated subset)
    (".claude/skills/CONTEXT.md", ".claude/skills/CONTEXT.md"),
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
    (".claude/templates/AGENT.md.template", ".claude/templates/AGENT.md.template"),
    (".claude/templates/gap-checklist.md", ".claude/templates/gap-checklist.md"),
    # Hooks
    (".claude/scripts/hooks/typecheck.sh", ".claude/scripts/hooks/typecheck.sh"),
    (".claude/scripts/hooks/lint.sh", ".claude/scripts/hooks/lint.sh"),
    (".claude/scripts/hooks/check-todos.sh", ".claude/scripts/hooks/check-todos.sh"),
    (".claude/scripts/hooks/branch-guard.sh", ".claude/scripts/hooks/branch-guard.sh"),
    # Worktree utilities (worktree support)
    (".claude/scripts/worktree-utils.sh", ".claude/scripts/worktree-utils.sh"),
    # Statusline script (pending count display)
    (".claude/scripts/statusline.sh", ".claude/scripts/statusline.sh"),
    # Codex sync script (GPT delegation via codex exec)
    (".claude/scripts/codex-sync.sh", ".claude/scripts/codex-sync.sh"),
    # Version file
    (".claude/.pilot-version", ".claude/.pilot-version"),
    # Rules (new - Claude Code official pattern)
    (".claude/rules/core/workflow.md", ".claude/rules/core/workflow.md"),
    (".claude/rules/documentation/tier-rules.md", ".claude/rules/documentation/tier-rules.md"),
    # Codex Delegator (new - GPT expert delegation)
    (".claude/rules/delegator/delegation-format.md", ".claude/rules/delegator/delegation-format.md"),
    (".claude/rules/delegator/model-selection.md", ".claude/rules/delegator/model-selection.md"),
    (".claude/rules/delegator/orchestration.md", ".claude/rules/delegator/orchestration.md"),
    (".claude/rules/delegator/triggers.md", ".claude/rules/delegator/triggers.md"),
    (".claude/rules/delegator/prompts/architect.md", ".claude/rules/delegator/prompts/architect.md"),
    (".claude/rules/delegator/prompts/code-reviewer.md", ".claude/rules/delegator/prompts/code-reviewer.md"),
    (".claude/rules/delegator/prompts/plan-reviewer.md", ".claude/rules/delegator/prompts/plan-reviewer.md"),
    (".claude/rules/delegator/prompts/scope-analyst.md", ".claude/rules/delegator/prompts/scope-analyst.md"),
    (".claude/rules/delegator/prompts/security-analyst.md", ".claude/rules/delegator/prompts/security-analyst.md"),
    # Guides (new - methodology documentation)
    (".claude/guides/*.md", ".claude/guides/"),
    # Guides CONTEXT file (curated subset)
    (".claude/guides/CONTEXT.md", ".claude/guides/CONTEXT.md"),
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

# External skills configuration
EXTERNAL_SKILLS: dict[str, dict[str, str]] = {
    "vercel-agent-skills": {
        "repo": "vercel-labs/agent-skills",
        "branch": "main",
        "skills_path": "skills",
    }
}

# External skills directories and files
EXTERNAL_SKILLS_DIR = ".claude/skills/external"
EXTERNAL_SKILLS_VERSION_FILE = ".claude/.external-skills-version"

# Codex authentication file path (for CLI availability check)
CODEX_AUTH_PATH = ".codex/auth.json"


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
    Get the path to the bundled assets directory.

    Returns:
        Traversable path to the assets directory in the package.
    """
    return importlib.resources.files("claude_pilot") / "assets"


def get_template_path(template_name: str) -> Any:
    """
    Get the path to a specific template file.

    Args:
        template_name: Name of the template file (e.g., ".claude/commands/00_plan.md")

    Returns:
        Traversable path to the template file.
    """
    return get_templates_path() / template_name

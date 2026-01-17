"""
Update functionality for claude-pilot.

This module handles updating managed files from bundled package templates,
with support for different merge strategies and backup management.
"""

from __future__ import annotations

import importlib.resources  # noqa: F401
import json
import shutil
import tempfile
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import Any

import click

from claude_pilot import config


class MergeStrategy(str, Enum):
    """Merge strategy for updates."""

    AUTO = "auto"
    MANUAL = "manual"


class UpdateStatus(str, Enum):
    """Status of update process."""

    ALREADY_CURRENT = "already_current"
    UPDATED = "updated"
    FAILED = "failed"


def get_current_version(target_dir: Path | None = None) -> str:
    """
    Get the currently installed version.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        The current version string, or "none" if not installed.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()
    version_file = config.get_version_file_path(target_dir)
    if version_file.exists():
        return version_file.read_text().strip()
    return "none"


def ensure_gitignore(target_dir: Path) -> None:
    """
    Add .pilot/ to .gitignore if not present.

    This ensures that plan tracking files are not tracked by git,
    which is critical for worktree support where .pilot/ state
    differs between main and worktree.

    Args:
        target_dir: Target directory containing .gitignore.
    """
    gitignore_path = target_dir / ".gitignore"
    pilot_pattern = ".pilot/"

    # Read existing content
    existing = ""
    if gitignore_path.exists():
        existing = gitignore_path.read_text()

    # Check if already present
    if pilot_pattern in existing:
        return

    # Append to .gitignore
    with gitignore_path.open("a") as f:
        if existing and not existing.endswith("\n"):
            f.write("\n")
        f.write("\n# claude-pilot plan tracking (worktree support)\n")
        f.write(".pilot/\n")


def get_latest_version() -> str:
    """
    Get the latest version from PyPI or fallback to config.

    Returns:
        The latest version string from PyPI, or config.VERSION if unavailable.
    """
    pypi_version = get_pypi_version()
    return pypi_version if pypi_version else config.VERSION


def get_pypi_version() -> str | None:
    """
    Fetch the latest version from PyPI API.

    Returns:
        The latest version string from PyPI, or None if fetch fails.
    """
    import requests

    try:
        response = requests.get(
            config.PYPI_API_URL,
            timeout=config.PYPI_TIMEOUT,
        )
        response.raise_for_status()
        data = response.json()
        return str(data["info"]["version"])
    except requests.RequestException as e:
        click.secho(f"! Warning: Could not fetch PyPI version: {e}", fg="yellow")
        return None


def get_installed_version() -> str:
    """
    Get the currently installed package version.

    Returns:
        The installed version string from config.
    """
    return config.VERSION


def upgrade_pip_package() -> bool:
    """
    Upgrade the claude-pilot pip package to the latest version.

    Returns:
        True if upgrade succeeded, False otherwise.
    """
    import subprocess
    import sys

    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip", "install", "--upgrade", "claude-pilot"],
            capture_output=True,
            text=True,
        )
        if result.returncode == 0:
            click.secho("i Pip package upgraded successfully", fg="blue")
            return True
        else:
            click.secho(f"! Pip upgrade failed: {result.stderr}", fg="yellow")
            return False
    except Exception as e:
        click.secho(f"! Error during pip upgrade: {e}", fg="yellow")
        return False


def create_backup(target_dir: Path) -> Path:
    """
    Create a backup of the .claude directory.

    Args:
        target_dir: Target directory containing .claude/.

    Returns:
        Path to the backup directory.
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_dir = target_dir / ".claude-backups" / timestamp
    claude_dir = target_dir / ".claude"

    # Ensure backup parent directory exists
    backup_dir.parent.mkdir(parents=True, exist_ok=True)

    if claude_dir.exists():
        shutil.copytree(claude_dir, backup_dir)
        click.secho(f"i Backup created: {backup_dir.name}", fg="blue")

    return backup_dir


def cleanup_old_backups(target_dir: Path, keep: int = 5) -> list[Path]:
    """
    Remove old backups, keeping only the most recent ones.

    Args:
        target_dir: Target directory containing backups.
        keep: Number of backups to keep.

    Returns:
        List of removed backup paths.
    """
    backups_dir = target_dir / ".claude-backups"
    if not backups_dir.exists():
        return []

    backups = sorted(
        [d for d in backups_dir.iterdir() if d.is_dir()],
        key=lambda x: x.stat().st_mtime,
        reverse=True,
    )

    removed = []
    for old_backup in backups[keep:]:
        shutil.rmtree(old_backup)
        removed.append(old_backup)

    if removed:
        click.secho(f"i Removed {len(removed)} old backup(s)", fg="blue")

    return removed


def copy_template_from_package(
    src: Any,
    dest: Path,
) -> bool:
    """
    Copy a single template file from package to destination.

    Args:
        src: Source template path (Traversable).
        dest: Destination file path.

    Returns:
        True if successful, False otherwise.
    """
    try:
        dest.parent.mkdir(parents=True, exist_ok=True)
        with src.open("rb") as f_src:
            dest.write_bytes(f_src.read())

        # Set executable permission for shell scripts (.sh files)
        # This ensures hooks can run after deployment
        if str(dest).endswith('.sh'):
            import stat
            dest.chmod(dest.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

        return True
    except (OSError, IOError):
        return False


def copy_templates_from_package(
    target_dir: Path,
) -> tuple[int, int]:
    """
    Copy all template files from the bundled package.

    Args:
        target_dir: Target directory for templates.

    Returns:
        Tuple of (success_count, fail_count).
    """
    templates_path = config.get_templates_path()
    success_count = 0
    fail_count = 0

    for src_path in templates_path.rglob("*"):
        if not src_path.is_file():
            continue

        # Get relative path from templates root
        src_str = str(src_path)
        templates_str = str(templates_path)
        if src_str.startswith(templates_str):
            rel_path_str = src_str[len(templates_str):].lstrip("/")
        else:
            rel_path_str = src_str
        rel_path = Path(rel_path_str)

        # Determine destination path
        if not rel_path.parts:
            continue

        if rel_path.parts[0] == "CLAUDE.md.template":
            dest_path = target_dir / "CLAUDE.md"
        else:
            # Use the full relative path (includes .claude/ or .pilot/)
            dest_path = target_dir / rel_path

        # Skip user files
        if any(str(dest_path).endswith(f) for f in config.USER_FILES):
            # Check if file exists and is user-owned
            if dest_path.exists():
                continue

        if copy_template_from_package(src_path, dest_path):
            success_count += 1
        else:
            fail_count += 1

    return success_count, fail_count


def perform_auto_update(target_dir: Path) -> UpdateStatus:
    """
    Perform automatic update with merge.

    Args:
        target_dir: Target directory for update.

    Returns:
        UpdateStatus indicating result.
    """
    # Create backup
    create_backup(target_dir)

    # Copy templates from package
    click.secho("i Updating managed files...", fg="blue")
    success_count, fail_count = copy_templates_from_package(target_dir)

    click.secho(f"i Updated: {success_count} files", fg="blue")
    if fail_count > 0:
        click.secho(f"! Failed: {fail_count} files", fg="yellow")

    # Apply settings.json updates (merge pattern - preserves user settings)
    click.secho("i Applying settings.json updates...", fg="blue")
    apply_hooks(target_dir)
    apply_statusline(target_dir)

    # Ensure .gitignore excludes .pilot/
    ensure_gitignore(target_dir)

    # Check Codex CLI availability for GPT delegation
    click.secho("i Checking Codex CLI availability...", fg="blue")
    from claude_pilot.codex import is_codex_available

    if is_codex_available():
        click.secho("✓ Codex CLI available (GPT delegation ready)", fg="green")
    else:
        click.secho("i Codex CLI not available or not authenticated (skipping)", fg="blue")

    # Cleanup old backups (keep last 5)
    cleanup_old_backups(target_dir, keep=5)

    # Save version
    save_version(config.VERSION, target_dir)

    return UpdateStatus.UPDATED


def generate_manual_merge_guide(target_dir: Path) -> Path:
    """
    Generate a manual merge guide for the user.

    Args:
        target_dir: Target directory.

    Returns:
        Path to the generated guide file.
    """
    guide_path = target_dir / ".claude-backups" / "MANUAL_MERGE_GUIDE.md"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    content = f"""# Manual Merge Guide
Generated: {timestamp}
Version: {config.VERSION}

## Overview
This guide will help you manually merge the latest claude-pilot templates into your project.

## Step 1: Review Backup
A backup has been created. Check the `.claude-backups/` directory.

## Step 2: Review Changes
Compare your current files with the latest templates:

```bash
# View bundled assets location
python3 -c "import importlib.resources; print(importlib.resources.files('claude_pilot') / 'assets')"
```

## Step 3: Manual Merge Commands
For each managed file, decide how to merge:

### Commands (.claude/commands/)
```bash
# Compare and merge specific command
diff .claude-backups/<timestamp>/commands/00_plan.md .claude/commands/00_plan.md
```

### Templates (.claude/templates/)
```bash
# Compare and merge template
diff .claude-backups/<timestamp>/templates/CONTEXT.md.template .claude/templates/CONTEXT.md.template
```

### Hooks (.claude/scripts/hooks/)
```bash
# Compare and merge hook
diff .claude-backups/<timestamp>/scripts/hooks/typecheck.sh .claude/scripts/hooks/typecheck.sh
```

## Step 4: Update Version
After merging, update the version file:
```bash
echo "{config.VERSION}" > .claude/.pilot-version
```

## Rollback
If you need to rollback:
```bash
# Restore from backup
rm -rf .claude
cp -r .claude-backups/<timestamp> .claude
```

## Managed Files
The following files are managed by claude-pilot:
"""
    for src, dest in config.MANAGED_FILES:
        content += f"- `{dest}`\n"

    content += """
## Preserved Files
These files are never overwritten:
"""
    for user_file in config.USER_FILES:
        content += f"- `{user_file}`\n"

    guide_path.write_text(content)
    return guide_path


def perform_manual_update(target_dir: Path) -> UpdateStatus:
    """
    Perform manual update (generate guide only).

    Args:
        target_dir: Target directory for update.

    Returns:
        UpdateStatus indicating result.
    """
    # Create backup
    create_backup(target_dir)

    # Generate manual merge guide
    guide_path = generate_manual_merge_guide(target_dir)

    click.secho(f"i Manual merge guide generated: {guide_path}", fg="blue")
    click.secho("", fg="blue")
    click.secho("Next steps:", fg="blue")
    click.secho("  1. Review the backup and merge guide", fg="blue")
    click.secho("  2. Manually merge the changes", fg="blue")
    click.secho("  3. Update version: echo '" + config.VERSION + "' > .claude/.pilot-version", fg="blue")

    return UpdateStatus.UPDATED


def save_version(
    version: str,
    target_dir: Path | None = None,
) -> None:
    """
    Save the version to the version file.

    Args:
        version: Version string to save.
        target_dir: Optional target directory. Defaults to current working directory.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()
    version_file = config.get_version_file_path(target_dir)
    version_file.write_text(version)


def _create_default_settings(settings_path: Path) -> bool:
    """
    Create default settings.json with statusLine configuration.

    Args:
        settings_path: Path to settings.json file.

    Returns:
        True if successful, False otherwise.
    """
    default_settings = {
        "statusLine": {
            "type": "command",
            "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/statusline.sh'
        }
    }
    try:
        with settings_path.open("w") as f:
            json.dump(default_settings, f, indent=2)
        click.secho("i Created settings.json with statusLine configuration", fg="blue")
        return True
    except OSError as e:
        click.secho(f"! Error creating settings.json: {e}", fg="yellow")
        return False


def _create_settings_backup(settings_path: Path, target_dir: Path) -> Path | None:
    """
    Create backup of settings.json before modifying.

    Args:
        settings_path: Path to settings.json file.
        target_dir: Target directory containing .claude/.

    Returns:
        Path to backup file, or None if backup failed.
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = target_dir / ".claude" / f"settings.json.backup.{timestamp}"
    try:
        shutil.copy2(settings_path, backup_path)
        click.secho(f"i Backup created: {backup_path.name}", fg="blue")
        return backup_path
    except OSError as e:
        click.secho(f"! Warning: Could not create backup: {e}", fg="yellow")
        return None


def _write_settings_atomically(
    settings: dict[str, Any],
    settings_path: Path,
    backup_path: Path | None,
) -> bool:
    """
    Write settings using atomic write pattern with fallback to backup.

    Args:
        settings: Settings dictionary to write.
        settings_path: Path to settings.json file.
        backup_path: Path to backup file for rollback.

    Returns:
        True if successful, False otherwise.
    """
    temp_path = settings_path.with_suffix(".json.tmp")
    try:
        with temp_path.open("w") as f:
            json.dump(settings, f, indent=2)
        # Validate JSON syntax
        with temp_path.open("r") as f:
            json.load(f)
        # Atomic rename
        temp_path.replace(settings_path)
        click.secho("i statusLine configuration added to settings.json", fg="green")
        return True
    except (json.JSONDecodeError, OSError) as e:
        click.secho(f"! Error writing settings.json: {e}", fg="yellow")
        # Clean up temp file
        if temp_path.exists():
            temp_path.unlink()
        # Restore from backup if available
        if backup_path and backup_path.exists():
            shutil.copy2(backup_path, settings_path)
            click.secho("i Restored settings.json from backup", fg="blue")
        return False


def apply_statusline(target_dir: Path | None = None) -> bool:
    """
    Apply statusline configuration to existing settings.json.

    This function adds the statusLine configuration to an existing
    settings.json file without overwriting other user settings.
    If statusLine already exists, it will be preserved unchanged.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        True if statusLine was added or already exists, False on error.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    settings_path = target_dir / ".claude" / "settings.json"

    # Create .claude directory if it doesn't exist
    settings_path.parent.mkdir(parents=True, exist_ok=True)

    # Create default settings.json if it doesn't exist
    if not settings_path.exists():
        return _create_default_settings(settings_path)

    # Read existing settings
    try:
        with settings_path.open("r") as f:
            settings = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        click.secho(f"! Error reading settings.json: {e}", fg="yellow")
        return False

    # Check if statusLine already exists
    if "statusLine" in settings:
        click.secho("i statusLine already configured, preserving existing config", fg="blue")
        return True

    # Create backup, add statusLine, and write atomically
    backup_path = _create_settings_backup(settings_path, target_dir)
    settings["statusLine"] = {
        "type": "command",
        "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/statusline.sh'
    }
    return _write_settings_atomically(settings, settings_path, backup_path)


# Default hooks configuration with $CLAUDE_PROJECT_DIR paths
DEFAULT_HOOKS: dict[str, Any] = {
    "PreToolUse": [
        {
            "matcher": "Edit|Write",
            "hooks": [
                {
                    "type": "command",
                    "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/typecheck.sh'
                },
                {
                    "type": "command",
                    "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/lint.sh'
                }
            ]
        },
        {
            "matcher": "Bash",
            "hooks": [
                {
                    "type": "command",
                    "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/branch-guard.sh'
                }
            ]
        }
    ],
    "PostToolUse": [
        {
            "matcher": "Edit|Write",
            "hooks": [
                {
                    "type": "command",
                    "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/typecheck.sh'
                }
            ]
        }
    ],
    "Stop": [
        {
            "hooks": [
                {
                    "type": "command",
                    "command": '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/check-todos.sh'
                }
            ]
        }
    ]
}


def _is_hook_path_updated(command: str) -> bool:
    """Check if hook command path uses $CLAUDE_PROJECT_DIR pattern."""
    return "$CLAUDE_PROJECT_DIR" in command


def _update_hook_path(command: str) -> str:
    """
    Update hook command path to use $CLAUDE_PROJECT_DIR pattern.

    Converts relative paths like '.claude/scripts/hooks/typecheck.sh'
    to '"$CLAUDE_PROJECT_DIR"/.claude/scripts/hooks/typecheck.sh'.
    Also updates hardcoded absolute paths to use the variable.
    """
    if _is_hook_path_updated(command):
        return command

    # Handle relative paths starting with .claude/
    # This catches both ".claude/..." and quoted forms
    import re
    rel_match = re.search(r'(["\']?)\.claude/', command)
    if rel_match and not command.startswith("$"):
        opening_quote = rel_match.group(1)
        # Extract everything from .claude/ onwards
        claude_start = command.find(".claude/")
        if claude_start >= 0:
            rest = command[claude_start:]  # ".claude/scripts/hooks/xxx.sh" or ".claude/scripts/hooks/xxx.sh'"
            # Remove trailing quote if present and matches opening quote
            if opening_quote and rest.endswith(opening_quote):
                trailing = rest[-1]
                rest = rest[:-1]
            else:
                trailing = ''
            return f'"$CLAUDE_PROJECT_DIR"/{rest}{trailing}'

    # Handle hardcoded absolute paths (e.g., "/Users/xxx/.claude/...")
    # We look for the pattern and extract the part after .claude/
    if "/.claude/" in command and not command.startswith("$"):
        # Find the .claude/ position
        claude_pos = command.find("/.claude/")
        if claude_pos > 0:
            # Extract the full path from .claude/ onwards
            abs_part = command[claude_pos:]  # "/.claude/scripts/hooks/xxx.sh" or "/.claude/scripts/hooks/xxx.sh""

            # Get the relative part
            rel_part = abs_part[len("/.claude/"):]  # "scripts/hooks/xxx.sh"

            # Handle trailing quotes
            trailing_quote = ''
            if rel_part.endswith('"') or rel_part.endswith("'"):
                trailing_quote = rel_part[-1]
                rel_part = rel_part[:-1]

            # Reconstruct with $CLAUDE_PROJECT_DIR
            return f'"$CLAUDE_PROJECT_DIR"/.claude/{rel_part}{trailing_quote}'

    return command


def _update_hooks_in_settings(hooks: dict[str, Any]) -> tuple[dict[str, Any], int]:
    """
    Update all hook command paths in hooks configuration.

    Args:
        hooks: The hooks configuration dict.

    Returns:
        Tuple of (updated_hooks, update_count).
    """
    updated_hooks = {}
    update_count = 0

    for event_name, matchers in hooks.items():
        updated_matchers = []
        for matcher in matchers:
            updated_matcher = matcher.copy()
            if "hooks" in matcher:
                updated_hook_list = []
                for hook in matcher["hooks"]:
                    updated_hook = hook.copy()
                    if "command" in hook:
                        old_cmd = hook["command"]
                        new_cmd = _update_hook_path(old_cmd)
                        if old_cmd != new_cmd:
                            update_count += 1
                        updated_hook["command"] = new_cmd
                    updated_hook_list.append(updated_hook)
                updated_matcher["hooks"] = updated_hook_list
            updated_matchers.append(updated_matcher)
        updated_hooks[event_name] = updated_matchers

    return updated_hooks, update_count


def apply_hooks(target_dir: Path | None = None) -> bool:
    """
    Apply hooks configuration to existing settings.json.

    This function updates hook command paths to use $CLAUDE_PROJECT_DIR
    pattern for better reliability. If hooks section doesn't exist,
    it adds the default hooks configuration.

    User customizations (additional hooks, matchers) are preserved.
    Only the command paths are updated to the new pattern.

    Missing hook types (PreToolUse, PostToolUse, Stop) are added
    from DEFAULT_HOOKS if they don't exist in user's configuration.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        True if hooks were updated or already current, False on error.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    settings_path = target_dir / ".claude" / "settings.json"

    # Skip if settings.json doesn't exist (will be created by init)
    if not settings_path.exists():
        click.secho("i settings.json not found, skipping hooks update", fg="blue")
        return True

    # Read existing settings
    try:
        with settings_path.open("r") as f:
            settings = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        click.secho(f"! Error reading settings.json: {e}", fg="yellow")
        return False

    # If no hooks section, add default hooks
    if "hooks" not in settings:
        click.secho("i Adding default hooks configuration", fg="blue")
        backup_path = _create_settings_backup(settings_path, target_dir)
        settings["hooks"] = DEFAULT_HOOKS
        return _write_settings_atomically(settings, settings_path, backup_path)

    # Ensure all required hook types exist (PreToolUse, PostToolUse, Stop)
    updated = False
    for hook_type in DEFAULT_HOOKS.keys():
        if hook_type not in settings["hooks"]:
            click.secho(f"i Adding missing {hook_type} hooks", fg="blue")
            settings["hooks"][hook_type] = DEFAULT_HOOKS[hook_type]
            updated = True

    # Update existing hooks paths
    updated_hooks, update_count = _update_hooks_in_settings(settings["hooks"])

    if update_count == 0 and not updated:
        click.secho("i Hooks already use $CLAUDE_PROJECT_DIR paths and all types present", fg="blue")
        return True

    # Create backup and write updated settings
    if updated:
        click.secho("i Added missing hook types and updating paths", fg="blue")
    else:
        click.secho(f"i Updating {update_count} hook path(s) to $CLAUDE_PROJECT_DIR pattern", fg="blue")
    backup_path = _create_settings_backup(settings_path, target_dir)
    settings["hooks"] = updated_hooks
    return _write_settings_atomically(settings, settings_path, backup_path)


def cleanup_deprecated_files(
    target_dir: Path | None = None,
) -> list[str]:
    """
    Remove deprecated files from previous versions.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        List of removed file paths.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    removed_files: list[str] = []
    for file_path in config.DEPRECATED_FILES:
        full_path = target_dir / file_path
        if full_path.exists():
            full_path.unlink()
            removed_files.append(file_path)

    if removed_files:
        click.secho("i Removed deprecated files:", fg="blue")
        for file in removed_files:
            click.secho(f"  - {file}")

    return removed_files


def check_update_needed(target_dir: Path | None = None) -> bool:
    """
    Check if an update is needed.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        True if update is needed, False otherwise.
    """
    current = get_current_version(target_dir)
    latest = get_latest_version()
    return current != latest


def get_github_latest_sha(repo: str, branch: str) -> str | None:
    """
    Fetch the latest commit SHA from a GitHub repository.

    Args:
        repo: Repository in format "owner/repo".
        branch: Branch name (default: "main").

    Returns:
        The latest commit SHA, or None if fetch fails.
    """
    import requests

    api_url = f"https://api.github.com/repos/{repo}/commits/{branch}"
    try:
        response = requests.get(api_url, timeout=config.REQUEST_TIMEOUT)
        response.raise_for_status()
        data = response.json()
        # Validate response structure (Security: Warning #1)
        if not isinstance(data, dict) or "sha" not in data:
            return None
        return str(data["sha"])
    except (requests.RequestException, KeyError, TypeError, ValueError):
        return None


def download_github_tarball(repo: str, ref: str, dest: Path) -> bool:
    """
    Download a GitHub repository tarball.

    Args:
        repo: Repository in format "owner/repo".
        ref: Git reference (commit SHA, branch, tag).
        dest: Destination directory for the tarball.

    Returns:
        True if successful, False otherwise.
    """
    import requests

    download_url = f"https://api.github.com/repos/{repo}/tarball/{ref}"
    try:
        response = requests.get(download_url, timeout=config.REQUEST_TIMEOUT, stream=True)
        response.raise_for_status()

        tarball_path = dest / f"{repo.replace('/', '-')}-{ref[:7]}.tar.gz"
        with tarball_path.open("wb") as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)

        return True
    except requests.RequestException:
        return False


def extract_skills_from_tarball(
    tarball: Path,
    skills_path: str,
    dest: Path,
) -> bool:
    """
    Extract skills from a GitHub tarball.

    Args:
        tarball: Path to the tarball file.
        skills_path: Path within the repo to the skills directory.
        dest: Destination directory for extracted skills.

    Returns:
        True if successful, False otherwise.
    """
    import tarfile

    try:
        with tarfile.open(tarball, "r:gz") as tar:
            # Find the root directory (GitHub tarballs have a prefix)
            members = tar.getmembers()
            if not members:
                return False

            # Get the root prefix (e.g., "vercel-labs-agent-skills-abc123/")
            root_prefix = members[0].name.split("/")[0]
            full_skills_path = f"{root_prefix}/{skills_path}"

            # Extract skills directory
            dest.mkdir(parents=True, exist_ok=True)
            extracted_count = 0

            for member in members:
                # Skip symlinks entirely for security (Critical #2: Symlink Attack)
                if member.issym() or member.islnk():
                    click.secho(f"! Warning: Skipping symlink: {member.name}", fg="yellow")
                    continue

                if member.name.startswith(full_skills_path):
                    # Strip the prefix to get relative path
                    relative_path = member.name[len(root_prefix) + 1 :]
                    if not relative_path:
                        continue

                    # Strip the skills_path prefix to get the actual file path
                    # relative_path is like "skills/test-skill/SKILL.md", we want "test-skill/SKILL.md"
                    if relative_path.startswith(skills_path + "/"):
                        file_path = relative_path[len(skills_path) + 1 :]
                    elif relative_path == skills_path:
                        # This is the skills directory itself, skip
                        continue
                    else:
                        continue

                    # Security: Validate the extracted path doesn't escape dest
                    # (Critical #1: Path Traversal Vulnerability)
                    extracted_path = (dest / file_path).resolve()
                    dest_resolved = dest.resolve()

                    if not extracted_path.is_relative_to(dest_resolved):
                        click.secho(
                            f"! Warning: Skipping unsafe path: {member.name}", fg="yellow"
                        )
                        continue

                    member.name = file_path
                    tar.extract(member, dest)
                    extracted_count += 1

            # Return True only if we extracted at least one file
            return extracted_count > 0
    except (OSError, tarfile.TarError):
        return False


def sync_external_skills(
    target_dir: Path | None = None,
    skip: bool = False,
) -> str:
    """
    Sync external skills from GitHub repositories.

    Args:
        target_dir: Target directory for skills. Defaults to current directory.
        skip: If True, skip syncing.

    Returns:
        Status: "success", "already_current", "failed", "skipped".
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    if skip:
        click.secho("i Skipping external skills sync", fg="blue")
        return "skipped"

    # Check existing version
    version_file = target_dir / config.EXTERNAL_SKILLS_VERSION_FILE
    current_sha = None
    if version_file.exists():
        current_sha = version_file.read_text().strip()

    # Sync each external skill source
    for skill_name, skill_config in config.EXTERNAL_SKILLS.items():
        repo = skill_config["repo"]
        branch = skill_config["branch"]
        skills_path = skill_config["skills_path"]

        # Fetch latest SHA
        click.secho(f"i Checking {skill_name} for updates...", fg="blue")
        latest_sha = get_github_latest_sha(repo, branch)

        if latest_sha is None:
            click.secho(f"! Warning: Could not fetch {skill_name} version", fg="yellow")
            return "failed"

        # Check if already up to date
        if current_sha == latest_sha:
            click.secho(f"i {skill_name} already up to date", fg="blue")
            return "already_current"

        # Download and extract
        click.secho(f"i Downloading {skill_name}...", fg="blue")
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)

            if not download_github_tarball(repo, latest_sha, temp_path):
                click.secho(f"! Warning: Failed to download {skill_name}", fg="yellow")
                return "failed"

            # Find the downloaded tarball
            tarball = None
            for f in temp_path.glob("*.tar.gz"):
                tarball = f
                break

            if tarball is None:
                click.secho("! Warning: Could not find downloaded tarball", fg="yellow")
                return "failed"

            # Extract skills
            dest_dir = target_dir / config.EXTERNAL_SKILLS_DIR / skill_name
            if not extract_skills_from_tarball(tarball, skills_path, dest_dir):
                click.secho(f"! Warning: Failed to extract {skill_name}", fg="yellow")
                return "failed"

            click.secho(f"i Extracted {skill_name} to {dest_dir}", fg="blue")

        # Save version
        version_file.parent.mkdir(parents=True, exist_ok=True)
        version_file.write_text(latest_sha)
        click.secho(f"i Updated {skill_name} to {latest_sha[:7]}", fg="green")

    return "success"


def perform_update(
    target_dir: Path | None = None,
    strategy: MergeStrategy = MergeStrategy.AUTO,
    skip_pip: bool = False,
    check_only: bool = False,
) -> UpdateStatus:
    """
    Perform the update process.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.
        strategy: Merge strategy to use (auto or manual).
        skip_pip: If True, skip pip package upgrade.
        check_only: If True, only check for updates without applying them.

    Returns:
        Status of the update.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    # Phase 1: Check pip package version
    installed_version = get_installed_version()
    pypi_version = get_pypi_version()

    click.secho(f"i Installed version: {installed_version}", fg="blue")
    if pypi_version:
        click.secho(f"i PyPI version: {pypi_version}", fg="blue")
    else:
        click.secho("i PyPI version: Unknown (network error)", fg="yellow")

    # Check if pip upgrade is needed
    pip_upgrade_needed = pypi_version and pypi_version != installed_version

    if check_only:
        if pip_upgrade_needed:
            click.secho(
                f"i Pip package update available: v{installed_version} → v{pypi_version}",
                fg="yellow",
            )
        else:
            click.secho("✓ Pip package is up to date", fg="green")
        return UpdateStatus.ALREADY_CURRENT

    # Phase 2: Upgrade pip package if needed
    pip_upgraded = False
    if pip_upgrade_needed and not skip_pip:
        click.secho(
            f"i Upgrading pip package from v{installed_version} to v{pypi_version}...",
            fg="blue",
        )
        pip_upgraded = upgrade_pip_package()
        if pip_upgraded:
            click.secho(
                "i Pip package upgraded. Please re-run this command for full effect.",
                fg="yellow",
            )

    # Phase 3: Update managed files
    current_version = get_current_version(target_dir)
    latest_version = get_latest_version()

    if current_version == latest_version:
        if not pip_upgrade_needed or skip_pip:
            click.secho(f"✓ Already up to date (v{latest_version})", fg="green")
        return UpdateStatus.ALREADY_CURRENT

    click.secho(
        f"i Updating managed files from v{current_version} to v{latest_version}...",
        fg="blue",
    )

    # Perform update based on strategy
    if strategy == MergeStrategy.MANUAL:
        return perform_manual_update(target_dir)

    return perform_auto_update(target_dir)

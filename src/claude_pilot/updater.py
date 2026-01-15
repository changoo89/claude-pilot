"""
Update functionality for claude-pilot.

This module handles updating managed files from bundled package templates,
with support for different merge strategies and backup management.
"""

from __future__ import annotations

import importlib.resources  # noqa: F401
import json
import shutil
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

    # Ensure .gitignore excludes .pilot/
    ensure_gitignore(target_dir)

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
# View bundled templates location
python3 -c "import importlib.resources; print(importlib.resources.files('claude_pilot/templates'))"
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

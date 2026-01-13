"""
Update functionality for claude-pilot.

This module handles downloading files from the remote repository
and updating the local installation.
"""

from __future__ import annotations

from pathlib import Path
from typing import Literal

import click
import requests

from claude_pilot import config


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


def get_latest_version() -> str:
    """
    Get the latest version from the remote repository.

    Returns:
        The latest version string, or the local VERSION if fetch fails.
    """
    try:
        response = requests.get(
            f"{config.REPO_BASE}/.claude/.pilot-version",
            timeout=config.REQUEST_TIMEOUT,
        )
        if response.status_code == 200:
            return response.text.strip()
    except requests.RequestException:
        click.secho("! Could not fetch latest version from remote", fg="yellow")
    return config.VERSION


def download_file(
    src_path: str,
    dest_path: str,
    target_dir: Path | None = None,
) -> bool:
    """
    Download a single file from the remote repository.

    Args:
        src_path: Source path in the remote repository.
        dest_path: Destination path relative to target directory.
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        True if download succeeded, False otherwise.
    """
    if target_dir is None:
        target_dir = config.get_target_dir()
    dest_full = target_dir / dest_path

    # Create directory if needed
    dest_full.parent.mkdir(parents=True, exist_ok=True)

    # Download file
    url = f"{config.REPO_RAW}/{src_path}"
    try:
        response = requests.get(url, timeout=config.REQUEST_TIMEOUT)
        if response.status_code == 200:
            dest_full.write_text(response.text)
            return True
    except requests.RequestException:
        pass
    return False


def update_files(
    target_dir: Path | None = None,
) -> tuple[int, int]:
    """
    Download all managed files from the remote repository.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        A tuple of (success_count, fail_count).
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    click.secho("i Downloading claude-pilot managed files...", fg="blue")

    success_count = 0
    fail_count = 0

    for src_path, dest_path in config.MANAGED_FILES:
        if download_file(src_path, dest_path, target_dir):
            success_count += 1
        else:
            fail_count += 1
            click.secho(f"! Failed to download: {src_path}", fg="yellow")

    click.secho(f"i Downloaded: {success_count} files", fg="blue")
    if fail_count > 0:
        click.secho(f"! Failed: {fail_count} files", fg="yellow")

    return success_count, fail_count


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


UpdateStatus = Literal["already_current", "updated", "failed"]


def perform_update(
    target_dir: Path | None = None,
) -> UpdateStatus:
    """
    Perform the update process.

    Args:
        target_dir: Optional target directory. Defaults to current working directory.

    Returns:
        Status of the update: "already_current", "updated", or "failed".
    """
    if target_dir is None:
        target_dir = config.get_target_dir()

    current_version = get_current_version(target_dir)
    latest_version = get_latest_version()

    if current_version == latest_version:
        click.secho(f"✓ Already up to date (v{latest_version})", fg="green")
        return "already_current"

    click.secho(f"i Updating from v{current_version} to v{latest_version}...", fg="blue")

    # Download managed files
    success_count, fail_count = update_files(target_dir)

    if fail_count > 0 and success_count == 0:
        click.secho(
            "Error: Failed to download any files. Please check your internet connection.",
            fg="red",
            err=True,
        )
        return "failed"

    # Cleanup deprecated files
    cleanup_deprecated_files(target_dir)

    # Save version
    save_version(latest_version, target_dir)
    click.secho(f"✓ Updated to version {latest_version}", fg="green")

    return "updated"

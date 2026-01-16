"""
CLI commands for claude-pilot.

This module provides the Click command-line interface for the claude-pilot tool.
"""

from __future__ import annotations

from pathlib import Path

import click
from click import ClickException

from claude_pilot import config
from claude_pilot.initializer import InitStatus, ProjectInitializer
from claude_pilot.updater import (
    MergeStrategy,
    get_current_version,
    get_latest_version,
    perform_update,
)

# =============================================================================
# OUTPUT UTILITIES
# =============================================================================


def success(message: str) -> None:
    """Print a success message in green."""
    click.secho(f"✓ {message}", fg="green")


def error(message: str) -> None:
    """Print an error message in red."""
    click.secho(f"Error: {message}", fg="red", err=True)


def info(message: str) -> None:
    """Print an info message in blue."""
    click.secho(f"i {message}", fg="blue")


def warning(message: str) -> None:
    """Print a warning message in yellow."""
    click.secho(f"! {message}", fg="yellow")


# =============================================================================
# BANNER
# =============================================================================


def print_banner() -> None:
    """Print the claude-pilot banner."""
    click.echo()
    click.secho(
        """
   _                 _                  _ _       _
___| | __ _ _   _  __| | ___       _ __ (_) | ___ | |_
/ __| |/ _` | | | |/ _` |/ _ \\_____| '_ \\| | |/ _ \\| __|
| (__| | (_| | |_| | (_| |  __/_____| |_) | | | (_) | |_
\\___|_|\\__,_|\\__,_|\\__,_|\\___|     | .__/|_|_|\\___/ \\__|
                                    |_|
                        Your Claude Code Pilot
""",
        fg="blue",
        reset=False,
    )
    click.echo()
    success(f"claude-pilot v{config.VERSION}")
    click.echo()


# =============================================================================
# CLI COMMANDS
# =============================================================================


@click.group()
@click.version_option(version=config.VERSION, prog_name="claude-pilot")
def main() -> None:
    """
    claude-pilot - Claude Code CLI Pilot

    Your development workflow companion for Claude Code.
    """
    pass


@main.command()
def version() -> None:
    """
    Show version information.

    Displays both the current installed version and the latest available version.
    """
    print_banner()
    current = get_current_version()
    latest = get_latest_version()
    click.echo("claude-pilot version information:")
    click.echo(f"  Latest:  {latest}")
    click.echo(f"  Current: {current}")
    click.echo()
    if current == latest:
        success("You are running the latest version!")


@main.command()
@click.argument(
    "path",
    type=click.Path(path_type=Path),
    default=".",
)
@click.option(
    "--lang",
    type=click.Choice(["en", "ko", "ja"]),
    help="Language for the project (en/ko/ja)",
)
@click.option(
    "--force",
    is_flag=True,
    help="Force re-initialization even if already initialized",
)
@click.option(
    "--yes",
    "-y",
    is_flag=True,
    help="Non-interactive mode (for CI/CD)",
)
@click.option(
    "--skip-external-skills",
    is_flag=True,
    help="Skip downloading external skills during initialization",
)
def init(path: Path, lang: str | None, force: bool, yes: bool, skip_external_skills: bool) -> None:
    """
    Initialize claude-pilot in a project directory.

    Creates the .claude/ and .pilot/ directory structure with all necessary
    template files for Claude Code development workflow.
    """
    initializer = ProjectInitializer(
        target_dir=path,
        language=lang,
        force=force,
        yes=yes,
        skip_external_skills=skip_external_skills,
    )
    status = initializer.initialize()

    if status == InitStatus.FAILED:
        raise ClickException("Initialization failed")
    if status == InitStatus.SKIPPED:
        click.echo("Initialization skipped.")


@main.command()
@click.option(
    "--target-dir",
    type=click.Path(exists=True, path_type=Path),
    default=None,
    help="Target directory for update (default: current directory)",
)
@click.option(
    "--strategy",
    type=click.Choice(["auto", "manual"]),
    default="auto",
    help="Merge strategy: auto (default) or manual",
)
@click.option(
    "--skip-pip",
    is_flag=True,
    help="Skip pip package upgrade, only update managed files",
)
@click.option(
    "--check-only",
    is_flag=True,
    help="Only check for updates without applying them",
)
@click.option(
    "--apply-statusline",
    is_flag=True,
    help="Apply statusline configuration to existing settings.json",
)
@click.option(
    "--skip-external-skills",
    is_flag=True,
    help="Skip syncing external skills during update",
)
def update(
    target_dir: Path | None,
    strategy: str,
    skip_pip: bool,
    check_only: bool,
    apply_statusline: bool,
    skip_external_skills: bool,
) -> None:
    """
    Update claude-pilot to the latest version.

    Updates all managed files from bundled package templates.
    User-owned files are preserved.
    """
    print_banner()
    merge_strategy = MergeStrategy(strategy)

    # Handle --apply-statusline flag
    if apply_statusline:
        from claude_pilot.updater import apply_statusline as apply_sl
        result = apply_sl(target_dir)
        if result:
            click.echo()
            success("statusLine configuration applied successfully!")
        else:
            click.echo()
            error("Failed to apply statusLine configuration")
            raise ClickException("statusLine application failed")
        return

    # Sync external skills if not skipped
    if not skip_external_skills and not check_only:
        from claude_pilot.updater import sync_external_skills

        click.echo()
        sync_status = sync_external_skills(target_dir, skip=False)
        if sync_status == "success":
            success("External skills synced")
        elif sync_status == "already_current":
            info("External skills already up to date")
        elif sync_status == "failed":
            warning("External skills sync failed (continuing)")
        click.echo()

    status = perform_update(target_dir, merge_strategy, skip_pip, check_only)
    if status == "updated" and not check_only:
        if strategy == "auto":
            click.echo()
            info("Updated files:")
            click.echo("  - Commands (00-03, 90-92)")
            click.echo("  - Templates (CONTEXT-tier2, CONTEXT-tier3)")
            click.echo("  - Hooks")
            click.echo()
            info("Preserved files (your changes):")
            click.echo("  - CLAUDE.md")
            click.echo("  - AGENTS.md")
            click.echo("  - .pilot/")
            click.echo("  - .claude/settings.json")
            click.echo("  - Custom commands")
            click.echo()
            success("Update complete!")


# =============================================================================
# MAIN ENTRY POINT
# =============================================================================

if __name__ == "__main__":
    main()

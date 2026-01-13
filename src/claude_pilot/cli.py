"""
CLI commands for claude-pilot.

This module provides the Click command-line interface for the claude-pilot tool.
"""

from __future__ import annotations

from pathlib import Path

import click
from click import ClickException

from claude_pilot import config
from claude_pilot.updater import get_current_version, get_latest_version, perform_update

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
@click.option(
    "--target-dir",
    type=click.Path(exists=True, path_type=Path),
    default=None,
    help="Target directory for update (default: current directory)",
)
def update(target_dir: Path | None) -> None:
    """
    Update claude-pilot to the latest version.

    Downloads and updates all managed files from the remote repository.
    User-owned files are preserved.
    """
    print_banner()
    status = perform_update(target_dir)
    if status == "updated":
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

"""
Project initialization functionality for claude-pilot.

This module handles the initialization of claude-pilot in a project directory,
including language selection, directory structure creation, and template copying.
"""

from __future__ import annotations

import importlib.resources  # noqa: F401
import json
import shutil
from enum import Enum
from pathlib import Path
from typing import Any, Literal

import questionary
from rich.console import Console

from claude_pilot import config

console = Console()


class Language(str, Enum):
    """Supported languages for claude-pilot."""

    ENGLISH = "en"
    KOREAN = "ko"
    JAPANESE = "ja"


class InitStatus(str, Enum):
    """Status of initialization process."""

    SUCCESS = "success"
    SKIPPED = "skipped"
    FAILED = "failed"


class ProjectInitializer:
    """
    Handles project initialization for claude-pilot.

    This class manages the creation of .claude/ and .pilot/ directories,
    language selection, and template copying from bundled package resources.
    """

    def __init__(
        self,
        target_dir: Path,
        language: str | None = None,
        force: bool = False,
        yes: bool = False,
        skip_external_skills: bool = False,
    ) -> None:
        """
        Initialize the ProjectInitializer.

        Args:
            target_dir: Target directory for initialization.
            language: Optional language code. If None, prompts user.
            force: Force re-initialization even if already initialized.
            yes: Non-interactive mode (use defaults).
            skip_external_skills: Skip downloading external skills.
        """
        self.target_dir = target_dir.resolve()
        self.language = language
        self.force = force
        self.yes = yes
        self.skip_external_skills = skip_external_skills
        self._backup_dir: Path | None = None

    def select_language(self) -> str:
        """
        Select the language for the project.

        Returns:
            Selected language code.
        """
        if self.language:
            return self.language

        if self.yes:
            return Language.ENGLISH.value

        choices = [
            questionary.Choice(
                title="English (en)", value=Language.ENGLISH.value
            ),
            questionary.Choice(
                title="한국어 (ko)", value=Language.KOREAN.value
            ),
            questionary.Choice(
                title="日本語 (ja)", value=Language.JAPANESE.value
            ),
        ]

        answer = questionary.select(
            "Select language / 언어 선택 / 言語選択:",
            choices=choices,
            default=Language.ENGLISH.value,
        ).ask()

        return answer if answer else Language.ENGLISH.value

    def detect_partial_state(self) -> Literal["none", "partial", "full"]:
        """
        Detect the current state of the project.

        Returns:
            "none" if neither .claude/ nor .pilot/ exist.
            "partial" if only one exists.
            "full" if both exist.
        """
        has_claude = (self.target_dir / ".claude").exists()
        has_pilot = (self.target_dir / ".pilot").exists()

        if not has_claude and not has_pilot:
            return "none"
        if has_claude and has_pilot:
            return "full"
        return "partial"

    def should_proceed_with_init(self, state: str) -> bool:
        """
        Determine if initialization should proceed based on current state.

        Args:
            state: Current state ("none", "partial", "full").

        Returns:
            True if initialization should proceed, False otherwise.
        """
        if state == "none":
            return True

        if state == "partial":
            console.print(
                "[yellow]![/yellow] Partial installation detected. "
                "Will fix directory structure."
            )
            return True

        if self.force:
            return True

        if self.yes:
            console.print(
                "[yellow]![/yellow] Already initialized. "
                "Use --force to reinitialize."
            )
            return False

        answer = questionary.confirm(
            "Already initialized. Reinitialize?",
            default=False,
        ).ask()

        return answer if answer is not None else False

    def create_backup(self) -> Path | None:
        """
        Create a backup of existing .claude/ directory.

        Returns:
            Path to backup directory, or None if no backup was created.
        """
        claude_dir = self.target_dir / ".claude"
        if not claude_dir.exists():
            return None

        from datetime import datetime

        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self._backup_dir = self.target_dir / f".claude-backup-{timestamp}"

        shutil.copytree(claude_dir, self._backup_dir)
        console.print(
            f"[blue]i[/blue] Backup created: {self._backup_dir.name}"
        )
        return self._backup_dir

    def create_directory_structure(self) -> None:
        """Create the .claude/ and .pilot/ directory structure."""
        directories = [
            self.target_dir / ".claude" / "commands",
            self.target_dir / ".claude" / "templates",
            self.target_dir / ".claude" / "scripts" / "hooks",
            self.target_dir / ".claude" / "local",
            self.target_dir / ".pilot" / "plan" / "pending",
            self.target_dir / ".pilot" / "plan" / "in_progress",
            self.target_dir / ".pilot" / "plan" / "done",
            self.target_dir / ".pilot" / "plan" / "active",
        ]

        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)

    def copy_template(self, src: Any, dest: Path) -> bool:
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
            # This ensures hooks can run after initialization
            if str(dest).endswith('.sh'):
                import stat
                dest.chmod(dest.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

            return True
        except (OSError, IOError) as e:
            console.print(f"[red]Error:[/red] Failed to copy {dest}: {e}")
            return False

    def copy_templates_from_package(self) -> tuple[int, int]:
        """
        Copy all template files from the bundled package.

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
                dest_path = self.target_dir / "CLAUDE.md"
            else:
                # Use the full relative path (includes .claude/ or .pilot/)
                dest_path = self.target_dir / rel_path

            if self.copy_template(src_path, dest_path):
                success_count += 1
            else:
                fail_count += 1

        return success_count, fail_count

    def update_settings_language(self, language: str) -> None:
        """
        Update the language setting in settings.json.

        Args:
            language: Language code to set.
        """
        settings_file = self.target_dir / ".claude" / "settings.json"
        if not settings_file.exists():
            return

        try:
            with settings_file.open("r") as f:
                settings = json.load(f)
            settings["language"] = language
            with settings_file.open("w") as f:
                json.dump(settings, f, indent=2)
        except (OSError, json.JSONDecodeError):
            pass

    def update_gitignore(self) -> None:
        """
        Add .pilot/ to .gitignore if not present.

        This ensures that plan tracking files are not tracked by git,
        which is critical for worktree support where .pilot/ state
        differs between main and worktree.
        """
        gitignore_path = self.target_dir / ".gitignore"
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

    def cleanup_on_failure(self) -> None:
        """Clean up partially created directories on failure."""
        claude_dir = self.target_dir / ".claude"
        pilot_dir = self.target_dir / ".pilot"

        if claude_dir.exists():
            shutil.rmtree(claude_dir, ignore_errors=True)
        if pilot_dir.exists():
            shutil.rmtree(pilot_dir, ignore_errors=True)

        console.print("[red]Error:[/red] Initialization failed. Cleaned up partial files.")

    def initialize(self) -> InitStatus:
        """
        Perform the complete initialization process.

        Returns:
            InitStatus indicating the result of initialization.
        """
        console.print("\n[bold blue]claude-pilot Project Initialization[/bold blue]\n")

        # Detect current state
        state = self.detect_partial_state()

        # Check if we should proceed
        if not self.should_proceed_with_init(state):
            return InitStatus.SKIPPED

        # Select language
        language = self.select_language()
        console.print(f"[green]✓[/green] Language: {language}\n")

        # Create backup if reinitializing
        if state in ("partial", "full"):
            self.create_backup()

        # Create directory structure
        console.print("[blue]i[/blue] Creating directory structure...")
        self.create_directory_structure()

        # Copy templates from package
        console.print("[blue]i[/blue] Copying template files...")
        success_count, fail_count = self.copy_templates_from_package()

        if fail_count > 0 and success_count == 0:
            self.cleanup_on_failure()
            return InitStatus.FAILED

        console.print(f"[green]✓[/green] Copied {success_count} files")

        # Update language setting
        self.update_settings_language(language)

        # Update .gitignore to exclude .pilot/
        self.update_gitignore()

        # Write version file
        version_file = self.target_dir / ".claude" / ".pilot-version"
        version_file.write_text(config.VERSION)

        # Sync external skills
        console.print("[blue]i[/blue] Syncing external skills...")
        from claude_pilot.updater import sync_external_skills

        sync_status = sync_external_skills(self.target_dir, skip=self.skip_external_skills)
        if sync_status == "success":
            console.print("[green]✓[/green] External skills synced")
        elif sync_status == "skipped":
            console.print("[blue]i[/blue] External skills sync skipped")
        elif sync_status == "failed":
            console.print("[yellow]![/yellow] External skills sync failed (continuing)")

        # Check Codex CLI availability for GPT delegation
        from claude_pilot.codex import is_codex_available

        console.print("[blue]i[/blue] Checking Codex CLI availability...")
        if is_codex_available():
            console.print("[green]✓[/green] Codex CLI available (GPT delegation ready)")
        else:
            console.print("[blue]i[/blue] Codex CLI not available or not authenticated (skipping)")

        console.print(f"[green]✓[/green] Version {config.VERSION} initialized\n")
        console.print("[bold green]Initialization complete![/bold green]\n")
        console.print("[blue]Next steps:[/blue]")
        console.print("  1. Review CLAUDE.md and customize for your project")
        console.print("  2. Test: /00_plan 'test feature'")
        console.print("  3. Start building: /02_execute")

        return InitStatus.SUCCESS

"""
Tests for claude_pilot statusline functionality.

Tests the statusline.sh script behavior including:
- Pending count display
- Error handling (invalid JSON, missing jq)
- Edge cases (.gitkeep only, empty pending/)
"""

from __future__ import annotations

from pathlib import Path
from typing import Any
from unittest.mock import MagicMock, patch

import pytest
import subprocess

from claude_pilot import config


class TestStatuslineScript:
    """Test statusline.sh script functionality."""

    def get_statusline_script_path(self) -> Path:
        """Get the path to the statusline.sh script from templates."""
        templates_path = config.get_templates_path()
        return Path(templates_path) / ".claude" / "scripts" / "statusline.sh"

    def run_statusline_script(self, cwd: str, tmp_path: Path) -> tuple[bool, str, str]:
        """
        Run the statusline.sh script with mock input.

        Args:
            cwd: Current working directory to pass in JSON input
            tmp_path: Temporary directory for creating test files

        Returns:
            Tuple of (success, stdout, stderr)
        """
        script_path = self.get_statusline_script_path()

        # Create mock JSON input
        json_input = f'{{"workspace":{{"current_dir":"{cwd}"}}}}'

        # Run script
        result = subprocess.run(
            ["bash", str(script_path)],
            input=json_input,
            capture_output=True,
            text=True,
            cwd=tmp_path,
        )

        return result.returncode == 0, result.stdout, result.stderr

    def test_script_file_exists(self) -> None:
        """Test that the statusline.sh script file exists in templates."""
        script_path = self.get_statusline_script_path()
        assert script_path.exists(), f"Statusline script not found at {script_path}"
        assert script_path.is_file(), "Statusline path is not a file"

    def test_script_is_executable(self) -> None:
        """Test that the statusline.sh script is executable."""
        script_path = self.get_statusline_script_path()
        # Check file has execute permission
        assert script_path.stat().st_mode & 0o111, "Statusline script is not executable"

    def test_no_pending_displays_clean_statusline(self, tmp_path: Path) -> None:
        """Test statusline with no pending files (TS-1)."""
        # Create .pilot/plan/pending/ directory
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋" not in stdout, "Should not show pending count when pending=0"

    def test_with_pending_displays_count(self, tmp_path: Path) -> None:
        """Test statusline with pending files (TS-2)."""
        # Create .pilot/plan/pending/ directory with 3 files
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)

        # Create 3 pending plan files
        for i in range(1, 4):
            (pending_dir / f"plan_{i}.md").write_text(f"Plan {i}")

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋" in stdout, "Expected pending icon in output"
        assert "P:3" in stdout, "Expected pending count of 3"

    def test_gitkeep_only_treated_as_empty(self, tmp_path: Path) -> None:
        """Test that .gitkeep only is treated as empty pending (TS-8)."""
        # Create .pilot/plan/pending/ directory with only .gitkeep
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)
        (pending_dir / ".gitkeep").write_text("")

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋" not in stdout, "Should not show pending count for .gitkeep only"

    def test_invalid_json_graceful_fallback(self, tmp_path: Path) -> None:
        """Test graceful fallback with invalid JSON input (TS-3)."""
        script_path = self.get_statusline_script_path()

        # Run script with invalid JSON
        result = subprocess.run(
            ["bash", str(script_path)],
            input="invalid json{{{",
            capture_output=True,
            text=True,
            cwd=tmp_path,
        )

        # Should still succeed and show directory
        assert result.returncode == 0, "Script should handle invalid JSON gracefully"
        assert "📁" in result.stdout, "Should fallback to showing directory"

    def test_missing_jq_fallback(self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test fallback when jq is not available (TS-9)."""
        script_path = self.get_statusline_script_path()

        # Mock PATH to not include jq
        # Remove all directories that might contain jq
        original_path = "/usr/bin:/bin"  # Minimal PATH without jq

        # Create valid JSON input
        json_input = f'{{"workspace":{{"current_dir":"{tmp_path}"}}}}'

        # Run script with minimal PATH (no jq)
        env = {"PATH": original_path}
        result = subprocess.run(
            ["bash", str(script_path)],
            input=json_input,
            capture_output=True,
            text=True,
            cwd=tmp_path,
            env=env,
        )

        # Should still succeed and show directory
        assert result.returncode == 0, "Script should handle missing jq gracefully"
        assert "📁" in result.stdout, "Should fallback to showing directory without jq"

    def test_missing_pending_directory(self, tmp_path: Path) -> None:
        """Test statusline when .pilot/plan/pending/ doesn't exist."""
        # Don't create the pending directory

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋" not in stdout, "Should not show pending count when directory missing"

    def test_multiple_pending_files_counted_correctly(self, tmp_path: Path) -> None:
        """Test that multiple pending files are counted correctly."""
        # Create .pilot/plan/pending/ directory with various files
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)

        # Create 7 pending plan files
        for i in range(1, 8):
            (pending_dir / f"plan_{i}.md").write_text(f"Plan {i}")

        # Add .gitkeep (should be excluded)
        (pending_dir / ".gitkeep").write_text("")

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📋" in stdout, "Expected pending icon in output"
        assert "P:7" in stdout, "Expected pending count of 7 (excluding .gitkeep)"

    def test_directory_name_extraction(self, tmp_path: Path) -> None:
        """Test that directory name is correctly extracted from path."""
        # Create a subdirectory with a specific name
        test_dir = tmp_path / "my-project"
        test_dir.mkdir()

        pending_dir = test_dir / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)
        (pending_dir / "plan_1.md").write_text("Plan 1")

        success, stdout, _ = self.run_statusline_script(str(test_dir), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "my-project" in stdout, "Expected directory name 'my-project' in output"
        assert "📋 P:1" in stdout, "Expected pending count of 1"

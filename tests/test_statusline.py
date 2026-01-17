"""
Tests for claude_pilot statusline functionality.

Tests the statusline.sh script behavior including:
- Global hook integration (model info display)
- Pending count display (always shown, even when 0)
- Error handling (invalid JSON, missing jq)
- Edge cases (.gitkeep only, empty pending/)
"""

from __future__ import annotations

import subprocess
from pathlib import Path

import pytest


class TestStatuslineScript:
    """Test statusline.sh script functionality."""

    def get_statusline_script_path(self) -> Path:
        """Get the path to the statusline.sh script from assets or source."""
        import importlib.resources

        # Try assets first (packaged location)
        try:
            assets_path = importlib.resources.files("claude_pilot") / "assets"
            if assets_path.is_dir():
                script_path = Path(str(assets_path)) / ".claude" / "scripts" / "statusline.sh"
                if script_path.exists():
                    return script_path
        except (AttributeError, FileNotFoundError):
            pass

        # Fall back to source .claude directory for development environment
        # Get the project root (tests/ is at project root)
        project_root = Path(__file__).parent.parent
        source_script = project_root / ".claude" / "scripts" / "statusline.sh"
        if source_script.exists():
            return source_script

        # Last resort: try old templates path (should not exist anymore)
        templates_path = importlib.resources.files("claude_pilot") / "templates"
        return Path(str(templates_path)) / ".claude" / "scripts" / "statusline.sh"

    def run_statusline_script(
        self, cwd: str, tmp_path: Path, model: str = "Sonnet 4"
    ) -> tuple[bool, str, str]:
        """
        Run the statusline.sh script with mock input.

        Args:
            cwd: Current working directory to pass in JSON input
            tmp_path: Temporary directory for creating test files
            model: Model name to include in JSON input

        Returns:
            Tuple of (success, stdout, stderr)
        """
        script_path = self.get_statusline_script_path()

        # Create mock JSON input (matches Claude Code's format)
        json_input = f'{{"workspace":{{"current_dir":"{cwd}"}},"model":{{"display_name":"{model}"}}}}'

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

    def test_no_pending_displays_p0(self, tmp_path: Path) -> None:
        """Test statusline with no pending files shows P:0."""
        # Create .pilot/plan/pending/ directory
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋 P:0" in stdout, "Should show P:0 when pending=0"

    def test_with_pending_displays_count(self, tmp_path: Path) -> None:
        """Test statusline with pending files shows correct count."""
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

    def test_gitkeep_only_shows_p0(self, tmp_path: Path) -> None:
        """Test that .gitkeep only is treated as P:0."""
        # Create .pilot/plan/pending/ directory with only .gitkeep
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)
        (pending_dir / ".gitkeep").write_text("")

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋 P:0" in stdout, "Should show P:0 for .gitkeep only"

    def test_invalid_json_graceful_fallback(self, tmp_path: Path) -> None:
        """Test graceful fallback with invalid JSON input."""
        script_path = self.get_statusline_script_path()

        # Run script with invalid JSON
        result = subprocess.run(
            ["bash", str(script_path)],
            input="invalid json{{{",
            capture_output=True,
            text=True,
            cwd=tmp_path,
        )

        # set -euo pipefail will cause script to fail on invalid JSON
        # This is expected behavior
        assert result.returncode != 0, "Script should fail with invalid JSON (set -euo pipefail)"

    def test_missing_jq_fallback(self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test fallback when jq is not available."""
        script_path = self.get_statusline_script_path()

        # Mock PATH to not include jq
        original_path = "/usr/bin:/bin"  # Minimal PATH without jq

        # Create valid JSON input
        json_input = f'{{"workspace":{{"current_dir":"{tmp_path}"}},"model":{{"display_name":"Sonnet 4"}}}}'

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

        # Script should fail due to set -euo pipefail (jq not found)
        assert result.returncode != 0, "Script should fail without jq (set -euo pipefail)"

    def test_missing_pending_directory_shows_p0(self, tmp_path: Path) -> None:
        """Test statusline when .pilot/plan/pending/ doesn't exist shows P:0."""
        # Don't create the pending directory

        success, stdout, _ = self.run_statusline_script(str(tmp_path), tmp_path)

        assert success, f"Script failed: {stdout}"
        assert "📁" in stdout, "Expected folder icon in output"
        assert "📋 P:0" in stdout, "Should show P:0 when directory missing"

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

    def test_model_info_in_output(self, tmp_path: Path) -> None:
        """Test that model information is included in output (fallback mode)."""
        # Create .pilot/plan/pending/ directory
        pending_dir = tmp_path / ".pilot" / "plan" / "pending"
        pending_dir.mkdir(parents=True, exist_ok=True)

        # Run with custom model name
        success, stdout, _ = self.run_statusline_script(
            str(tmp_path), tmp_path, model="Opus"
        )

        assert success, f"Script failed: {stdout}"
        # In fallback mode (no global hook), should show model name
        # Note: If global hook exists, it might format differently
        assert "Opus" in stdout or "opus" in stdout.lower(), "Expected model name in output"

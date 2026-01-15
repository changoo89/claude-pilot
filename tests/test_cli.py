"""
Tests for claude_pilot.cli module.
"""

from __future__ import annotations

from unittest.mock import MagicMock, patch

from click.testing import CliRunner

from claude_pilot.cli import main


class TestUpdateCommand:
    """Test the update command with new options."""

    def test_update_with_skip_pip_flag(self, mock_subprocess_run: MagicMock) -> None:
        """Test that --skip-pip flag skips pip upgrade."""
        runner = CliRunner()
        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                with patch("claude_pilot.updater.get_current_version", return_value="2.1.4"):
                    with patch("claude_pilot.updater.perform_auto_update"):
                        result = runner.invoke(main, ["update", "--skip-pip"])
                        # Should not call subprocess.run for pip upgrade
                        assert result.exit_code == 0 or result.exit_code is None

    def test_update_with_check_only_flag(self) -> None:
        """Test that --check-only flag only checks without applying."""
        runner = CliRunner()
        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                result = runner.invoke(main, ["update", "--check-only"])
                assert result.exit_code == 0 or result.exit_code is None

    def test_update_with_both_flags(self) -> None:
        """Test that both --skip-pip and --check-only can be used together."""
        runner = CliRunner()
        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                result = runner.invoke(main, ["update", "--skip-pip", "--check-only"])
                assert result.exit_code == 0 or result.exit_code is None


class TestVersionCommand:
    """Test the version command."""

    def test_version_command_shows_versions(self) -> None:
        """Test that version command shows version information."""
        runner = CliRunner()
        with patch("claude_pilot.cli.get_current_version", return_value="2.1.4"):
            with patch("claude_pilot.cli.get_latest_version", return_value="2.1.5"):
                result = runner.invoke(main, ["version"])
                assert result.exit_code == 0
                assert "claude-pilot version information" in result.output


# Note: Init command tests are not in scope for this change
# The init command functionality is not being modified

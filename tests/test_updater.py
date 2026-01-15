"""
Tests for claude_pilot.updater module.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any
from unittest.mock import MagicMock, patch

import pytest

from claude_pilot import config
from claude_pilot.updater import get_latest_version


class TestGetPypiVersion:
    """Test get_pypi_version() function."""

    def test_get_pypi_version_returns_version_from_pypi(
        self, mock_requests_get: None
    ) -> None:
        """Test that get_pypi_version() returns the version from PyPI API."""
        # This test will fail because get_pypi_version() doesn't exist yet
        from claude_pilot.updater import get_pypi_version

        result = get_pypi_version()
        assert result == "2.1.5"

    def test_get_pypi_version_with_timeout_returns_none(
        self, mock_requests_timeout: None, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """Test that get_pypi_version() returns None on timeout."""
        from claude_pilot.updater import get_pypi_version

        result = get_pypi_version()
        assert result is None

        captured = capsys.readouterr()
        assert "warning" in captured.out.lower() or "timed out" in captured.out.lower()

    def test_get_pypi_version_with_connection_error_returns_none(
        self, mock_requests_connection_error: None, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """Test that get_pypi_version() returns None on connection error."""
        from claude_pilot.updater import get_pypi_version

        result = get_pypi_version()
        assert result is None

        captured = capsys.readouterr()
        assert "warning" in captured.out.lower() or "unreachable" in captured.out.lower()


class TestGetInstalledVersion:
    """Test get_installed_version() function."""

    def test_get_installed_version_returns_config_version(self) -> None:
        """Test that get_installed_version() returns the config.VERSION."""
        # This test will fail because get_installed_version() doesn't exist yet
        from claude_pilot.updater import get_installed_version

        result = get_installed_version()
        assert result == config.VERSION


class TestGetLatestVersion:
    """Test get_latest_version() function with PyPI integration."""

    def test_get_latest_version_returns_pypi_version_when_available(
        self, mock_requests_get: None
    ) -> None:
        """Test that get_latest_version() returns PyPI version when available."""
        # After modification, this should return PyPI version
        result = get_latest_version()
        assert result == "2.1.5"

    def test_get_latest_version_falls_back_to_config_on_error(
        self, mock_requests_timeout: None
    ) -> None:
        """Test that get_latest_version() falls back to config.VERSION on error."""
        result = get_latest_version()
        assert result == config.VERSION


class TestUpgradePipPackage:
    """Test upgrade_pip_package() function."""

    def test_upgrade_pip_package_runs_pip_install(
        self, mock_subprocess_run: MagicMock
    ) -> None:
        """Test that upgrade_pip_package() runs pip install --upgrade."""
        # This test will fail because upgrade_pip_package() doesn't exist yet
        from claude_pilot.updater import upgrade_pip_package

        result = upgrade_pip_package()
        assert result is True
        # Verify subprocess was called
        mock_subprocess_run.assert_called_once()

    def test_upgrade_pip_package_returns_false_on_failure(self) -> None:
        """Test that upgrade_pip_package() returns False on pip failure."""

        def _mock_run_failure(*args: Any, **kwargs: Any) -> MagicMock:
            mock_result = MagicMock()
            mock_result.returncode = 1
            mock_result.stderr = "Permission denied"
            return mock_result

        with patch("subprocess.run", side_effect=_mock_run_failure):
            from claude_pilot.updater import upgrade_pip_package

            result = upgrade_pip_package()
            assert result is False


class TestPerformUpdate:
    """Test perform_update() function with new parameters."""

    def test_perform_update_with_skip_pip(self, mock_subprocess_run: MagicMock) -> None:
        """Test perform_update() with skip_pip=True."""
        from claude_pilot.updater import perform_update

        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                with patch("claude_pilot.updater.get_current_version", return_value="2.1.4"):
                    with patch("claude_pilot.updater.get_latest_version", return_value="2.1.5"):
                        with patch("claude_pilot.updater.perform_auto_update") as mock_auto:
                            perform_update(skip_pip=True)
                            # Should skip pip upgrade and go straight to file updates
                            assert mock_auto.called

    def test_perform_update_with_check_only(self) -> None:
        """Test perform_update() with check_only=True."""
        from claude_pilot.updater import UpdateStatus, perform_update

        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                result = perform_update(check_only=True)
                # Should return ALREADY_CURRENT without making changes
                assert result == UpdateStatus.ALREADY_CURRENT

    def test_perform_update_pypi_upgraded_notification(
        self, mock_subprocess_run: MagicMock
    ) -> None:
        """Test that perform_update() notifies user when pip is upgraded."""
        from claude_pilot.updater import perform_update

        with patch("claude_pilot.updater.get_pypi_version", return_value="2.1.5"):
            with patch("claude_pilot.updater.get_installed_version", return_value="2.1.4"):
                with patch("claude_pilot.updater.get_current_version", return_value="2.1.4"):
                    with patch("claude_pilot.updater.get_latest_version", return_value="2.1.4"):
                        result = perform_update()
                        # Should complete without error
                        assert result is not None


class TestGetCurrentVersion:
    """Test get_current_version() function."""

    def test_get_current_version_returns_version_from_file(self, tmp_path: Path) -> None:
        """Test that get_current_version() reads from version file."""
        from claude_pilot import config
        from claude_pilot.updater import get_current_version

        version_file = tmp_path / config.VERSION_FILE
        version_file.parent.mkdir(parents=True, exist_ok=True)
        version_file.write_text("2.1.3")

        with patch("claude_pilot.config.get_target_dir", return_value=tmp_path):
            result = get_current_version()
            assert result == "2.1.3"

    def test_get_current_version_returns_none_when_missing(self, tmp_path: Path) -> None:
        """Test that get_current_version() returns 'none' when file missing."""
        from claude_pilot.updater import get_current_version

        with patch("claude_pilot.config.get_target_dir", return_value=tmp_path):
            result = get_current_version()
            assert result == "none"


class TestCheckUpdateNeeded:
    """Test check_update_needed() function."""

    def test_check_update_needed_returns_true_when_outdated(self, tmp_path: Path) -> None:
        """Test that check_update_needed() returns True when versions differ."""
        from claude_pilot.updater import check_update_needed

        with patch("claude_pilot.updater.get_current_version", return_value="2.1.3"):
            with patch("claude_pilot.updater.get_latest_version", return_value="2.1.4"):
                result = check_update_needed()
                assert result is True

    def test_check_update_needed_returns_false_when_current(self, tmp_path: Path) -> None:
        """Test that check_update_needed() returns False when up to date."""
        from claude_pilot.updater import check_update_needed

        with patch("claude_pilot.updater.get_current_version", return_value="2.1.4"):
            with patch("claude_pilot.updater.get_latest_version", return_value="2.1.4"):
                result = check_update_needed()
                assert result is False


class TestPerformAutoUpdate:
    """Test perform_auto_update() function."""

    def test_perform_auto_update_creates_backup(self, tmp_path: Path) -> None:
        """Test that perform_auto_update() creates a backup."""
        from claude_pilot.updater import UpdateStatus, perform_auto_update

        # Create .claude directory with a test file
        claude_dir = tmp_path / ".claude"
        claude_dir.mkdir(parents=True, exist_ok=True)
        (claude_dir / "test.txt").write_text("test content")

        result = perform_auto_update(tmp_path)
        assert result == UpdateStatus.UPDATED

        # Check backup was created
        backup_dir = tmp_path / ".claude-backups"
        assert backup_dir.exists()


class TestPerformManualUpdate:
    """Test perform_manual_update() function."""

    def test_perform_manual_update_generates_guide(self, tmp_path: Path) -> None:
        """Test that perform_manual_update() generates a merge guide."""
        from claude_pilot.updater import UpdateStatus, perform_manual_update

        # Create .claude directory
        claude_dir = tmp_path / ".claude"
        claude_dir.mkdir(parents=True, exist_ok=True)

        result = perform_manual_update(tmp_path)
        assert result == UpdateStatus.UPDATED

        # Check guide was generated
        guide = tmp_path / ".claude-backups" / "MANUAL_MERGE_GUIDE.md"
        assert guide.exists()


class TestGetPypiVersionEdgeCases:
    """Test edge cases for get_pypi_version()."""

    def test_get_pypi_version_http_error(
        self, monkeypatch: pytest.MonkeyPatch, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """Test that get_pypi_version() handles HTTP errors."""

        def _mock_get_http_error(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.HTTPError("404 Not Found")

        monkeypatch.setattr("requests.get", _mock_get_http_error)

        from claude_pilot.updater import get_pypi_version

        result = get_pypi_version()
        assert result is None

        captured = capsys.readouterr()
        assert "warning" in captured.out.lower()


class TestPerformUpdateEdgeCases:
    """Test edge cases for perform_update()."""

    def test_perform_update_manual_strategy(self, tmp_path: Path) -> None:
        """Test perform_update() with manual strategy."""
        from claude_pilot.updater import MergeStrategy, UpdateStatus, perform_update

        with patch("claude_pilot.updater.get_pypi_version", return_value=None):
            with patch("claude_pilot.updater.get_current_version", return_value="2.1.3"):
                with patch("claude_pilot.updater.get_latest_version", return_value="2.1.4"):
                    result = perform_update(target_dir=tmp_path, strategy=MergeStrategy.MANUAL)
                    # Should generate manual merge guide
                    assert result == UpdateStatus.UPDATED

    def test_perform_update_already_current_no_pypi(self) -> None:
        """Test perform_update() when already current and PyPI unavailable."""
        from claude_pilot.updater import UpdateStatus, perform_update

        with patch("claude_pilot.updater.get_pypi_version", return_value=None):
            with patch("claude_pilot.updater.get_current_version", return_value="2.1.4"):
                with patch("claude_pilot.updater.get_latest_version", return_value="2.1.4"):
                    result = perform_update()
                    assert result == UpdateStatus.ALREADY_CURRENT

"""
Pytest configuration and shared fixtures for claude-pilot tests.
"""

from __future__ import annotations

from collections.abc import Generator
from pathlib import Path
from typing import Any
from unittest.mock import MagicMock, patch

import pytest


@pytest.fixture
def mock_target_dir(tmp_path: Path) -> Path:
    """Create a mock target directory for testing."""
    return tmp_path


@pytest.fixture
def mock_requests_get(monkeypatch: pytest.MonkeyPatch) -> None:
    """Mock requests.get for PyPI API calls."""

    def _mock_get(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "info": {"version": "2.1.5"},
            "releases": {},
        }
        return mock_response

    monkeypatch.setattr("requests.get", _mock_get)


@pytest.fixture
def mock_requests_timeout(monkeypatch: pytest.MonkeyPatch) -> None:
    """Mock requests.get to raise timeout exception."""

    def _mock_get_timeout(url: str, timeout: int | None = None, **kwargs: Any) -> None:
        import requests
        raise requests.exceptions.Timeout("PyPI request timed out")

    monkeypatch.setattr("requests.get", _mock_get_timeout)


@pytest.fixture
def mock_requests_connection_error(monkeypatch: pytest.MonkeyPatch) -> None:
    """Mock requests.get to raise connection error."""

    def _mock_get_error(url: str, timeout: int | None = None, **kwargs: Any) -> None:
        import requests
        raise requests.exceptions.ConnectionError("Network unreachable")

    monkeypatch.setattr("requests.get", _mock_get_error)


@pytest.fixture
def mock_subprocess_run() -> Generator[MagicMock, None, None]:
    """Mock subprocess.run for pip upgrade commands."""
    mock_result = MagicMock()
    mock_result.returncode = 0
    mock_result.stdout = "Successfully installed claude-pilot-2.1.5"
    mock_result.stderr = ""

    with patch("subprocess.run", return_value=mock_result) as mock_run:
        yield mock_run

"""
Tests for Codex integration functionality.

This module tests Codex CLI detection, authentication checking,
and availability for GPT expert delegation via codex exec.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from claude_pilot.codex import check_codex_auth, detect_codex_cli, is_codex_available


class TestDetectCodexCli:
    """Test detect_codex_cli() function."""

    def test_detect_codex_installed(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test detect_codex_cli() returns True when codex is installed (TS-1)."""
        # Mock shutil.which to return a path
        monkeypatch.setattr("shutil.which", lambda x: "/usr/local/bin/codex")

        result = detect_codex_cli()
        assert result is True

    def test_detect_codex_not_installed(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test detect_codex_cli() returns False when codex is not installed (TS-2)."""
        # Mock shutil.which to return None
        monkeypatch.setattr("shutil.which", lambda x: None)

        result = detect_codex_cli()
        assert result is False


class TestCheckCodexAuth:
    """Test check_codex_auth() function."""

    def test_codex_authenticated(self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test check_codex_auth() returns True when valid auth.json exists (TS-3)."""
        # Create a mock auth.json with valid tokens
        auth_dir = tmp_path / ".codex"
        auth_dir.mkdir()
        auth_file = auth_dir / "auth.json"
        auth_file.write_text('{"tokens": {"access_token": "test_token"}}')

        # Mock Path.home to return tmp_path
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is True

    def test_codex_not_authenticated_no_file(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test check_codex_auth() returns False when auth.json doesn't exist (TS-4)."""
        # Mock Path.home to return a path without .codex/auth.json
        tmp_path = Path("/tmp/no_codex")
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is False

    def test_codex_not_authenticated_invalid_json(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test check_codex_auth() returns False when auth.json is invalid (TS-4)."""
        # Create a mock auth.json with missing tokens
        auth_dir = tmp_path / ".codex"
        auth_dir.mkdir()
        auth_file = auth_dir / "auth.json"
        auth_file.write_text('{"not_tokens": "value"}')

        # Mock Path.home to return tmp_path
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is False

    def test_codex_auth_malformed_json(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test check_codex_auth() returns False when auth.json is malformed JSON (line 44)."""
        # Create a mock auth.json with malformed JSON
        auth_dir = tmp_path / ".codex"
        auth_dir.mkdir()
        auth_file = auth_dir / "auth.json"
        auth_file.write_text('{"tokens": "invalid json')

        # Mock Path.home to return tmp_path
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is False

    def test_codex_auth_missing_tokens_key(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test check_codex_auth() returns False when tokens key is missing (line 44)."""
        # Create a mock auth.json without tokens key
        auth_dir = tmp_path / ".codex"
        auth_dir.mkdir()
        auth_file = auth_dir / "auth.json"
        auth_file.write_text('{"other_key": "value"}')

        # Mock Path.home to return tmp_path
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is False

    def test_codex_auth_invalid_tokens_structure(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test check_codex_auth() returns False when tokens is not a dict (line 45)."""
        # Create a mock auth.json with tokens as string instead of dict
        auth_dir = tmp_path / ".codex"
        auth_dir.mkdir()
        auth_file = auth_dir / "auth.json"
        auth_file.write_text('{"tokens": "not_a_dict"}')

        # Mock Path.home to return tmp_path
        monkeypatch.setattr("pathlib.Path.home", lambda: tmp_path)

        result = check_codex_auth()
        assert result is False


class TestIsCodexAvailable:
    """Test is_codex_available() function."""

    def test_available_when_installed_and_authenticated(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test is_codex_available() returns True when installed and authenticated."""
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: True)
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: True)

        result = is_codex_available()
        assert result is True

    def test_not_available_when_not_installed(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test is_codex_available() returns False when not installed."""
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: False)
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: True)

        result = is_codex_available()
        assert result is False

    def test_not_available_when_not_authenticated(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test is_codex_available() returns False when not authenticated."""
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: True)
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: False)

        result = is_codex_available()
        assert result is False

    def test_not_available_when_neither(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test is_codex_available() returns False when neither installed nor authenticated."""
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: False)
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: False)

        result = is_codex_available()
        assert result is False


class TestDelegatorTemplates:
    """Test delegator rules and prompts are in templates (SC-4, SC-5)."""

    def test_delegator_rules_exist(self) -> None:
        """Test that 4 orchestration rules exist in assets (SC-4)."""
        import importlib.resources

        # Try assets first (packaged location), fall back to source (dev env)
        try:
            assets_path = importlib.resources.files("claude_pilot") / "assets"
            delegator_path = assets_path / ".claude" / "rules" / "delegator"
            if delegator_path.is_dir():
                assert delegator_path.is_dir()
            else:
                # Fall back to source directory for development
                project_root = Path(__file__).parent.parent
                delegator_path = project_root / ".claude" / "rules" / "delegator"
        except (AttributeError, FileNotFoundError):
            # Fall back to source directory for development
            project_root = Path(__file__).parent.parent
            delegator_path = project_root / ".claude" / "rules" / "delegator"

        # Check directory exists
        assert delegator_path.is_dir()

        # Check 4 orchestration rule files exist
        expected_rules = [
            "delegation-format.md",
            "model-selection.md",
            "orchestration.md",
            "triggers.md",
        ]

        for rule_file in expected_rules:
            rule_path = delegator_path / rule_file
            assert rule_path.is_file(), f"Rule file {rule_file} not found"

    def test_expert_prompts_exist(self) -> None:
        """Test that 5 expert prompts exist in assets (SC-5)."""
        import importlib.resources

        # Try assets first (packaged location), fall back to source (dev env)
        try:
            assets_path = importlib.resources.files("claude_pilot") / "assets"
            prompts_path = assets_path / ".claude" / "rules" / "delegator" / "prompts"
            if prompts_path.is_dir():
                assert prompts_path.is_dir()
            else:
                # Fall back to source directory for development
                project_root = Path(__file__).parent.parent
                prompts_path = project_root / ".claude" / "rules" / "delegator" / "prompts"
        except (AttributeError, FileNotFoundError):
            # Fall back to source directory for development
            project_root = Path(__file__).parent.parent
            prompts_path = project_root / ".claude" / "rules" / "delegator" / "prompts"

        # Check directory exists
        assert prompts_path.is_dir()

        # Check 5 expert prompt files exist
        expected_prompts = [
            "architect.md",
            "code-reviewer.md",
            "plan-reviewer.md",
            "scope-analyst.md",
            "security-analyst.md",
        ]

        for prompt_file in expected_prompts:
            prompt_path = prompts_path / prompt_file
            assert prompt_path.is_file(), f"Prompt file {prompt_file} not found"

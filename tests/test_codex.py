"""
Tests for Codex integration functionality.

This module tests Codex CLI detection, authentication checking,
and MCP configuration generation for GPT expert delegation.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from claude_pilot.codex import check_codex_auth, detect_codex_cli, setup_codex_mcp


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


class TestSetupCodexMcp:
    """Test setup_codex_mcp() function."""

    def test_setup_mcp_fresh(self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test setup_codex_mcp() creates new .mcp.json when none exists (TS-5)."""
        # Mock detect_codex_cli to return True
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: True)

        # Mock check_codex_auth to return True
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: True)

        # Create target directory
        result = setup_codex_mcp(tmp_path)

        assert result is True

        # Check .mcp.json was created
        mcp_file = tmp_path / ".mcp.json"
        assert mcp_file.exists()

        # Verify content
        import json

        content = json.loads(mcp_file.read_text())
        assert "mcpServers" in content
        assert "codex" in content["mcpServers"]
        assert content["mcpServers"]["codex"]["type"] == "stdio"
        assert content["mcpServers"]["codex"]["command"] == "codex"
        # Note: Plan specifies gpt-5.2, reference shows gpt-5.2-codex
        # Using gpt-5.2 as per plan requirement
        assert content["mcpServers"]["codex"]["args"] == ["-m", "gpt-5.2", "mcp-server"]

    def test_setup_mcp_merge(self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test setup_codex_mcp() merges with existing .mcp.json (TS-6)."""
        # Create existing .mcp.json
        existing_mcp = tmp_path / ".mcp.json"
        import json

        existing_content = {"mcpServers": {"existing-server": {"type": "stdio", "command": "existing"}}}
        existing_mcp.write_text(json.dumps(existing_content))

        # Mock detect_codex_cli to return True
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: True)

        # Mock check_codex_auth to return True
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: True)

        # Setup
        result = setup_codex_mcp(tmp_path)

        assert result is True

        # Verify existing server was preserved
        content = json.loads(existing_mcp.read_text())
        assert "existing-server" in content["mcpServers"]
        assert "codex" in content["mcpServers"]

    def test_setup_mcp_skip_not_installed(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test setup_codex_mcp() skips when Codex not installed (TS-7)."""
        # Mock detect_codex_cli to return False
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: False)

        # Setup
        result = setup_codex_mcp(tmp_path)

        assert result is True  # Function succeeds but skips setup

        # Verify .mcp.json was NOT created
        mcp_file = tmp_path / ".mcp.json"
        assert not mcp_file.exists()

    def test_setup_mcp_skip_not_authenticated(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test setup_codex_mcp() skips when Codex not authenticated."""
        # Mock detect_codex_cli to return True
        monkeypatch.setattr("claude_pilot.codex.detect_codex_cli", lambda: True)

        # Mock check_codex_auth to return False
        monkeypatch.setattr("claude_pilot.codex.check_codex_auth", lambda: False)

        # Setup
        result = setup_codex_mcp(tmp_path)

        assert result is True  # Function succeeds but skips setup

        # Verify .mcp.json was NOT created
        mcp_file = tmp_path / ".mcp.json"
        assert not mcp_file.exists()


class TestDelegatorTemplates:
    """Test delegator rules and prompts are in templates (SC-4, SC-5)."""

    def test_delegator_rules_exist(self) -> None:
        """Test that 4 orchestration rules exist in templates (SC-4)."""
        import importlib.resources

        templates_path = importlib.resources.files("claude_pilot") / "templates"
        delegator_path = templates_path / ".claude" / "rules" / "delegator"

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
        """Test that 5 expert prompts exist in templates (SC-5)."""
        import importlib.resources

        templates_path = importlib.resources.files("claude_pilot") / "templates"
        prompts_path = templates_path / ".claude" / "rules" / "delegator" / "prompts"

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

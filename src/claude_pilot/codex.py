"""
Codex integration for GPT expert delegation.

This module provides functionality for detecting Codex CLI installation,
checking authentication status, and generating MCP configuration for
GPT expert delegation via Codex MCP server.
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

# Codex MCP configuration
CODEX_MCP_CONFIG = {
    "mcpServers": {
        "codex": {
            "type": "stdio",
            "command": "codex",
            "args": ["-m", "gpt-5.2", "mcp-server"],
        }
    }
}

# Codex authentication file path
CODEX_AUTH_PATH = ".codex/auth.json"


def detect_codex_cli() -> bool:
    """
    Detect if Codex CLI is installed on the system.

    Returns:
        True if codex command is available, False otherwise.
    """
    return shutil.which("codex") is not None


def check_codex_auth() -> bool:
    """
    Check if Codex CLI is authenticated with valid tokens.

    Returns:
        True if ~/.codex/auth.json exists with valid tokens, False otherwise.
    """
    auth_file = Path.home() / CODEX_AUTH_PATH

    if not auth_file.exists():
        return False

    try:
        content = json.loads(auth_file.read_text())
        # Check for tokens.access_token field
        return "tokens" in content and "access_token" in content["tokens"]
    except (json.JSONDecodeError, KeyError, TypeError):
        return False


def setup_codex_mcp(target_dir: Path) -> bool:
    """
    Setup Codex MCP configuration in .mcp.json.

    Creates or merges .mcp.json with Codex MCP server configuration.
    Skips if Codex CLI is not installed or not authenticated.

    Args:
        target_dir: Target directory for .mcp.json file.

    Returns:
        True if setup succeeded or was skipped, False on error.
    """
    # Skip if Codex not available or not authenticated
    if not detect_codex_cli():
        return True
    if not check_codex_auth():
        return True

    mcp_file = target_dir / ".mcp.json"

    # Load existing config or create new
    if mcp_file.exists():
        try:
            existing_config = json.loads(mcp_file.read_text())
        except (json.JSONDecodeError, IOError):
            existing_config = {"mcpServers": {}}
    else:
        existing_config = {"mcpServers": {}}

    # Merge Codex config
    if "mcpServers" not in existing_config:
        existing_config["mcpServers"] = {}
    existing_config["mcpServers"]["codex"] = CODEX_MCP_CONFIG["mcpServers"]["codex"]

    # Write merged config
    try:
        mcp_file.write_text(json.dumps(existing_config, indent=2) + "\n")
        return True
    except IOError:
        return False

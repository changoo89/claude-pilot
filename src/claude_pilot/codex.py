"""
Codex integration for GPT expert delegation.

This module provides functionality for detecting Codex CLI installation
and checking authentication status. GPT delegation is handled via
codex-sync.sh script using `codex exec` command.
"""

from __future__ import annotations

import json
import shutil
from pathlib import Path

from claude_pilot.config import CODEX_AUTH_PATH


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


def is_codex_available() -> bool:
    """
    Check if Codex is fully available (installed and authenticated).

    Returns:
        True if Codex CLI is installed and authenticated, False otherwise.
    """
    return detect_codex_cli() and check_codex_auth()

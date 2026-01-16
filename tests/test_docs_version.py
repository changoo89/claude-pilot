"""
Documentation version and quality tests.

Tests TS-1 through TS-5 for documentation improvement plan.
"""
from __future__ import annotations

from pathlib import Path

import pytest


class TestDocumentationVersion:
    """Test suite for documentation version consistency (TS-1)."""

    def test_version_consistency_no_old_version_refs(self, project_root: Path) -> None:
        """TS-1: Verify no 3.4.0 version references exist in documentation headers."""
        doc_files = [
            project_root / "CLAUDE.md",
            project_root / "docs" / "ai-context" / "system-integration.md",
            project_root / "docs" / "ai-context" / "project-structure.md",
            project_root / "src" / "claude_pilot" / "CONTEXT.md",
        ]

        for doc_file in doc_files:
            if not doc_file.exists():
                continue

            content = doc_file.read_text()
            # Check only first 50 lines (header section) for version markers
            # Version history sections are exempt as they document historical versions
            lines = content.split("\n")[:50]
            header_content = "\n".join(lines)
            assert "3.4.0" not in header_content, f"Found old version 3.4.0 in header of {doc_file}"

    def test_version_consistency_current_version_present(self, project_root: Path) -> None:
        """Verify current version 4.0.3 is present in key documentation."""
        claude_md = project_root / "CLAUDE.md"
        if claude_md.exists():
            content = claude_md.read_text()
            assert "4.0.3" in content, "Current version 4.0.3 not found in CLAUDE.md"


class TestChangelog:
    """Test suite for CHANGELOG.md (TS-2)."""

    def test_changelog_exists(self, project_root: Path) -> None:
        """TS-2: Verify CHANGELOG.md exists."""
        changelog = project_root / "CHANGELOG.md"
        assert changelog.exists(), "CHANGELOG.md does not exist"

    def test_changelog_has_proper_format(self, project_root: Path) -> None:
        """TS-2: Verify CHANGELOG.md has Keep a Changelog format."""
        changelog = project_root / "CHANGELOG.md"
        if not changelog.exists():
            pytest.skip("CHANGELOG.md does not exist yet")

        content = changelog.read_text()
        # Check for basic Keep a Changelog format markers
        assert "# Changelog" in content or "# Changelog" in content, (
            "CHANGELOG.md missing proper title"
        )


class TestCliFlags:
    """Test suite for CLI flag accuracy (TS-3)."""

    def test_cli_flags_accurate(self, project_root: Path) -> None:
        """TS-3: Verify CLI examples use --strategy manual, not --manual."""
        readme = project_root / "README.md"
        if not readme.exists():
            pytest.skip("README.md does not exist")

        content = readme.read_text()
        # Check that --manual does not appear as standalone flag
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if "--manual" in line and "--strategy manual" not in line:
                # Allow it in code blocks or explanations, but not as standalone command
                if "claude-pilot" in line:
                    pytest.fail(
                        f"Line {i+1}: Found '--manual' flag instead of '--strategy manual': {line}"
                    )


class TestDocumentationSize:
    """Test suite for documentation size limits (TS-4)."""

    def test_claude_md_size_limit(self, project_root: Path) -> None:
        """TS-4: Verify CLAUDE.md is within 300 line limit."""
        claude_md = project_root / "CLAUDE.md"
        if not claude_md.exists():
            pytest.skip("CLAUDE.md does not exist")

        line_count = len(claude_md.read_text().split("\n"))
        assert line_count <= 300, f"CLAUDE.md has {line_count} lines, exceeds 300 line limit"


class TestPlatformReferences:
    """Test suite for platform reference accuracy (TS-5)."""

    def test_no_npm_references_in_python_docs(self, project_root: Path) -> None:
        """TS-5: Verify no 'publish to npm' references in Python documentation."""
        project_structure = project_root / "docs" / "ai-context" / "project-structure.md"
        if not project_structure.exists():
            pytest.skip("project-structure.md does not exist")

        content = project_structure.read_text()
        assert "publish to npm" not in content.lower(), (
            "Found 'publish to npm' reference in Python documentation"
        )

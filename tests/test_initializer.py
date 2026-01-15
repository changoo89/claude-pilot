"""
Tests for claude_pilot.initializer module.
"""

from __future__ import annotations

from pathlib import Path

from claude_pilot.initializer import ProjectInitializer


class TestUpdateGitignore:
    """Test update_gitignore() method."""

    def test_update_gitignore_creates_new_gitignore(self, tmp_path: Path) -> None:
        """Test that update_gitignore() creates .gitignore when it doesn't exist."""
        initializer = ProjectInitializer(target_dir=tmp_path)

        initializer.update_gitignore()

        gitignore_path = tmp_path / ".gitignore"
        assert gitignore_path.exists()
        content = gitignore_path.read_text()
        assert ".pilot/" in content
        assert "# claude-pilot plan tracking (worktree support)" in content

    def test_update_gitignore_appends_to_existing_gitignore(
        self, tmp_path: Path
    ) -> None:
        """Test that update_gitignore() appends to existing .gitignore."""
        gitignore_path = tmp_path / ".gitignore"
        gitignore_path.write_text("node_modules/\n*.pyc\n")

        initializer = ProjectInitializer(target_dir=tmp_path)
        initializer.update_gitignore()

        content = gitignore_path.read_text()
        assert "node_modules/" in content
        assert "*.pyc" in content
        assert ".pilot/" in content
        assert "# claude-pilot plan tracking (worktree support)" in content

    def test_update_gitignore_skips_if_already_present(self, tmp_path: Path) -> None:
        """Test that update_gitignore() skips if .pilot/ already in .gitignore."""
        gitignore_path = tmp_path / ".gitignore"
        original_content = "node_modules/\n.pilot/\n*.pyc\n"
        gitignore_path.write_text(original_content)

        initializer = ProjectInitializer(target_dir=tmp_path)
        initializer.update_gitignore()

        # Content should be unchanged (no duplicate entries)
        content = gitignore_path.read_text()
        assert content == original_content
        # Count occurrences - should be exactly 1
        assert content.count(".pilot/") == 1

    def test_update_gitignore_adds_newline_if_needed(self, tmp_path: Path) -> None:
        """Test that update_gitignore() adds newline before appending if needed."""
        gitignore_path = tmp_path / ".gitignore"
        gitignore_path.write_text("node_modules/")  # No trailing newline

        initializer = ProjectInitializer(target_dir=tmp_path)
        initializer.update_gitignore()

        content = gitignore_path.read_text()
        assert content.startswith("node_modules/\n")
        assert ".pilot/" in content

    def test_update_gitignore_preserves_existing_content(self, tmp_path: Path) -> None:
        """Test that update_gitignore() preserves all existing content."""
        gitignore_path = tmp_path / ".gitignore"
        existing_lines = [
            "# Build artifacts",
            "build/",
            "dist/",
            "*.egg-info/",
            "# Python",
            "__pycache__/",
            "*.pyc",
        ]
        gitignore_path.write_text("\n".join(existing_lines))

        initializer = ProjectInitializer(target_dir=tmp_path)
        initializer.update_gitignore()

        content = gitignore_path.read_text()
        for line in existing_lines:
            assert line in content


class TestEnsureGitignore:
    """Test ensure_gitignore() function in updater module."""

    def test_ensure_gitignore_function_exists(self) -> None:
        """Test that ensure_gitignore() function exists in updater module."""
        from claude_pilot.updater import ensure_gitignore

        assert callable(ensure_gitignore)

    def test_ensure_gitignore_creates_gitignore(self, tmp_path: Path) -> None:
        """Test that ensure_gitignore() creates .gitignore when missing."""
        from claude_pilot.updater import ensure_gitignore

        ensure_gitignore(tmp_path)

        gitignore_path = tmp_path / ".gitignore"
        assert gitignore_path.exists()
        content = gitignore_path.read_text()
        assert ".pilot/" in content

    def test_ensure_gitignore_appends_if_missing(self, tmp_path: Path) -> None:
        """Test that ensure_gitignore() appends .pilot/ if missing."""
        from claude_pilot.updater import ensure_gitignore

        gitignore_path = tmp_path / ".gitignore"
        gitignore_path.write_text("node_modules/\n")

        ensure_gitignore(tmp_path)

        content = gitignore_path.read_text()
        assert ".pilot/" in content
        assert "node_modules/" in content

    def test_ensure_gitignore_skips_if_present(self, tmp_path: Path) -> None:
        """Test that ensure_gitignore() skips if .pilot/ already present."""
        from claude_pilot.updater import ensure_gitignore

        gitignore_path = tmp_path / ".gitignore"
        original_content = "node_modules/\n.pilot/\n*.pyc\n"
        gitignore_path.write_text(original_content)

        ensure_gitignore(tmp_path)

        # Content should be unchanged
        content = gitignore_path.read_text()
        assert content == original_content

    def test_ensure_gitignore_adds_newline_if_needed(self, tmp_path: Path) -> None:
        """Test that ensure_gitignore() adds newline before appending if needed."""
        from claude_pilot.updater import ensure_gitignore

        gitignore_path = tmp_path / ".gitignore"
        gitignore_path.write_text("node_modules/")  # No trailing newline

        ensure_gitignore(tmp_path)

        content = gitignore_path.read_text()
        assert content.startswith("node_modules/\n")
        assert ".pilot/" in content

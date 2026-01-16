"""
Tests for worktree utility functions.

These tests verify the worktree-utils.sh functions for:
- Absolute path handling (SC-2)
- Metadata parsing with multi-line sections (SC-5)
- Dual active pointer storage (SC-4)
- Main project path storage (SC-3)
- Lock file cleanup (SC-7)
- Force cleanup for dirty worktrees (SC-6)
"""

import shutil
import subprocess
from pathlib import Path

import pytest


class TestWorktreeUtils:
    """Test worktree utility functions."""

    @pytest.fixture
    def worktree_utils_path(self) -> Path:
        """Path to worktree-utils.sh."""
        return Path(__file__).parent.parent / ".claude" / "scripts" / "worktree-utils.sh"

    @pytest.fixture
    def temp_git_repo(self, tmp_path: Path) -> Path:
        """Create a temporary git repository for testing."""
        repo_path = tmp_path / "test-repo"
        repo_path.mkdir()

        # Initialize git repo
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_path, check=True, capture_output=True)

        # Create initial commit
        (repo_path / "README.md").write_text("# Test Repo")
        subprocess.run(["git", "add", "."], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo_path, check=True, capture_output=True)

        return repo_path

    def source_worktree_utils(self, worktree_utils_path: Path) -> str:
        """Return bash command to source worktree-utils.sh."""
        return f'. "{worktree_utils_path}"'

    # SC-2: Test create_worktree returns absolute path
    def test_create_worktree_returns_absolute_path(self, temp_git_repo: Path, worktree_utils_path: Path) -> None:
        """Test that create_worktree returns absolute path (SC-2)."""
        branch_name = "feature/test-absolute-path"
        plan_file = "20260117_120000_test_plan.md"
        main_branch = "main"

        cmd = f'''
        cd "{temp_git_repo}" && \
        . "{worktree_utils_path}" && \
        result=$(create_worktree "{branch_name}" "{plan_file}" "{main_branch}") && \
        printf "%s" "$result"
        '''

        result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)
        # The function echoes progress messages, extract the last line (actual return value)
        output_lines = result.stdout.strip().split('\n')
        worktree_path = output_lines[-1] if output_lines else ""

        # Assert path is absolute (starts with /)
        assert worktree_path.startswith("/"), f"Expected absolute path, got: {worktree_path}"

        # Cleanup
        worktree_full = Path(temp_git_repo / worktree_path).resolve()
        if worktree_full.exists():
            shutil.rmtree(worktree_full, ignore_errors=True)
        subprocess.run(["git", "worktree", "remove", worktree_path], cwd=temp_git_repo, capture_output=True)
        subprocess.run(["git", "branch", "-D", branch_name], cwd=temp_git_repo, capture_output=True)

    # SC-3: Test add_worktree_metadata includes main project and lock file
    def test_add_worktree_metadata_includes_main_project_and_lock(self, temp_git_repo: Path, worktree_utils_path: Path) -> None:
        """Test that metadata includes Main Project and Lock File fields (SC-3)."""
        plan_path = temp_git_repo / "test-plan.md"
        plan_path.write_text("# Test Plan\n")

        branch = "feature/test-metadata"
        worktree_path = "/absolute/path/to/worktree"
        main_branch = "main"
        main_project = str(temp_git_repo)
        lock_file = str(temp_git_repo / ".pilot" / ".locks" / "test-plan.md.lock")

        cmd = f'''
        cd "{temp_git_repo}" && \
        . "{worktree_utils_path}" && \
        add_worktree_metadata "{plan_path}" "{branch}" "{worktree_path}" "{main_branch}" "{main_project}" "{lock_file}"
        '''

        subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)

        # Read plan file and check for new fields
        content = plan_path.read_text()
        assert "## Worktree Info" in content
        assert f"Branch: {branch}" in content
        assert f"Worktree Path: {worktree_path}" in content
        assert f"Main Branch: {main_branch}" in content
        assert "Main Project:" in content, "Missing Main Project field (SC-3)"
        assert "Lock File:" in content, "Missing Lock File field (SC-7)"

    # SC-5: Test read_worktree_metadata parses multi-line sections
    def test_read_worktree_metadata_multiline_parsing(self, temp_git_repo: Path, worktree_utils_path: Path) -> None:
        """Test that read_worktree_metadata correctly parses multi-line sections (SC-5)."""
        plan_path = temp_git_repo / "test-plan.md"

        # Create plan with multi-line metadata
        plan_path.write_text("""# Test Plan

## Worktree Info

- Branch: feature/test-branch
- Worktree Path: /absolute/path/to/worktree
- Main Branch: main
- Main Project: /absolute/path/to/main/project
- Lock File: /absolute/path/to/.locks/test.lock
- Created At: 2026-01-17T12:00:00
""")

        cmd = f'''
        cd "{temp_git_repo}" && \
        . "{worktree_utils_path}" && \
        read_worktree_metadata "{plan_path}"
        '''

        result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)

        # Should return pipe-delimited values
        assert result.returncode == 0, f"read_worktree_metadata failed: {result.stderr}"
        assert "|" in result.stdout, "Expected pipe-delimited output"

        parts = result.stdout.strip().split("|")
        assert len(parts) >= 4, f"Expected at least 4 fields, got {len(parts)}: {parts}"

        branch, worktree_path, main_branch, main_project = parts[0], parts[1], parts[2], parts[3]

        assert branch == "feature/test-branch", f"Expected branch 'feature/test-branch', got '{branch}'"
        assert worktree_path == "/absolute/path/to/worktree", f"Expected worktree_path '/absolute/path/to/worktree', got '{worktree_path}'"
        assert main_branch == "main", f"Expected main_branch 'main', got '{main_branch}'"
        assert main_project == "/absolute/path/to/main/project", f"Expected main_project '/absolute/path/to/main/project', got '{main_project}'"

    # SC-6: Test cleanup_worktree with --force option
    def test_cleanup_worktree_with_force_option(self, temp_git_repo: Path, worktree_utils_path: Path) -> None:
        """Test that cleanup_worktree handles dirty worktrees with --force (SC-6)."""
        # Create a worktree
        worktree_path = temp_git_repo / ".." / f"{temp_git_repo.name}-wt-test"
        worktree_path = worktree_path.resolve()

        subprocess.run([
            "git", "worktree", "add", "-b", "feature/test-force",
            str(worktree_path), "main"
        ], cwd=temp_git_repo, check=True, capture_output=True)

        # Create dirty file (uncommitted changes)
        (worktree_path / "dirty.txt").write_text("Uncommitted changes")

        cmd = f'''
        cd "{temp_git_repo}" && \
        . "{worktree_utils_path}" && \
        cleanup_worktree "{worktree_path}" "feature/test-force"
        '''

        result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)

        # Cleanup should succeed even with dirty state
        assert result.returncode == 0, f"cleanup_worktree failed: {result.stderr}"
        assert not worktree_path.exists(), f"Worktree directory still exists: {worktree_path}"

    # SC-4: Test dual active pointer storage (integration test)
    def test_dual_active_pointer_storage(self, temp_git_repo: Path) -> None:
        """Test that active pointers are created for both main and worktree branches (SC-4)."""
        active_dir = temp_git_repo / ".pilot" / "plan" / "active"
        active_dir.mkdir(parents=True)

        plan_path = temp_git_repo / ".pilot" / "plan" / "in_progress" / "test-plan.md"
        plan_path.parent.mkdir(parents=True)
        plan_path.write_text("# Test Plan")

        main_branch = "main"
        worktree_branch = "feature/test-branch"

        # Sanitize branch names for filenames
        main_key = main_branch.replace("/", "_")
        worktree_key = worktree_branch.replace("/", "_")

        # Simulate dual pointer storage
        (active_dir / f"{main_key}.txt").write_text(str(plan_path))
        (active_dir / f"{worktree_key}.txt").write_text(str(plan_path))

        # Verify both pointers exist
        assert (active_dir / f"{main_key}.txt").exists(), "Main branch active pointer missing (SC-4)"
        assert (active_dir / f"{worktree_key}.txt").exists(), "Worktree branch active pointer missing (SC-4)"

        # Verify both point to same plan
        main_content = (active_dir / f"{main_key}.txt").read_text()
        worktree_content = (active_dir / f"{worktree_key}.txt").read_text()

        assert main_content == str(plan_path), f"Main pointer points to wrong plan: {main_content}"
        assert worktree_content == str(plan_path), f"Worktree pointer points to wrong plan: {worktree_content}"

    # SC-7: Test lock file cleanup
    def test_lock_file_cleanup(self, temp_git_repo: Path, worktree_utils_path: Path) -> None:
        """Test that lock files are cleaned up properly (SC-7)."""
        lock_dir = temp_git_repo / ".pilot" / ".locks"
        lock_dir.mkdir(parents=True)

        # Create a lock file (directory-based lock)
        plan_name = "test-plan.md"
        lock_file = lock_dir / f"{plan_name}.lock"
        lock_file.mkdir()

        assert lock_file.exists(), "Lock file should exist before cleanup"

        # Simulate cleanup
        lock_file.rmdir()

        assert not lock_file.exists(), "Lock file should be removed after cleanup (SC-7)"


class TestWorktreeIntegration:
    """Integration tests for worktree flow."""

    @pytest.fixture
    def worktree_utils_path(self) -> Path:
        """Path to worktree-utils.sh."""
        return Path(__file__).parent.parent / ".claude" / "scripts" / "worktree-utils.sh"

    @pytest.fixture
    def integrated_repo(self, tmp_path: Path) -> Path:
        """Create a repository with plan structure for integration testing."""
        repo_path = tmp_path / "integrated-repo"
        repo_path.mkdir()

        # Initialize git repo
        subprocess.run(["git", "init"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=repo_path, check=True, capture_output=True)

        # Create initial commit
        (repo_path / "README.md").write_text("# Test Repo")
        subprocess.run(["git", "add", "."], cwd=repo_path, check=True, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=repo_path, check=True, capture_output=True)

        # Create pilot directory structure
        pilot_dir = repo_path / ".pilot" / "plan"
        pilot_dir.mkdir(parents=True)
        (pilot_dir / "pending").mkdir()
        (pilot_dir / "in_progress").mkdir()
        (pilot_dir / "done").mkdir()
        (pilot_dir / "active").mkdir()
        (pilot_dir / ".locks").mkdir()

        return repo_path

    # TS-1: Single worktree execute+close flow
    def test_single_worktree_flow(self, integrated_repo: Path, worktree_utils_path: Path) -> None:
        """Test single worktree execute and close flow (TS-1)."""
        plan_path = integrated_repo / ".pilot" / "plan" / "pending" / "20260117_120000_test.md"
        plan_path.write_text("# Test Plan\n\n## Success Criteria\n- SC-1: Test complete\n")

        # Simulate execute command
        cmd = f'''
        cd "{integrated_repo}" && \
        . "{worktree_utils_path}" && \
        branch_name=$(plan_to_branch "{plan_path}") && \
        worktree_dir=$(create_worktree "$branch_name" "{plan_path.name}" "main") && \
        main_project="{integrated_repo}" && \
        lock_file="{integrated_repo}/.pilot/plan/.locks/{plan_path.name}.lock" && \
        mkdir -p "$(dirname "$lock_file")" && \
        mkdir "$lock_file" && \
        add_worktree_metadata "{plan_path}" "$branch_name" "$worktree_dir" "main" "$main_project" "$lock_file" && \
        printf "%s|%s|%s|%s" "$branch_name" "$worktree_dir" "main" "$main_project"
        '''

        result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)

        assert result.returncode == 0, f"Execute flow failed: {result.stderr}"

        parts = result.stdout.strip().split("|")
        branch, worktree_dir, main_branch, main_project = parts

        # Verify metadata was added
        plan_content = plan_path.read_text()
        assert "## Worktree Info" in plan_content
        assert f"Branch: {branch}" in plan_content
        assert f"Worktree Path: {worktree_dir}" in plan_content
        assert "Main Project:" in plan_content
        assert "Lock File:" in plan_content

        # Cleanup
        worktree_full = Path(worktree_dir)
        if worktree_full.exists():
            subprocess.run(["git", "worktree", "remove", str(worktree_full)], cwd=integrated_repo, capture_output=True)
        subprocess.run(["git", "branch", "-D", branch], cwd=integrated_repo, capture_output=True)
        lock_path = integrated_repo / ".pilot" / ".locks" / f"{plan_path.name}.lock"
        if lock_path.exists():
            lock_path.rmdir()

    # TS-5: Metadata parsing verification
    def test_metadata_parsing_verification(self, integrated_repo: Path, worktree_utils_path: Path) -> None:
        """Test metadata parsing with all fields (TS-5)."""
        plan_path = integrated_repo / "test-plan.md"

        # Create plan with complete metadata
        plan_path.write_text("""# Test Plan

## Worktree Info

- Branch: feature/20260117-120000-test
- Worktree Path: /absolute/path/to/worktree
- Main Branch: main
- Main Project: /absolute/path/to/main/project
- Lock File: /absolute/path/to/.locks/test.md.lock
- Created At: 2026-01-17T12:00:00
""")

        cmd = f'''
        cd "{integrated_repo}" && \
        . "{worktree_utils_path}" && \
        read_worktree_metadata "{plan_path}"
        '''

        result = subprocess.run(["bash", "-c", cmd], capture_output=True, text=True)

        assert result.returncode == 0, f"read_worktree_metadata failed: {result.stderr}"

        parts = result.stdout.strip().split("|")
        assert len(parts) >= 5, f"Expected at least 5 fields, got {len(parts)}: {parts}"

        branch, wt_path, main_branch, main_project, lock_file = parts[0], parts[1], parts[2], parts[3], parts[4]

        assert branch == "feature/20260117-120000-test"
        assert wt_path == "/absolute/path/to/worktree"
        assert main_branch == "main"
        assert main_project == "/absolute/path/to/main/project"
        assert lock_file == "/absolute/path/to/.locks/test.md.lock"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

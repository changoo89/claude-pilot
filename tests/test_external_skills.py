"""
Tests for external skills sync functionality.

This module tests the sync_external_skills() function and related helpers
for downloading and syncing skills from external GitHub repositories.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any
from unittest.mock import MagicMock

import pytest

from claude_pilot import config
from claude_pilot.updater import (
    download_github_tarball,
    extract_skills_from_tarball,
    get_github_latest_sha,
    sync_external_skills,
)


class TestGetGithubLatestSha:
    """Test get_github_latest_sha() function."""

    def test_get_github_latest_sha_success(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test successful SHA fetch from GitHub API (TS-1)."""

        def _mock_get(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"sha": "abc123def456"}
            mock_response.raise_for_status = MagicMock()
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result == "abc123def456"

    def test_get_github_latest_sha_timeout(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test get_github_latest_sha() handles timeout (TS-3)."""

        def _mock_get_timeout(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.Timeout("Request timed out")

        monkeypatch.setattr("requests.get", _mock_get_timeout)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None

    def test_get_github_latest_sha_connection_error(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test get_github_latest_sha() handles connection error (TS-3)."""

        def _mock_get_error(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.ConnectionError("Network unreachable")

        monkeypatch.setattr("requests.get", _mock_get_error)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None

    def test_get_github_latest_sha_http_error(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test get_github_latest_sha() handles HTTP error (TS-3)."""

        def _mock_get_http_error(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            import requests
            mock_response = MagicMock()
            mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError(
                "404 Not Found"
            )
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get_http_error)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None

    def test_get_github_latest_sha_rate_limit(self, monkeypatch: pytest.MonkeyPatch) -> None:
        """Test get_github_latest_sha() handles rate limiting (TS-5)."""

        def _mock_get_rate_limit(
            url: str, timeout: int | None = None, **kwargs: Any
        ) -> MagicMock:
            import requests
            mock_response = MagicMock()
            mock_response.status_code = 403
            mock_response.raise_for_status.side_effect = requests.exceptions.HTTPError(
                "403 Forbidden"
            )
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get_rate_limit)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None

    def test_get_github_latest_sha_invalid_json(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test get_github_latest_sha() handles invalid JSON (Security: Warning #1)."""

        def _mock_get_invalid(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"not_sha": "some_value"}  # Missing "sha" key
            mock_response.raise_for_status = MagicMock()
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get_invalid)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None

    def test_get_github_latest_sha_not_dict(
        self, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test get_github_latest_sha() handles non-dict JSON response (Security: Warning #1)."""

        def _mock_get_list(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = ["sha1", "sha2"]  # List instead of dict
            mock_response.raise_for_status = MagicMock()
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get_list)

        result = get_github_latest_sha("vercel-labs/agent-skills", "main")
        assert result is None


class TestDownloadGithubTarball:
    """Test download_github_tarball() function."""

    def test_download_github_tarball_success(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test successful tarball download (TS-1)."""

        def _mock_get(url: str, timeout: int | None = None, stream: bool = False, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.raise_for_status = MagicMock()
            mock_response.iter_content = MagicMock(return_value=[b"fake tarball content"])
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get)

        result = download_github_tarball("vercel-labs/agent-skills", "abc123", tmp_path)
        assert result is True

        # Check that tarball was created
        tarballs = list(tmp_path.glob("*.tar.gz"))
        assert len(tarballs) == 1

    def test_download_github_tarball_failure(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test download_github_tarball() handles network error (TS-3)."""

        def _mock_get_error(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.ConnectionError("Network unreachable")

        monkeypatch.setattr("requests.get", _mock_get_error)

        result = download_github_tarball("vercel-labs/agent-skills", "abc123", tmp_path)
        assert result is False

    def test_download_github_tarball_timeout(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test download_github_tarball() handles timeout (TS-3)."""

        def _mock_get_timeout(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.Timeout("Download timed out")

        monkeypatch.setattr("requests.get", _mock_get_timeout)

        result = download_github_tarball("vercel-labs/agent-skills", "abc123", tmp_path)
        assert result is False


class TestExtractSkillsFromTarball:
    """Test extract_skills_from_tarball() function."""

    def test_extract_skills_from_tarball_success(self, tmp_path: Path) -> None:
        """Test successful skills extraction from tarball (TS-1)."""
        import tarfile

        # Create a mock tarball
        tarball_path = tmp_path / "test.tar.gz"
        with tarfile.open(tarball_path, "w:gz") as tar:
            # Create a mock directory structure
            import io

            # Add mock files with GitHub prefix
            mock_skill_content = b"# Test Skill\n\nTest content."

            # Create mock file info
            root_dir = "vercel-labs-agent-skills-abc123"
            skill_file = f"{root_dir}/skills/test-skill/SKILL.md"

            info = tarfile.TarInfo(name=skill_file)
            info.size = len(mock_skill_content)
            tar.addfile(info, io.BytesIO(mock_skill_content))

        # Extract skills
        dest_dir = tmp_path / "extracted"
        result = extract_skills_from_tarball(tarball_path, "skills", dest_dir)

        assert result is True
        # Check that skills were extracted (skills_path prefix stripped)
        # File should be at dest_dir/test-skill/SKILL.md (not dest_dir/skills/test-skill/SKILL.md)
        extracted_skills = list(dest_dir.rglob("SKILL.md"))
        assert len(extracted_skills) >= 1
        # Verify the skill is in the correct location (not under skills/)
        assert extracted_skills[0].parent.name == "test-skill"
        assert extracted_skills[0].parent.parent == dest_dir

    def test_extract_skills_from_tarball_invalid_tarball(
        self, tmp_path: Path
    ) -> None:
        """Test extract_skills_from_tarball() handles invalid tarball."""
        # Create an invalid tarball
        tarball_path = tmp_path / "invalid.tar.gz"
        tarball_path.write_text("not a valid tarball")

        dest_dir = tmp_path / "extracted"
        result = extract_skills_from_tarball(tarball_path, "skills", dest_dir)

        assert result is False

    def test_extract_skills_from_tarball_empty_tarball(
        self, tmp_path: Path
    ) -> None:
        """Test extract_skills_from_tarball() handles empty tarball."""
        import tarfile

        # Create an empty tarball
        tarball_path = tmp_path / "empty.tar.gz"
        with tarfile.open(tarball_path, "w:gz"):
            pass  # Empty tarball

        dest_dir = tmp_path / "extracted"
        result = extract_skills_from_tarball(tarball_path, "skills", dest_dir)

        assert result is False

    def test_extract_skills_from_tarball_rejects_symlinks(
        self, tmp_path: Path, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """Test extract_skills_from_tarball() skips symlinks (Security: Critical #2)."""
        import tarfile

        # Create a tarball with a symlink
        tarball_path = tmp_path / "malicious.tar.gz"
        with tarfile.open(tarball_path, "w:gz") as tar:
            root_dir = "vercel-labs-agent-skills-abc123"

            # Add a symlink pointing to /etc/passwd
            symlink_path = f"{root_dir}/skills/malicious-skill/SKILL.md"
            info = tarfile.TarInfo(name=symlink_path)
            info.type = tarfile.SYMTYPE
            info.linkname = "/etc/passwd"
            tar.addfile(info)

        dest_dir = tmp_path / "extracted"
        result = extract_skills_from_tarball(tarball_path, "skills", dest_dir)

        # Should return False (no valid skills extracted)
        assert result is False

        # Check that no symlink was extracted
        extracted_files = list(dest_dir.rglob("*"))
        assert not any(f.is_symlink() for f in extracted_files)

    def test_extract_skills_from_tarball_blocks_path_traversal(
        self, tmp_path: Path, capsys: pytest.CaptureFixture[str]
    ) -> None:
        """Test extract_skills_from_tarball() blocks path traversal (Security: Critical #1)."""
        import io
        import tarfile

        # Create a tarball with path traversal
        tarball_path = tmp_path / "malicious.tar.gz"
        with tarfile.open(tarball_path, "w:gz") as tar:
            root_dir = "vercel-labs-agent-skills-abc123"

            # Add a file with path traversal sequence
            malicious_content = b"malicious content"
            malicious_path = f"{root_dir}/skills/../../../etc/passwd"
            info = tarfile.TarInfo(name=malicious_path)
            info.size = len(malicious_content)
            tar.addfile(info, io.BytesIO(malicious_content))

        dest_dir = tmp_path / "extracted"
        result = extract_skills_from_tarball(tarball_path, "skills", dest_dir)

        # Should return False (no valid skills extracted)
        assert result is False

        # Check that no file escaped the destination directory
        passwd_file = tmp_path / "etc" / "passwd"
        assert not passwd_file.exists()


class TestSyncExternalSkills:
    """Test sync_external_skills() function."""

    def test_sync_external_skills_skip_flag(self, tmp_path: Path) -> None:
        """Test sync_external_skills() with skip=True (TS-4)."""
        result = sync_external_skills(tmp_path, skip=True)
        assert result == "skipped"

    def test_sync_external_skills_success(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test successful external skills sync (TS-1)."""
        # Mock get_github_latest_sha to return a new SHA
        def _mock_get_sha(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"sha": "new123sha456"}
            mock_response.raise_for_status = MagicMock()
            return mock_response

        # Mock download_github_tarball to succeed
        def _mock_download(repo: str, ref: str, dest: Path) -> bool:
            # Create a mock tarball
            import io
            import tarfile

            tarball_path = dest / f"{repo.replace('/', '-')}-{ref[:7]}.tar.gz"

            # Create a minimal valid tarball with skills
            # GitHub tarball format: {repo}-{sha} (e.g., vercel-labs-agent-skills-abc123def)
            root_dir = f"{repo.replace('/', '-')}-{ref[:7]}"
            skill_content = b"# Test Skill\n\nTest content."

            with tarfile.open(tarball_path, "w:gz") as tar:
                # Add skills directory structure
                skill_file = f"{root_dir}/skills/test-skill/SKILL.md"
                info = tarfile.TarInfo(name=skill_file)
                info.size = len(skill_content)
                tar.addfile(info, io.BytesIO(skill_content))

            return True

        monkeypatch.setattr("requests.get", _mock_get_sha)
        monkeypatch.setattr("claude_pilot.updater.download_github_tarball", _mock_download)

        result = sync_external_skills(tmp_path, skip=False)
        assert result == "success"

        # Check version file was created
        version_file = tmp_path / config.EXTERNAL_SKILLS_VERSION_FILE
        assert version_file.exists()
        assert version_file.read_text().strip() == "new123sha456"

    def test_sync_external_skills_already_current(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test sync_external_skills() when already up to date (TS-2)."""
        # Create version file with existing SHA
        version_file = tmp_path / config.EXTERNAL_SKILLS_VERSION_FILE
        version_file.parent.mkdir(parents=True, exist_ok=True)
        existing_sha = "abc123def456"
        version_file.write_text(existing_sha)

        # Mock get_github_latest_sha to return the same SHA
        def _mock_get_sha(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"sha": existing_sha}
            mock_response.raise_for_status = MagicMock()
            return mock_response

        monkeypatch.setattr("requests.get", _mock_get_sha)

        result = sync_external_skills(tmp_path, skip=False)
        assert result == "already_current"

    def test_sync_external_skills_network_failure(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test sync_external_skills() handles network failure (TS-3)."""

        def _mock_get_error(url: str, timeout: int | None = None, **kwargs: Any) -> None:
            import requests
            raise requests.exceptions.ConnectionError("Network unreachable")

        monkeypatch.setattr("requests.get", _mock_get_error)

        result = sync_external_skills(tmp_path, skip=False)
        assert result == "failed"

    def test_sync_external_skills_download_failure(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test sync_external_skills() handles download failure (TS-3)."""

        # Mock get_github_latest_sha to succeed
        def _mock_get_sha(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"sha": "new123sha456"}
            mock_response.raise_for_status = MagicMock()
            return mock_response

        # Mock download_github_tarball to fail
        def _mock_download_fail(repo: str, ref: str, dest: Path) -> bool:
            return False

        monkeypatch.setattr("requests.get", _mock_get_sha)
        monkeypatch.setattr("claude_pilot.updater.download_github_tarball", _mock_download_fail)

        result = sync_external_skills(tmp_path, skip=False)
        assert result == "failed"

    def test_sync_external_skills_creates_external_dir(
        self, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        """Test sync_external_skills() creates external directory (SC-1)."""

        # Mock get_github_latest_sha to return a new SHA
        def _mock_get_sha(url: str, timeout: int | None = None, **kwargs: Any) -> MagicMock:
            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"sha": "new123sha456"}
            mock_response.raise_for_status = MagicMock()
            return mock_response

        # Mock download_github_tarball to succeed
        def _mock_download(repo: str, ref: str, dest: Path) -> bool:
            import io
            import tarfile

            tarball_path = dest / f"{repo.replace('/', '-')}-{ref[:7]}.tar.gz"

            with tarfile.open(tarball_path, "w:gz") as tar:
                root_dir = f"{repo}-abc123"
                skill_content = b"# Test Skill\n\nTest content."

                skill_file = f"{root_dir}/skills/test-skill/SKILL.md"
                info = tarfile.TarInfo(name=skill_file)
                info.size = len(skill_content)
                tar.addfile(info, io.BytesIO(skill_content))

            return True

        monkeypatch.setattr("requests.get", _mock_get_sha)
        monkeypatch.setattr("claude_pilot.updater.download_github_tarball", _mock_download)

        sync_external_skills(tmp_path, skip=False)

        # Check external directory was created
        external_dir = tmp_path / config.EXTERNAL_SKILLS_DIR
        assert external_dir.exists()

        # Check skill subdirectory was created
        skill_dir = external_dir / "vercel-agent-skills"
        assert skill_dir.exists()


class TestConfigExternalSkills:
    """Test config.EXTERNAL_SKILLS configuration."""

    def test_external_skills_config_exists(self) -> None:
        """Test that EXTERNAL_SKILLS configuration exists (SC-1)."""
        assert hasattr(config, "EXTERNAL_SKILLS")
        assert isinstance(config.EXTERNAL_SKILLS, dict)
        assert "vercel-agent-skills" in config.EXTERNAL_SKILLS

    def test_external_skills_dir_constant(self) -> None:
        """Test that EXTERNAL_SKILLS_DIR constant exists (SC-1)."""
        assert hasattr(config, "EXTERNAL_SKILLS_DIR")
        assert config.EXTERNAL_SKILLS_DIR == ".claude/skills/external"

    def test_external_skills_version_file_constant(self) -> None:
        """Test that EXTERNAL_SKILLS_VERSION_FILE constant exists."""
        assert hasattr(config, "EXTERNAL_SKILLS_VERSION_FILE")
        assert config.EXTERNAL_SKILLS_VERSION_FILE == ".claude/.external-skills-version"

    def test_vercel_agent_skills_config(self) -> None:
        """Test Vercel agent-skills configuration (SC-1)."""
        vercel_config = config.EXTERNAL_SKILLS.get("vercel-agent-skills")
        assert vercel_config is not None
        assert vercel_config["repo"] == "vercel-labs/agent-skills"
        assert vercel_config["branch"] == "main"
        assert vercel_config["skills_path"] == "skills"

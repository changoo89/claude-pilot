"""Hatchling build hook for generating packaged assets.

This module implements a custom Hatchling build hook that generates
packaged assets from the .claude/** directory at build time.

The build hook:
1. Reads from .claude/** (development source of truth)
2. Filters using AssetManifest (curated subset)
3. Writes to src/claude_pilot/assets/.claude/** (packaged assets)
4. Ensures wheel contains only generated assets, not templates

This approach eliminates drift between development and packaged assets.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any

try:
    # hatchling is only available during build, not during normal imports
    from hatchling.builders.hooks.plugin.interface import (  # type: ignore[import-not-found]
        BuildHookInterface,
    )
    HATCHLING_AVAILABLE = True
except ImportError:
    HATCHLING_AVAILABLE = False
    # Use typing.Any for the base class when hatchling is not available
    BuildHookInterface: Any = object  # type: ignore

# Import assets module with fallback for build environment
try:
    from claude_pilot.assets import AssetManifest, generate_assets
except ImportError:
    # During wheel build from sdist, need to use sys.path tricks
    import sys
    from pathlib import Path
    # Add src directory to path when building from sdist
    src_path = Path(__file__).parent.parent.parent
    if str(src_path) not in sys.path:
        sys.path.insert(0, str(src_path))
    try:
        from claude_pilot.assets import AssetManifest, generate_assets
    except ImportError:
        # Last resort: define minimal implementations for build
        class AssetManifest:
            def __init__(self):
                self.includes = []
                self.excludes = []

        def generate_assets(src, dst, manifest):
            # Minimal fallback - copy essential files
            import shutil
            claude_src = Path(src) / ".claude"
            claude_dst = Path(dst) / ".claude"
            if claude_src.exists():
                if claude_dst.exists():
                    shutil.rmtree(claude_dst)
                shutil.copytree(claude_src, claude_dst,
                    ignore=shutil.ignore_patterns(
                        "*external*", "*.pyc", "__pycache__",
                        ".pilot/*", "999_publish.md"
                    )
                )
            return len(list(claude_dst.rglob("*"))) if claude_dst.exists() else 0


class AssetGenerationHook(BuildHookInterface):  # type: ignore
    """
    Custom Hatchling build hook for asset generation.

    This hook generates packaged assets from .claude/** during wheel build.
    It ensures that the wheel contains only curated, generated assets
    rather than a committed templates mirror.
    """

    PLUGIN_NAME = "asset-generation"

    def initialize(self, version: str, build_data: dict[str, Any]) -> None:
        """
        Initialize the build hook.

        Args:
            version: Build target version (e.g., "standard" or "editable").
            build_data: Dictionary containing build configuration.
        """
        self.build_data = build_data
        self.version = version

    def clean(self, versions: list[str]) -> None:
        """Clean up generated assets."""
        # No cleanup needed for our use case
        pass

    def update(self, versions: list[str]) -> dict[str, Any]:
        """
        Update build data with generated assets.

        This method is called by Hatchling during the build process.
        It generates packaged assets and ensures they are included
        in the wheel.

        Args:
            versions: List of build target versions (e.g., ["standard"]).

        Returns:
            Updated build data dictionary.
        """
        # Only process for standard builds (not editable installs)
        if "standard" not in versions:
            return self.build_data

        # Get project directory (root of the repo)
        project_dir = Path(self.root)

        # Get assets destination directory
        # This will be src/claude_pilot/assets/ within the project
        assets_dir = project_dir / "src" / "claude_pilot" / "assets"

        # Generate packaged assets
        generate_packaged_assets(str(project_dir), str(assets_dir))

        # Add assets directory to build data
        # This ensures assets are included in the wheel
        if "artifacts" not in self.build_data:
            self.build_data["artifacts"] = []

        # Add generated asset files to artifacts
        for asset_file in assets_dir.rglob("*"):
            if asset_file.is_file():
                rel_path = asset_file.relative_to(project_dir)
                self.build_data["artifacts"].append(str(rel_path))

        return self.build_data


def generate_packaged_assets(
    project_dir: str,
    assets_dir: str,
) -> int:
    """
    Generate packaged assets from .claude/** directory.

    This is the core function that copies files from the development
    .claude/** directory to the packaged assets directory, filtering
    according to the AssetManifest.

    Args:
        project_dir: Path to project root directory.
        assets_dir: Path to destination assets directory.

    Returns:
        Number of files copied.
    """
    project_path = Path(project_dir)
    assets_path = Path(assets_dir)

    # Source is the project root (manifest expects paths like .claude/commands/00_plan.md)
    source_dir = project_path

    if not source_dir.exists():
        raise FileNotFoundError(f"Source directory not found: {source_dir}")

    # Create assets directory
    assets_path.mkdir(parents=True, exist_ok=True)

    # Get manifest
    manifest = AssetManifest()

    # Generate assets
    count = generate_assets(source_dir, assets_path, manifest)

    return count


# Required paths that must be present in wheel
REQUIRED_PATHS = [
    ".claude/commands/00_plan.md",
    ".claude/commands/01_confirm.md",
    ".claude/commands/02_execute.md",
    ".claude/commands/03_close.md",
    ".claude/commands/CONTEXT.md",
    ".claude/agents/CONTEXT.md",
    ".claude/skills/tdd/SKILL.md",
    ".claude/skills/ralph-loop/SKILL.md",
    ".claude/guides/CONTEXT.md",
    ".claude/rules/core/workflow.md",
    ".claude/settings.json",
]

# Forbidden paths that must NOT be present in wheel
FORBIDDEN_PATHS = [
    ".claude/commands/999_publish.md",
    ".claude/skills/external/",
    ".claude/.external-skills-version",
    ".pilot/plan/",
]


def verify_wheel_contents(assets_dir: str) -> list[str]:
    """
    Verify that wheel contents meet requirements.

    Checks that:
    1. Required paths are present
    2. Forbidden paths are absent

    Args:
        assets_dir: Path to generated assets directory.

    Returns:
        List of error messages (empty if verification passes).
    """
    assets_path = Path(assets_dir)
    errors: list[str] = []

    # Check required paths
    for required_path in REQUIRED_PATHS:
        full_path = assets_path / required_path
        if not full_path.exists():
            errors.append(f"Missing required path: {required_path}")

    # Check forbidden paths
    for forbidden_pattern in FORBIDDEN_PATHS:
        # Handle both files and directories
        if forbidden_pattern.endswith("/"):
            # Directory pattern
            forbidden_dir = assets_path / forbidden_pattern.rstrip("/")
            if forbidden_dir.exists() and forbidden_dir.is_dir():
                errors.append(f"Forbidden directory present: {forbidden_pattern}")
        else:
            # File pattern
            forbidden_file = assets_path / forbidden_pattern
            if forbidden_file.exists():
                errors.append(f"Forbidden file present: {forbidden_pattern}")

    return errors

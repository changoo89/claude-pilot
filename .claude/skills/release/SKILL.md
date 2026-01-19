---
name: release
description: Plugin release workflow skill for version bumping, git tagging, and GitHub release creation. Use when releasing plugin versions with automated CHANGELOG generation and version synchronization.
---

# SKILL: Plugin Release Workflow

> **Purpose**: Execute plugin release workflow with version bumping, git tagging, and GitHub release
> **Target**: Plugin maintainers releasing new versions

---

## Quick Start

### When to Use This Skill
- Release new plugin version
- Bump version (patch/minor/major)
- Create git tag and GitHub release

### Quick Reference
```bash
# Standard release (patch version, CI handles GitHub release)
/999_release

# Minor version
/999_release minor

# Force local GitHub release
/999_release patch --create-gh

# Dry run (preview)
/999_release patch --dry-run
```

## What This Skill Covers

### In Scope
- Version synchronization (2 files: plugin.json, marketplace.json)
- Git tagging and pushing
- CHANGELOG auto-generation from commits
- GitHub release creation (optional)
- Pre-flight validation

### Out of Scope
- Plugin architecture → @CLAUDE.md
- Git workflow patterns → @.claude/skills/git-master/SKILL.md
- Migration guide → MIGRATION.md

## Core Concepts

### Single Source of Truth

**plugin.json** is the PRIMARY version source:
```json
{
  "version": "4.2.0"  // Always update this file
}
```

**Auto-synced file** (DO NOT edit manually):
- marketplace.json - Plugin entry version

### Release Workflow

**Pre-flight** → Version bump → CHANGELOG → Git tag → GitHub release

1. **Pre-flight Checks**: Validate jq, git, working tree, plugin manifests
2. **Version Bump**: Update all 2 version files atomically
3. **CHANGELOG**: Auto-generate from git commits (conventional commit format)
4. **Git Operations**: Commit, tag, push to remote
5. **GitHub Release**: Optional (local or CI/CD)

### CI/CD Integration

**Hybrid model**: Local tagging + CI/CD release creation
- Local: Bump version, create tag, push
- CI: Validates versions, creates GitHub release

**Benefits**:
- No API rate limits
- No authentication setup
- Runs on GitHub's infrastructure

## Further Reading

**Internal**: @.claude/skills/release/REFERENCE.md - Full release workflow implementation details | @.claude/skills/git-master/SKILL.md - Git operations and commits | @.claude/commands/999_release.md - Release command

**External**: [Semantic Versioning](https://semver.org/) | [Conventional Commits](https://www.conventionalcommits.org/) | [Keep a Changelog](https://keepachangelog.com/)

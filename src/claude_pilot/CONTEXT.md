# claude_pilot Package Context

> **Purpose**: Core Python package for claude-pilot CLI tool
> **Last Updated**: 2026-01-16

---

## Purpose

This package contains the core functionality for the claude-pilot CLI tool, including project initialization, update management, and external skills synchronization.

---

## Key Files

| File | Purpose | Lines |
|------|---------|-------|
| `__init__.py` | Package initialization, version export | 10 |
| `__main__.py` | Package entry point for `python -m claude_pilot` | 5 |
| `cli.py` | Click-based CLI commands (init, update, version) | 230 |
| `codex.py` | Codex CLI detection, auth check, MCP setup (NEW) | 101 |
| `config.py` | Configuration constants, version, managed files, external skills config | 157 |
| `initializer.py` | Project initialization logic, language selection, template copying | 392 |
| `updater.py` | Update management, external skills sync, GitHub API integration | 1010+ |
| `py.typed` | PEP 561 type marker for mypy | 0 |

---

## Common Tasks

### Adding a New CLI Command

1. Add command function in `cli.py` with `@main.command()` decorator
2. Define options with `@click.option()` decorators
3. Call appropriate module functions (initializer.py, updater.py)
4. Handle errors with ClickException

### Adding External Skills Source

Edit `config.py` EXTERNAL_SKILLS dict:
```python
EXTERNAL_SKILLS = {
    "source-name": {
        "repo": "owner/repo",
        "branch": "main",
        "skills_path": "skills",
    }
}
```

### Modifying Update Behavior

1. Add new functions to `updater.py`
2. Call from `perform_update()` or `sync_external_skills()`
3. Update `MergeStrategy` enum if needed
4. Add tests in `tests/test_updater.py`

---

## Patterns

### CLI Command Pattern

All CLI commands follow this structure:
1. **Options**: Click decorators with type hints
2. **Docstring**: Command description
3. **Logic**: Delegate to module functions
4. **Error Handling**: Raise ClickException on failure
5. **User Feedback**: Use success/error/info/warning functions

### Configuration Pattern

- **Constants**: Upper case with underscore separators
- **Version**: Single source of truth in `VERSION`
- **Managed Files**: List of (source, dest) tuples
- **External Skills**: Dict with repo metadata

### Update Pattern

1. **Fetch**: Get latest version/info from remote
2. **Compare**: Check if update available
3. **Download**: Fetch new files (with timeout)
4. **Backup**: Preserve existing files
5. **Merge**: Apply new files with strategy
6. **Cleanup**: Remove temp files

### External Skills Sync Pattern

1. **Check Skip**: Test skip flag
2. **Read Version**: Load existing SHA from file
3. **Fetch SHA**: Get latest commit from GitHub API
4. **Compare**: Skip if same version
5. **Download**: Stream tarball to temp directory
6. **Extract**: Validate paths, reject symlinks
7. **Save**: Write new SHA to version file

### Codex MCP Setup Pattern (v3.4.0)

1. **Detect CLI**: Check if `codex` command available (`shutil.which`)
2. **Check Auth**: Verify `~/.codex/auth.json` has valid tokens
3. **Load Config**: Read existing `.mcp.json` or create new
4. **Merge Config**: Add Codex MCP server to `mcpServers.codex`
5. **Write Config**: Atomic write to `.mcp.json` with GPT 5.2 model

---

## Security Considerations

### Tarball Extraction (v3.3.6)

- **Path Traversal**: Reject paths containing `..`
- **Symlinks**: Reject all symlinks to prevent arbitrary file writes
- **Temp Directory**: Extract to temp directory before atomic move
- **Validation**: Check all paths before extraction

### GitHub API Integration

- **Rate Limiting**: Check X-RateLimit-Remaining header
- **Timeout**: Use config.REQUEST_TIMEOUT (30 seconds)
- **Error Handling**: Graceful degradation on network failure

---

## Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `cli.py` | User interface | → Commands → initializer/updater |
| `initializer.py` | Project setup | → .claude/ directory creation |
| `updater.py` | Updates | → GitHub API, tarball download |
| `codex.py` | Codex MCP setup | → .mcp.json (GPT 5.2 config) |
| `config.py` | Configuration | ← All modules read constants |

---

## Testing

### Test Files

| File | Purpose | Coverage |
|------|---------|----------|
| `tests/test_initializer.py` | Init command tests | 80%+ |
| `tests/test_updater.py` | Update command tests | 80%+ |
| `tests/test_external_skills.py` | External skills sync tests | 90%+ |
| `tests/test_codex.py` | Codex detection & MCP setup tests (NEW) | 81%+ |

### Running Tests

```bash
# All tests
pytest

# Coverage
pytest --cov=src/claude_pilot

# Specific test file
pytest tests/test_external_skills.py
```

---

## Related Documentation

- `CLAUDE.md` - Tier 1: Project documentation
- `docs/ai-context/system-integration.md` - CLI workflows, integration points
- `docs/ai-context/project-structure.md` - Directory layout, key files
- `.claude/commands/CONTEXT.md` - Command workflow and file list

---

**Last Updated**: 2026-01-16
**Version**: 3.4.0

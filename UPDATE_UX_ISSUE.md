# claude-pilot Update UX Issue

## Date Created
2026-01-14

## Summary
`claude-pilot update` command does not check PyPI for the latest version, causing confusion for users.

## Current Problem

### User Experience Issue
When a new version is published to PyPI:
1. User runs `claude-pilot update`
2. Shows: "Already up to date (v2.1.3)" ← **Misleading!**
3. But PyPI actually has v2.1.4 published

### Root Cause
The `get_latest_version()` function in `src/claude_pilot/updater.py` returns the **locally installed package version**, not the actual latest version from PyPI:

```python
# src/claude_pilot/updater.py:55-62
def get_latest_version() -> str:
    """
    Get the latest version from the package.
    """
    return config.VERSION  # ← Returns local package version!
```

### Current User Workflow (Broken)
```bash
# User expects this to work:
claude-pilot update
# → Shows "Already up to date (v2.1.3)" ❌

# User has to manually do this instead:
pip install --upgrade claude-pilot
# → Now claude-pilot update shows v2.1.4 ✅
```

## Expected Behavior
```bash
claude-pilot update
# → Should detect v2.1.4 on PyPI
# → Prompt user to upgrade pip package
# → OR automatically upgrade with --auto flag
```

## Proposed Solutions

### Option 1: Check PyPI API (Recommended)
Add PyPI version checking to `get_latest_version()`:

```python
import requests

def get_latest_version() -> str:
    """
    Get the latest version from PyPI.
    Falls back to local package version if PyPI is unavailable.
    """
    try:
        response = requests.get(
            "https://pypi.org/pypi/claude-pilot/json",
            timeout=5
        )
        response.raise_for_status()
        return response.json()["info"]["version"]
    except (requests.RequestException, KeyError):
        # Fallback to local version
        return config.VERSION
```

### Option 2: Auto-upgrade pip package
Add automatic pip upgrade when outdated:

```python
def upgrade_pip_package() -> bool:
    """Upgrade claude-pilot via pip."""
    import subprocess
    try:
        subprocess.run(
            ["pip", "install", "--upgrade", "claude-pilot"],
            check=True,
            capture_output=True
        )
        return True
    except subprocess.CalledProcessError:
        return False
```

### Option 3: Hybrid Approach
1. Check PyPI for latest version
2. If local is outdated:
   - Show clear message: "New version available on PyPI"
   - Provide upgrade command or auto-upgrade option
   - Then proceed with file updates

## Files to Modify

### Primary Changes
- `src/claude_pilot/updater.py`:
  - Modify `get_latest_version()` to check PyPI
  - Add `upgrade_pip_package()` function
  - Update `perform_update()` to handle pip upgrades

### Optional Changes
- `src/claude_pilot/cli.py`:
  - Add `--auto-upgrade` flag to update command
  - Add `--check-only` flag to just check versions

- `pyproject.toml`:
  - Ensure `requests` is in dependencies (already there)

## Success Criteria
- [ ] `claude-pilot update` detects new PyPI versions
- [ ] Clear messaging when pip upgrade is needed
- [ ] Optional auto-upgrade functionality
- [ ] Fallback behavior when PyPI is unreachable
- [ ] Tests for PyPI API calls

## Technical Considerations

### Dependencies
- `requests` is already in dependencies ✅
- May need to add timeout handling
- Consider rate limiting for frequent checks

### Error Handling
- PyPI API unreachable → fallback to local version
- Network timeout → graceful degradation
- pip upgrade failure → clear error message

### Backward Compatibility
- Keep `--strategy` (auto/manual) flags working
- Ensure fallback to local version works
- Don't break existing workflows

## Related Code Locations

| File | Lines | Description |
|------|-------|-------------|
| `src/claude_pilot/updater.py` | 55-62 | `get_latest_version()` function |
| `src/claude_pilot/updater.py` | 398-432 | `perform_update()` main logic |
| `src/claude_pilot/cli.py` | TBD | Update CLI command definition |
| `src/claude_pilot/config.py` | 15 | `VERSION` constant |

## Example Desired Output

```bash
$ claude-pilot update
i Checking for updates...
i New version available: v2.1.4 (you have v2.1.3)
i Run: pip install --upgrade claude-pilot
i Or use: claude-pilot update --auto-upgrade

$ claude-pilot update --auto-upgrade
i Checking for updates...
i New version available: v2.1.4 (you have v2.1.3)
i Upgrading pip package...
✓ Upgraded to v2.1.4
i Updating managed files...
✓ Already up to date (v2.1.4)
```

## Priority
**HIGH** - This is a significant UX issue that causes user confusion.

## Notes
- PyPI API endpoint: `https://pypi.org/pypi/claude-pilot/json`
- No authentication required for read-only API calls
- CDN propagation may take 1-5 minutes (already published)

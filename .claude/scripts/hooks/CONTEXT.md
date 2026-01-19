# Hooks Context

## Purpose

Claude Code hooks for quality validation and workflow automation. Optimized with dispatcher pattern, caching, and profile system (v4.3.0).

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `quality-dispatch.sh` | O(1) dispatcher with caching | 247 | Called by Stop hook, routes validators |
| `cache.sh` | Cache utilities (hash-based invalidation) | 256 | Read/write/invalidate cache |
| `typecheck.sh` | TypeScript validation | 66 | Optimized with early exit + cache |
| `lint.sh` | Multi-language lint | 143 | Optimized with early exit + cache |
| `check-todos.sh` | Ralph Loop enforcement | 115 | Optimized with debounce |
| `branch-guard.sh` | Protected branch warnings | 52 | Already fast (no changes needed) |

**Total**: 6 files, 879 lines (average: 147 lines per file)

## Architecture

### Dispatcher Pattern

**Single Entry Point**: `quality-dispatch.sh` handles all quality validation

**Flow**:
```
Claude Code Event (Stop)
    ↓
quality-dispatch.sh
    ↓
    ├─→ cache.sh (read)
    │   ├─→ Cache hit? → Check debounce → Skip or Run
    │   └─→ Cache miss → Continue
    ↓
    ├─→ Detect project type (O(1))
    │   ├─→ tsconfig.json → TypeScript
    │   ├─→ package.json → Node.js
    │   ├─→ go.mod → Go
    │   ├─→ Cargo.toml → Rust
    │   └─→ None → Exit (skip)
    ↓
    ├─→ Detect tools (O(1))
    │   ├─→ tsc available?
    │   ├─→ eslint available?
    │   └─→ ...
    ↓
    ├─→ Check profile mode
    │   ├─→ off → Exit (skip all)
    │   ├─→ stop → Continue (batch)
    │   └─→ strict → Continue (per-operation)
    ↓
    ├─→ Run validators
    │   ├─→ typecheck.sh (if enabled)
    │   └─→ lint.sh (if enabled)
    ↓
    ├─→ cache.sh (write)
    │   └─→ Store results + timestamp
    ↓
check-todos.sh
```

### Gate vs Validator Separation

| Type | Hook Type | Purpose | Timeout | Example |
|------|-----------|---------|----------|---------|
| **Gate** | PreToolUse | Safety checks | 5s | Block destructive git commands |
| **Validator** | Stop | Quality checks | 30s | Batch validation on stop |

### Cache Design

**Location**: `.claude/cache/quality-check.json`

**Format** (JSON):
```json
{
  "version": 1,
  "repository": "/path/to/project/repo",
  "detected_at": 1705689000,
  "project_type": "typescript",
  "tools": {
    "tsc": { "available": true, "version": "5.3.0" },
    "eslint": { "available": true, "version": "8.57.0" }
  },
  "last_run": {
    "typecheck": 1705689100,
    "lint": 1705689100
  },
  "config_hashes": {
    "tsconfig.json": "abc123",
    "package.json": "def456"
  },
  "profile": {
    "mode": "stop",
    "typescript_typecheck": true,
    "typescript_lint": true
  }
}
```

**Cache Invalidation**: Config file hash changes trigger cache invalidation

## Profile System

### Mode Definitions

| Mode | PreToolUse | Stop | Behavior |
|------|------------|------|----------|
| **off** | None | None | All validators disabled |
| **stop** | None | All validators | Batch validation on stop (default) |
| **strict** | All validators | All validators | Per-operation validation (old behavior) |

### Priority Order (Highest to Lowest)

1. **Environment Variable**: `QUALITY_MODE=off|stop|strict`
2. **Repository Profile**: `.claude/quality-profile.json`
3. **User Settings**: `.claude/settings.json` → `quality.mode`
4. **Plugin Default**: `stop`

### Example Profile

```json
{
  "version": 1,
  "mode": "stop",
  "cache_ttl": 30,
  "debounce_seconds": 10,
  "language_overrides": {
    "typescript": {
      "typecheck": true,
      "lint": true
    },
    "python": {
      "typecheck": false,
      "lint": false
    },
    "go": {
      "typecheck": false,
      "lint": true
    },
    "rust": {
      "typecheck": false,
      "lint": true
    }
  }
}
```

## Common Tasks

### Add New Language Support

**Task**: Add support for a new language to the dispatcher

**Files to modify**:
1. `quality-dispatch.sh` - Add project type detection
2. `cache.sh` - Add config hash key
3. Create new validator script (e.g., `rust-typecheck.sh`)

**Example** (Rust support):
```bash
# In quality-dispatch.sh
detect_project_type() {
    # ...
    elif [ -f "Cargo.toml" ]; then
        project_type="rust"
    # ...
}

# In cache.sh
compute_config_hash() {
    # ...
    elif [ -f "Cargo.toml" ]; then
        hash_file "Cargo.toml"
    # ...
}
```

### Adjust Debounce Time

**Task**: Change debounce interval for Stop hook

**Method 1**: Environment variable
```bash
export QUALITY_DEBOUNCE=30  # 30 seconds
```

**Method 2**: Profile configuration
```json
{
  "debounce_seconds": 30
}
```

**Method 3**: User settings
```json
{
  "quality": {
    "debounce_seconds": 30
  }
}
```

### Disable Specific Validator

**Task**: Disable typecheck for Python projects

**Method**: Language override in profile
```json
{
  "language_overrides": {
    "python": {
      "typecheck": false,
      "lint": true
    }
  }
}
```

## Patterns

### Early Exit Pattern

**Purpose**: Skip validators for non-matching projects

**Example** (typecheck.sh):
```bash
# Early exit: No TypeScript project
if [ ! -f "tsconfig.json" ]; then
    exit 0
fi

# Early exit: tsc not available
if ! command -v tsc &> /dev/null; then
    exit 0
fi

# Run typecheck
tsc --noEmit
```

### Cache-First Pattern

**Purpose**: Avoid redundant expensive operations

**Example** (cache.sh):
```bash
# Read cache
CACHE=$(read_cache)

# Check if cache is valid
if cache_is_valid "$CACHE"; then
    # Check debounce
    if ! should_run_debounced "$CACHE" "typecheck"; then
        exit 0  # Skip: Debounce active
    fi
fi

# Run validator
run_validator

# Write cache
write_cache "typecheck"
```

### Debounce Pattern

**Purpose**: Prevent duplicate executions within time window

**Example** (check-todos.sh):
```bash
DEBOUNCE_SECONDS=${QUALITY_DEBOUNCE:-10}
CURRENT_TIME=$(date +%s)
LAST_RUN=$(jq -r '.last_run.check_todos // 0' "$CACHE_FILE")

if [ $((CURRENT_TIME - LAST_RUN)) -lt $DEBOUNCE_SECONDS ]; then
    # Config changed?
    CURRENT_HASH=$(compute_hash ".claude/settings.json")
    CACHED_HASH=$(jq -r '.config_hashes.settings_json // ""' "$CACHE_FILE")

    if [ "$CURRENT_HASH" = "$CACHED_HASH" ]; then
        exit 0  # Skip: Debounce active, no config change
    fi
fi
```

## Performance Characteristics

### Dispatcher Performance

- **P95 latency**: 20ms (target: <100ms)
- **Cache hit rate**: 100%
- **External process reduction**: 75-100%

### Before vs After

| Metric | Before (v4.2.0) | After (v4.3.0) | Improvement |
|--------|----------------|----------------|-------------|
| 100 file edits | 10-25 seconds | 30-60ms | 99.4-99.8% |
| External processes per provision | 2-4 | 0-1 | 75-100% |
| Cache hit rate | N/A | 100% | N/A |

### Critical Optimizations

1. **O(1) Project Detection**: File existence checks (no external processes)
2. **Hash-Based Invalidation**: Config changes trigger cache invalidation
3. **Debounce**: 10-second window prevents duplicate executions
4. **Early Exit**: Skip validators for non-matching projects
5. **File Locking**: flock prevents race conditions

## Testing

### Test Files

| Test File | Purpose | Type |
|-----------|---------|------|
| `test-dispatcher-perf.sh` | Dispatcher latency | Performance |
| `test-early-exit-process.sh` | Early exit validation | Deterministic |
| `test-cache-hit-rate.sh` | Cache effectiveness | Deterministic |
| `test-debounce-deterministic.sh` | Debounce logic | Deterministic |
| `test-profiles.sh` | Profile mode switching | Integration |
| `test-profile-mode-switch.sh` | Mode changes | Integration |
| `test-stop-no-infinite-loop.sh` | Stop hook safety | Unit |
| `test-check-todos-integration.sh` | TODO check integration | Integration |

### Test Results (v4.3.0)

- **Test Suites**: 7/8 passing (87.5%)
- **Cache Hit Rate**: 100%
- **Performance**: P95 latency 20ms (target: <100ms)
- **External Process Reduction**: 75-100%

## Configuration Examples

### Example 1: Minimal Profile (Fastest)

```json
{
  "mode": "off",
  "language_overrides": {}
}
```

**Use Case**: Development mode, maximum speed

### Example 2: Default Profile (Balanced)

```json
{
  "mode": "stop",
  "cache_ttl": 30,
  "debounce_seconds": 10,
  "language_overrides": {
    "typescript": { "typecheck": true, "lint": true },
    "python": { "typecheck": true, "lint": true },
    "go": { "typecheck": false, "lint": true },
    "rust": { "typecheck": false, "lint": true }
  }
}
```

**Use Case**: Typical development (batch validation on stop)

### Example 3: Strict Profile (Safest)

```json
{
  "mode": "strict",
  "cache_ttl": 0,
  "debounce_seconds": 0,
  "language_overrides": {
    "typescript": { "typecheck": true, "lint": true },
    "python": { "typecheck": true, "lint": true },
    "go": { "typecheck": false, "lint": true },
    "rust": { "typecheck": false, "lint": true }
  }
}
```

**Use Case**: CI/CD, production builds (per-operation validation)

## See Also

**Configuration**:
- `@.claude/settings.json.example` - Optimized hooks configuration
- `@.claude/quality-profile.json.template` - Profile template
- `@docs/migration-guide.md` - Migration guide (v4.2.0 → v4.3.0)

**Implementation**:
- `@.claude/commands/CONTEXT.md` - Command workflows
- `@docs/ai-context/testing-quality.md` - Quality standards
- `@CLAUDE.md` - Plugin documentation (Tier 1)

---

**Last Updated**: 2026-01-19 (Hooks Performance Optimization v4.3.0)

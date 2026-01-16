# Codex Delegator Source Fix
- Generated: 2026-01-16 23:17:01 | Work: codex_delegator_source_fix | Location: /Users/chanho/claude-pilot/.pilot/plan/pending/20260116_231701_codex_delegator_source_fix.md

## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 2026-01-16 | "상위폴더의 hater 에서 claude-pilot update 를 통해 기존에 쓰고있던거 계속 버전업 해서 우리 플러그인 사용중인데" | hater 프로젝트에서 claude-pilot 업데이트 사용중 |
| UR-2 | 2026-01-16 | "지금 우리 배포 계획대로 다 전달된거 맞는지 검토해봐줘" | 배포 계획 검토 요청 |
| UR-3 | 2026-01-16 | "codex 도 깔려있고 로그인도 되어있는 상태야 참고" | Codex 설치 및 인증 완료 상태 |
| UR-4 | 2026-01-16 | "명령어는 init 과 update 두개면 돠. 깃헙 액션 칠요없고" | GitHub Actions 불필요, init/update만 유지 |
| UR-5 | 2026-01-16 | "codex 관련 내용들 유저레벨이 아니고 프로젝트 레벨에 설치해야하는데 유저레벨로 해놨나보네 이것도 수정해줘" | Codex 파일들을 프로젝트 레벨로 이동 |

### Requirements Coverage Check

> **Verification**: All user requirements mapped to Success Criteria

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |
| UR-2 | ✅ | SC-2, SC-3, SC-6 | Mapped |
| UR-3 | ✅ | SC-1 | Mapped |
| UR-4 | ⏭️ | Out of scope (not a code change) | Excluded |
| UR-5 | ✅ | SC-3, SC-4, SC-5 | Mapped |
| **Coverage** | **100%** | **All in-scope requirements mapped** | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix Codex delegator rules being missing from source code, causing incomplete project initialization

**Scope**:
- **In scope**:
  - Create `.claude/rules/delegator/` folder with 4 rule files and 5 prompt files
  - Update `config.py` MANAGED_FILES to include delegator files
  - Verify template sync includes delegator files
  - Ensure deployment readiness
- **Out of scope**:
  - GitHub Actions workflow (UR-4: user explicitly excluded)
  - Actual PyPI release deployment
  - Changes to init/update command logic

### Why (Context)

**Current Problem**:
- Codex delegator rules exist in `templates/.claude/rules/delegator/` but NOT in source `.claude/rules/delegator/`
- This makes them "orphan files" not managed by the source code
- `claude-pilot update` cannot properly sync delegator files to projects
- Projects may have incomplete Codex integration

**Desired State**:
- Source code contains all 9 delegator files (4 rules + 5 prompts)
- `config.py` MANAGED_FILES includes delegator entries
- `sync-templates.sh` properly syncs delegator files
- Projects receive complete Codex integration on init/update

**Business Value**:
- **User impact**: Complete Codex GPT expert delegation functionality in all projects
- **Technical impact**: Proper source code management and template synchronization
- **Deployment impact**: Reliable Codex integration delivery via PyPI

### How (Approach)

- **Phase 1**: Create delegator files in source `.claude/rules/delegator/`
- **Phase 2**: Update `config.py` MANAGED_FILES
- **Phase 3**: Run template sync verification
- **Phase 4**: Verify deployment readiness

### Success Criteria

SC-1: Codex integration status verified
- Verify: `~/.codex/auth.json` valid, project `.mcp.json` exists, prompts copied
- Expected: All Codex files properly configured

SC-2: Deployment process reviewed
- Verify: `/999_publish` command, `sync-templates.sh`, `verify-version-sync.sh`
- Expected: Deployment process documented and functional

SC-3: Missing files root cause identified
- Verify: Source code `.claude/rules/delegator/` exists
- Expected: Root cause found (source folder missing)

SC-4: Source code delegator files created
- Verify: `.claude/rules/delegator/` contains 9 files (4 rules + 5 prompts)
- Expected: All files present in source

SC-5: config.py MANAGED_FILES updated
- Verify: MANAGED_FILES includes 9 delegator entries
- Expected: All delegator files managed during update

SC-6: Deployment ready
- Verify: `sync-templates.sh` passes, `verify-version-sync.sh` passes
- Expected: Ready for PyPI deployment

### Constraints

- Must preserve all existing functionality
- No changes to templates folder structure
- Maintain backward compatibility with existing projects
- English only for all content

---

## Scope

### In Scope

1. **Source Code Creation**:
   - `.claude/rules/delegator/delegation-format.md`
   - `.claude/rules/delegator/model-selection.md`
   - `.claude/rules/delegator/orchestration.md`
   - `.claude/rules/delegator/triggers.md`
   - `.claude/rules/delegator/prompts/architect.md`
   - `.claude/rules/delegator/prompts/code-reviewer.md`
   - `.claude/rules/delegator/prompts/plan-reviewer.md`
   - `.claude/rules/delegator/prompts/scope-analyst.md`
   - `.claude/rules/delegator/prompts/security-analyst.md`

2. **Config Update**:
   - `src/claude_pilot/config.py`: Add 9 delegator entries to MANAGED_FILES

3. **Verification**:
   - Run `scripts/sync-templates.sh`
   - Run `scripts/verify-version-sync.sh`

### Out of Scope

- GitHub Actions workflows (user excluded)
- PyPI actual release
- Changes to init/update command logic
- Modifications to existing project structure

---

## Test Environment (Detected)

**Note**: This is a plan review, not implementation. No test environment required.

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/rules/` | Source rules folder | N/A | **Missing delegator/** |
| `src/claude_pilot/templates/.claude/rules/delegator/` | Template delegator files | All 9 files | Present but orphaned |
| `src/claude_pilot/config.py` | MANAGED_FILES definition | 33-81 | **Missing delegator entries** |
| `scripts/sync-templates.sh` | Template sync script | 42 | `cp -r "$SOURCE/rules/"*` will include delegator |
| `scripts/verify-version-sync.sh` | Version verification | 31-36 | Checks 6 version locations |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|------------------------|
| Create delegator in source | Makes files managed by source control | Keep only in templates (rejected: orphan files) |
| Add to MANAGED_FILES | Ensures files are synced during update | Manual copy (rejected: unreliable) |
| Copy from templates | Templates already have correct content | Create from scratch (rejected: duplication) |

### Implementation Patterns (FROM CONVERSATION)

#### File Structure
> **FROM CONVERSATION:**
> ```bash
> # Delegator rules location (PROJECT-LEVEL, not user-level)
> .claude/rules/delegator/
> ├── delegation-format.md
> ├── model-selection.md
> ├── orchestration.md
> ├── triggers.md
> └── prompts/
>     ├── architect.md
>     ├── code-reviewer.md
>     ├── plan-reviewer.md
>     ├── scope-analyst.md
>     └── security-analyst.md
> ```

#### Config.py Modification
> **FROM CONVERSATION:**
> ```python
> MANAGED_FILES: list[tuple[str, str]] = [
>     # ... existing files ...
>     # Codex Delegator (new - GPT expert delegation)
>     (".claude/rules/delegator/delegation-format.md", ".claude/rules/delegator/delegation-format.md"),
>     (".claude/rules/delegator/model-selection.md", ".claude/rules/delegator/model-selection.md"),
>     (".claude/rules/delegator/orchestration.md", ".claude/rules/delegator/orchestration.md"),
>     (".claude/rules/delegator/triggers.md", ".claude/rules/delegator/triggers.md"),
>     (".claude/rules/delegator/prompts/architect.md", ".claude/rules/delegator/prompts/architect.md"),
>     (".claude/rules/delegator/prompts/code-reviewer.md", ".claude/rules/delegator/prompts/code-reviewer.md"),
>     (".claude/rules/delegator/prompts/plan-reviewer.md", ".claude/rules/delegator/prompts/plan-reviewer.md"),
>     (".claude/rules/delegator/prompts/scope-analyst.md", ".claude/rules/delegator/prompts/scope-analyst.md"),
>     (".claude/rules/delegator/prompts/security-analyst.md", ".claude/rules/delegator/prompts/security-analyst.md"),
> ]
> ```

#### Deployment Commands
> **FROM CONVERSATION:**
> ```bash
> # Sync templates before publishing
> bash scripts/sync-templates.sh
>
> # Verify version synchronization
> bash scripts/verify-version-sync.sh
> ```

### Discovered Dependencies

| Dependency | Version | Purpose | Status |
|------------|---------|---------|--------|
| `templates/.claude/rules/delegator/*` | N/A | Source for delegator files | ✅ Present (use as source) |
| `sync-templates.sh` | N/A | Sync source to templates | ✅ Will include delegator |
| `config.py` | 4.0.0 | MANAGED_FILES definition | ⚠️ Needs update |

### Warnings & Gotchas

| Issue | Location | Recommendation |
|-------|----------|----------------|
| **Source folder missing** | `.claude/rules/delegator/` | Create from templates |
| **MANAGED_FILES incomplete** | `src/claude_pilot/config.py` | Add 9 delegator entries |
| **Orphan files in templates** | `templates/.claude/rules/delegator/` | After fix: sync will update from source |

---

## Architecture

### Current State (Broken)

```
Source Code (.claude/rules/)
├── core/
│   └── workflow.md
├── documentation/
│   └── tier-rules.md
└── [NO delegator/] ❌

Templates (templates/.claude/rules/)
├── core/
│   └── workflow.md
├── documentation/
│   └── tier-rules.md
└── delegator/ ✅ (but orphaned, not in source!)
    ├── delegation-format.md
    ├── model-selection.md
    ├── orchestration.md
    ├── triggers.md
    └── prompts/
        ├── architect.md
        ├── code-reviewer.md
        ├── plan-reviewer.md
        ├── scope-analyst.md
        └── security-analyst.md
```

### Desired State (Fixed)

```
Source Code (.claude/rules/)
├── core/
│   └── workflow.md
├── documentation/
│   └── tier-rules.md
└── delegator/ ✅
    ├── delegation-format.md
    ├── model-selection.md
    ├── orchestration.md
    ├── triggers.md
    └── prompts/
        ├── architect.md
        ├── code-reviewer.md
        ├── plan-reviewer.md
        ├── scope-analyst.md
        └── security-analyst.md

Templates (templates/.claude/rules/)
├── (synced from source via sync-templates.sh)
```

### Integration Points

| Component | Integration | Data Flow |
|-----------|-------------|-----------|
| `.claude/rules/delegator/` | Source of truth | → `templates/.claude/rules/delegator/` |
| `templates/.claude/rules/delegator/` | Bundled in package | → `PROJECT/.claude/rules/delegator/` |
| `config.py` MANAGED_FILES | Update manifest | → Copied during `claude-pilot update` |
| `sync-templates.sh` | Pre-publish sync | Ensures templates match source |

---

## Execution Plan

### Phase 1: Create Source Files

**Action**: Copy delegator files from templates to source

**Steps**:
1. Create `.claude/rules/delegator/` folder
2. Copy 4 rule files from `templates/.claude/rules/delegator/*.md`
3. Create `prompts/` subfolder
4. Copy 5 prompt files from `templates/.claude/rules/delegator/prompts/*.md`

**Verification**:
```bash
ls -la .claude/rules/delegator/
# Expected: 9 files (4 rules + 5 prompts in prompts/)
```

### Phase 2: Update config.py

**Action**: Add delegator entries to MANAGED_FILES

**Location**: `src/claude_pilot/config.py` lines 71-81

**Add after existing rules entries**:
```python
# Codex Delegator (GPT expert delegation)
(".claude/rules/delegator/delegation-format.md", ".claude/rules/delegator/delegation-format.md"),
(".claude/rules/delegator/model-selection.md", ".claude/rules/delegator/model-selection.md"),
(".claude/rules/delegator/orchestration.md", ".claude/rules/delegator/orchestration.md"),
(".claude/rules/delegator/triggers.md", ".claude/rules/delegator/triggers.md"),
(".claude/rules/delegator/prompts/architect.md", ".claude/rules/delegator/prompts/architect.md"),
(".claude/rules/delegator/prompts/code-reviewer.md", ".claude/rules/delegator/prompts/code-reviewer.md"),
(".claude/rules/delegator/prompts/plan-reviewer.md", ".claude/rules/delegator/prompts/plan-reviewer.md"),
(".claude/rules/delegator/prompts/scope-analyst.md", ".claude/rules/delegator/prompts/scope-analyst.md"),
(".claude/rules/delegator/prompts/security-analyst.md", ".claude/rules/delegator/prompts/security-analyst.md"),
```

**Verification**:
```bash
grep -c "delegator" src/claude_pilot/config.py
# Expected: 9 matches
```

### Phase 3: Sync Templates

**Action**: Run template sync to update templates from source

**Command**:
```bash
bash scripts/sync-templates.sh
```

**Verification**:
```bash
diff -r .claude/rules/delegator/ src/claude_pilot/templates/.claude/rules/delegator/
# Expected: No differences (files are synced)
```

### Phase 4: Verify Deployment Readiness

**Action**: Run version sync verification

**Command**:
```bash
bash scripts/verify-version-sync.sh
```

**Expected**: All 6 version files show 4.0.0

---

## Acceptance Criteria

- [ ] SC-1: Codex integration status verified
  - [ ] `~/.codex/auth.json` contains valid tokens
  - [ ] `PROJECT/.mcp.json` exists with codex config
  - [ ] `PROJECT/.claude/rules/delegator/` contains 9 files
- [ ] SC-2: Deployment process reviewed
  - [ ] `/999_publish` workflow documented
  - [ ] `sync-templates.sh` verified
  - [ ] `verify-version-sync.sh` verified
- [ ] SC-3: Missing files root cause identified
  - [ ] Source `.claude/rules/delegator/` was missing
  - [ ] Templates had orphan files
  - [ ] MANAGED_FILES was incomplete
- [ ] SC-4: Source code delegator files created
  - [ ] `.claude/rules/delegator/` folder exists
  - [ ] 4 rule files present
  - [ ] `prompts/` folder with 5 files present
- [ ] SC-5: config.py MANAGED_FILES updated
  - [ ] 9 delegator entries added
  - [ ] Syntax is correct
  - [ ] No duplicate entries
- [ ] SC-6: Deployment ready
  - [ ] `sync-templates.sh` passes
  - [ ] `verify-version-sync.sh` passes
  - [ ] All 6 version files synchronized

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Source folder creation | Copy from templates | 9 files in `.claude/rules/delegator/` | Manual | `ls -la .claude/rules/delegator/` |
| TS-2 | config.py update | Add 9 MANAGED_FILES entries | 9 delegator entries | Manual | `grep -c delegator src/claude_pilot/config.py` |
| TS-3 | Template sync | Run sync-templates.sh | No diff between source and templates | Manual | `diff -r .claude/rules/delegator/ src/claude_pilot/templates/.claude/rules/delegator/` |
| TS-4 | Version sync | Run verify-version-sync.sh | All 6 files show 4.0.0 | Manual | `bash scripts/verify-version-sync.sh` |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| File copy errors | Low | Medium | Verify file count and content after copy |
| MANAGED_FILES syntax error | Low | High | Test config.py import after modification |
| Template sync fails | Low | Medium | Run sync in test environment first |
| Version mismatch | Low | High | Always run verify-version-sync.sh before deployment |

---

## Open Questions

None - All requirements clarified and mapped to Success Criteria.

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-16 | Plan (Self) | Initial plan created | Pending |

---

## Execution Summary

*This section will be populated after execution via `/02_execute`*

## Execution Summary

### Changes Made
1. **Created source folder structure**: `.claude/rules/delegator/` with `prompts/` subfolder
2. **Copied 4 rule files** from templates to source:
   - delegation-format.md
   - model-selection.md
   - orchestration.md
   - triggers.md
3. **Copied 5 prompt files** from templates/prompts/ to source/prompts/:
   - architect.md
   - code-reviewer.md
   - plan-reviewer.md
   - scope-analyst.md
   - security-analyst.md
4. **Updated config.py**: Added 9 delegator entries to MANAGED_FILES (lines 74-83)
5. **Ran sync-templates.sh**: Successfully synced 64 files
6. **Ran verify-version-sync.sh**: All 6 version files synchronized to 4.0.0

### Verification Results
- ✅ Source `.claude/rules/delegator/` folder created with 9 files
- ✅ config.py MANAGED_FILES includes 9 delegator entries
- ✅ sync-templates.sh passed (64 files synced)
- ✅ verify-version-sync.sh passed (all 6 files show 4.0.0)

### Deployment Status
✅ **Ready for PyPI deployment**
- All source files in place
- MANAGED_FILES properly configured
- Templates synchronized
- Version consistency verified

### Follow-ups
None - all Success Criteria met:
- SC-1: Codex integration verified ✅
- SC-2: Deployment process reviewed ✅
- SC-3: Root cause identified (source folder was missing) ✅
- SC-4: Source files created ✅
- SC-5: config.py updated ✅
- SC-6: Deployment ready ✅

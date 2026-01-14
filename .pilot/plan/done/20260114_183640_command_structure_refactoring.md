# Command Structure Refactoring

- Generated: 2026-01-14 18:36:40 | Work: command_structure_refactoring
- Location: .pilot/plan/pending/20260114_183640_command_structure_refactoring.md

---

## User Requirements

Refactor `.claude/commands/` to follow Claude Code official guide and best practices:
1. All languages must be English
2. Guides should be reusable methodology documents (independently readable, not command-specific)
3. Commands should be concise execution prompts (50-150 lines)
4. No information loss from current commands
5. Backup before work, delete backup after completion

---

## PRP Analysis

### What (Functionality)

**Objective**: Restructure `.claude/commands/` files to align with Claude Code official best practices
- Split verbose commands into concise execution prompts + reusable methodology guides
- Commands: 50-150 lines (currently 250-525 lines)
- Guides: Independent methodology documents for reference during any work

**Scope**:
- **In scope**: 8 command files, 8 new guide files, backup/restore
- **Out of scope**: `.claude/templates/` folder, `CLAUDE.md` changes

### Why (Context)

**Current Problem**:
- Commands average 376 lines (official recommendation: concise, focused)
- Commands function as "complete manuals" instead of "prompt templates"
- Duplicate sections across commands (Extended Thinking, Core Philosophy, References)
- Methodology content trapped inside commands (not independently referenceable)

**Desired State**:
- Commands: Focused execution prompts following official best practices
- Guides: Reusable methodology documents readable without running commands
- Zero information loss from original commands

**Business Value**:
- Faster command execution (less context to process)
- Better maintainability (methodology in one place)
- Methodology reference during any work phase

### How (Approach)

- **Phase 1**: Backup current commands
- **Phase 2**: Create 8 methodology guide files
- **Phase 3**: Refactor 8 command files
- **Phase 4**: Verification and cleanup

### Success Criteria

```
SC-1: All commands ≤150 lines
- Verify: wc -l .claude/commands/*.md
- Expected: Each file ≤150 lines

SC-2: All 8 guide files created
- Verify: ls .claude/guides/*.md | wc -l
- Expected: 8 files

SC-3: Zero information loss
- Verify: Manual diff comparison with backup
- Expected: All original content preserved in commands or guides

SC-4: Guides independently readable
- Verify: Each guide makes sense without running a command
- Expected: Complete methodology explanation in each guide

SC-5: Commands executable with guide references
- Verify: Run each command, check workflow completion
- Expected: All commands work as before
```

### Constraints

- Must preserve all existing functionality
- No changes to `.claude/templates/`
- English only for all content
- Backup must be created before any changes

---

## Scope

### In Scope
- 8 command files: 00_plan, 01_confirm, 02_execute, 03_close, 90_review, 91_document, 92_init, 999_publish
- 8 new guide files in `.claude/guides/`
- Backup folder creation and cleanup

### Out of Scope
- `.claude/templates/` folder
- `CLAUDE.md` modifications
- Adding new functionality
- Changing command behavior

---

## Architecture

### Directory Structure (After)

```
.claude/
├── commands/                    # Concise execution prompts (50-150 lines)
│   ├── 00_plan.md
│   ├── 01_confirm.md
│   ├── 02_execute.md
│   ├── 03_close.md
│   ├── 90_review.md
│   ├── 91_document.md
│   ├── 92_init.md
│   └── 999_publish.md
│
├── guides/                      # Reusable methodology guides (NEW)
│   ├── tdd-methodology.md      # TDD cycle: Red-Green-Refactor
│   ├── ralph-loop.md           # Autonomous completion loop
│   ├── vibe-coding.md          # LLM-readable code standards
│   ├── prp-framework.md        # Problem-Requirements-Plan definition
│   ├── review-checklist.md     # Mandatory + Extended review items
│   ├── gap-detection.md        # External service verification
│   ├── 3tier-documentation.md  # Context Engineering system
│   └── test-environment.md     # Test framework detection
│
├── backup/                      # Temporary backup (delete after completion)
│   └── commands-backup-20260114/
│
└── templates/                   # No changes
```

### Content Distribution

| Content Type | Location | Rationale |
|--------------|----------|-----------|
| TDD Red-Green-Refactor | guides/tdd-methodology.md | Universal methodology |
| Ralph Loop structure | guides/ralph-loop.md | Universal methodology |
| Vibe Coding standards | guides/vibe-coding.md | Universal methodology |
| PRP definition | guides/prp-framework.md | Universal methodology |
| Review checklists | guides/review-checklist.md | Universal methodology |
| Gap Detection | guides/gap-detection.md | Universal methodology |
| 3-Tier documentation | guides/3tier-documentation.md | Universal methodology |
| Test environment detection | guides/test-environment.md | Universal methodology |
| Step sequences | commands/*.md | Command-specific |
| File paths | commands/*.md | Command-specific |
| Bash commands | commands/*.md | Command-specific |
| Next command guidance | commands/*.md | Command-specific |
| Phase Boundary Protection | commands/00_plan.md | Command-specific |
| Interactive Recovery | commands/01_confirm.md | Command-specific |
| Worktree mode | commands/02_execute.md, 03_close.md | Command-specific |

### Command Template (After Refactoring)

```markdown
---
description: [One-line description]
argument-hint: "[args] - description"
allowed-tools: [tool list]
---

# /command_name

_[One-line purpose]_

## Prerequisites
- [Preconditions]

## Steps
1. **[Step Name]**: [Brief description]
2. **[Step Name]**: [Brief description]
...

## Output
[Expected result]

## Next
[Next command guidance]

---

## Related Guides
- @.claude/guides/xxx.md - [Description]
```

---

## Vibe Coding Compliance

> Plan enforces code quality standards:

| Target | Limit | Compliance |
|--------|-------|------------|
| Command files | ≤150 lines | ✅ Target: 50-150 lines |
| Guide files | ≤300 lines | ✅ Single methodology per file |
| Nesting | ≤3 levels | ✅ Simple structure |

Principles applied: SRP (one purpose per file), DRY (methodology in guides), KISS (simple command structure)

---

## Execution Plan

### Phase 1: Backup (Estimated: 1 step)
- [ ] Create `.claude/backup/commands-backup-20260114/`
- [ ] Copy all 8 command files to backup

### Phase 2: Create Methodology Guides (Estimated: 8 steps)
- [ ] Create `guides/tdd-methodology.md` - Extract from 02_execute.md
- [ ] Create `guides/ralph-loop.md` - Extract from 02_execute.md
- [ ] Create `guides/vibe-coding.md` - Extract from 00_plan, 02_execute, 90_review
- [ ] Create `guides/prp-framework.md` - Extract from 00_plan.md
- [ ] Create `guides/review-checklist.md` - Extract from 90_review.md
- [ ] Create `guides/gap-detection.md` - Extract from 90_review, 01_confirm
- [ ] Create `guides/3tier-documentation.md` - Extract from 91_document, 92_init
- [ ] Create `guides/test-environment.md` - Extract from 00_plan, 02_execute

### Phase 3: Refactor Commands (Estimated: 8 steps)
- [ ] Refactor `00_plan.md` - Remove methodology, add guide refs (~80 lines)
- [ ] Refactor `01_confirm.md` - Remove methodology, add guide refs (~60 lines)
- [ ] Refactor `02_execute.md` - Remove methodology, add guide refs (~100 lines)
- [ ] Refactor `03_close.md` - Remove methodology, add guide refs (~70 lines)
- [ ] Refactor `90_review.md` - Remove methodology, add guide refs (~80 lines)
- [ ] Refactor `91_document.md` - Remove methodology, add guide refs (~60 lines)
- [ ] Refactor `92_init.md` - Remove methodology, add guide refs (~70 lines)
- [ ] Refactor `999_publish.md` - Remove methodology, add guide refs (~80 lines)

### Phase 4: Verification (Estimated: 4 steps)
- [ ] Verify line counts: `wc -l .claude/commands/*.md`
- [ ] Verify guide count: `ls .claude/guides/*.md | wc -l`
- [ ] Verify information preservation: Compare with backup
- [ ] Delete backup folder after all verification passes

---

## Acceptance Criteria

- [ ] AC-1: All 8 command files exist and are ≤150 lines
- [ ] AC-2: All 8 guide files exist in `.claude/guides/`
- [ ] AC-3: Each guide is independently readable (complete methodology)
- [ ] AC-4: Each command has "Related Guides" section with @ references
- [ ] AC-5: No information lost from original commands
- [ ] AC-6: Backup folder deleted after successful verification

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Verification |
|----|----------|-------|----------|------|--------------|
| TS-1 | Command line count | `wc -l .claude/commands/*.md` | All ≤150 | Unit | Bash output |
| TS-2 | Guide file count | `ls .claude/guides/*.md \| wc -l` | 8 files | Unit | Bash output |
| TS-3 | Guide independence | Read each guide | Complete methodology | Manual | Human review |
| TS-4 | Information preservation | Diff backup vs new | All content exists | Manual | Human review |
| TS-5 | Command execution | Run /00_plan | Works as before | Integration | Manual test |

## Test Environment (Detected)

- Project Type: Python (claude-pilot CLI tool)
- Test Framework: Manual verification (documentation refactoring)
- Test Command: Manual inspection
- Coverage Command: N/A (no code changes)
- Test Directory: N/A

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Information loss | Medium | High | Backup before changes, diff verification |
| Guide reference broken | Low | Medium | Test @ references after refactoring |
| Command flow disruption | Low | High | Preserve step sequences in commands |
| Methodology incomplete | Medium | Medium | Cross-check with backup for completeness |

---

## Open Questions

All questions resolved in planning:
1. ✅ Language: English only
2. ✅ Guide purpose: Independent methodology reference
3. ✅ @ reference style: "Related Guides" section at command end
4. ✅ Backup strategy: Create before, delete after verification

---

## Guide Content Outline

### guides/tdd-methodology.md (~80 lines)
- Red-Green-Refactor cycle explanation
- When to write tests first
- Code examples for each phase
- Common mistakes to avoid

### guides/ralph-loop.md (~100 lines)
- Loop structure and entry conditions
- Iteration tracking format
- Exit conditions (success/failure/blocked)
- Coverage thresholds (80% overall, 90% core)

### guides/vibe-coding.md (~60 lines)
- Function ≤50 lines rule
- File ≤200 lines rule
- Nesting ≤3 levels rule
- SRP, DRY, KISS, Early Return principles

### guides/prp-framework.md (~80 lines)
- What (Functionality) definition
- Why (Context) definition
- How (Approach) definition
- Success Criteria format
- Constraints documentation

### guides/review-checklist.md (~150 lines)
- 8 Mandatory review items
- 8 Extended review items (A-H)
- Activation matrix by plan type
- Result format examples

### guides/gap-detection.md (~120 lines)
- External API verification
- Database operation verification
- Async operation verification
- File operation verification
- Environment verification
- Error handling verification

### guides/3tier-documentation.md (~100 lines)
- Tier 1: CLAUDE.md purpose
- Tier 2: Component CONTEXT.md
- Tier 3: Feature CONTEXT.md
- Auto-update rules
- Template references

### guides/test-environment.md (~80 lines)
- Detection priority order
- Project type to test command mapping
- Coverage command mapping
- Test directory conventions
- Fallback behavior

---

## References

- [Claude Code Official Docs](https://code.claude.com/docs/en/slash-commands)
- [Anthropic Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [wshobson/commands](https://github.com/wshobson/commands) - Example command repository

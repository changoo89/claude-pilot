---
name: spec-driven-workflow
description: Use when planning or executing work. SPEC-First: Requirements, success criteria, test scenarios before implementation.
---

# SKILL: Spec-Driven Workflow

> **Purpose**: SPEC-First development - clear requirements, success criteria, test scenarios before coding
> **Target**: Planners, coders, testers

---

## Quick Start

### When to Use This Skill
- Starting a new feature or bugfix
- Creating implementation plans
- Verifying work completion
- Managing todo state (pending → progress → done)

### Quick Reference
```markdown
## SPEC-First Template

### 1. What (Functionality)
**Objective**: [Single sentence goal]
**Scope**: In-scope items, out-of-scope exclusions

### 2. Why (Context)
**Problem**: [Current pain point]
**Business Value**: [User/technical impact]
**Background**: [Relevant history]

### 3. How (Approach)
**Implementation Strategy**: [Step-by-step plan]
**Dependencies**: [What must exist first]
**Risks & Mitigations**: [What could go wrong]

### 4. Success Criteria
- **SC-1**: [Measurable outcome] - Verify: [test command]
- **SC-2**: [Measurable outcome] - Verify: [test command]
```

---

## Core Concepts

### SPEC-First Framework

**Always start with clear requirements**:

1. **What** (Functionality): What needs to be built
2. **Why** (Context): Business value and rationale
3. **How** (Approach): Implementation strategy
4. **Success Criteria**: Measurable acceptance criteria

### Success Criteria (SC)

**Format**: Each SC must be:
- **Measurable**: Can be verified with test/command
- **Testable**: Has verification step
- **Atomic**: One specific outcome
- **Independent**: Doesn't depend on other SCs (when possible)

**Example**:
```markdown
- [ ] **SC-1**: Create user authentication endpoint
  - **Verify**: `curl -X POST /api/auth/login -d '{"email":"test@example.com","password":"pass"}'`
  - **Expected**: HTTP 200 with JWT token
```

---

## Todo State Management

### Pending → Progress → Done

**State Transitions**:
```bash
# Pending: Todo not started
{"id": "SC-1", "status": "pending", "iteration": 0}

# In Progress: Currently working
{"id": "SC-1", "status": "in_progress", "iteration": 1}

# Completed: Verified and done
{"id": "SC-1", "status": "completed", "iteration": 1}
```

**Update Pattern**:
```bash
# Mark in_progress when starting
update_state "SC-1" "in_progress" 1

# Mark completed after verification
update_state "SC-1" "completed" 1

# Get next pending todo
next_todo=$(jq -r '.todos[] | select(.status == "pending") | .id' .pilot/state/continuation.json | head -1)
```

---

## Integration Points

### Commands

| Command | SPEC-First Role |
|---------|----------------|
| `/00_plan` | Creates SPEC with PRP analysis and SCs |
| `/02_execute` | Executes SCs with Ralph Loop |
| `/03_close` | Verifies all SCs complete |
| `/04_fix` | Single-command bug fix with mini-SPEC |

### Plans

**Every plan must have**:
- User Requirements (UR): Verbatim user input
- Success Criteria (SC): Measurable outcomes
- PRP Analysis: What, Why, How
- Test Plan: Verification scenarios

**Example Plan Structure**:
```markdown
## User Requirements (Verbatim)
| ID | User Input | Summary |
|----|------------|---------|
| UR-1 | "Add authentication" | Add login feature |

## Requirements Coverage Check
| Requirement | In Scope | Success Criteria | Status |
|-------------|----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2 | Mapped |

## Success Criteria
- [ ] **SC-1**: Create /api/auth/login endpoint
  - **Verify**: `test -f src/api/auth/login.ts`
```

---

## Verification

### Test SPEC Quality
```bash
# Check plan has required sections
grep -q "## User Requirements" plan.md
grep -q "## Success Criteria" plan.md
grep -q "## Test Plan" plan.md

# Verify SCs have test commands
grep -A2 "SC-" plan.md | grep -q "Verify:"

# Verify 100% requirements coverage
grep "UR-" plan.md | wc -l  # Should match UR count
grep "SC-" plan.md | wc -l  # Should map all URs
```

---

## Anti-Patterns

**Don't**:
- Start coding without clear requirements
- Write vague success criteria ("make it work")
- Skip verification steps
- Mix multiple outcomes in one SC

**Do**:
- Write SPEC before implementation
- Include test commands for each SC
- Verify completion before marking done
- Keep SCs atomic and measurable

---

## Related Skills

- **ralph-loop**: Autonomous iteration until SCs complete
- **test-driven-development**: Red-Green-Refactor for SC implementation

---

**Version**: claude-pilot 4.2.0

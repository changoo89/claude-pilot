---
name: execute-plan
description: Plan execution workflow - parallel SC implementation, worktree mode, verification patterns, GPT delegation. Use for executing plans with TDD + Ralph Loop.
---

# SKILL: Execute Plan (Plan Execution Workflow)

> **Purpose**: Execute plans using TDD + Ralph Loop with parallel execution
> **Target**: Coder Agent implementing Success Criteria from plans

**When to Use**: Execute plans from `/01_confirm`, implement SCs with TDD, parallel execution of independent SCs, worktree mode for isolated development

**Quick Reference**:
```bash
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"
Task: subagent_type: $AGENT_TYPE, prompt: "Execute SC-1 from $PLAN_PATH"
```

**Scope**: Plan detection, SC dependency analysis, parallel execution, worktree mode, GPT delegation. TDD/Ralph/Vibe → separate skills.

---

## Execution Steps

**⚠️ EXECUTION DIRECTIVE**: Execute ALL steps IMMEDIATELY. NEVER move plan to done/ (only `/03_close` has this authority), do NOT call close-plan automatically, plan MUST remain in `.pilot/plan/in_progress/`

---

## Step 1: Plan Detection & SC Extraction

**⚠️ CRITICAL**: Always use absolute path based on Claude Code's initial working directory.

```bash
PROJECT_ROOT="$(pwd)"
PLAN_PATH="$(find "$PROJECT_ROOT/.pilot/plan/pending" "$PROJECT_ROOT/.pilot/plan/in_progress" -name "*.md" -type f 2>/dev/null | sort | head -1)"

[ -z "$PLAN_PATH" ] && { echo "❌ No plan found"; exit 1; }

# Move from pending/ to in_progress/
if echo "$PLAN_PATH" | grep -q "/pending/"; then
    PLAN_FILENAME="$(basename "$PLAN_PATH")"
    IN_PROGRESS_PATH="$PROJECT_ROOT/.pilot/plan/in_progress/${PLAN_FILENAME}"
    mkdir -p "$PROJECT_ROOT/.pilot/plan/in_progress"
    mv "$PLAN_PATH" "$IN_PROGRESS_PATH"
    PLAN_PATH="$IN_PROGRESS_PATH"
fi

echo "✓ Plan: $PLAN_PATH"

# Extract SCs (supports both header ### SC-N: and checkbox - [ ] **SC-N** formats)
SC_LIST=$(grep -E "^### SC-[0-9]+:|^- \[ \] \*\*SC-[0-9]+\*\*" "$PLAN_PATH" | sed -E 's/.*SC-([0-9]+).*/SC-\1/')
SC_COUNT=$(echo "$SC_LIST" | grep -c "SC-" || echo "0")

if [ "$SC_COUNT" -eq 0 ]; then
    echo "❌ No Success Criteria found in plan"
    exit 1
fi

echo "✓ Found $SC_COUNT Success Criteria"
echo "$SC_LIST"
```

---

## Step 2.5: Agent Selection

**Priority Order** (first match wins):
1. `.claude/*` or `docs/*` → coder (plugin/documentation work)
2. `src/components/*` + UI keywords → frontend-engineer
3. `src/api/*` or `server/*` + API keywords → backend-engineer
4. Default → coder

```bash
PLAN_CONTENT=$(cat "$PLAN_PATH")
FILES_TO_MODIFY=$(grep -E "^\| \`" "$PLAN_PATH" | sed 's/.*`\([^`]*\)`.*/\1/' || echo "")

# Priority 1: Plugin/Documentation work
if echo "$FILES_TO_MODIFY" | grep -qE "^\.claude/|^docs/"; then
    AGENT_TYPE="coder"
    echo "Selected agent: coder (plugin/documentation work)"
# Priority 2: Frontend (only for src/ paths)
elif echo "$FILES_TO_MODIFY" | grep -qE "^src/components/|^src/ui/" && \
     echo "$PLAN_CONTENT" | grep -qiE "component|UI|React|CSS|Tailwind"; then
    AGENT_TYPE="frontend-engineer"
    echo "Selected agent: frontend-engineer"
# Priority 3: Backend (only for src/ paths)
elif echo "$FILES_TO_MODIFY" | grep -qE "^src/api/|^src/server/|^server/" && \
     echo "$PLAN_CONTENT" | grep -qiE "API|endpoint|database|server|backend"; then
    AGENT_TYPE="backend-engineer"
    echo "Selected agent: backend-engineer"
# Default: coder
else
    AGENT_TYPE="coder"
    echo "Selected agent: coder (default)"
fi
```

---

## Step 2.7: Pre-Execution Confidence

**Purpose**: Evaluate confidence before complex SCs. If < 0.5 → consult GPT Architect (rubric: @.claude/skills/gpt-delegation/SKILL.md).

```bash
# Confidence detection (arch/multi/uncertain patterns reduce score)
ARCH_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'architecture|tradeoff|design|scalability|pattern|choice' || echo "0")
APPROACH_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'could|might|option [AB]|either' || echo "0")
UNCERTAINTY_COUNT=$(echo "$SC_CONTENT" | grep -ciE 'not sure|unclear|depends' || echo "0")

# Calculate: 1.0 - (arch*0.3) - (approach*0.2) - (uncertain*0.2), clamp to [0,1]
CONFIDENCE=$(echo "scale=2; 1.0 - ($ARCH_COUNT * 0.3) - ($APPROACH_COUNT * 0.2) - ($UNCERTAINTY_COUNT * 0.2)" | bc)
CONFIDENCE=$(echo "$CONFIDENCE" | awk '{if ($1 < 0) print 0; else if ($1 > 1) print 1; else print $1}')
echo "📊 Pre-Execution Confidence: $CONFIDENCE"

# Proactive GPT if < 0.5 (graceful fallback if codex unavailable)
if (( $(echo "$CONFIDENCE < 0.5" | bc -l) )); then
    echo "⚠️  Low confidence - consulting GPT Architect"
    if command -v codex &> /dev/null; then
        codex exec -m gpt-5.2 -s read-only -c reasoning_effort=medium --json "TASK: Review SC $SC for architecture/approach/risks. Confidence: $CONFIDENCE"
        echo "✓ GPT consultation complete - apply recommendations"
    else
        echo "⚠️  Codex unavailable - Claude-only mode (graceful fallback)"
    fi
fi
```

---

## Step 3: Execute with Ralph Loop

**Dependency Analysis** (supports both `### SC-N:` and `- [ ] **SC-N**` formats):
```bash
for SC in $SC_LIST; do
    SC_NUM=$(echo "$SC" | sed 's/SC-//')
    SC_CONTENT=$(sed -n "/### SC-${SC_NUM}:/,/^###\|^- \[ \] \*\*SC-/p" "$PLAN_PATH" | tail -n +2 | head -n -1 2>/dev/null)
    if [ -z "$SC_CONTENT" ]; then
        SC_CONTENT=$(sed -n "/\*\*SC-${SC_NUM}\*\*/,/^\*- \[ \]/p" "$PLAN_PATH" | tail -n +2 | head -n -1 2>/dev/null)
    fi
    if echo "$SC_CONTENT" | grep -qiE 'after|depends|requires|follows'; then
        echo "**SequentialGroup**: $SC"
    else
        echo "**ParallelGroup**: $SC"
    fi
done
```

**Smart Grouping**: When SCs follow Atomic SC Principle (@.claude/skills/spec-driven-workflow/SKILL.md), parallel execution naturally emerges. SCs modifying same file type automatically group for specialized agents (e.g., frontend-engineer for `src/components/*`, backend-engineer for `src/api/*`).

**Execution Strategies**: Parallel (Independent SCs, 50-70% speedup): `Task: subagent_type: $AGENT_TYPE, prompt: "Execute SC-{N} from $PLAN_PATH. Skills: tdd, ralph-loop, vibe-coding. Output: <CODER_COMPLETE> or <CODER_BLOCKED>"` | Sequential (Dependent SCs): One agent with all SCs | Single Coder (1-2 SCs): Always delegate

**Process Results**: Check `<CODER_COMPLETE>`, run `npm test`, mark complete or retry. Quality Gates: Tests pass, Coverage ≥80%, Type-check clean, Lint clean.

**Handle CODER_BLOCKED**: Delegate to GPT Architect (gpt-5.2, workspace-write, reasoning_effort=medium). Fallback: Continue with Claude.

```bash
if grep -q "<CODER_BLOCKED>" /tmp/coder_output.log 2>/dev/null; then
    if command -v codex &> /dev/null; then
        codex exec -m gpt-5.2 -s workspace-write -c reasoning_effort=medium --json "$ARCHITECT_PROMPT"
    fi
fi
```

---

## Step 4: Completion & E2E Verification

**Completion**:
```bash
echo "✅ All Success Criteria Complete"
echo "📦 Next Step: Run Step 5 for E2E verification"
```

**E2E Verification**: Detect project type → Web: Chrome in Claude, CLI: check exit code/stdout, Library: run tests. Retry max 3, then GPT delegation, then user. Full: @REFERENCE.md

---

## Further Reading

**Internal**: @.claude/skills/execute-plan/REFERENCE.md | @.claude/skills/tdd/SKILL.md | @.claude/skills/ralph-loop/SKILL.md | @.claude/skills/gpt-delegation/SKILL.md

**External**: [Test-Driven Development](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530) | [Working Effectively with Legacy Code](https://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)

---

**Version**: claude-pilot 4.4.14

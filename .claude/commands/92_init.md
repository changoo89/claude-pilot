---
description: Initialize 3-Tier Documentation System for existing projects
argument-hint: ""
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, AskUserQuestion
---

# /92_init

_Initialize 3-Tier Documentation System for existing projects - automated analysis and document generation._

## Core Philosophy

- **Migration-First**: Bring existing projects to same documentation standard as new projects
- **Interactive**: Confirm before making changes
- **Smart Merging**: Preserve existing documentation rather than overwriting
- **Tech Stack Detection**: Automatically identify project type and structure

**3-Tier Documentation**: See @.claude/guides/3tier-documentation.md

---

## Step 0: Pre-flight Checks

```bash
[ -f "CLAUDE.md" ] && MODE="migration" || MODE="fresh"
git rev-parse --git-dir > /dev/null 2>&1 && IS_GIT_REPO=true || IS_GIT_REPO=false
```

---

## Step 1: Project Analysis

### 1.1 Detect Tech Stack
```bash
[ -f "package.json" ] && TECH_STACK="node"
[ -f "requirements.txt" ] || [ -f "pyproject.toml" ] && TECH_STACK="python"
[ -f "go.mod" ] && TECH_STACK="go"
[ -f "Cargo.toml" ] && TECH_STACK="rust"
```

### 1.2 Scan Structure
```bash
for DIR in src lib app components pages server; do
    [ -d "$DIR" ] && SOURCE_DIRS+=("$DIR")
done
for DIR in test tests spec __tests__; do
    [ -d "$DIR" ] && TEST_DIR="$DIR" && break
done
```

### 1.3 Identify Tier 2 Candidates
| Pattern | Example | Criteria |
|---------|---------|----------|
| `src/*/`, `lib/*/` | `src/components/` | Has 3+ files |
| `components/*/` | `components/admin/` | Has 3+ files |
| Top-level | `src/`, `lib/` | Main source folders |

---

## Step 2: Interactive Customization

### 2.1 Present Analysis
```
📊 Project Analysis Complete

## Detected Configuration
- Technology Stack: {TECH_STACK}
- Git Repository: {IS_GIT_REPO}
- Source Directories: {SOURCE_DIRS}
- Test Directory: {TEST_DIR}
- Tier 2 Candidates: {FOLDER_LIST}
```

### 2.2 Get Project Info
Use AskUserQuestion: "Provide a brief project description (1-2 sentences):"

### 2.3 Confirm Tier 2 Folders
Ask: "Select folders to create Tier 2 (Component) CONTEXT.md:" [Multi-select from candidates]

---

## Step 3: Generate Documentation Structure

### 3.1 Create/Update CLAUDE.md (Tier 1)

| Section | Content |
|---------|---------|
| Project Overview | One-line description, tech stack, status |
| Quick Start | Installation, common commands |
| Project Structure | Directory layout, key files |
| 3-Tier Documentation | Links to Tier 2/3 CONTEXT.md |

### 3.2 Create docs/ai-context/

```bash
mkdir -p docs/ai-context
```

**@docs/ai-context/docs-overview.md**:
```markdown
# Documentation Overview
## 3-Tier System
| Tier | Location | Purpose | Frequency |
|------|----------|---------|-----------|
| Tier 1 | CLAUDE.md | Project standards | Rarely |
| Tier 2 | {component}/CONTEXT.md | Component architecture | Occasionally |
| Tier 3 | {feature}/CONTEXT.md | Implementation details | Frequently |
```

**@docs/ai-context/project-structure.md**:
```markdown
# Project Structure
## Technology Stack
| Category | Technology |
|-----------|------------|
| Language | {detected} |
| Framework | {detected} |
```

**@docs/ai-context/system-integration.md**:
```markdown
# System Integration
## Component Interactions
## Data Flow
## Shared Patterns
```

### 3.3 Create Tier 2 CONTEXT.md Files

For each selected folder, use @.claude/templates/CONTEXT-tier2.md.template

| Section | Source |
|---------|--------|
| Purpose | Folder name analysis |
| Key Files | Scan directory |
| Dependencies | Import analysis |
| Integration | Identify related components |

---

## Step 4: Verification & Completion

### 4.1 Validate
```bash
ls -la CLAUDE.md
ls -la docs/ai-context/*.md
find . -name "CONTEXT.md" -type f
```

### 4.2 Summary Report
```
✅ 3-Tier Documentation System Initialized

## Created Files
### Tier 1: CLAUDE.md
### docs/ai-context/: docs-overview.md, project-structure.md, system-integration.md
### Tier 2: {folder}/CONTEXT.md

## Next Steps
1. Review generated documentation
2. Customize CLAUDE.md for your project
3. Use /91_document to keep docs in sync
4. Run /91_document {folder} for Tier 3 docs
```

---

## Success Criteria

| Check | Verification | Expected |
|-------|--------------|----------|
| CLAUDE.md exists | `ls CLAUDE.md` | File created/merged |
| docs/ai-context/ exists | `ls docs/ai-context/` | 3 files |
| Tier 2 CONTEXT.md created | `find . -name "CONTEXT.md"` | At least 1 |
| Existing content preserved | Manual review | Original intact |

---

## Common Usage Patterns

| Pattern | Description |
|----------|-------------|
| Fresh Project | Creates full 3-Tier from scratch |
| Migration | Creates docs/ai-context/, merges into CLAUDE.md |
| Targeted | Select specific folders during analysis |

---

## Templates Used

| Template | Purpose | Location |
|----------|---------|----------|
| CONTEXT-tier2.md.template | Component docs | `.claude/templates/` |
| CONTEXT-tier3.md.template | Feature docs | `.claude/templates/` |

---

## Related Guides
- @.claude/guides/3tier-documentation.md - 3-Tier system overview
- @.claude/templates/CONTEXT-tier2.md.template - Component template
- @.claude/templates/CONTEXT-tier3.md.template - Feature template

---

## References
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- `/91_document` (keep docs in sync)
- **Branch**: `git rev-parse --abbrev-ref HEAD`
- **Status**: `git status --short`

---
description: Initialize 3-Tier Documentation System for existing projects
argument-hint: ""
allowed-tools: Read, Glob, Grep, Edit, Write, Bash, AskUserQuestion
---

# /92_init

_Initialize 3-Tier Documentation System for existing projects - automated analysis and document generation._

---

## Core Philosophy

- **Migration-First**: Bring existing projects up to the same documentation standard as new projects
- **Interactive**: Confirm before making changes
- **Smart Merging**: Preserve existing documentation rather than overwriting
- **Tech Stack Detection**: Automatically identify project type and structure

> Reference: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
> Principle: 3-Tier Documentation System - Foundation/Component/Feature hierarchy

---

## Step 0: Pre-flight Checks

### 0.1 Verify Command Context

Check if this is a fresh install or existing project:

```bash
# Check for existing CLAUDE.md
if [ -f "CLAUDE.md" ]; then
    MODE="migration"
else
    MODE="fresh"
fi
```

### 0.2 Check Git Repository

```bash
# Verify git repo
git rev-parse --git-dir > /dev/null 2>&1
if [ $? -eq 0 ]; then
    IS_GIT_REPO=true
else
    IS_GIT_REPO=false
fi
```

---

## Step 1: Project Analysis

### 1.1 Detect Technology Stack

Scan for package/dependency files:

```bash
# Node.js/TypeScript
if [ -f "package.json" ]; then
    TECH_STACK="node"
    FRAMEWORK=$(grep -E '"(react|next|vue|angular|express|fastify)"' package.json | head -1)
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    TECH_STACK="python"
fi

# Go
if [ -f "go.mod" ]; then
    TECH_STACK="go"
fi

# Rust
if [ -f "Cargo.toml" ]; then
    TECH_STACK="rust"
fi
```

### 1.2 Scan Directory Structure

```bash
# Find main source directories
for DIR in src lib app components pages server; do
    if [ -d "$DIR" ]; then
        SOURCE_DIRS+=("$DIR")
    fi
done

# Find test directories
for DIR in test tests spec __tests__; do
    if [ -d "$DIR" ]; then
        TEST_DIR="$DIR"
        break
    fi
done
```

### 1.3 Identify Key Folders for Tier 2 CONTEXT.md

Generate list of candidates:

| Pattern | Example | Criteria |
|---------|---------|----------|
| `src/*/` | `src/components/` | Has 3+ files |
| `lib/*/` | `lib/utils/` | Has 3+ files |
| `components/*/` | `components/admin/` | Has 3+ files |
| Top-level | `src/`, `lib/` | Main source folders |

```bash
# Find folders with 3+ files
find . -maxdepth 3 -type d | while read DIR; do
    FILE_COUNT=$(find "$DIR" -maxdepth 1 -type f | wc -l)
    if [ $FILE_COUNT -ge 3 ]; then
        echo "$DIR ($FILE_COUNT files)"
    fi
done
```

---

## Step 2: Interactive Customization

### 2.1 Present Analysis Results

Display detected information:

```
📊 Project Analysis Complete

## Detected Configuration
- Technology Stack: {TECH_STACK}
- Framework: {FRAMEWORK}
- Git Repository: {IS_GIT_REPO}

## Source Structure
- Source Directories: {SOURCE_DIRS}
- Test Directory: {TEST_DIR}

## Candidates for Tier 2 CONTEXT.md
{FOLDER_LIST}
```

### 2.2 Ask for Project Description

Use AskUserQuestion to get project info:

```
Provide a brief project description (1-2 sentences):
```

### 2.3 Confirm Tier 2 Folders

Ask user to select folders for Tier 2 CONTEXT.md:

```
Select folders to create Tier 2 (Component) CONTEXT.md:
[Multi-select from candidate folders]
```

---

## Step 3: Generate Documentation Structure

### 3.1 Create/Update CLAUDE.md (Tier 1)

If CLAUDE.md exists, merge with existing content:

```bash
if [ -f "CLAUDE.md" ]; then
    # Merge mode: preserve existing sections
    # Add/update only new sections
else
    # Create new CLAUDE.md from template
fi
```

CLAUDE.md should include:

| Section | Content |
|---------|---------|
| Project Overview | One-line description, tech stack, current status |
| Quick Start | Installation, common commands |
| Project Structure | Directory layout, key files |
| 3-Tier Documentation | Links to Tier 2/3 CONTEXT.md files |

### 3.2 Create docs/ai-context/ Directory

```bash
mkdir -p docs/ai-context
```

Create three files:

#### docs/ai-context/docs-overview.md

Document routing and hierarchy:

```markdown
# Documentation Overview

## 3-Tier Documentation System

| Tier | Location | Purpose | Update Frequency |
|------|----------|---------|------------------|
| Tier 1 | CLAUDE.md (root) | Project standards & quick reference | Rarely |
| Tier 2 | {component}/CONTEXT.md | Component architecture & integration | Occasionally |
| Tier 3 | {feature}/CONTEXT.md | Implementation details | Frequently |

## Quick Start

1. **New to project**: Read CLAUDE.md (Tier 1)
2. **Working on component**: Read component's CONTEXT.md (Tier 2)
3. **Deep implementation**: Read feature's CONTEXT.md (Tier 3)

## Document Map

### Tier 1 (Foundation)
- `CLAUDE.md` - Project root documentation

### Tier 2 (Components)
- `{list of Tier 2 CONTEXT.md locations}`

### Tier 3 (Features)
- `{list of Tier 3 CONTEXT.md locations}`
```

#### docs/ai-context/project-structure.md

Technology stack and file structure:

```markdown
# Project Structure

## Technology Stack

| Category | Technology |
|----------|-----------|
| Language | {detected language} |
| Framework | {detected framework} |
| Package Manager | {npm/pip/cargo/etc} |
| Build Tool | {detected build tool} |

## Directory Layout

```
{project-root}/
├── {source-dir}/           # Main source code
│   ├── {folder1}/         # {purpose}
│   └── {folder2}/         # {purpose}
├── {test-dir}/            # Test files
├── docs/
│   └── ai-context/        # This directory
├── CLAUDE.md              # Tier 1 documentation
└── package.json           # Dependencies
```

## Key Files

| File | Purpose |
|------|---------|
| {entry-file} | Application entry point |
| {config-file} | Configuration |
| {main-file} | Main module |
```

#### docs/ai-context/system-integration.md

Cross-component patterns:

```markdown
# System Integration

## Component Interactions

```
[Component A] → [Component B] → [Component C]
       ↓              ↓              ↓
   [Service]    [Utility]      [Repository]
```

## Data Flow

1. **Request Flow**: {describe request flow}
2. **State Management**: {describe state management}
3. **Error Handling**: {describe error handling strategy}

## Shared Patterns

- **Pattern 1**: {description}
- **Pattern 2**: {description}

## Integration Points

| Component | Interface | Direction | Purpose |
|-----------|-----------|-----------|---------|
| {Comp A}  | {API}     | →         | {Purpose} |
```

### 3.3 Create Tier 2 CONTEXT.md Files

For each selected folder from Step 2.3:

```bash
for FOLDER in "${SELECTED_FOLDERS[@]}"; do
    # Use CONTEXT-tier2.md.template as base
    # Fill in folder-specific information
    # Create at: ${FOLDER}/CONTEXT.md
done
```

Content should include:

| Section | Source |
|---------|--------|
| Purpose | Folder name analysis |
| Key Files | Scan directory |
| Dependencies | Import analysis |
| Integration | Identify related components |

---

## Step 4: Verification & Completion

### 4.1 Validate Created Files

```bash
# Check files exist
ls -la CLAUDE.md
ls -la docs/ai-context/*.md
find . -name "CONTEXT.md" -type f
```

### 4.2 Generate Summary Report

```
✅ 3-Tier Documentation System Initialized

## Created Files

### Tier 1 (Foundation)
- CLAUDE.md

### docs/ai-context/
- docs-overview.md
- project-structure.md
- system-integration.md

### Tier 2 (Components)
- {folder}/CONTEXT.md
- {folder}/CONTEXT.md

## Next Steps

1. Review generated documentation
2. Customize CLAUDE.md for your project
3. Use /91_document to keep docs in sync
4. Run /91_document {folder} to create Tier 3 docs for features

## Preservation

Existing files were merged, not replaced.
Original content preserved in sections marked with [Existing].

---

Ready to start building with claude-pilot! 🚀
```

---

## Success Criteria

| Check | Verification | Expected |
|-------|--------------|----------|
| CLAUDE.md exists | `ls CLAUDE.md` | File created/merged |
| docs/ai-context/ exists | `ls docs/ai-context/` | 3 files created |
| Tier 2 CONTEXT.md created | `find . -name "CONTEXT.md"` | At least 1 created |
| Existing content preserved | Manual review | Original content intact |

---

## Common Usage Patterns

### Fresh Project (no existing CLAUDE.md)

```
/92_init
→ Creates full 3-Tier structure from scratch
→ Uses detected tech stack
→ All sections filled with detected info
```

### Migration (existing CLAUDE.md)

```
/92_init
→ Creates docs/ai-context/
→ Merges new sections into CLAUDE.md
→ Preserves existing content
→ Creates Tier 2 CONTEXT.md for selected folders
```

### Targeted Initialization

```
/92_init
→ During analysis, select specific folders
→ Creates CONTEXT.md only for selected folders
→ Run again later for additional folders
```

---

## Templates Used

| Template | Purpose | Location |
|----------|---------|----------|
| CONTEXT-tier2.md.template | Component-level docs | `.claude/templates/CONTEXT-tier2.md.template` |
| CONTEXT-tier3.md.template | Feature-level docs | `.claude/templates/CONTEXT-tier3.md.template` |

---

## References

- **3-Tier Documentation**: [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Related Commands**: `/91_document` (keep docs in sync)
- **Templates**: `.claude/templates/CONTEXT-*.md.template`

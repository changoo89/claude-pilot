# claude-pilot

> Your Claude Code copilot - Structured workflows, SPEC-First TDD, Ralph Loop automation, and context engineering. Fly with discipline.

---

## Quick Start

```bash
# One-line install (curl)
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash

# Or clone and install
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot
./install.sh

# Or copy to existing project
cp -r .claude /path/to/your/project/
cp CLAUDE.md /path/to/your/project/
```

---

## What is claude-pilot?

**claude-pilot** is an opinionated preset for Claude Code that brings structure and discipline to AI-assisted development. It provides:

- **SPEC-First TDD**: Test-Driven Development with clear success criteria
- **Ralph Loop**: Autonomous iteration until all tests pass
- **3-Tier Documentation**: Foundation/Component/Feature hierarchy for efficient context
- **PRP Pattern**: Structured prompts for unambiguous requirements
- **Integrated Hooks**: Type checking, linting, and todo validation
- **Migration Support**: Auto-generate docs for existing projects with `/92_init`
- **Multilingual**: Runtime language selection (English/Korean/Japanese)

---

## Core Workflow

```
/92_init     → Initialize 3-Tier Documentation (for existing projects)
/00_plan     → Create spec-driven plan with PRP format
/01_confirm  → Review and approve plan
/02_execute  → Execute with Ralph Loop + TDD
/03_close    → Complete and commit
/90_review   → Auto-review code (multi-angle)
/91_document → Auto-document changes
```

---

## Project Structure

```
claude-pilot/
├── README.md
├── install.sh              # One-line installation
├── pyproject.toml          # Python CLI package config
├── mcp.json                # Recommended MCP servers
├── CLAUDE.md               # Main project guide
├── AGENTS.md               # Agent configuration
├── .claude/
│   ├── settings.json       # Hooks, LSP, language config
│   ├── commands/           # Slash commands (7)
│   ├── templates/          # CONTEXT.md, SKILL.md, PRP.md, Tier templates
│   └── scripts/hooks/      # Typecheck, lint, todos, branch
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Plans awaiting confirmation
│       ├── in_progress/    # Active plans
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
├── src/                    # Python CLI source
│   └── claude_pilot/       # CLI package
│       ├── __init__.py
│       ├── __main__.py
│       ├── cli.py          # Click commands
│       ├── config.py       # Configuration
│       └── updater.py      # Update logic
└── examples/               # Sample configurations
```

---

## Features

### 1. SPEC-First Development

Every feature starts with clear requirements:
- **What**: Functionality description
- **Why**: Business value and context
- **How**: Implementation approach
- **Success Criteria**: Measurable acceptance criteria
- **Constraints**: Technical/time/resource limits

### 2. Ralph Loop TDD

Autonomous iteration pattern:
1. **Red**: Write failing test
2. **Green**: Implement minimal code to pass
3. **Refactor**: Clean up while keeping tests green
4. **Repeat**: Until all criteria met

### 3. 3-Tier Documentation System

Optimized token usage with hierarchical documentation:
- **Tier 1** (CLAUDE.md): Project foundation, rarely changes
- **Tier 2** (Component): Architecture, integration, occasionally changes
- **Tier 3** (Feature): Implementation details, frequently changes

Run `/92_init` in existing projects to auto-generate this structure.

### 4. Integrated Hooks

Automation at key points:
- **PreToolUse**: Type checking, linting before edits
- **PostToolUse**: Validation after changes
- **Stop**: Todo completion verification (Ralph continuation)

---

## Installation

### Option 1: One-line Install (Recommended)

```bash
# Install to current directory
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash

# Update existing installation
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash -s -- update

# Check version
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash -s -- version
```

**Why curl?**
- No git clone required
- Single command installation
- Safe updates that preserve your customizations
- Works in any directory

The installer will:
1. Download claude-pilot core files
2. Create `.claude/` directory structure
3. Set up `.pilot/` for plan management
4. Initialize version tracking

**After installation:**
```bash
# For new projects, start planning
/00_plan "your first feature"

# For existing projects, initialize documentation
/92_init
```

### Option 2: Clone and Install

```bash
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot && ./install.sh
```

### Option 3: Manual Install

```bash
# Clone the template
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot

# Copy to your project
cp -r .claude /path/to/your/project/
cp CLAUDE.md /path/to/your/project/
cp AGENTS.md /path/to/your/project/

# Edit CLAUDE.md with your project info
nano /path/to/your/project/CLAUDE.md
```

### Option 4: Python CLI (New!)

After installing with any method above, you can also install the Python CLI:

```bash
# Install via pip (from project directory)
pip3 install .

# Usage
claude-pilot version    # Show version info
claude-pilot update     # Update managed files
```

**CLI Benefits:**
- Simple, memorable commands
- No need to remember long curl commands
- Works alongside the bash install.sh

**Note:** The CLI is optional - the bash `install.sh` continues to work for all operations.

---

## Updates

claude-pilot supports safe updates that preserve your customizations:

```bash
# Option 1: Using the CLI (if installed)
claude-pilot update

# Option 2: Using curl (original method)
curl -fsSL https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash -s -- update
```

**What gets updated:**
- Core commands (00_plan, 01_confirm, 02_execute, 03_close, 90_review, 91_document)
- Guides and templates
- Hooks scripts
- Version tracking

**What gets preserved:**
- Your `CLAUDE.md` customizations
- Your `AGENTS.md` configuration
- Your `.pilot/` plans and data
- Your `.claude/settings.json` settings
- Custom commands you've added

---

## Configuration

### Language Settings

Edit `.claude/settings.json`:

```json
{
  "language": "en"  // Options: en, ko, ja
}
```

### MCP Servers

Recommended MCPs (auto-installed):

| MCP | Purpose |
|-----|---------|
| context7 | Latest library docs |
| serena | Semantic code operations |
| grep-app | Advanced search |
| sequential-thinking | Complex reasoning |

### Hook Customization

Edit `.claude/settings.json` hooks section:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": ".claude/scripts/hooks/typecheck.sh"}]
      }
    ]
  }
}
```

---

## Usage Examples

### Initialize Existing Project

```bash
# In Claude Code - for projects that already have code
/92_init

# Automatically:
# - Analyzes project structure and tech stack
# - Creates CLAUDE.md (merging if exists)
# - Creates docs/ai-context/ with 3 supporting files
# - Creates Tier 2 CONTEXT.md for selected components
```

### Start a New Feature

```bash
# In Claude Code
/00_plan "Add user authentication with JWT"

# Review the generated plan in .pilot/plan/pending/
# Edit if needed, then:

/01_confirm  # Approve the plan

/02_execute  # Execute with TDD + Ralph Loop
```

### Auto-Document Changes

```bash
# After completing work
/91_document

# Automatically updates:
# - CLAUDE.md (Tier 1)
# - docs/ai-context/ files
# - Tier 2/3 CONTEXT.md files
```

### Multi-Angle Review

```bash
# Before committing
/90_review security performance accessibility

# Reviews code from multiple perspectives
```

---

## Development Workflow

### 1. Planning Phase

```
User Request
    ↓
/00_plan → Designs plan in conversation (no file)
    ↓
Manual Review/Edit
    ↓
/01_confirm → Saves plan to .pilot/plan/pending/
```

### 2. Execution Phase

```
/02_execute
    ↓
Create Todo List from Plan
    ↓
Ralph Loop:
  1. Write test (Red)
  2. Implement (Green)
  3. Refactor
  4. Verify
    ↓
Repeat until all pass
    ↓
/03_close → Archive to .pilot/plan/done/
```

### 3. Documentation Phase

```
/91_document
    ↓
Analyze changes
    ↓
Update 3-Tier documentation:
  - Tier 1: CLAUDE.md
  - docs/ai-context/ files
  - Tier 2: Component CONTEXT.md
  - Tier 3: Feature CONTEXT.md
    ↓
Commit with docs
```

---

## Inspiration & Credits

claude-pilot synthesizes best practices from these projects:

### Core Methodology

- **[Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)**
  - 3-Tier Documentation System (Foundation/Component/Feature)
  - Hierarchical CONTEXT.md structure
  - AI-context documentation patterns

- **[moai-adk](https://github.com/modu-ai/moai-adk)**
  - SPEC-First TDD methodology
  - Multilingual support architecture

- **[oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode)**
  - Ralph Loop autonomous iteration
  - Todo continuation enforcement

### Official Resources

- **[Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)**
  - Official Anthropic guidelines

---

## Guides

- [Getting Started](GETTING_STARTED.md)
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit) - 3-Tier Documentation System

---

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`/00_plan "your feature"`)
3. Follow TDD workflow (`/02_execute`)
4. Ensure tests pass
5. Submit PR with `/90_review` output

---

## License

MIT License - Free to use, modify, and distribute.

---

## FAQ

### Q: Can I use this for commercial projects?
A: Yes, MIT license allows commercial use.

### Q: How do I disable hooks?
A: Edit `.claude/settings.json` and remove unwanted hooks from the hooks section.

### Q: Can I add my own MCPs?
A: Yes, add them to `.claude/settings.json` under the mcp section.

### Q: What if I don't want TDD?
A: Ralph Loop can be configured to skip tests. Edit `/02_execute` command to adjust.

### Q: How do I add a new language?
A: Create translation files in `.claude/locales/` and add language code to settings.json.

---

## Support

- **Issues**: [GitHub Issues](https://github.com/changoo89/claude-pilot/issues)
- **Discussions**: [GitHub Discussions](https://github.com/changoo89/claude-pilot/discussions)

---

**Built with inspiration from the Claude Code community.**

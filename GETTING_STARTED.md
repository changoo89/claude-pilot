# Getting Started with claude-pilot

Welcome to **claude-pilot**! This guide will help you get up and running quickly.

## Quick Install

### Plugin Marketplace Installation (Recommended)

```bash
# Step 1: Add marketplace
/plugin marketplace add changoo89/claude-pilot

# Step 2: Install plugin
/plugin install claude-pilot

# Step 3: Run setup
/pilot:setup
```

The installer will:
1. Copy plugin files to `.claude/` directory
2. Create `.pilot/` directory for plan management
3. Configure recommended MCP servers
4. Set up hooks and templates
5. Prompt for language selection (English/Korean/Japanese)

### Verification

After installation, verify the plugin is working:

```bash
# Check version (should show 4.3.1)
/pilot:setup --version

# List available commands
ls .claude/commands/

# Should show: 00_plan.md, 01_confirm.md, 02_execute.md, etc.
```

---

## First Steps

### For New Projects

After installation, start planning your first feature:

```bash
/00_plan "your first feature"
```

### For Existing Projects

If you already have a codebase, initialize the 3-Tier Documentation System:

```bash
/setup
```

This command will:
1. **Analyze your project** - Detect tech stack, structure, and key folders
2. **Ask for confirmation** - Show detected info and let you customize
3. **Generate documentation**:
   - Create/update `CLAUDE.md` (merging if exists)
   - Create `CLAUDE.local.md` (gitignored, project-specific)
   - Create `docs/ai-context/` folder with 3 supporting files
   - Create Tier 2 `CONTEXT.md` for selected components

---

## Configuration

### 1. Customize CLAUDE.local.md

Edit `CLAUDE.local.md` to add your project's specifics:

```markdown
# [Your Project Name] - Project Configuration

## Quick Start
\`\`\`bash
npm install
npm run dev
\`\`\`

## Project Overview
**One-line description**: What your project does

**Tech Stack**:
- Framework: [e.g., Next.js, Express]
- Language: [e.g., TypeScript, Python]
- Database: [e.g., PostgreSQL, MongoDB]

## Key Commands
| Command | Description |
|---------|-------------|
| npm run dev | Start development server |
| npm test | Run tests |
```

### 2. Configure Settings

Edit `.claude/settings.json` to match your project:

```json
{
  "language": "en",
  "continuation_level": "normal",
  "coverage_threshold": 80,
  "lsp": {
    "typescript-language-server": {
      "command": "typescript-language-server",
      "args": ["--stdio"],
      "filetypes": ["typescript", "typescriptreact"]
    }
  }
}
```

### 3. Set Up Hooks

The plugin includes quality enforcement hooks:

- **typecheck.sh** - Runs `tsc --noEmit` on file edits
- **lint.sh** - Runs ESLint/Pylint/gofmt on file edits
- **check-todos.sh** - Warns if todos incomplete at session end
- **branch-guard.sh** - Warns before dangerous git operations

Make sure hooks are executable:
```bash
chmod +x .claude/scripts/hooks/*.sh
```

---

## Using the Commands

### Planning Workflow

```
0. /setup     → Initialize 3-Tier Documentation (for existing projects)
1. /00_plan     → Create SPEC-First execution plan (read-only exploration)
2. /01_confirm  → Save plan to pending/ (optional, /02_execute can auto-detect)
3. /02_execute  → Implement with Ralph Loop + TDD
4. /review   → Multi-angle code review
5. /document → Sync 3-Tier documentation
6. /03_close    → Finalize and create git commit
```

### Quick Examples

**Initialize existing project:**
```
/setup
> [Analyzes project structure and tech stack]
> [Shows detected info: Node.js, React, etc.]
> [Asks for project description and Tier 2 folders]
> [Creates CLAUDE.local.md, docs/ai-context/, CONTEXT.md files]
```

**Plan a new feature:**
```
/00_plan
> I need to add user authentication with JWT tokens
> Requirements: Login, logout, session management
> Success criteria: Users can log in and maintain session
```

**Execute the plan:**
```
/02_execute
> [Automatically implements the plan with TDD]
```

**Review the code:**
```
/review
> [Runs parallel verification: tester, validator, code-reviewer]
```

### Parallel Work with Worktrees

For parallel plan execution using Git worktrees:

```
1. /00_plan × N    → Create multiple plans (stored in pending/)
2. /02_execute --wt → Create worktree from oldest pending plan
3. cd to worktree   → Work in isolated environment
4. /02_execute      → Implement plan (normal flow)
5. /03_close        → Squash merge to main and cleanup
```

**Example workflow:**

```bash
# Create multiple plans
/00_plan "Add user authentication"
/00_plan "Implement search feature"

# Start work on oldest plan (creates worktree)
/02_execute --wt
# Output: ✅ Worktree created at ../project-wt-feature-20260113-auth
#         cd ../project-wt-feature-20260113-auth to continue

# Change to worktree and work
cd ../project-wt-feature-20260113-auth
/02_execute  # Normal execution without --wt

# Complete and merge
/03_close  # Squash merges to main, removes worktree
```

**Worktree benefits:**
- Work on multiple features simultaneously
- Isolated environments prevent conflicts
- Automatic cleanup after merge
- Each worktree has its own branch

---

## Plan Management

Plans are stored in `.pilot/plan/`:

```
.pilot/
└── plan/
    ├── pending/       # Plans awaiting confirmation
    ├── in_progress/   # Currently executing plans
    ├── done/          # Completed and archived plans
    └── active/        # Branch pointers
```

---

## Templates

The plugin includes document templates for the 3-Tier Documentation System:

### Tier 2 Template (Component)
For component-level architecture and integration:
```bash
# CONTEXT-tier2.md.template
# Used for major components, utilities, API routes
# Auto-applied by /document for component folders
```

### Tier 3 Template (Feature)
For feature-level implementation details:
```bash
# CONTEXT-tier3.md.template
# Used for specific features, deep nested folders
# Auto-applied by /document for feature folders
```

### General Template
```bash
# CONTEXT.md.template (L0/L1/L2 system)
# General-purpose template for any context
```

### SKILL.md.template
For domain-specific skill documentation:
```bash
# Create skill for frontend development
cp .claude/templates/SKILL.md.template .claude/skills/frontend/SKILL.md
```

---

## MCP Servers

The plugin recommends 5 MCP servers (configured via `/pilot:setup`):

1. **context7** - Up-to-date library documentation
2. **serena** - Semantic code search and editing
3. **grep-app** - Fast code search
4. **sequential-thinking** - Complex reasoning support
5. **codex** - GPT integration for intelligent delegation

Configure MCP servers:
```bash
/pilot:setup
```

Or manually edit `.mcp.json`:
```json
{
  "mcpServers": {
    "context7": {...},
    "serena": {...}
  }
}
```

---

## GPT Codex Integration (Optional)

claude-pilot supports intelligent GPT delegation via Codex CLI:

### Expert Mapping

| Situation | GPT Expert |
|-----------|------------|
| Architecture decisions | **Architect** |
| Security-related code | **Security Analyst** |
| Large plans (5+ SCs) | **Plan Reviewer** |
| 2+ failed fix attempts | **Architect** |

### Configuration

```bash
export CODEX_REASONING_EFFORT="medium"  # low | medium | high | xhigh
```

**Full Guide**: [docs/ai-context/codex-integration.md](docs/ai-context/codex-integration.md)

---

## Examples

See the `examples/` folder for configuration examples:

- **minimal-typescript** - Basic TypeScript project setup

---

## Troubleshooting

### Hooks not executing
```bash
# Make sure hooks are executable
chmod +x .claude/scripts/hooks/*.sh

# Check hook syntax
bash -n .claude/scripts/hooks/typecheck.sh
```

### Commands not appearing
```bash
# Verify command files exist
ls .claude/commands/

# Should show: 00_plan.md, 01_confirm.md, etc.
```

### Language Server not working
```bash
# Install LSP binaries
npm install -g typescript-language-server
npm install -g vscode-eslint-language-server

# Verify LSP config
cat .claude/settings.json | jq '.lsp'
```

### Plan not found
```bash
# Verify .pilot directory exists
ls -la .pilot/plan/

# Run /00_plan first to create a plan
```

---

## Next Steps

1. Install the plugin via marketplace
2. Run `/pilot:setup` to configure MCP servers
3. Try your first `/00_plan` command
4. Explore [examples/](examples/) for more configurations

---

## Resources

- [README.md](README.md) - Project overview and features
- [CLAUDE.md](CLAUDE.md) - Plugin documentation
- [examples/](examples/) - Configuration examples
- [docs/ai-context/codex-integration.md](docs/ai-context/codex-integration.md) - GPT delegation guide

---

## Support

For issues or questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Review example configurations
3. Open an issue on [GitHub](https://github.com/changoo89/claude-pilot/issues)

---

**Happy coding with claude-pilot!**

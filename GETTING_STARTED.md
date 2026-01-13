# Getting Started with claude-pilot

Welcome to **claude-pilot**! This guide will help you get up and running quickly.

## Quick Install

```bash
# Clone and run installer
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot
./install.sh
```

The installer will:
1. Backup your existing `.claude/` folder (if it exists)
2. Ask you to select a language (en/ko/ja)
3. Ask which components to install
4. Copy the template files to your project
5. Create `.pilot/` directory for plan management

## Manual Install

```bash
# Clone or download this repository
git clone https://github.com/changoo89/claude-pilot.git
cd claude-pilot

# Copy the template to your project
cp -r .claude/ ~/your-project/
cp -r .pilot/ ~/your-project/

# Copy the main configuration
cp CLAUDE.md AGENTS.md ~/your-project/

# (Optional) Copy example configuration
cp -r examples/minimal-typescript/.claude/settings.json ~/your-project/.claude/
```

## First Steps

### 1. Customize CLAUDE.md

Edit `CLAUDE.md` to add your project's specifics:

```markdown
# [Your Project Name] - Claude Code Configuration

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

The template includes quality enforcement hooks:

- **typecheck.sh** - Runs `tsc --noEmit` on file edits
- **lint.sh** - Runs ESLint/Pylint/gofmt on file edits
- **check-todos.sh** - Warns if todos incomplete at session end
- **branch-guard.sh** - Warns before dangerous git operations

Make sure hooks are executable:
```bash
chmod +x .claude/scripts/hooks/*.sh
```

## Using the Commands

### Planning Workflow

```
1. /00_plan    → Create SPEC-First execution plan (read-only exploration)
2. /01_confirm → Approve plan and move to in-progress
3. /02_execute → Implement with Ralph Loop + TDD
4. /90_review  → Multi-angle code review
5. /91_document → Sync documentation
6. /03_close   → Finalize and create git commit
```

### Quick Examples

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
/90_review
> [Runs 8 mandatory reviews + type-specific reviews]
```

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

## Templates

The template includes three document templates:

### CONTEXT.md.template
For folder-level hierarchical context:
```bash
# Create CONTEXT.md for src/components/
cp .claude/templates/CONTEXT.md.template src/components/CONTEXT.md
```

### SKILL.md.template
For domain-specific skill documentation:
```bash
# Create skill for frontend development
cp .claude/templates/SKILL.md.template .claude/skills/frontend/SKILL.md
```

### PRP.md.template
For structured requirements:
```bash
# Create PRP for a new feature
cp .claude/templates/PRP.md.template docs/auth-feature-prp.md
```

## MCP Servers

The template recommends 4 MCP servers (configured in `mcp.json`):

1. **context7** - Up-to-date library documentation
2. **serena** - Semantic code search and editing
3. **grep-app** - Fast code search
4. **sequential-thinking** - Complex reasoning support

Install MCP servers:
```bash
npx @modelcontextprotocol/inspector install mcp.json
```

## Examples

See the `examples/` folder for configuration examples:

- **minimal-typescript** - Basic TypeScript project setup

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

## Next Steps

1. Install the template
2. Customize CLAUDE.md
3. Configure settings.json
4. Try your first `/00_plan` command
5. Read [AGENTS.md](AGENTS.md) for agent patterns
6. Explore [examples/](examples/) for more configurations

## Resources

- [README.md](README.md) - Project overview and features
- [AGENTS.md](AGENTS.md) - Agent patterns and coordination
- [examples/](examples/) - Configuration examples
- [install.sh](install.sh) - Installation script source

## Support

For issues or questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Review example configurations
3. Open an issue on [GitHub](https://github.com/changoo89/claude-pilot/issues)

---

**Happy coding with claude-pilot!**

# Minimal TypeScript Project Example

A minimal configuration for TypeScript projects using the claude-pilot preset.

## What's Included

- **TypeScript LSP** - Language server for IntelliSense
- **ESLint LSP** - Real-time linting feedback
- **Type Check Hook** - Runs `tsc --noEmit` on file edits
- **Lint Hook** - Runs ESLint on file edits
- **Branch Guard** - Warns before dangerous git operations

## Setup

```bash
# Copy this example to your project
cp -r .claude/ ~/your-project/

# Or use the install script from the template root
curl -s https://raw.githubusercontent.com/changoo89/claude-pilot/main/install.sh | bash
```

## Configuration Files

- `.claude/settings.json` - LSP and hooks configuration
- `CLAUDE.md` - Project-specific instructions
- `.claude/scripts/hooks/` - Quality enforcement scripts

## Customize

Edit `CLAUDE.md` to add:
- Your project's tech stack
- Specific commands for your workflow
- Important conventions and patterns

## Requirements

- Node.js 20+
- TypeScript 5+
- ESLint (configured in package.json)

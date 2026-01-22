# MCP Servers

> **Last Updated**: 2026-01-21
> **Purpose**: Recommended MCP servers for Claude Code

---

## Recommended Servers

### Core Servers (Installed by Default)

| Server | Purpose | Package |
|--------|---------|---------|
| **context7** | Documentation navigation and context | `@upstash/context7-mcp` |
| **filesystem** | Local file operations and grep search | `@modelcontextprotocol/server-filesystem` |
| **sequential-thinking** | Step-by-step reasoning for complex problems | `@modelcontextprotocol/server-sequential-thinking` |

### Optional Servers

| Server | Purpose | Package | Note |
|--------|---------|---------|------|
| **grep-app** | GitHub public repository search | `@modelcontextprotocol/server-grep-app` | OPTIONAL - Not included by default. Add manually if needed for GitHub code search. |

---

## Configuration

**Location**: Project-level MCP servers are configured in `~/.claude.json` under `projects.<project-path>.mcpServers`

**Quick Setup** (context7 + filesystem + sequential-thinking):
```bash
# Add to ~/.claude.json manually:
{
  "projects": {
    "/your/project/path": {
      "mcpServers": {
        "context7": {
          "command": "npx",
          "args": ["-y", "@upstash/context7-mcp"]
        },
        "filesystem": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-filesystem", "/your/project/path"]
        },
        "sequential-thinking": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
        }
      }
    }
  }
}
```

**Or use /pilot:setup** to automatically configure:
```bash
/pilot:setup
```

---

## Server Details

### context7

**Package**: `@upstash/context7-mcp`
**Purpose**: Latest library documentation and code examples

**Use When**:
- Looking up latest library APIs
- Finding up-to-date code examples
- Version-specific documentation queries

**Source**: [github.com/upstash/context7](https://github.com/upstash/context7)

### filesystem

**Package**: `@modelcontextprotocol/server-filesystem`
**Purpose**: Local file read/write operations and grep search

**Use When**:
- Reading/writing project files
- Searching code within local project
- File system operations

**Source**: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)

### sequential-thinking

**Package**: `@modelcontextprotocol/server-sequential-thinking`
**Purpose**: Step-by-step reasoning for complex problems

**Use When**:
- Complex multi-step problem solving
- Architecture decisions requiring structured reasoning
- Debugging complex issues with systematic approach
- Planning implementation with clear thought progression

**Source**: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)

### grep-app (OPTIONAL)

**Package**: `@modelcontextprotocol/server-grep-app`
**Purpose**: GitHub public repository code search

**Status**: OPTIONAL - Not included by default in `/pilot:setup`. Add manually if needed.

**Use When**:
- Searching open-source code for implementation examples
- Finding reference code from GitHub projects
- Learning from public repositories

**Manual Setup**:
```json
{
  "projects": {
    "/your/project/path": {
      "mcpServers": {
        "grep-app": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-grep-app"]
        }
      }
    }
  }
}
```

**Source**: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/grep-app)

---

## Verification

After adding MCP servers, restart Claude Code and verify:

```bash
/mcp
```

Expected output:
```
⎿  MCP Server Status
⎿
⎿  • context7: connected
⎿  • filesystem: connected
⎿  • sequential-thinking: connected
```

---

## Migration Notes

### Restored Servers (2026-01-22)

| Server | Reason |
|--------|--------|
| **sequential-thinking** | Re-added for complex problem solving use cases |

### Removed Servers (2026-01-21)

| Server | Reason | Replacement |
|--------|--------|-------------|
| **serena** | Inefficient, complex setup | `filesystem` for local operations |

---

## See Also

- **@docs/ai-context/system-integration.md** - System integration overview
- **@docs/ai-context/codex-integration.md** - Codex delegation details
- **[Configuring MCP Tools in Claude Code](https://code.claude.com/docs/en/mcp)** - Official documentation
- **@CLAUDE.md** - Project standards (Tier 1)

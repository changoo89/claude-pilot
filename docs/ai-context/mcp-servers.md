# MCP Servers

> **Last Updated**: 2026-01-21
> **Purpose**: Recommended MCP servers for Claude Code

---

## Recommended Servers

| Server | Purpose | Package |
|--------|---------|---------|
| **context7** | Documentation navigation and context | `@modelcontextprotocol/server-context7` |
| **filesystem** | Local file operations and grep search | `@modelcontextprotocol/server-filesystem` |
| **grep-app** | GitHub public repository search | `@modelcontextprotocol/server-grep-app` |

---

## Configuration

**Location**: Project-level MCP servers are configured in `~/.claude.json` under `projects.<project-path>.mcpServers`

**Quick Setup** (context7 + filesystem + grep-app):
```bash
# Add to ~/.claude.json manually:
{
  "projects": {
    "/Users/chanho/claude-pilot": {
      "mcpServers": {
        "context7": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-context7"]
        },
        "filesystem": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-filesystem", "--allow", "."]
        },
        "grep-app": {
          "command": "npx",
          "args": ["-y", "@modelcontextprotocol/server-grep-app"]
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

**Package**: `@modelcontextprotocol/server-context7`
**Purpose**: Latest library documentation and code examples

**Use When**:
- Looking up latest library APIs
- Finding up-to-date code examples
- Version-specific documentation queries

**Source**: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/context7)

### filesystem

**Package**: `@modelcontextprotocol/server-filesystem`
**Purpose**: Local file read/write operations and grep search

**Use When**:
- Reading/writing project files
- Searching code within local project
- File system operations

**Source**: [github.com/modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)

### grep-app

**Package**: `@modelcontextprotocol/server-grep-app`
**Purpose**: GitHub public repository code search

**Use When**:
- Searching open-source code
- Finding implementation examples
- Learning from GitHub projects

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
⎿  • grep-app: connected
```

---

## Migration Notes

### Removed Servers (2026-01-21)

| Server | Reason | Replacement |
|--------|--------|-------------|
| **serena** | Inefficient, complex setup | `filesystem` for local operations |
| **sequential-thinking** | Redundant with core capabilities | Built-in reasoning sufficient |

---

## See Also

- **@docs/ai-context/system-integration.md** - System integration overview
- **@docs/ai-context/codex-integration.md** - Codex delegation details
- **[Configuring MCP Tools in Claude Code](https://code.claude.com/docs/en/mcp)** - Official documentation
- **@CLAUDE.md** - Project standards (Tier 1)

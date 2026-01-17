# Gap Verification Checklist

> **Purpose**: Prevent assumption-based implementation by verifying all external service integrations are specified
> **Usage**: Include this checklist in plans involving external APIs, databases, files, async operations, or environment variables

---

## External API

- [ ] All API calls specify SDK vs HTTP mechanism
  - **SDK**: Specify package name and version (e.g., `openai@4.x`)
  - **HTTP**: Specify method and full endpoint path (e.g., `POST https://api.example.com/v1/generate`)
- [ ] All "Existing" endpoints verified via codebase search
  - Run: `grep -r "endpoint_path" --include="*.ts" --include="*.tsx"`
- [ ] All "New" endpoints have creation tasks in Execution Plan
  - Verify: Task exists like "Create /api/analyze endpoint"
- [ ] Error handling strategy defined for each external call
  - Specify: Timeout, retry logic, user notification method

**Automated Verification Commands**:
```bash
# Endpoint existence check
grep -r "endpoint_path" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx"

# SDK dependency check
grep "package_name" package.json
```

---

## Database Operations

- [ ] Schema changes have migration files specified
  - Include migration filename or path
- [ ] Rollback strategy documented
  - Specify how to revert if migration fails
- [ ] Data integrity checks included
  - Specify validation for existing data after migration

---

## Async Operations

- [ ] Timeout values specified for all async operations
  - Example: `fetch(url, { timeout: 30000 })`
- [ ] Concurrent operation limits defined
  - Example: `Promise.all([tasks])` with batch size
- [ ] Race condition scenarios addressed
  - Document potential conflicts and mitigation

---

## File Operations

- [ ] File paths are absolute or properly resolved
  - Use: `path.resolve()` or `path.join(__dirname, ...)`
- [ ] File existence checks before operations
  - Verify: `fs.existsSync()` or equivalent before read/write
- [ ] Cleanup strategy for temporary files
  - Specify temp file location and cleanup mechanism

---

## Environment

- [ ] All new env vars documented in .env.example
  - Verify: Variable name exists in .env.example
- [ ] All referenced env vars exist in current environment
  - Run: `grep "VAR_NAME" .env .env.example .env.local 2>/dev/null`
- [ ] No actual secret values in plan
  - Use placeholders like `YOUR_API_KEY` or `***`

**Automated Verification Commands**:
```bash
# Environment variable check
grep "VAR_NAME" .env .env.example .env.local 2>/dev/null
```

---

## Error Handling

- [ ] No silent catches (console.error only)
  - **Bad**: `catch(e) { console.error(e); }`
  - **Good**: `catch(e) { toast.error('Operation failed: ' + e.message); throw e; }`
- [ ] User notification strategy for each failure mode
  - Specify: Toast, status update, alert, or UI feedback
- [ ] Graceful degradation paths defined
  - Document fallback behavior when operations fail

---

## Severity Levels

| Level | Symbol | Description |
|-------|--------|-------------|
| **BLOCKING** | 🛑 | Cannot proceed - missing critical details |
| **Critical** | 🚨 | Must fix before execution |
| **Warning** | ⚠️ | Should fix |
| **Suggestion** | 💡 | Nice to have |

---

## Example: Good vs Bad

### Bad (Vague)
```markdown
## Implementation
- Call GPT 5.1 for analysis
- Save result to database
```
**Result**: 🛑 BLOCKING - API mechanism unspecified, database operation unclear

### Good (Complete)
```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| GPT Analysis | Next.js API | OpenAI | N/A | openai@4.x | New | [ ] `npm list openai` |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| OPENAI_API_KEY | Next.js | New | [ ] Add to .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| GPT call | Timeout/API error | Toast + status update | Retry 3x then fail |

## Database Operations
- Schema change: Add `analysis_result` column to `complaints` table
- Migration: `20250114_add_analysis_result.sql`
- Rollback: Drop column if migration fails
```
**Result**: ✅ Pass - All details specified

---

**Template Version**: 1.0.0
**Last Updated**: 2026-01-14

# Coding Standards - Detailed Reference

> **Purpose**: Extended details and examples for coding standards
> **Main Skill**: @.claude/skills/coding-standards/SKILL.md
> **Last Updated**: 2026-01-22

---

## TypeScript Deep Dive

### Type System Best Practices

**Discriminated Unions**:
```typescript
type AsyncState<T, E = Error> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: E };

function handleState<T>(state: AsyncState<T>) {
  switch (state.status) {
    case 'success': return `Got ${state.data}`;
    case 'error': return `Error: ${state.error.message}`;
    default: return assertNever(state);
  }
}
```

**Utility Types**:
```typescript
type PartialUser = Partial<User>;
type UserSummary = Pick<User, 'id' | 'name'>;
type CreateUserInput = Omit<User, 'id' | 'createdAt'>;
```

**Generic Constraints**:
```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}
```

---

## React Advanced Patterns

### Custom Hooks Library

| Hook | Purpose | Key Feature |
|------|---------|-------------|
| `useFetch<T>` | Data fetching | Cleanup on unmount |
| `useForm<T>` | Form handling | Auto error clearing |
| `useDebounce<T>` | Input debouncing | Configurable delay |

**Example: useFetch**:
```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    async function fetchData() {
      try {
        const response = await fetch(url);
        const result = await response.json();
        if (!cancelled) setData(result);
      } catch (err) {
        if (!cancelled) setError(err as Error);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }
    fetchData();
    return () => { cancelled = true; };
  }, [url]);

  return { data, loading, error };
}
```

### Performance Optimization

**useMemo vs useCallback**:

| Tool | Use Case | Example |
|------|----------|---------|
| `useMemo` | Expensive calculations | `useMemo(() => sort(items), [items])` |
| `useCallback` | Stable function refs | `useCallback((id) => update(id), [])` |

---

## API Design Patterns

### Versioning & Pagination

**URL Versioning**:
```typescript
app.use('/api/v1/users', usersRouterV1);
app.use('/api/v2/users', usersRouterV2);
```

**Cursor-based Pagination**:
```typescript
interface PaginatedResponse<T> {
  data: T[];
  meta: { totalCount: number; hasNextPage: boolean; cursor?: string };
}

async function getUsers(limit = 20, cursor?: string): Promise<PaginatedResponse<User>> {
  const users = await db.users.find(buildCursorQuery(cursor, limit)).limit(limit + 1);
  const hasNextPage = users.length > limit;
  const data = hasNextPage ? users.slice(0, -1) : users;

  return {
    data,
    meta: {
      totalCount: await db.users.countDocuments(),
      hasNextPage,
      cursor: hasNextPage ? encodeCursor(data[data.length - 1].id) : undefined
    }
  };
}
```

---

## Testing Patterns

### Integration Testing

**API Test Example**:
```typescript
describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'test@example.com', name: 'Test User' })
      .expect(201);

    expect(response.body).toMatchObject({
      data: { id: expect.any(String), email: 'test@example.com' }
    });
  });

  it('should return 400 with invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ email: 'invalid-email', name: 'Test User' })
      .expect(400);

    expect(response.body.error.code).toBe('VALIDATION_ERROR');
  });
});
```

### Test Doubles

**Dependency Injection Pattern**:
```typescript
class UserService {
  constructor(private emailService: EmailService) {}

  async welcomeUser(userId: string) {
    const user = await this.getUser(userId);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}

// Test with mock
it('should send welcome email', async () => {
  const mockEmailService = { sendWelcome: jest.fn().mockResolvedValue(undefined) };
  const service = new UserService(mockEmailService);

  await service.welcomeUser('user-123');

  expect(mockEmailService.sendWelcome).toHaveBeenCalledWith('user@example.com');
});
```

---

## Error Handling Patterns

**Structured Error Types**:
```typescript
class AppError extends Error {
  constructor(
    public code: string,
    message: string,
    public statusCode: number = 500,
    public isOperational: boolean = true
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message: string, public fields: Record<string, string>) {
    super('VALIDATION_ERROR', message, 400);
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super('NOT_FOUND', `${resource} not found: ${id}`, 404);
  }
}
```

---

## Performance Patterns

**Debouncing Hook**:
```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(handler);
  }, [value, delay]);

  return debouncedValue;
}

// Usage
function SearchInput() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) performSearch(debouncedQuery);
  }, [debouncedQuery]);

  return <input value={query} onChange={e => setQuery(e.target.value)} />;
}
```

---

## Code Review Checklist

### TypeScript
- [ ] No `any` types used
- [ ] All functions have return types
- [ ] Proper error handling with try-catch
- [ ] Immutability patterns (const, spread)
- [ ] Type guards for runtime validation

### React
- [ ] Functional components (no classes)
- [ ] Hooks rules followed
- [ ] Props interface defined
- [ ] No prop drilling (use context)
- [ ] Memoization used where needed

### API
- [ ] RESTful conventions
- [ ] Consistent response format
- [ ] Proper HTTP status codes
- [ ] Input validation
- [ ] Error responses

### Testing
- [ ] AAA pattern followed
- [ ] Descriptive test names
- [ ] Edge cases covered
- [ ] Mocking external deps
- [ ] Coverage ≥80%

---

## Related Documentation

- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md
- **TDD**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Claude Code Standards**: @.claude/skills/coding-standards/SKILL.md

---

**Version**: 1.0.1 (Reduced to ≤300 lines)
**Last Updated**: 2026-01-22

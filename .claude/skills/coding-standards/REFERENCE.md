# Coding Standards - Detailed Reference

> **Purpose**: Extended details and examples for coding standards
> **Main Skill**: @.claude/skills/coding-standards/SKILL.md
> **Last Updated**: 2026-01-20

---

## TypeScript Deep Dive

### Type System Best Practices

**Discriminated Unions for State**:
```typescript
// ✅ Good - Type-safe state handling
type AsyncState<T, E = Error> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: E };

function handleState<T>(state: AsyncState<T>) {
  switch (state.status) {
    case 'idle':
      return 'Not started';
    case 'loading':
      return 'Loading...';
    case 'success':
      return `Got ${state.data}`;
    case 'error':
      return `Error: ${state.error.message}`;
    default:
      return assertNever(state); // Exhaustiveness check
  }
}

// Helper for exhaustiveness checking
function assertNever(x: never): never {
  throw new Error(`Unexpected object: ${x}`);
}
```

**Utility Types**:
```typescript
// ✅ Good - Using built-in utility types
interface User {
  id: number;
  name: string;
  email: string;
  createdAt: Date;
}

// Make all properties optional
type PartialUser = Partial<User>;

// Make all properties required
type RequiredUser = Required<Partial<User>>;

// Pick specific properties
type UserSummary = Pick<User, 'id' | 'name'>;

// Omit specific properties
type CreateUserInput = Omit<User, 'id' | 'createdAt'>;

// Make properties readonly
type ReadonlyUser = Readonly<User>;
```

**Generic Constraints**:
```typescript
// ✅ Good - Constrained generics
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// ✅ Good - Multiple constraints
interface WithId {
  id: string;
}

function updateEntity<T extends WithId>(entity: T, updates: Partial<T>): T {
  return { ...entity, ...updates };
}
```

---

## React Advanced Patterns

### Custom Hooks Library

**Data fetching hook**:
```typescript
function useFetch<T>(url: string) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function fetchData() {
      try {
        setLoading(true);
        const response = await fetch(url);
        const result = await response.json();
        if (!cancelled) {
          setData(result);
        }
      } catch (err) {
        if (!cancelled) {
          setError(err as Error);
        }
      } finally {
        if (!cancelled) {
          setLoading(false);
        }
      }
    }

    fetchData();

    return () => {
      cancelled = true;
    };
  }, [url]);

  return { data, loading, error };
}
```

**Form handling hook**:
```typescript
function useForm<T extends Record<string, unknown>>(
  initialValues: T,
  onSubmit: (values: T) => void | Promise<void>
) {
  const [values, setValues] = useState<T>(initialValues);
  const [errors, setErrors] = useState<Partial<Record<keyof T, string>>>({});
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (name: keyof T) => (value: T[keyof T]) => {
    setValues(prev => ({ ...prev, [name]: value }));
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({ ...prev, [name]: undefined }));
    }
  };

  const handleSubmit = async (event: React.FormEvent) => {
    event.preventDefault();
    setSubmitting(true);
    try {
      await onSubmit(values);
    } finally {
      setSubmitting(false);
    }
  };

  return {
    values,
    errors,
    submitting,
    handleChange,
    handleSubmit
  };
}
```

### Performance Optimization

**useMemo for expensive calculations**:
```typescript
function ExpensiveList({ items }: { items: Item[] }) {
  const sortedItems = useMemo(() => {
    return [...items].sort((a, b) => a.value - b.value);
  }, [items]);

  const groupedItems = useMemo(() => {
    return sortedItems.reduce((groups, item) => {
      const category = item.category;
      return {
        ...groups,
        [category]: [...(groups[category] || []), item]
      };
    }, {} as Record<string, Item[]>);
  }, [sortedItems]);

  return <GroupedList groups={groupedItems} />;
}
```

**useCallback for stable references**:
```typescript
function ParentComponent() {
  const [data, setData] = useState<Data[]>([]);

  const handleUpdate = useCallback((id: string, updates: Partial<Data>) => {
    setData(prev => prev.map(item =>
      item.id === id ? { ...item, ...updates } : item
    ));
  }, []); // Empty deps = stable reference

  return (
    <>
      {data.map(item => (
        <ChildItem
          key={item.id}
          item={item}
          onUpdate={handleUpdate}
        />
      ))}
    </>
  );
}
```

---

## API Design Patterns

### Versioning Strategy

**URL versioning** (recommended):
```typescript
// v1 API
app.use('/api/v1/users', usersRouterV1);

// v2 API with breaking changes
app.use('/api/v2/users', usersRouterV2);
```

**Header versioning** (alternative):
```typescript
app.use('/api/users', (req, res, next) => {
  const version = req.headers['api-version'] || 'v1';
  req.apiVersion = version;
  next();
});
```

### Pagination

**Cursor-based pagination**:
```typescript
interface PaginatedResponse<T> {
  data: T[];
  meta: {
    totalCount: number;
    hasNextPage: boolean;
    cursor?: string;
  };
}

async function getUsers(
  limit: number = 20,
  cursor?: string
): Promise<PaginatedResponse<User>> {
  const query = buildCursorQuery(cursor, limit);
  const users = await db.users.find(query).limit(limit + 1); // Fetch one extra

  const hasNextPage = users.length > limit;
  const data = hasNextPage ? users.slice(0, -1) : users;
  const nextCursor = hasNextPage ? encodeCursor(data[data.length - 1].id) : undefined;

  return {
    data,
    meta: {
      totalCount: await db.users.countDocuments(),
      hasNextPage,
      cursor: nextCursor
    }
  };
}
```

---

## Testing Patterns

### Integration Testing

**API integration tests**:
```typescript
describe('POST /api/users', () => {
  it('should create user with valid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'test@example.com',
        name: 'Test User'
      })
      .expect(201);

    expect(response.body).toMatchObject({
      data: {
        id: expect.any(String),
        email: 'test@example.com',
        name: 'Test User'
      }
    });
  });

  it('should return 400 with invalid email', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'invalid-email',
        name: 'Test User'
      })
      .expect(400);

    expect(response.body).toMatchObject({
      error: {
        code: 'VALIDATION_ERROR',
        message: expect.stringContaining('email')
      }
    });
  });
});
```

### Test Doubles

**Mocking external dependencies**:
```typescript
// ✅ Good - Use dependency injection
class UserService {
  constructor(private emailService: EmailService) {}

  async welcomeUser(userId: string) {
    const user = await this.getUser(userId);
    await this.emailService.sendWelcome(user.email);
    return user;
  }
}

// Test with mock
describe('UserService', () => {
  it('should send welcome email', async () => {
    const mockEmailService = {
      sendWelcome: jest.fn().mockResolvedValue(undefined)
    };
    const service = new UserService(mockEmailService);

    await service.welcomeUser('user-123');

    expect(mockEmailService.sendWelcome).toHaveBeenCalledWith(
      'user@example.com'
    );
  });
});
```

---

## Error Handling Patterns

**Structured error types**:
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

// Usage
function getUser(id: string): Promise<User> {
  const user = await db.users.findById(id);
  if (!user) {
    throw new NotFoundError('User', id);
  }
  return user;
}
```

---

## Performance Patterns

**Debouncing user input**:
```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value);
    }, delay);

    return () => {
      clearTimeout(handler);
    };
  }, [value, delay]);

  return debouncedValue;
}

// Usage
function SearchInput() {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);

  useEffect(() => {
    if (debouncedQuery) {
      performSearch(debouncedQuery);
    }
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

**Version**: 1.0.0 (Coding Standards Reference)
**Last Updated**: 2026-01-20

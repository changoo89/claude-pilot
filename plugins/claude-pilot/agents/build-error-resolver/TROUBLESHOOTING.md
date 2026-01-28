# Build Error Resolver - Troubleshooting Guide

> **Companion to**: [build-error-resolver.md](./build-error-resolver.md)
> **Purpose**: Extended error catalog and resolution patterns

## Extended Error Catalog

### TypeScript Errors

#### Type Mismatches
```typescript
// Error: Type 'string' is not assignable to type 'number'
function process(value: string): number {
  return value; // Error
}

// Fix: Add type conversion
function process(value: string): number {
  return parseInt(value, 10);
}
```

#### Missing Imports
```typescript
// Error: Cannot find name 'Logger'
const result = Logger.info("message");

// Fix: Add import
import { Logger } from './logger';
const result = Logger.info("message");
```

#### Implicit Any
```typescript
// Error: Parameter 'data' implicitly has an 'any' type
function process(data) {
  return data.value;
}

// Fix: Add type annotation
function process(data: { value: string }) {
  return data.value;
}
```

#### Property Not Found
```typescript
// Error: Property 'user' does not exist on type 'Response'
const user = response.user;

// Fix: Use optional chaining or type assertion
const user = response?.user;
// OR
const user = (response as any).user;
```

### Python Errors

#### Import Errors
```python
# Error: ModuleNotFoundError: No module named 'utils'
logger = Logger()

# Fix: Add import
from utils import Logger
logger = Logger()
```

#### Type Annotation Issues
```python
# Error: Missing type annotation for 'data'
def process(data):
    return data.value

# Fix: Add type hints
def process(data: UserData) -> Result:
    return data.value
```

#### Syntax Errors
```python
# Error: invalid syntax
if True
    print("missing colon")

# Fix: Add colon
if True:
    print("has colon")
```

### Go Errors

#### Missing Imports
```go
// Error: undefined: log
log.Info("message")

// Fix: Add import
import "log"
log.Info("message")
```

#### Type Errors
```go
// Error: cannot use "string" as type int in assignment
var num int = "string"

// Fix: Use correct type
var num int = 42
```

#### Unused Variables
```go
// Error: x declared but not used
func process() {
  x := 10
}

// Fix: Use variable or remove
func process() {
  x := 10
  fmt.Println(x)
}
```

### Rust Errors

#### Borrow Checker Issues
```rust
// Error: cannot borrow as mutable more than once
let mut data = vec![1, 2, 3];
let first = &data[0];
data.push(4); // Error
println!("{}", first);

// Fix: Clone or restructure
let mut data = vec![1, 2, 3];
let first = data[0];
data.push(4);
println!("{}", first);
```

#### Type Mismatches
```rust
// Error: expected i32, found f32
let x: i32 = 3.14;

// Fix: Use correct type
let x: f32 = 3.14;
```

#### Missing Traits
```rust
// Error: doesn't implement std::fmt::Display
struct Point { x: i32, y: i32 }
println!("{}", Point { x: 0, y: 0 });

// Fix: Derive trait
#[derive(Debug)]
struct Point { x: i32, y: i32 }
println!("{:?}", Point { x: 0, y: 0 });
```

## Edge Cases and Complex Scenarios

### Circular Dependencies
**Problem**: Module A imports B, B imports A

**Detection**:
- Build fails with "dependency cycle detected"
- Runtime import errors

**Resolution**:
1. Extract shared code to module C
2. Use dependency injection
3. Restructure to break cycle

### Type Inference Failures
**Problem**: Compiler cannot infer complex types

**Detection**:
- "Type inference failed" errors
- "Cannot infer return type"

**Resolution**:
1. Add explicit type annotations
2. Break complex expressions into smaller steps
3. Use type assertions sparingly

### Macro Expansion Errors
**Problem**: Errors in generated code from macros

**Detection**:
- Error points to macro invocation
- Message mentions "macro expansion"

**Resolution**:
1. Check macro arguments
2. View expanded code (cargo expand or similar)
3. Fix macro definition or usage

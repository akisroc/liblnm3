# Platform Service Tests

## Test Structure

```
test/
├── platform/
│   ├── accounts_test.exs              # Accounts context tests
│   └── accounts/
│       └── session_test.exs           # Session tests
├── platform_web/
│   └── controllers/
│       ├── user_controller_test.exs   # Registration API tests
│       └── session_controller_test.exs # Authentication API tests
└── support/
    ├── fixtures.ex                     # Test data helpers
    ├── conn_case.ex                    # Base for controller tests
    └── data_case.ex                    # Base for database tests
```

## Running Tests

```bash
# Run all tests
mix test

# Run a specific file
mix test test/platform/accounts_test.exs

# Run a specific test
mix test test/platform/accounts_test.exs:15

# Run with coverage
mix test --cover
```

## Configuration

Test database is configured in `config/test.exs`:
- Database: `lnm3_platform_test`
- User: `user` / Password: `pass`
- Uses SQL Sandbox for test isolation

## Available Tests

### Accounts Context (`test/platform/accounts_test.exs`)
- ✅ User registration
- ✅ Field validation (email, password, username)
- ✅ Uniqueness (email, username, slug)
- ✅ Password hashing
- ✅ Authentication
- ✅ Disabled/removed user handling

### Sessions (`test/platform/accounts/session_test.exs`)
- ✅ Token generation
- ✅ Token hashing in DB
- ✅ Session expiration
- ✅ User retrieval by token
- ✅ Expired session cleanup

### User Controller (`test/platform_web/controllers/user_controller_test.exs`)
- ✅ POST /api/register with valid data
- ✅ Validation errors
- ✅ Duplicate email/username handling
- ✅ Password hashing verification

### Session Controller (`test/platform_web/controllers/session_controller_test.exs`)
- ✅ POST /api/login with valid credentials
- ✅ Invalid credentials errors
- ✅ Cookie configuration (httpOnly, secure, max_age)
- ✅ Session creation in DB
- ✅ Token hashing in DB

## Fixtures

Use `Platform.Fixtures` to create test data:

```elixir
import Platform.Fixtures

# Create user with default attributes
user = user_fixture()

# Create user with custom attributes
user = user_fixture(%{
  email: "custom@example.com",
  password: "custompass123"
})

# Get valid attributes map
attrs = valid_user_attributes(%{username: "myuser"})
```

## Best Practices

1. **Isolation**: Each test must be independent (uses SQL Sandbox)
2. **Async**: Use `async: true` when possible for parallelization
3. **Fixtures**: Use fixtures to create test data
4. **Clear descriptions**: Name tests clearly with `test "description"`

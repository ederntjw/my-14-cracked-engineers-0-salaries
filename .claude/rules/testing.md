---
description: "Testing requirements: 80% coverage, TDD workflow, unit/integration/E2E testing"
---
# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (framework chosen per language)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "This is too simple to need tests" | Simple code called in complex contexts breaks. The test takes 30 seconds to write. The debugging takes 30 minutes. |
| "I'll write the tests after the implementation" | Then you're not doing TDD — you're writing tests to confirm your assumptions, not to challenge them. Tests-first catches design problems that tests-after misses. |
| "We're just prototyping, tests can wait" | Prototypes become production code. The tests you skip now become the bugs your users find later. |
| "The types are strict enough, we don't need tests" | Types check structure, not behavior. A function can return the right type with the wrong value. Types + tests, not types instead of tests. |
| "Adding tests will slow us down" | Tests slow you down for 5 minutes now. No tests slow you down for 5 hours later when you're debugging a regression you can't reproduce. |

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first

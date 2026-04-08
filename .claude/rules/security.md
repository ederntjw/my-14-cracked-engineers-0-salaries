---
description: "Security rules: no hardcoded secrets, input validation, parameterized queries, HTTPS"
---
# Security Guidelines

## Mandatory Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (sanitized HTML)
- [ ] CSRF protection enabled
- [ ] Authentication/authorization verified
- [ ] Rate limiting on all endpoints
- [ ] Error messages don't leak sensitive data

## Secret Management

- NEVER hardcode secrets in source code
- ALWAYS use environment variables or a secret manager
- Validate that required secrets are present at startup
- Rotate any secrets that may have been exposed

## Common Rationalizations (DO NOT fall for these)

| Excuse | Reality |
|--------|---------|
| "This is an internal tool, security doesn't matter" | Internal tools get exposed. Attackers target the weakest link. Internal doesn't mean safe. |
| "We'll add security later" | Security retrofitted onto existing code is 10x more expensive and 10x less effective than security built in from the start. Later never comes. |
| "It's just a prototype" | Prototypes become production. That hardcoded API key in your prototype will end up in git history forever. |
| "Nobody will find this endpoint" | Security through obscurity is not security. Automated scanners will find it in hours. |
| "The framework handles security for us" | Frameworks provide tools, not guarantees. A framework can't know if you're passing user input to a shell command. You still have to write secure code. |

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use **security-reviewer** agent
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review entire codebase for similar issues

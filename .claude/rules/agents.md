---
description: "Agent orchestration: available agents, automatic invocation, parallel execution"
---
# Agent Orchestration — Engineering Team

## Available Agents

Located in `agents/` in the project root:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **strategist** | Translate business context into phased build plans | Starting new projects, new requirements from stakeholders |
| **planner** | Break features into buildable steps | "I want to add [feature]", "Plan this out" |
| **architect** | Design system structure and data flow | "How should I structure this?", architectural decisions |
| **data-engineer** | Build data connectors, entity resolution, pipeline work | Pipeline work, new data sources, Supabase schema |
| **tdd-guide** | Write tests before code | New features, bug fixes, any implementation |
| **code-reviewer** | Review code for quality and bugs | After writing code, before commits |
| **security-reviewer** | Find security holes | Before deploys, when touching auth/API/data |
| **build-fixer** | Fix TypeScript and build errors | Build failing, red terminal output |
| **e2e-runner** | Run Playwright browser tests | Testing user flows end-to-end |
| **ui-builder** | Build responsive interfaces | Frontend work, landing pages, dashboards |
| **codebase-auditor** | Audit existing code quality | Onboarding to existing code, periodic health checks |
| **refactor-cleaner** | Remove dead code, fix duplicates | Code maintenance, cleanup |
| **doc-updater** | Keep docs in sync with code | After API or schema changes |
| **database-reviewer** | Optimize PostgreSQL/Supabase queries | Slow queries, schema review |

## Automatic Agent Invocation

Invoke the right agent automatically:
1. Complex feature requests → **planner** then **architect**
2. Code just written/modified → **code-reviewer**
3. Bug fix or new feature → **tdd-guide**
4. Build errors → **build-fixer**
5. New documents in context/ → **strategist**
6. Pipeline/data work → **data-engineer**

## Parallel Execution

Use parallel agents for independent operations:
- Security analysis + code review + type checking = 3 agents in parallel
- Never run sequentially when tasks are independent

## Teaching Mode

Every agent explains what it did and why in plain English. This is not optional.

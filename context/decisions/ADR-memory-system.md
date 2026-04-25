# ADR: Cross-Session Memory and Codebase Knowledge Graph

## Status
Accepted

## Date
2026-04-09

## Context

The engineering team loses all institutional knowledge between sessions. Every new session starts with a blank slate, reading only STATUS.md and ACTION-ITEMS.md for context. This creates three problems:

1. **Repeated decisions** — the team suggests approaches that were already tried and rejected in prior sessions, wasting time and frustrating the user.
2. **Blind codebase exploration** — every session spends 10-15 minutes grepping and reading files to understand the architecture, even when the codebase hasn't changed.
3. **Lost preferences** — user preferences, stakeholder constraints, and informal decisions that don't warrant formal ADRs are forgotten between sessions.

For projects lasting weeks or months, these costs compound significantly.

## Decision

Integrate two complementary systems:

1. **MemPalace** (institutional memory) — stores decisions, preferences, discoveries, rejected approaches, and stakeholder constraints across sessions. Uses ChromaDB for vector search with metadata-based filtering organized as wings (projects) and rooms (topics). Memory persistence is explicit: agents call `mempalace_add_drawer` and `mempalace_kg_add` during `/update` (or whenever the user says "save this"). The session-stop hook flags whether `/update` ran so the next session can warn the user if memory wasn't saved.

2. **Graphify** (codebase knowledge graph) — maps module relationships, god nodes (core abstractions), and communities (domain clusters) using a two-pass extraction system: free AST parsing via tree-sitter + optional semantic extraction via Claude. Auto-rebuilds AST on every git commit. Agents consult the graph before exploring files.

Neither tool is a hard dependency. The team works without them — they are upgrades that compound in value over time.

## Alternatives Considered

### Alternative 1: Expand STATUS.md and ADRs only
- **Pros:** No external dependencies. Already in place.
- **Cons:** STATUS.md is a summary, not searchable knowledge. ADRs are formal and don't capture informal decisions. No semantic search. No codebase structure mapping.
- **Why not:** Doesn't solve the repeated-decisions or blind-exploration problems.

### Alternative 2: MemPalace only (no Graphify)
- **Pros:** Simpler setup. Solves the institutional memory problem.
- **Cons:** Doesn't solve blind codebase exploration. Agents still grep around to understand architecture.
- **Why not:** Solves half the problem. Both tools are cheap to run and complementary.

### Alternative 3: Graphify only (no MemPalace)
- **Pros:** Solves architecture awareness. Lower risk (fewer open bugs).
- **Cons:** Doesn't capture decisions, preferences, or stakeholder context.
- **Why not:** The most expensive context loss is human context (why decisions were made), not code context. Need both.

### Alternative 4: Karpathy-style LLM Knowledge Base
- **Pros:** Rich, wiki-style knowledge compilation.
- **Cons:** Designed for personal knowledge management, not AI agent memory. Requires Obsidian. Doesn't integrate with Claude Code. Solves a different problem (organizing articles/papers for humans).
- **Why not:** Wrong use case. Better suited for a personal AI assistant, not an engineering team.

## Consequences

### Positive
- New sessions start with full architectural awareness and institutional memory
- Decisions, preferences, and constraints survive across sessions
- Agents navigate by graph structure instead of blind exploration
- User never re-explains something they told the team before
- Value compounds over time — by session 20, the team has deep project knowledge

### Negative
- Two pip dependencies (Python 3.9+, graphifyy, mempalace)
- Session-start token overhead (~3-5K tokens for MemPalace L0+L1 + graph status)
- MemPalace has known scaling issues above ~10K documents (HNSW index bloat)
- MemPalace has a system prompt corruption bug (#333) that requires clean MCP queries
- Both tools are young projects — may encounter bugs
- First-run Graphify semantic extraction costs tokens (subsequent runs cached)

### What this means in plain English
> Think of it this way: before this change, every time you started a new conversation with the team, it was like they had amnesia. They could read their notes (STATUS.md), but they didn't remember the conversations, your preferences, or the layout of the building. Now they have both a memory (MemPalace) and a map (Graphify). They remember what you told them last month and they know where everything is in the codebase. The tradeoff is two extra tools to install and a small amount of overhead at the start of each session.

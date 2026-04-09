# Graph-First Navigation

## The Rule

When a knowledge graph exists (`graphify-out/graph.json`), consult it BEFORE grepping or globbing through the codebase. The graph tells you how modules connect, where the core abstractions live, and which components are central. This saves time and prevents the blind exploration that wastes the first 10-15 minutes of every session.

## How to Use the Graph

### Step 1: Read GRAPH_REPORT.md

At the start of any session where code work is planned, read `graphify-out/GRAPH_REPORT.md`. This gives you:
- **God nodes** — the most-connected entities (core abstractions everything depends on)
- **Communities** — clusters of related code (auth, dashboard, billing, etc.)
- **Surprising connections** — non-obvious relationships worth knowing about
- **Cohesion scores** — which communities are well-organized vs tangled

### Step 2: Use MCP Tools for Targeted Queries

| You want to know... | Use this tool | Example |
|---|---|---|
| What connects to a module | `get_neighbors` | "What depends on AuthMiddleware?" |
| How two things are related | `shortest_path` | "How does UserModel connect to BillingService?" |
| What's in a domain area | `get_community` | "Show me everything in the auth community" |
| The most important abstractions | `god_nodes` | "What are the core abstractions?" |
| General architecture question | `query_graph` | "What connects the API layer to the database?" |
| Stats about the codebase | `graph_stats` | "How big is the codebase? How many communities?" |

### Step 3: Then Do Targeted File Reads

After the graph tells you WHERE to look, use Read to look at the specific files. This is the opposite of the old approach (read everything until you understand).

**Old approach:** Glob → Grep → Read → Read → Read → slowly build understanding
**Graph approach:** GRAPH_REPORT.md → get_neighbors → Read specific files → ready to work

## When the Graph Is Stale

The AST layer auto-rebuilds on every git commit (via the post-commit hook). But the semantic layer (doc/image analysis) only rebuilds manually.

**Stale signals:**
- GRAPH_REPORT.md modification date is more than a week old
- Major new files exist that aren't in the graph
- The user says "we restructured the codebase"

**When stale:** Fall back to normal exploration for the affected area, then suggest rebuilding the graph (`graphify $PROJECT_DIR`).

## When NOT to Use the Graph

- The codebase has fewer than 10 files (just read them)
- You're making a single-file change and already know the file
- The graph hasn't been built yet
- You're doing non-code work (docs, planning, brainstorming)

## Blast Radius Assessment

Before any multi-file change, use `get_neighbors` on the primary module being changed. This shows:
- What imports it
- What it imports
- What calls its functions
- What shares data with it

If the change affects a **god node**, it's high-risk — changes ripple through many modules. Flag this in the plan and get explicit approval.

## Teaching Moment

> A knowledge graph is like a map of a city. Without it, you have to walk every street to understand the layout. With it, you can see which roads are main arteries (god nodes), which neighborhoods exist (communities), and how to get from one place to another (shortest paths). The graph doesn't replace reading the code — it tells you WHICH code to read first.

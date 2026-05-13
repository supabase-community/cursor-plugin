# Supabase Plugin for Cursor

The Supabase plugin for [Cursor](https://cursor.com) gives Cursor's AI agent the tools and skills needed to work effectively with Supabase projects.

## What's Included

- **MCP Server** — Remote HTTP connection to the [Supabase MCP server](https://supabase.com/mcp) for project management, SQL execution, migrations, database advisors, and more.
- **Skills** — Agent skills sourced from [supabase/agent-skills](https://github.com/supabase/agent-skills):
  - `supabase` — Core Supabase skill covering Auth, Database, Edge Functions, Realtime, Storage, Vectors, CLI usage, MCP troubleshooting, security best practices, and schema migration workflows.
  - `supabase-postgres-best-practices` — Comprehensive Postgres performance guide with rules across 8 categories (query performance, connection management, security & RLS, schema design, locking, data access patterns, monitoring, and advanced features).

## Prerequisites

- [Cursor](https://cursor.com) editor installed
- A [Supabase](https://supabase.com) account and project
- Git (for cloning and submodule initialization)

## Installation

<!-- TODO: Add Cursor install command when the plugin registry is available -->

### Manual Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/supabase-community/cursor-plugin.git
   ```

2. Initialize the agent-skills submodule:

   ```bash
   cd cursor-plugin
   git submodule update --init --recursive
   ```

3. Verify the `skills/` symlink resolves correctly:

   ```bash
   ls skills/
   # Expected: supabase  supabase-postgres-best-practices
   ```

## Configuration

### MCP Server

The plugin connects to the Supabase MCP server via the config in `mcp.json`:

```json
{
  "supabase": {
    "type": "http",
    "url": "https://mcp.supabase.com/mcp",
    "headers": {
      "X-Source-Name": "cursor-plugin",
      "X-Source-Version": "0.1.7"
    }
  }
}
```

The MCP server uses OAuth 2.1 for authentication. When prompted by Cursor, complete the auth flow in your browser to connect to your Supabase account.

**Troubleshooting connection issues:**

1. Check server reachability:
   ```bash
   curl -so /dev/null -w "%{http_code}" https://mcp.supabase.com/mcp
   # 401 = server is up (expected without a token)
   ```
2. Verify `.mcp.json` exists in your project root with the correct server URL.
3. If tools aren't visible after auth, reload your Cursor session.

For full MCP setup details, see the [Supabase MCP guide](https://supabase.com/docs/guides/getting-started/mcp).

## Usage

Once installed, Cursor's agent automatically uses the plugin when you work on Supabase-related tasks.

### MCP Tools

The MCP server gives the agent access to tools such as:

- **`execute_sql`** — Run SQL queries directly against your Supabase database
- **`apply_migration`** — Apply migration files to your project
- **`search_docs`** — Search the Supabase documentation
- **`get_advisors`** — Run database performance and security advisors

### Agent Skills

Skills are activated automatically based on context. For example:

- Ask the agent to "set up RLS on my users table" → triggers the `supabase` skill with security checklist guidance.
- Ask "optimize this slow query" → triggers `supabase-postgres-best-practices` with index and query plan recommendations.
- Ask about Auth, Edge Functions, Storage, or Realtime → the `supabase` skill provides current best practices and warns against common pitfalls.

### Skill Feedback

If the agent gives incorrect or outdated guidance, you can submit feedback directly. The agent will draft a GitHub issue on [supabase/agent-skills](https://github.com/supabase/agent-skills/issues/new) for the maintainers.

## Project Structure

```
cursor-plugin/
├── .cursor-plugin/
│   └── plugin.json            # Plugin manifest (name, version, metadata)
├── mcp.json                   # MCP server configuration
├── skills/                    # Symlink → submodules/agent-skills/skills
│   ├── supabase/              # Core Supabase agent skill
│   └── supabase-postgres-best-practices/  # Postgres optimization rules
├── submodules/
│   └── agent-skills/          # Git submodule (supabase/agent-skills)
├── .github/
│   └── workflows/
│       └── release-please.yml # Automated release pipeline
├── release-please-config.json # Release Please versioning config
└── README.md
```

## Development

This repo uses a git submodule for shared agent skills.

After cloning, initialize the submodule:

```bash
git submodule update --init --recursive
```

To update the submodule to the latest upstream version:

```bash
git submodule update --remote submodules/agent-skills
git add submodules/agent-skills
git commit -m "chore: update agent-skills submodule"
```

### Building the Plugin Archive

To build the release archive locally (replicates the CI release step):

```bash
tar -czvf supabase-cursor-plugin.tar.gz \
  --dereference \
  .cursor-plugin/plugin.json \
  mcp.json \
  skills/
```

The `--dereference` flag resolves the `skills/` symlink so the archive contains the actual skill files.

## Releasing

This repo uses [Release Please](https://github.com/googleapis/release-please) for automated releases.

1. Merge commits with `feat:` or `fix:` prefixes to trigger a release (see [How should I write my commits?](https://github.com/googleapis/release-please#how-should-i-write-my-commits)).
2. Release Please opens a "Release PR" with a version bump and changelog update.
3. Merge the Release PR to publish.
4. `supabase-cursor-plugin.tar.gz` is uploaded to the GitHub release.

Version is bumped in both `.cursor-plugin/plugin.json` and `mcp.json` automatically. Release Please is configured to only bump patch versions (0.1.x) until the project is more stable.

## License

[MIT](LICENSE)

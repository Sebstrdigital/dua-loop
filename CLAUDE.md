# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is dua-loop?

dua-loop is an autonomous AI agent loop that implements features from a PRD (Product Requirements Document) without human intervention between iterations. Based on [Geoffrey Huntley's Ralph Wiggum pattern](https://ghuntley.com/ralph/).

Each iteration spawns a **fresh Claude Code instance** with clean context. Memory persists via:
- **Git history** - commits from previous iterations
- **prd.json** - tracks which stories are `passes: true/false`
- **progress.txt** - append-only log of learnings between iterations

## Commands

```bash
# Install globally (one-time, from dua-loop repo)
./install.sh

# Initialize a project (from project directory)
dualoop init

# Run autonomous loop (default: auto-calculated iterations)
dualoop [max_iterations]

# Check story status
cat prd.json | jq '.userStories[] | {id, title, passes}'

# View progress log
cat progress.txt
```

## Architecture

### Core Loop (`bin/dualoop.sh`)
1. Reads `prd.json` for next incomplete story (lowest priority where `passes: false`)
2. Spawns Claude Code with agent instructions from `~/.claude/lib/dualoop/prompt.md`
3. Detects model and verify mode from story's `model` and `verify` fields
4. On completion signal (`<promise>COMPLETE</promise>`), runs deep verification for stories with `verify: deep`
5. Archives completed PRDs to `archive/YYYY-MM-DD-feature-name/`

### Key Files (source -> installed)
- `bin/dualoop.sh` -> `~/.claude/lib/dualoop/dualoop.sh` - Main loop script
- `lib/prompt.md` -> `~/.claude/lib/dualoop/prompt.md` - Agent instructions
- `agents/verifier.md` -> `~/.claude/lib/dualoop/verifier.md` - Deep verification agent
- `commands/*.md` -> `~/.claude/commands/` - Slash commands

### Slash Commands
- `/dua-prd` - Generate PRDs from feature descriptions
- `/dua` - Convert PRDs to `prd.json` format
- `/tdd` - Test-Driven Development workflow

### Story Fields in prd.json
- `model`: `"sonnet"` (default) or `"opus"` (for complex multi-file work)
- `verify`: `"inline"` (self-verified) or `"deep"` (independent verification agent)
- `passes`: `false` -> `true` when story complete

## dua-loop Agent Rules

When running as a dua-loop agent (via `dualoop`):

1. **ONE story per iteration** - Never continue to next story
2. **TDD required** - Write failing tests first, then minimal code to pass
3. **Goal-backward verification** - Verify OUTCOMES, not just code existence
4. **Browser verification** for UI stories - Use Chrome integration
5. **Append to progress.txt** - Include learnings for future iterations
6. **Keep stories small** - Must fit in one context window (no auto-handoff)

## Story Sizing Guidelines

Stories must complete in ONE iteration:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic

Too big (split these):
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

## Running Tests

```bash
bats tests/
```

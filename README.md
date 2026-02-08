# dua-loop

An autonomous AI agent loop that runs [Claude Code](https://claude.com/claude-code) repeatedly until all PRD items are complete. Each iteration is a fresh Claude Code instance with clean context.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

## Installation

```bash
git clone https://github.com/duadigital/dua-loop.git
cd dua-loop && ./install.sh
```

Everything installs into `~/.claude/`. The repo can be deleted after install.

## Updating

```bash
cd dua-loop && git pull && ./install.sh
```

## What Gets Installed

```
~/.claude/
├── lib/dualoop/
│   ├── dualoop.sh              # Loop script
│   ├── prompt.md               # Agent instructions
│   └── verifier.md             # Deep verification agent
├── commands/
│   ├── dua.md                  # /dua — convert PRD to prd.json
│   ├── dua-prd.md              # /dua-prd — generate PRD
│   └── tdd.md                  # /tdd — TDD workflow
└── CLAUDE.md                   # dua-loop section appended
```

## Usage

1. Open Claude Code in your project
2. Discuss and plan the feature with Claude
3. Say "Create the PRD" -- Claude uses `/dua-prd` to generate `tasks/prd-feature.md`
4. Say "Convert to prd.json" -- Claude uses `/dua` to create `prd.json` with stories
5. Say "Start the loop" -- Claude runs `dualoop` autonomously

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│                           PLANNING PHASE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  You + Claude: Discuss feature, analyze codebase, plan architecture │
│                                                                      │
│  You: "Create the PRD"                                              │
│       ↓                                                              │
│  Claude: Creates tasks/prd-feature-name.md                          │
│       ↓                                                              │
│  ⏸️ "Convert to prd.json?" ──────────────────────── Review PRD       │
│       ↓ Yes                                                          │
│  Claude: Creates prd.json (includes branchName: dua/feature-name)   │
│       ↓                                                              │
│  ⏸️ "Start the loop?" ───────────────────────────── Review stories   │
│       ↓ Yes                                                          │
└───────┼─────────────────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      AUTONOMOUS LOOP                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ CREATE BRANCH: dua/feature-name (once, from prd.json)          │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                              │                                       │
│                              ▼                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    STORY ITERATION                              │ │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐           │ │
│  │  │ Pick next   │──▶│ Implement   │──▶│ Run checks  │           │ │
│  │  │ story from  │   │ with TDD    │   │ (typecheck, │           │ │
│  │  │ prd.json    │   │             │   │ lint, test) │           │ │
│  │  └─────────────┘   └─────────────┘   └──────┬──────┘           │ │
│  │                                             │                   │ │
│  │                                             ▼                   │ │
│  │  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐           │ │
│  │  │ Log to      │◀──│ Mark story  │◀──│ Commit      │           │ │
│  │  │ progress.txt│   │ passes:true │   │ changes     │           │ │
│  │  └──────┬──────┘   └─────────────┘   └─────────────┘           │ │
│  │         │                                                       │ │
│  │         ▼                                                       │ │
│  │  ┌─────────────┐  Yes                                          │ │
│  │  │More stories?│────────────────────────────────────┐          │ │
│  │  │passes:false │                                    │          │ │
│  │  └──────┬──────┘                                    │          │ │
│  │         │ No                                   Back to Pick     │ │
│  └─────────┼──────────────────────────────────────────┼───────────┘ │
│            │                                          │             │
│            ▼                                          │             │
│  ┌─────────────────┐                                  │             │
│  │ Deep verify?    │ (for stories with verify: deep)  │             │
│  │ Run verifier    │                                  │             │
│  │ agent           │                                  │             │
│  └────────┬────────┘                                  │             │
│           │                                           │             │
│           ▼                                           │             │
│  ┌─────────────────┐  No                              │             │
│  │ All verified?   │──────────────────────────────────┘             │
│  └────────┬────────┘  (mark failed stories passes:false)            │
│           │ Yes                                                      │
│           ▼                                                          │
│  ┌─────────────────┐                                                │
│  │ Archive PRD     │──▶ tasks/archive/YYYY-MM-DD-feature/           │
│  └────────┬────────┘                                                │
│           │                                                          │
└───────────┼──────────────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────────────┐
│  ⏸️ COMPLETE - What would you like to do?                            │
│                                                                      │
│     1) Merge to main                                                │
│     2) Create Pull Request                                          │
│     3) Stay on branch                                               │
└─────────────────────────────────────────────────────────────────────┘
```

## Per-Project Files

When dua-loop initializes a project, it creates:

```
my-project/
├── prd.json           # Active user stories
├── progress.txt       # Iteration learnings
└── tasks/
    └── archive/       # Completed PRDs
```

## Prerequisites

- [Claude Code CLI](https://claude.com/claude-code) installed and authenticated
- `jq` installed (`brew install jq` on macOS)
- A git repository for your project

## References

- [Geoffrey Huntley's Ralph article](https://ghuntley.com/ralph/)
- [Claude Code documentation](https://claude.com/claude-code)

## License

[MIT](LICENSE)

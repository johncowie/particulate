# Particulate

A Claude Code plugin providing skills for managing a structured Obsidian learning vault.

## Skills

| Skill | Description |
|---|---|
| `/create-course` | Create a new learning course (top-level subject area) |

## Vault Structure

These skills are designed for an Obsidian vault with this layout:

```
<vault-root>/
├── _index/
│   └── Home.md          ← master index (used to locate the vault)
└── <course-name>/
    ├── README.md         ← course overview
    └── <module-name>/
        ├── README.md     ← module overview
        └── <note>.md     ← concept notes
```

The vault root is discovered automatically by searching for a directory containing `_index/Home.md`. It does not need to be named anything specific.

## Development

### Prerequisites

Install [mise](https://mise.jdx.dev/) then run:

```
mise install
```

### Tasks

| Command | Description |
|---|---|
| `mise run test` | Run all test suites |
| `mise run test:unit` | Run unit tests only |
| `mise run scripts:check` | Lint and format-check shell scripts |
| `mise run scripts:format` | Auto-format shell scripts |
| `mise run version -- patch\|minor\|major` | Bump version |

## Installation

```
/plugin marketplace add johncowie/particulate
```

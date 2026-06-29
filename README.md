# Particulate

A Claude Code plugin providing skills for managing a structured Obsidian learning vault.

## Skills

| Skill | Description |
|---|---|
| `/create-course` | Create a new learning course (top-level subject area) |
| `/add-note` | Add a concept note to a module, teach it, and quiz the user |
| `/quiz` | Quiz the user on a note, module, or entire course |

## Vault Structure

These skills are designed for an Obsidian vault with this layout:

```
<vault-root>/
├── README.md            ← master index (type: index in frontmatter)
└── <course-name>/
    ├── README.md         ← course overview
    └── <module-name>/
        ├── README.md     ← module overview
        └── <note>.md     ← concept notes
```

The vault root is discovered automatically by searching for a directory whose `README.md` has `type: index` in its frontmatter. It does not need to be named anything specific.

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

Add the marketplace and install the plugin:

```
/plugin marketplace add johncowie/particulate
/plugin install particulate@johncowie
```

Verify it's installed:

```
/plugin list
```

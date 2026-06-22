# Particulate

A Claude Code plugin providing skills for managing a structured Obsidian learning vault.

## Skills

| Skill | Description |
|---|---|
| `/create-course` | Create a new learning course (top-level subject area) |

## Vault Structure

These skills are designed for an Obsidian vault with this layout:

```
ai-learning/
├── _index/
│   └── Home.md          ← master index
└── <track-name>/
    ├── README.md         ← track overview
    └── <module-name>/
        ├── README.md     ← module overview
        └── <note>.md     ← concept notes
```

## Installation

```
/plugin marketplace add johncowie/particulate
```

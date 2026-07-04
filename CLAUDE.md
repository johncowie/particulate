# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

Particulate is a Claude Code plugin (`.claude-plugin/plugin.json`) providing
skills for managing a structured Obsidian learning vault: creating courses,
adding notes, and quizzing on material. The repo itself is the plugin source
— it doesn't contain a vault. Skills operate on a separate Obsidian vault
that the user points them at (discovered by finding a `README.md` with
`type: index` in its frontmatter).

## Layout

- `skills/<name>/SKILL.md` — the three skills: `create-course`, `add-note`,
  `quiz`. Each SKILL.md has YAML frontmatter (`name`, `description`,
  `argument-hint`, `arguments`, `allow-tools`/`allowed-tools`) followed by
  numbered step-by-step instructions the agent executes when the skill runs.
- `scripts/` — helper scripts used by skills and CI:
  - `shuffle-order.sh` — used by `/quiz` to shuffle multiple-choice option
    order without leaking the correct answer's position to the model.
  - `bump-version.py` — bumps the version in `.claude-plugin/plugin.json`
    (patch/minor/major/get).
  - `test.sh` — runs all test suites.
- `tests/unit/test-skill-frontmatter.sh` — validates every `SKILL.md` has
  required frontmatter fields (`name`, `description`).
- `.claude-plugin/plugin.json` — plugin manifest (name, version, metadata).
- `.claude-plugin/marketplace.json` — marketplace listing for installation.

## Vault structure the skills assume

```
<vault-root>/
├── README.md            ← master index (frontmatter: type: index)
└── <course-name>/
    ├── README.md         ← course overview (type: track)
    └── <NN-module-name>/
        ├── README.md     ← module overview (type: module)
        └── <NN Note Title>.md
```

Notes use `- [ ]` / `- [x]` checkboxes in course/module READMEs to track
progress, and Obsidian wikilinks (`[[NN Note Title|Note Title]]`) to link
between notes.

## Development

Uses [mise](https://mise.jdx.dev/) for tooling (Python, shellcheck, shfmt).

| Command | Description |
|---|---|
| `mise run test` | Run all test suites |
| `mise run test:unit` | Run unit tests only (skill frontmatter checks) |
| `mise run scripts:check` | shellcheck + shfmt diff-check on scripts |
| `mise run scripts:format` | Auto-format shell scripts with shfmt |
| `mise run version -- patch\|minor\|major` | Bump plugin version |

Shell scripts are formatted with `shfmt -i 2` (2-space indent) and must pass
`shellcheck`.

## Editing skills

When modifying a `SKILL.md`:
- Keep frontmatter's `name`/`description` present — `test-skill-frontmatter.sh`
  enforces this and will fail CI otherwise.
- Steps are written as instructions to the agent executing the skill, not as
  code — keep this style (numbered sections, imperative voice) consistent
  with the existing three skills.
- `quiz`'s `allowed-tools` restricts `Bash` to specific invocations
  (`shuffle-order.sh` and `date`) — mirror this scoping style if a skill
  needs shell access, rather than granting unrestricted `Bash`.

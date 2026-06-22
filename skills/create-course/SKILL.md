---
name: create-course
description: Create a new learning course in the Obsidian vault, including the full module structure and note outlines. Use when starting a new broad subject area (e.g. aws, machine-learning, physics).
argument-hint: <course-name> [Course Title]
arguments: [course_name, course_title]
allow-tools: Read Write Edit Bash
---

# Create Learning Course

Create a new learning course for "$course_name" in the Obsidian vault.

## Steps

### 1. Locate the vault root

Look for a directory containing a `README.md` with `type: index` in its frontmatter — that is the vault root. Search the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Validate the course name

The course name "$course_name" should be lowercase and hyphen-separated (e.g. `machine-learning`, `aws`, `physics`). If it isn't, convert it automatically and confirm with the user.

### 3. Check for duplicates

If `<vault-root>/$course_name/` already exists, tell the user and stop — don't overwrite it.

### 4. Determine the display title

If "$course_title" was provided, use it. Otherwise derive a title from "$course_name" by converting hyphens to spaces and title-casing each word (e.g. `machine-learning` → `Machine Learning`).

### 5. Plan the course structure with the user

Propose a set of modules for this course — ordered from foundational to advanced. For each module, propose an ordered list of notes (individual concepts) it will cover.

Present the proposed structure clearly, for example:

```
01-core-concepts/
  01 What Is X.md
  02 Key Terminology.md
  03 How It Works.md
02-advanced-topics/
  01 Topic A.md
  02 Topic B.md
```

Ask the user to confirm, adjust, or expand the structure before creating any files. This is the most important step — don't proceed until the structure is agreed.

### 6. Create the course README

Create `<vault-root>/$course_name/README.md`:

```markdown
---
title: "<derived title>"
type: track
tags: [$course_name]
---

# <derived title>

## Modules

- [[01-<module-name>/README|<Module Title>]]
- [[02-<module-name>/README|<Module Title>]]
...
```

### 7. Create each module directory and README

For each module, create `<vault-root>/$course_name/<NN>-<module-name>/README.md` where `NN` is a zero-padded two-digit number (01, 02, …).

Module folder names: zero-padded number + lowercase hyphen-separated name (e.g. `01-core-concepts`).

Each module README:

```markdown
---
title: "<Module Title>"
track: $course_name
type: module
tags: [$course_name, <module-name>]
---

# <Module Title>

## Notes

- [ ] [[NN <Note Title>|<Note Title>]]
- [ ] [[NN <Note Title>|<Note Title>]]
...
```

Note filenames in the index: zero-padded two-digit number + Title Case with spaces (e.g. `01 Gradient Descent`). Wikilinks must include the number but use an alias to hide it: `[[01 Gradient Descent|Gradient Descent]]`. Each note entry gets an unchecked checkbox (`- [ ]`) so progress is visible at a glance — `/add-note` checks the box once the note is written.

Do **not** create the individual note `.md` files — those are created later by `/add-note`.

### 8. Update the vault index

Read `<vault-root>/README.md`. Add a wikilink to the new course under the tracks/courses list:

```
- [[$course_name/README|<derived title>]] — <one-line description>
```

### 9. Confirm completion

Tell the user what was created: the course directory, how many modules, and the total number of notes planned. Remind them they can run `/add-note` to start filling in the first note.

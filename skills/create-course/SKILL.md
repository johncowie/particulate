---
name: create-course
description: Create a new learning course in the Obsidian vault, including the full module structure and note outlines. Use when starting a new broad subject area (e.g. aws, machine-learning, physics).
argument-hint: <course-name> [Course Title or description]
arguments: [course_name, course_title]
allow-tools: Read Write Edit Bash WebSearch WebFetch
---

# Create Learning Course

Create a new learning course for "$course_name" in the Obsidian vault.

## Steps

### 1. Locate the vault root

Look for a directory containing a `README.md` with `type: index` in its frontmatter — that is the vault root. Search the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Interpret the user's input

The user may have provided either:
- A short course slug (e.g. `machine-learning`) with an optional display title or no extra argument
- A longer description of the course they want to create (e.g. "I want to learn about how neural networks work and how to train them")

If "$course_title" is long or sentence-like (i.e. appears to be a description rather than a title), treat the combined input as a course proposal: propose a suitable short display title and confirm it with the user before proceeding. If "$course_name" itself is descriptive rather than a valid slug, derive an appropriate slug from the proposed title.

### 3. Validate the course name

The course name "$course_name" should be lowercase and hyphen-separated (e.g. `machine-learning`, `aws`, `physics`). If it isn't, convert it automatically and confirm with the user.

### 4. Check for duplicates

If `<vault-root>/$course_name/` already exists, tell the user and stop — don't overwrite it.

### 5. Determine the display title

If a display title was confirmed in step 2, use it. Otherwise, if "$course_title" was provided as a short title, use it. Otherwise derive a title from "$course_name" by converting hyphens to spaces and title-casing each word (e.g. `machine-learning` → `Machine Learning`).

### 5a. Research unfamiliar topics

If you are not confident you have sufficient knowledge to propose a well-structured course on this topic, use WebSearch and WebFetch to research it before proceeding. Look for authoritative learning resources, syllabi, curricula, or documentation that can inform the module and note structure. Gather enough context to propose a course that is accurate and well-ordered.

### 6. Plan the course structure with the user

Propose a set of modules for this course — ordered from foundational to advanced. For each module, propose an ordered list of notes (individual concepts) it will cover.

As you plan, consider which notes will benefit from visual aids — for example: architecture or flow concepts suit Mermaid diagrams; CLI or API concepts suit code examples; comparison-heavy concepts suit tables. You don't need to list this in the proposal, but keep it in mind so the structure reflects where visual content will be most useful.

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

### 7. Create the course README

Create `<vault-root>/$course_name/README.md`:

```markdown
---
title: "<derived title>"
type: track
tags: [$course_name]
---

# <derived title>

## Modules

- [ ] [[01-<module-name>/README|<Module Title>]]
- [ ] [[02-<module-name>/README|<Module Title>]]
...
```

### 8. Create each module directory and README

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

### 9. Update the vault index

Read `<vault-root>/README.md`. Add a wikilink to the new course under the tracks/courses list:

```
- [[$course_name/README|<derived title>]] — <one-line description>
```

### 10. Confirm completion

Tell the user what was created: the course directory, how many modules, and the total number of notes planned. Remind them they can run `/add-note` to start filling in the first note.

---
name: create-course
description: Create a new learning course in the Obsidian vault. Use when starting a new broad subject area (e.g. aws, machine-learning, physics). Creates the course directory, README with correct frontmatter, and updates the master index.
argument-hint: <course-name> [Course Title]
arguments: [course_name, course_title]
allow-tools: Read Write Edit Bash
---

# Create Learning Course

Create a new learning course for "$course_name" in the Obsidian vault.

## Steps

1. **Locate the vault root** — The vault is an Obsidian vault directory somewhere in or near the current working directory. Look for a directory containing a `README.md` with `type: index` in its frontmatter — that directory is the vault root. Search the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

2. **Validate the course name** — The course name "$course_name" should be lowercase and hyphen-separated (e.g. `machine-learning`, `aws`, `physics`). If it isn't, convert it automatically and confirm the conversion with the user.

3. **Check if course already exists** — Check whether `<vault-root>/$course_name/` already exists. If it does, tell the user and stop — don't overwrite it.

4. **Determine the display title** — If "$course_title" was provided, use it as the title. Otherwise, derive a title from "$course_name" by converting hyphens to spaces and title-casing each word (e.g. `machine-learning` → `Machine Learning`).

5. **Create the course directory and README** — Create `<vault-root>/$course_name/README.md` with this exact frontmatter and a starter body:

```markdown
---
title: "<derived title>"
type: track
tags: [$course_name]
---

# <derived title>

## Modules

<!-- Modules will be listed here as they are created -->
```

6. **Update the master index** — Read `<vault-root>/_index/Home.md`. Add a wikilink to the new course's README under a "Tracks" section (or wherever courses are listed). Use the format `[[<course-name>/README|<derived title>]]`. If the file doesn't exist yet, create it with a basic structure listing the new course.

7. **Confirm completion** — Tell the user what was created and what the next step is (e.g. creating the first module with `/create-module`).

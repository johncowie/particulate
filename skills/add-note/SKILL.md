---
name: add-note
description: Add a new concept note to a module in the Obsidian learning vault. Writes the note, teaches the material in conversation, answers questions, then quizzes the user. Use when learning a specific concept within an existing course.
argument-hint: "<note topic> [track/module]"
arguments: [note_topic, track_module]
allow-tools: Read Write Edit Bash
---

# Add Note

Add a new concept note about "$note_topic" to the Obsidian learning vault.

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Identify the track and module

If "$track_module" was provided (e.g. `aws/networking` or just `aws`), parse it as `<track>/<module>` or `<track>`. Otherwise, make a reasonable suggestion based on "$note_topic" and ask the user to confirm before proceeding.

- The track is a top-level folder under the vault root (e.g. `catalan`, `aws`, `machine-learning`).
- The module is a numbered subfolder within the track (e.g. `01-core-concepts`, `02-networking`).
- If the track doesn't exist yet, tell the user to run `/create-course` first.
- If the module doesn't exist yet, offer to create it with the next available number in sequence (zero-padded two digits), confirm with the user, and create the module directory and `README.md` before continuing.

### 3. Check what already exists

Read the module `README.md` to:
- Count the existing notes and determine the next note number (zero-padded two digits, e.g. `03` if two notes exist).
- Check whether a note for "$note_topic" already exists — if so, ask the user whether to update it or stop.
- Identify related notes already in the vault that the new note should link to.

### 4. Determine the note filename and title

- **Title**: Derive a clean Title Case display title from "$note_topic" (e.g. `gradient descent` → `Gradient Descent`).
- **Filename**: `<NN> <Title Case Title>.md` where `NN` is the next number in the module sequence (e.g. `03 Gradient Descent.md`).
- The file lives at `<vault-root>/<track>/<module-folder>/<filename>`.

### 5. Write the note

Create the note file with this structure (fill in all sections with real content — do not leave placeholders):

```markdown
---
title: "<Title>"
track: <track>
module: <module-name-without-number>
tags: [<track>, <module-name-without-number>, <concept-tags>]
---

# <Title>

<One-sentence definition or summary.>

<Full explanation — as much depth as needed. Use headers, lists, tables, code blocks as appropriate. Link liberally to related concepts using wikilinks: [[Note Name]] or [[NN Note Name|Note Name]] for numbered notes.>

## Key Points

- <Most important things to remember, as bullet points>

## Related

- [[...]] — <brief description>

## Examples

<Concrete examples or analogies that make the concept tangible. Omit this section only if there are genuinely no useful examples.>

## Check Your Understanding

1. <Basic recall question>
2. <Comprehension question>
3. <Applied/conceptual question>
4. <Applied/conceptual question>
5. <Synthesis or edge-case question>

## References

- [<Source Title>](<url>) — <one-line description>
```

**Wikilink rules:**
- Use `[[Note Name]]` for unnumbered notes.
- Use `[[NN Note Name|Note Name]]` for numbered notes (alias hides the number).
- Link any mentioned concept that has (or should have) its own note.

### 6. Update the module README

**If the note already has an unchecked entry** (`- [ ] [[NN <Title>|<Title>]]`) in the module README — i.e. it was planned by `/create-course` — tick the checkbox:

```
- [x] [[NN <Title>|<Title>]] — <one-line description>
```

Add the one-line description after the wikilink if it isn't already there.

**If no entry exists yet** (note was not pre-planned), append a checked entry:

```
- [x] [[NN <Title>|<Title>]] — <one-line description>
```

If the module README didn't exist (new module), create it:

```markdown
---
title: "<Module Title>"
track: <track>
type: module
tags: [<track>, <module-name-without-number>]
---

# <Module Title>

<One sentence describing what this module covers.>

## Notes

- [x] [[NN <Title>|<Title>]] — <one-line description>
```

Also update the track README to include the new module if it was just created.

### 7. Teach the material

Summarise the note content in conversation in a clear, engaging way — as if explaining the concept to the user for the first time. Keep it concise but complete.

Then ask: "Do you have any questions?"

### 8. Answer questions

Answer each question thoroughly. After each answer, ask: "Anything else, or shall we move on?"

Continue until the user signals they are done.

### 9. Refine the note

After the conversation ends, if anything was discussed that would make the note clearer, more accurate, or more complete — update the note file. Also check for bidirectional linking opportunities: if the new note links to an existing note B, consider whether note B should link back to the new note.

### 10. Quiz the user

Offer a 5-question quiz drawn from the note's "Check Your Understanding" section:

> "Ready for a quick quiz on <Title>? I'll ask one question at a time."

Ask one question at a time. Wait for the user's answer before asking the next. Give feedback on each answer — whether it's correct, and why. Complete all 5 questions (or stop if the user skips).

### 11. Commit prompt

After the quiz (or if the user skips it), ask: "Want me to commit and push these notes?"

If yes, stage and commit only the new/modified vault files with a message like:

```
notes: add <Title> to <track>/<module>
```

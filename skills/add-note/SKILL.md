---
name: add-note
description: Add a new concept note to a module in the Obsidian learning vault. Writes the note, teaches the material in conversation, answers questions, then quizzes the user. Use when learning a specific concept within an existing course.
argument-hint: "<note topic> [track/module]"
arguments: [note_topic, track_module]
allow-tools: Read Write Edit Bash WebSearch WebFetch
---

# Add Note

Add a new concept note about "$note_topic" to the Obsidian learning vault.

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Identify the track, module, and note

If "$track_module" was provided (e.g. `aws/networking` or just `aws`), parse it as `<track>/<module>` or `<track>`. If "$note_topic" was also provided and unambiguous, proceed directly.

**When the target note is unclear** (no args, or only a track with no module/note specified), find the next thing to work on using the course checkboxes:

1. Read the course README and find the first module whose checkbox is unchecked (`- [ ]`).
2. Read that module's README and find the first note whose checkbox is unchecked (`- [ ]`).
3. Ask the user: "The next note to write is **<Note Title>** in **<Module Title>**. Want to work on that?"
4. If the user says yes, proceed with that note. If no, ask them what they'd like to work on instead.

Other rules:
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

### 5. Research the topic

Before writing, assess your confidence in the material:

- If there is **any uncertainty** about the accuracy of the content (e.g. niche topic, evolving field, specific API behaviour, version-dependent details), use WebSearch and WebFetch to verify and fill gaps.
- If the topic is **potentially out of date** (e.g. cloud services, frameworks, language features, tooling), search for the current state regardless of confidence.

Gather information from authoritative sources (official docs, reputable tutorials, academic references). Collect the URLs of any sources that meaningfully inform the note — they will be listed in the References section.

**Image search (optional but encouraged):** After gathering textual sources, search for 1–2 diagrams or illustrations that genuinely aid understanding of the concept — architecture diagrams, flow diagrams, concept maps, official documentation screenshots. Only use images that are clearly freely licensed (Creative Commons, public domain) or sourced from official documentation. Skip anything where licensing is unclear.

To include an image:
1. Create the assets directory if it doesn't exist: `<vault-root>/_assets/<track>/`
2. Download the image using `curl -L -o <vault-root>/_assets/<track>/<descriptive-name>.<ext> "<url>"`
3. Reference it in the note with a relative path: `![<alt text>](../../_assets/<track>/<filename>)`
4. Add the image source to the References section.

If no suitable freely licensed image exists, skip this step — a good Mermaid diagram you write yourself is always preferable to a poorly licensed or irrelevant image.

### 6. Write the note

**Acronym/initialism rule:** The first time any acronym or initialism appears in the note, write it out in full followed by the acronym in brackets — e.g. "Secure Shell (SSH)". After that first use, the acronym alone is fine throughout the rest of the note.

**Visual content guidance:** Notes should be engaging and visually rich where it helps understanding. Actively look for opportunities to include:

- **Mermaid diagrams** — use for flows, pipelines, architectures, state machines, sequences, hierarchies, or any concept with structure or relationships. Obsidian renders these natively. Choose the right diagram type: `flowchart` for processes, `sequenceDiagram` for interactions, `classDiagram` for structure, `stateDiagram` for state machines, `graph` for networks.
- **Code examples** — include for any programming, configuration, CLI, or API concept. Use realistic, runnable snippets rather than pseudocode. Label the language on every code fence (` ```python `, ` ```yaml `, etc.).
- **Tables** — use for comparing options, listing properties, mapping concepts, or summarising multiple related items side by side.
- **Obsidian callouts** — use to highlight key warnings, tips, or "gotcha" moments: `> [!warning]`, `> [!tip]`, `> [!info]`, `> [!important]`.

The goal is that a reader opening the note gets the concept faster than from prose alone. Don't add visuals for decoration — add them when they genuinely clarify.

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

<Full explanation — as much depth as needed. Use headers, lists, tables, code blocks, Mermaid diagrams, and callouts as appropriate. Link liberally to related concepts using wikilinks: [[Note Name]] or [[NN Note Name|Note Name]] for numbered notes.>

## Key Points

- <Most important things to remember, as bullet points>

## Related

- [[...]] — <brief description>

## Examples

<Concrete examples or analogies that make the concept tangible. Include code snippets or diagrams here where they aid understanding. Omit this section only if there are genuinely no useful examples.>

## Check Your Understanding

1. <Basic recall question>
2. <Comprehension question>
3. <Applied/conceptual question>
4. <Applied/conceptual question>
5. <Synthesis or edge-case question>

## References

- [<Source Title>](<url>) — <one-line description>

<!-- Include any web sources consulted during research. Omit this section only if no external sources were used. -->
```

**Wikilink rules:**
- Use `[[Note Name]]` for unnumbered notes.
- Use `[[NN Note Name|Note Name]]` for numbered notes (alias hides the number).
- Link any mentioned concept that has (or should have) its own note.

### 7. Update the module README

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

**Module completion check:** After updating the module README, re-read it and check whether every note entry is now checked (`- [x]`). If all notes are checked, open the course README and tick the checkbox for this module:

```
- [x] [[NN-<module-name>/README|<Module Title>]]
```

### 8. Teach the material

Summarise the note content in conversation in a clear, engaging way — as if explaining the concept to the user for the first time. Keep it concise but complete.

**Acronym/initialism rule:** The first time any acronym or initialism appears in the lesson text, write it out in full followed by the acronym in brackets — e.g. "Secure Shell (SSH)". After that first use, the acronym alone is fine for the rest of the lesson.

Then ask: "Do you have any questions?"

### 9. Answer questions

Answer each question thoroughly. After each answer, ask: "Anything else, or shall we move on?"

Continue until the user signals they are done.

### 10. Refine the note

After the conversation ends, if anything was discussed that would make the note clearer, more accurate, or more complete — update the note file. Also check for bidirectional linking opportunities: if the new note links to an existing note B, consider whether note B should link back to the new note.

### 11. Quiz the user

Offer a quiz on the note, then run it using the `/quiz` skill with `note` and the note title as arguments. If the user declines, skip to the next step.

### 12. Commit prompt

After the quiz (or if the user skips it), ask: "Want me to commit and push these notes?"

If yes, stage and commit only the new/modified vault files with a message like:

```
notes: add <Title> to <track>/<module>
```

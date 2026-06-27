---
name: quiz-module
description: Quiz the user on all notes across a module in the Obsidian learning vault. Draws questions from every note's Check Your Understanding section, shuffles them, and runs 5 by default. Use when the user wants to test their knowledge across a whole module.
argument-hint: "[track/module]"
arguments: [track_module]
allow-tools: Read Write Bash
---

# Quiz Module

Quiz the user on the module "$track_module".

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Resolve which module to quiz on

**If "$track_module" was provided** (e.g. `aws/networking` or just `aws`), parse it as `<track>/<module>` or `<track>`:
- If only a track is given, find the most recently modified module directory within that track and confirm with the user: "Quiz you on **<Module Title>**?"
- If `<track>/<module>` is given, locate the matching module directory (partial, case-insensitive match on the folder name is fine).
- If no match is found, list available modules in the track and ask the user to pick one.

**If "$track_module" was NOT provided**, check the vault for the most recently modified module (by scanning module README files):
- If found, ask the user: "Want to be quizzed on **<Module Title>** in **<Track>**?" and wait for confirmation.
- If the user says no, or nothing can be determined, ask: "Which module would you like to be quizzed on? (e.g. `aws/networking`)"

### 3. Collect questions from all notes in the module

Read the module README to get the list of notes. Then read each note file in order. From each note, extract:
- The **title**.
- All questions from the **Check Your Understanding** section.

Build a combined question pool, tagging each question with the note it came from. Skip any note that has no "Check Your Understanding" section (silently).

If the pool has fewer than 5 questions total, use all available questions and note the smaller count in the quiz announcement.

### 4. Load previous quiz results

Scan `meta/quiz-results/` for any existing result files matching this module (quiz-type `module`, scope matching the module name) as well as any `note`-type results for individual notes within this module. Read each matching file and extract:
- Which questions were asked.
- Which were answered correctly vs incorrectly.

Use this history to:
- **Prioritise questions the user has previously got wrong** — weight these more heavily in selection.
- **Deprioritise questions they've consistently got right** — prefer fresher or weaker areas.
- **Spread selection across notes**, but skew toward notes where past performance was weakest.
- If there is no prior history, select questions normally, spread evenly across notes.

Briefly note to the user if you're drawing on past results (e.g. "Based on past quizzes, I'll focus a bit more on <topic>.").

### 5. Run the quiz

Announce the quiz:

> "Ready to quiz you on **<Module Title>**! I'll ask 5 questions drawn from across the module."

Ask **one question at a time**:
1. Present the question (no need to mention which note it's from).
2. Wait for the user's answer.
3. Give clear feedback — whether the answer is correct or not, and why. Reference the note content to support the feedback.
4. Record internally whether each answer was correct, and which note it came from.
5. Move on to the next question.

Continue until all 5 questions are complete, or the user asks to stop.

After the final question, give a brief summary: how many they got right and any notes or concepts worth revisiting.

### 6. Save quiz results

Determine the scope slug: take the module name (strip the leading number if present, e.g. `01-core-concepts` → `core-concepts`), lowercase, hyphens for spaces.

Get the current date and time by running `date '+%Y-%m-%dT%H-%M-%S'` in the shell. Use the output as the timestamp in the filename — do not substitute zeros or approximate the time.

Write a result file to `meta/quiz-results/` with the filename:

```
<timestamp>_module_<scope>.md
```

For example: `2026-06-27T14-32-00_module_core-concepts.md`

Use this structure:

```markdown
---
quiz-type: module
scope: <module name>
track: <track name>
date: <ISO-8601 timestamp>
score: <n>/<total>
---

# Quiz Results — <Module Title>

**Date:** <human-readable date and time>
**Score:** <n>/<total>

## Questions

### Q1: <question text>
- **Note:** <note title the question came from>
- **Answer given:** <user's answer>
- **Correct:** yes / no
- **Correct answer:** <correct answer or summary>

### Q2: ...

## Summary

<One or two sentences on overall performance and any notes or areas to revisit.>
```

Create the `meta/quiz-results/` directory if it does not exist.

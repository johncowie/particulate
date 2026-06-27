---
name: quiz-note
description: Quiz the user on a concept note from the Obsidian learning vault. Asks one question at a time, gives feedback, and completes 5 questions by default. Use when the user wants to test their knowledge on a note they've already studied.
argument-hint: "[note title or path]"
arguments: [note]
allow-tools: Read Write Bash
---

# Quiz Note

Quiz the user on the note "$note".

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Resolve which note to quiz on

**If "$note" was provided**, search the vault for a matching note file:
- Try exact filename match first (e.g. `03 Gradient Descent.md`).
- Then try case-insensitive partial match on the filename or title frontmatter field.
- If multiple matches are found, list them and ask the user to pick one.
- If no match is found, tell the user and ask them to clarify.

**If "$note" was NOT provided**, check whether a most-recently-created note can be determined:
- Look for the most recently modified `.md` file in the vault (excluding `README.md` files and the vault index).
- If found, ask the user: "Want to be quizzed on **<Note Title>**?" and wait for confirmation.
- If the user says no, or if no recent note can be identified, ask: "Which note would you like to be quizzed on?"

### 3. Read the note

Read the resolved note file. Extract:
- The **title** (from frontmatter `title:` field or the first `# Heading`).
- The **Check Your Understanding** section — this is the source of quiz questions.
- If the note has no "Check Your Understanding" section, tell the user and offer to generate ad-hoc questions from the note's content instead.

### 4. Load previous quiz results

Scan `meta/quiz-results/` for any existing result files matching this note (quiz-type `note`, scope matching the note title). Read each matching file and extract:
- Which questions were asked.
- Which were answered correctly vs incorrectly.

Use this history to:
- **Prioritise questions the user has previously got wrong** — these should be selected first.
- **Avoid repeating questions they've consistently got right** unless the pool is too small to avoid it.
- If there is no prior history, select questions normally.

Briefly note to the user if you're drawing on past results (e.g. "I can see you've struggled with X before, so I'll focus on that.").

### 5. Run the quiz

Announce the quiz:

> "Ready to quiz you on **<Title>**! I'll ask 5 questions one at a time."

Ask **one question at a time**:
1. Present the question.
2. Wait for the user's answer.
3. Give clear feedback — whether the answer is correct or not, and why. Reference the note content to support the feedback.
4. Record internally whether each answer was correct.
5. Move on to the next question.

Continue until all 5 questions are complete, or the user asks to stop.

After the final question, give a brief summary: how many they got right and any concepts worth revisiting.

### 6. Save quiz results

Determine the scope slug: take the note title, lowercase it, and replace spaces with hyphens (e.g. `gradient-descent`).

Get the current date and time by running `date '+%Y-%m-%dT%H-%M-%S'` in the shell. Use the output as the timestamp in the filename — do not substitute zeros or approximate the time.

Write a result file to `meta/quiz-results/` with the filename:

```
<timestamp>_note_<scope>.md
```

For example: `2026-06-27T14-32-00_note_gradient-descent.md`

Use this structure:

```markdown
---
quiz-type: note
scope: <note title>
date: <ISO-8601 timestamp>
score: <n>/<total>
---

# Quiz Results — <Note Title>

**Date:** <human-readable date and time>
**Score:** <n>/<total>

## Questions

### Q1: <question text>
- **Answer given:** <user's answer>
- **Correct:** yes / no
- **Correct answer:** <correct answer or summary>

### Q2: ...

## Summary

<One or two sentences on overall performance and any areas to revisit.>
```

Create the `meta/quiz-results/` directory if it does not exist.

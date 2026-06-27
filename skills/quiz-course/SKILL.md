---
name: quiz-course
description: Quiz the user on notes across an entire course (track) in the Obsidian learning vault. Draws questions from every note's Check Your Understanding section, spreads them across modules, and runs 5 by default. Use when the user wants to test their knowledge across a whole course.
argument-hint: "[track]"
arguments: [track]
allow-tools: Read Write Bash
---

# Quiz Course

Quiz the user on the course "$track".

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Resolve which course to quiz on

**If "$track" was provided**, locate the matching top-level track directory under the vault root (case-insensitive, partial match is fine):
- If no match is found, list available tracks and ask the user to pick one.

**If "$track" was NOT provided**, check the vault index README for the most recently modified track:
- If found, ask the user: "Want to be quizzed on the **<Track Title>** course?" and wait for confirmation.
- If the user says no, or nothing can be determined, ask: "Which course would you like to be quizzed on?"

### 3. Collect questions from all notes across all modules

Read the track README to get the list of modules. For each module, read its README to get the list of notes. Then read each note file. From each note, extract:
- The **title** and **module** it belongs to.
- All questions from the **Check Your Understanding** section.

Build a combined question pool, tagging each question with the note title and module it came from. Skip any note that has no "Check Your Understanding" section (silently).

If the pool has fewer than 5 questions total, use all available questions and note the smaller count in the quiz announcement.

### 4. Load previous quiz results

Scan `meta/quiz-results/` for any existing result files matching this course — that includes:
- `course`-type results with a scope matching this track.
- `module`-type results for any module within this track.
- `note`-type results for any note within this track.

Read each matching file and extract:
- Which questions were asked.
- Which were answered correctly vs incorrectly.
- Which modules or notes have the weakest track record.

Use this history to:
- **Prioritise questions from modules and notes where the user has historically performed worst.**
- **Deprioritise questions from areas they've consistently got right.**
- **Spread selection across modules**, skewing toward weaker ones.
- If there is no prior history, select questions normally, spread evenly across modules.

Briefly note to the user if you're drawing on past results (e.g. "You've historically found **<module>** trickier, so I'll lean into that.").

### 5. Run the quiz

Announce the quiz:

> "Ready to quiz you on the **<Track Title>** course! I'll ask 5 questions drawn from across all modules."

Ask **one question at a time**:
1. Present the question (no need to mention which note or module it's from).
2. Wait for the user's answer.
3. Give clear feedback — whether the answer is correct or not, and why. Reference the note content to support the feedback.
4. Record internally whether each answer was correct, and which note and module it came from.
5. Move on to the next question.

Continue until all 5 questions are complete, or the user asks to stop.

After the final question, give a brief summary: how many they got right and any modules or concepts worth revisiting.

### 6. Save quiz results

Determine the scope slug: lowercase the track name and replace spaces with hyphens (e.g. `Machine Learning` → `machine-learning`).

Get the current date and time by running `date '+%Y-%m-%dT%H-%M-%S'` in the shell. Use the output as the timestamp in the filename — do not substitute zeros or approximate the time.

Write a result file to `meta/quiz-results/` with the filename:

```
<timestamp>_course_<scope>.md
```

For example: `2026-06-27T14-32-00_course_machine-learning.md`

Use this structure:

```markdown
---
quiz-type: course
scope: <track name>
date: <ISO-8601 timestamp>
score: <n>/<total>
---

# Quiz Results — <Track Title>

**Date:** <human-readable date and time>
**Score:** <n>/<total>

## Questions

### Q1: <question text>
- **Note:** <note title>
- **Module:** <module title>
- **Answer given:** <user's answer>
- **Correct:** yes / no
- **Correct answer:** <correct answer or summary>

### Q2: ...

## Summary

<One or two sentences on overall performance and any modules or areas to revisit.>
```

Create the `meta/quiz-results/` directory if it does not exist.

---
name: quiz
description: Quiz the user on material from the Obsidian learning vault — at the level of a single note, a whole module, or an entire course. Draws from Check Your Understanding sections, adapts to past results to focus on weak areas. Use when the user wants to test their knowledge on anything they've studied.
argument-hint: "[note|module|course] [scope]"
arguments: [granularity, scope]
allow-tools: Read Write Bash AskUserQuestion
---

# Quiz

Quiz the user. The granularity is "$granularity" and the scope is "$scope".

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the vault root. Check the current directory first, then one level of subdirectories. If not found, ask the user to specify the vault root path.

### 2. Resolve the quiz granularity

Determine whether this is a **note**, **module**, or **course** quiz.

- If "$granularity" is one of `note`, `module`, or `course` (case-insensitive), use it directly.
- If "$granularity" looks like a scope (e.g. a track name, a note title, a path) rather than a granularity keyword, treat it as the scope and leave granularity unresolved.
- If granularity is still unresolved, use `AskUserQuestion` to ask:

  > "What would you like to be quizzed on?"
  > Options: **Note** (a single concept), **Module** (all notes in one module), **Course** (all notes across a whole course)

### 3. Resolve the scope

The scope is what specifically to quiz on (a note title, a `track/module` path, or a track name).

**If "$scope" was provided**, use it as-is (the resolution steps below will validate it).

**If "$scope" was NOT provided**, determine a sensible default:

- **For a note quiz:** find the most recently modified `.md` file in the vault (excluding `README.md` files and the vault index). Use its title as the default.
- **For a module quiz:** find the most recently modified module directory (by scanning module `README.md` files). Use `<track>/<module>` as the default.
- **For a course quiz:** find the most recently modified track directory. Use the track name as the default.

Once a default is identified, use `AskUserQuestion` to confirm:

> "I'll quiz you on **<default>**. Go with that, or pick something else?"
> Options: **Yes, quiz me on `<default>`**, **No, I'll specify something else**

If the user selects "No, I'll specify something else", ask them to type what they'd like to be quizzed on.

### 4. Load vault content for the resolved scope

#### Note quiz
Search the vault for a note file matching the scope:
- Try exact filename match first, then case-insensitive partial match on filename or `title` frontmatter field.
- If multiple matches are found, list them and ask the user to pick one.
- If no match is found, tell the user and ask them to clarify.

Read the resolved note file and extract:
- The **title** (from `title:` frontmatter or the first `# Heading`).
- All questions from the **Check Your Understanding** section. If this section is missing, offer to generate ad-hoc questions from the note content instead.

#### Module quiz
Locate the matching module directory (partial, case-insensitive match on the folder name). If no match is found, list available modules and ask the user to pick one.

Read the module `README.md` to get the list of notes, then read each note file. From each note, extract the title and all **Check Your Understanding** questions, tagged with the note they came from.

#### Course quiz
Locate the matching top-level track directory (partial, case-insensitive). If no match is found, list available tracks and ask the user to pick one.

Read the track `README.md` to get the list of modules. For each module, read its `README.md` to get notes. Read each note file and extract the title, module, and all **Check Your Understanding** questions, tagged with note and module.

For module and course quizzes: if the total question pool has fewer than 5 questions, use all available and note the smaller count in the quiz announcement.

### 5. Load previous quiz results

Scan `meta/quiz-results/` for relevant prior result files:

- **Note quiz:** files with `quiz-type: note` and a scope matching the note title.
- **Module quiz:** files with `quiz-type: module` and matching scope, plus any `quiz-type: note` files for notes within this module.
- **Course quiz:** files with `quiz-type: course` and matching scope, plus any `quiz-type: module` or `quiz-type: note` files for content within this course.

From each matching file, extract which questions were asked and whether each was answered correctly.

Use this history to:
- **Prioritise questions the user has previously got wrong** — weight these more heavily in selection.
- **Deprioritise questions they've consistently got right** — prefer weaker areas.
- For module and course quizzes, **skew selection toward the notes or modules with the weakest track record**, while still spreading across the full scope.
- If there is no prior history, select questions normally, spread evenly.

Briefly note to the user if you're adapting based on past results (e.g. "You've struggled with **X** before, so I'll lean into that.").

### 6. Run the quiz

Select 5 questions (or fewer if the pool is smaller). For module and course quizzes, spread across notes/modules where possible.

Announce the quiz:
- Note: `"Ready to quiz you on **<Title>**! I'll ask 5 questions one at a time."`
- Module: `"Ready to quiz you on **<Module Title>**! I'll ask 5 questions drawn from across the module."`
- Course: `"Ready to quiz you on the **<Track Title>** course! I'll ask 5 questions drawn from across all modules."`

Ask **one question at a time**:
1. Present the question.
2. Wait for the user's answer.
3. Give clear feedback — whether correct or not, and why. Reference the note content.
4. Record internally whether the answer was correct, plus which note and module it came from (for module/course quizzes).
5. Move on to the next question.

Continue until all questions are complete, or the user asks to stop.

After the final question, give a brief summary: score and any concepts, notes, or modules worth revisiting.

### 7. Save quiz results

Run `date '+%Y-%m-%dT%H-%M-%S'` in the shell to get the current timestamp. Do not substitute zeros or approximate the time.

Determine the scope slug and quiz-type:
- **Note:** slug = note title, lowercased with spaces as hyphens. Type = `note`.
- **Module:** slug = module name with leading number stripped (e.g. `01-core-concepts` → `core-concepts`), lowercased. Type = `module`.
- **Course:** slug = track name, lowercased with spaces as hyphens. Type = `course`.

Write a result file to `meta/quiz-results/` (create the directory if needed) named:

```
<timestamp>_<quiz-type>_<scope-slug>.md
```

Use this structure, including only the fields relevant to the quiz type:

```markdown
---
quiz-type: <note|module|course>
scope: <note title | module name | track name>
track: <track name>          # module and course quizzes only
date: <ISO-8601 timestamp>
score: <n>/<total>
---

# Quiz Results — <Title>

**Date:** <human-readable date and time>
**Score:** <n>/<total>

## Questions

### Q1: <question text>
- **Note:** <note title>        # module and course quizzes only
- **Module:** <module title>    # course quizzes only
- **Answer given:** <user's answer>
- **Correct:** yes / no
- **Correct answer:** <correct answer or summary>

### Q2: ...

## Summary

<One or two sentences on overall performance and any areas to revisit.>
```

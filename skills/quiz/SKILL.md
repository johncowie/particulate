---
name: quiz
description: Quiz the user on material from the Obsidian learning vault — at the level of a single note, a whole module, or an entire course. Draws from Check Your Understanding sections, adapts to past results to focus on weak areas. Use when the user wants to test their knowledge on anything they've studied.
argument-hint: "[note|module|course] [scope]"
arguments: [granularity, scope]
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/shuffle-order.sh *)
  - Bash(date *)
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
- All questions from the **Check Your Understanding** section (if present).

Then generate additional ad-hoc questions from the note body to supplement the pre-written ones. Aim for a roughly even blend — for every pre-written question, generate roughly one ad-hoc question. Ad-hoc questions should cover angles not already addressed by the pre-written ones (e.g. applied scenarios, edge cases, or connections to related concepts).

If the **Check Your Understanding** section is missing entirely, generate all questions ad-hoc from the note content.

#### Module quiz
Locate the matching module directory (partial, case-insensitive match on the folder name). If no match is found, list available modules and ask the user to pick one.

Read the module `README.md` to get the list of notes, then read each note file. From each note, extract the title and all **Check Your Understanding** questions, then generate ad-hoc questions to supplement them (same blending approach as above), tagging all questions with the note they came from.

#### Course quiz
Locate the matching top-level track directory (partial, case-insensitive). If no match is found, list available tracks and ask the user to pick one.

Read the track `README.md` to get the list of modules. For each module, read its `README.md` to get notes. Read each note file and extract the title, module, and all **Check Your Understanding** questions, then generate ad-hoc questions to supplement them, tagging all questions with note and module.

For module and course quizzes: if the total question pool is smaller than `<question-count>`, use all available and note the smaller count in the quiz announcement.

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

### 6. Choose number of questions

Use `AskUserQuestion` to ask how many questions the user wants:

> "How many questions would you like?"
> Options:
> - **5** — a quick focused session
> - **10** — a longer session
> - **Custom** — I'll enter a different number

If the user selects **Custom**, ask them to type in how many they'd like.

Record the chosen count as `<question-count>`. If the available question pool is smaller than the chosen count, use the full pool and note the smaller count.

### 7. Choose quiz format

Use `AskUserQuestion` to ask the user how they'd like to be quizzed:

> "How would you like to be quizzed?"
> Options:
> - **Multiple choice** — I'll give you four options to pick from for each question
> - **Free recall** — You type your answer in your own words

Record the chosen format; it governs how questions are presented in the next step.

### 8. Run the quiz

Select `<question-count>` questions (or fewer if the pool is smaller). For module and course quizzes, spread across notes/modules where possible.

Announce the quiz:
- Note: `"Ready to quiz you on **<Title>**! I'll ask <question-count> questions one at a time."`
- Module: `"Ready to quiz you on **<Module Title>**! I'll ask <question-count> questions drawn from across the module."`
- Course: `"Ready to quiz you on the **<Track Title>** course! I'll ask <question-count> questions drawn from across all modules."`

Ask **one question at a time**, using the chosen format:

**If multiple choice:**
- Before presenting the question, generate four answer options: one correct answer and three plausible distractors drawn from the note content. Hold these in order as slots 1, 2, 3, 4 — **do not reveal this ordering to the user**.
- Run `${CLAUDE_PLUGIN_ROOT}/scripts/shuffle-order.sh 4` to get a shuffled index sequence (e.g. `3 1 4 2`). Rearrange your four options into that order. Note internally which position the correct answer (slot 1) now occupies — never pass any option text to the shell.
- Use `AskUserQuestion` to present the question and the four shuffled options.
- After the user selects an option, give feedback — whether it's correct and why. Reference the note content.

**If free recall:**
- Present the question in prose.
- Wait for the user to type their answer.
- Give clear feedback — whether correct or not, and why. Reference the note content.

For both formats:
- Record internally whether the answer was correct, plus which note and module it came from (for module/course quizzes).
- Move on to the next question.

Continue until all questions are complete, or the user asks to stop.

After the final question, give a brief summary: score and any concepts, notes, or modules worth revisiting.

### 9. Save quiz results

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
format: <multiple-choice|free-recall>
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

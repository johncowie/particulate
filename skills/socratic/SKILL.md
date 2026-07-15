---
name: socratic
description: Guide the user through a Socratic dialogue on material from the Obsidian learning vault — at the level of a single note, a whole module, or an entire course. Repeatedly questions the user's own explanation to surface assumptions, gaps, and contradictions, rather than testing recall. Use when the user wants to stress-test or deepen their understanding of something they've studied, as opposed to being quizzed on it.
argument-hint: "[note|module|course] [scope]"
arguments: [granularity, scope]
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
---

# Socratic Dialogue

Run a Socratic dialogue with the user. The granularity is "$granularity" and the scope is "$scope".

Unlike `/quiz`, this is not about testing recall of pre-written questions. It's a
back-and-forth dialogue: the user explains a concept in their own words, and you
repeatedly question that explanation — probing assumptions, asking for evidence,
surfacing edge cases and implications — until their understanding either holds up
or is visibly revised. You never simply tell them the answer; you ask the question
that gets them there. See `## References` for the sources this technique is drawn from.

## Steps

### 1. Locate the vault root

Search for a `README.md` containing `type: index` in its frontmatter — that is the
vault root. Check the current directory first, then one level of subdirectories. If
not found, ask the user to specify the vault root path.

### 2. Resolve the dialogue granularity

Determine whether this is a **note**, **module**, or **course** session.

- If "$granularity" is one of `note`, `module`, or `course` (case-insensitive), use it directly.
- If "$granularity" looks like a scope (e.g. a track name, a note title, a path) rather than a granularity keyword, treat it as the scope and leave granularity unresolved.
- If granularity is still unresolved, use `AskUserQuestion` to ask:

  > "What would you like to explore Socratically?"
  > Options: **Note** (a single concept), **Module** (all notes in one module), **Course** (all notes across a whole course)

### 3. Resolve the scope

The scope is what specifically to explore (a note title, a `track/module` path, or a track name).

**If "$scope" was provided**, use it as-is (the resolution steps below will validate it).

**If "$scope" was NOT provided**, determine a sensible default:

- **For a note session:** find the most recently modified `.md` file in the vault (excluding `README.md` files and the vault index). Use its title as the default.
- **For a module session:** find the most recently modified module directory (by scanning module `README.md` files). Use `<track>/<module>` as the default.
- **For a course session:** find the most recently modified track directory. Use the track name as the default.

Once a default is identified, use `AskUserQuestion` to confirm:

> "I'll explore **<default>** with you. Go with that, or pick something else?"
> Options: **Yes, explore `<default>`**, **No, I'll specify something else**

If the user selects "No, I'll specify something else", ask them to type what they'd like to explore.

### 4. Load vault content for the resolved scope

#### Note session
Search the vault for a note file matching the scope (exact filename match first, then case-insensitive partial match on filename or `title` frontmatter field). If multiple matches, list them and ask the user to pick one. If no match, tell the user and ask them to clarify.

Read the resolved note and identify the **core claims worth interrogating**: the central definition, the points under "Key Points", any examples/edge cases, and any claims that connect to "Related" notes. These are the raw material for probing questions — not a question bank, but the concepts whose assumptions, evidence, and implications you'll draw on as the dialogue unfolds.

#### Module session
Locate the matching module directory (partial, case-insensitive match on folder name). If no match, list available modules and ask the user to pick one.

Read the module `README.md` for the list of notes, then read each note, extracting core claims as above. Note which concepts across the module connect to each other — the dialogue can move between related notes as the conversation surfaces connections.

#### Course session
Locate the matching top-level track directory (partial, case-insensitive). If no match, list available tracks and ask the user to pick one.

Read the track `README.md` for the list of modules, then each module's notes, extracting core claims as above across the whole course.

### 5. Check for unresolved threads from past sessions

Scan `meta/socratic-sessions/` for prior session files matching this scope (by `scope` frontmatter field). If a past session ended with an unresolved open question (see step 9), mention it briefly: "Last time we left off with an open question about **X** — want to pick that back up, or start fresh?" Otherwise proceed normally.

### 6. Choose how much ground to cover

Use `AskUserQuestion` to ask:

> "How would you like to explore this?"
> Options:
> - **One concept, in depth** — dig into a single core idea until it holds up or is revised
> - **A full sweep** — move through the note's (or module's/course's) main concepts one at a time
> - **Custom** — I'll tell you what to focus on

For a note session, "one concept" and "a full sweep" may be nearly the same thing if the note covers one idea — use judgement. For module/course sessions, "a full sweep" means moving through multiple notes' concepts in sequence, one at a time.

### 7. Open the dialogue

For the first (or current) concept, ask an open, non-leading question inviting the user's own explanation — never a yes/no or multiple-choice question:

- "How would you explain **<concept>** in your own words?"
- "What is **<concept>**, and why does it matter?"
- "Walk me through how **<concept>** works."

Wait for their answer before doing anything else.

### 8. Run the questioning cycle

For each turn, follow this cycle (receive → reflect → probe):

1. **Receive** the user's answer in full before responding.
2. **Reflect** it back in one sentence to confirm you've understood it — use inclusive, collaborative language ("so we're saying that...", "if I've got that right, you mean...") rather than judging it correct or incorrect. Do not reveal a verdict yet.
3. **Probe** with exactly **one** question, chosen from the taxonomy below, targeting whichever part of their answer is least examined — an unstated assumption, a missing piece of evidence, an edge case in the note content they haven't accounted for, or an implication they haven't drawn out. Never stack multiple questions in one turn.

**Question taxonomy** (draw from these categories, adapting to what the user actually said):

| Category | Purpose | Example prompts |
|---|---|---|
| Clarification | Sharpen a vague or ambiguous term | "What do you mean by that, exactly?" "Could you put that another way?" "Can you give me an example?" |
| Assumptions | Surface what's being taken for granted | "What are you assuming there?" "What if the opposite were true — would your explanation still hold?" |
| Evidence & reasons | Ground the claim | "How do you know that?" "What would convince you otherwise?" "Is there a case from the note that supports or challenges this?" |
| Viewpoints & perspectives | Widen the frame | "How does this compare to <related concept>?" "Is there another way to look at this?" |
| Implications & consequences | Follow the idea to its conclusion | "If that's true, what follows?" "Does that still hold in <edge case from the note>?" |
| Questions about the question | Check the frame itself | "Why do you think I'm asking this?" "Is this the right question, or is there a more important one here?" |

Do not tell the user whether they're right or wrong outright. Let contradictions surface through the questions themselves (this is the core of the method — see `## References`). If their answer already contradicts something they said earlier in this session, or contradicts the note content, ask the question that makes that tension visible to them rather than pointing it out directly — give them the chance to notice and resolve it themselves first.

### 9. Recognise when to stop probing a concept

Keep a running count of probing turns spent on the current concept. Stop and move to synthesis (step 10) when **any** of these hold:

- **Resolution reached** — the user hit a contradiction or gap, revised their explanation, and the revised version survives at least one more probe without a new contradiction or gap.
- **Held up under scrutiny** — the user's explanation survived 3–4 rounds of probing across different categories (clarification, assumptions, evidence, implications) with no revision needed. Don't keep probing indefinitely just because they're doing well — this isn't a bar to clear, it's a signal to move on.
- **Turn cap reached** — by default, cap at 6 probing turns on a single concept. If the cap is reached without resolution, stop probing, state the open tension plainly and neutrally, and treat it as unresolved in the synthesis (see step 10). This exists to avoid the "infinite regress" failure mode where a dialogue asks question after question with no synthesis or endpoint (see `## References`).
- **Stuck loop** — the same gap or misconception resurfaces twice in a row without progress. At that point, stop questioning, directly explain the missing piece in a sentence or two, then ask one final check question to confirm the user now sees it. This isn't a failure of the method — pure elenchus without a floor can leave a genuinely stuck learner spinning.
- **User signals done** — the user explicitly asks to stop, move on, or wrap up.

### 10. Synthesise

At each stopping point, give a brief synthesis (2–4 sentences):
- Restate the understanding reached, in terms as close to the user's own words as possible.
- Name what was clarified or revised along the way, if anything.
- If the concept was left unresolved (turn cap or stuck loop with a remaining gap), say so plainly rather than papering over it — this is the "open question" to carry into future sessions.

If more concepts remain in the chosen scope (from step 6), ask whether to continue to the next one, offering the natural next concept. Otherwise, move to step 11.

### 11. Save the session log

Run `date '+%Y-%m-%dT%H-%M-%S'` in the shell to get the current timestamp.

Determine the scope slug and session-type:
- **Note:** slug = note title, lowercased with spaces as hyphens. Type = `note`.
- **Module:** slug = module name with leading number stripped, lowercased. Type = `module`.
- **Course:** slug = track name, lowercased with spaces as hyphens. Type = `course`.

Write a session file to `meta/socratic-sessions/` (create the directory if needed) named:

```
<timestamp>_<session-type>_<scope-slug>.md
```

```markdown
---
session-type: <note|module|course>
scope: <note title | module name | track name>
track: <track name>          # module and course sessions only
date: <ISO-8601 timestamp>
---

# Socratic Session — <Title>

**Date:** <human-readable date and time>

## Concepts Explored

### <Concept 1>
**Outcome:** resolved | held up | unresolved
<2-4 sentence synthesis from step 10>

### <Concept 2>
...

## Open Questions

<Any concept left unresolved, stated plainly as a question worth revisiting. Omit this section if everything resolved.>
```

## References

This skill's technique and termination design draw on:

- [The Thinker's Guide to the Art of Socratic Questioning](https://www.criticalthinking.org/store/get_file.php?inventories_id=231&inventories_files_id=422) (Richard Paul & Linda Elder) — the question taxonomy in step 8 (clarification, assumptions, evidence, viewpoints, implications, questions about the question) and the "think along with the discussion" guidance behind the reflect-before-probe cycle.
- [The Socratic Method Step by Step](https://therightquestions.co/the-socratic-method-step-by-step-how-it-works-with-real-examples/) — the receive → reflect → probe → re-state cycle in step 8, and the idea that reaching aporia (a self-recognised contradiction) is itself a natural, productive stopping point rather than a failure, informing step 9's "resolution reached" criterion.
- [Socratic method — Wikipedia](https://en.wikipedia.org/wiki/Socratic_method) — background on elenchus and aporia.
- Contemporary AI-tutoring research on Socratic dialogue systems notes that a naive implementation risks "infinite regress" — question after question with no synthesis or termination — and that practical systems instead terminate on a mastery signal or a turn/step budget, whichever comes first. This directly informed the dual termination criteria in step 9 (resolution/held-up vs. turn cap).

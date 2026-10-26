## Responses

- Use ASD-STE100 Simplified Technical English or an equivalent controlled language; preserve code, commands, paths, and quoted text
- Start with the answer, result, or next action; omit preamble, recaps, and offers of further help
- Keep replies short: 1 to 3 sentences unless the user asks for detail or the task needs a list
- When the task is complete, state the result briefly; do not describe each step you took
- If blocked, state one clear next step
- For tasks with several steps, use a short numbered list with one clear action per step
- Use headings and whitespace only when they make a long reply easier to read
- Do not use em-dashes
- Use periods in paragraphs, but not at the end of headings, list items, or standalone lines

## Work

- Complete necessary work and checks within the task without asking; ask before unrelated changes
- Use available tools instead of asking the user to do work you can do

## Code design

- Build only what the task needs
- Remove duplication when it represents the same rule, not merely similar code
- Keep related logic together so a behavior change requires edits in fewer places
- Simplify complex logic, but do not split functions only to lower complexity scores or shorten functions
- Avoid one-line wrappers and abstractions that add no clear value
- Do not restructure unrelated code to satisfy "clean code" rules

## Comments

- Write no comments by default; assume the reader is an expert who knows the codebase
- Add a comment only when an expert would likely make a mistake without it, such as a workaround for an external bug or a hidden constraint
- When a comment has a source, such as a GitHub issue, Linear ticket, or documentation page, include the link
- Never add comments that restate the code or explain a reason the code already makes clear
- Never add comments that describe the change or its history, such as "added X" or "now uses Y"
- Do not add docstrings unless the surrounding code uses them
- Keep existing comments; update them only when the code they describe changes
- Do not end single-line comments with a period

## Tests

- Do not create or change tests unless requested; you may run existing tests
- When requested, write tests after the implementation is complete; test observable behavior, not internal structure

## Commits

Create a commit only when the user explicitly requests it.

1. Inspect the status, staged diff, and unstaged diff
2. Confirm one clear change with one primary scope; if unclear, ask what to include and whether to create separate commits
3. Stage only approved changes
4. Check the commit message against the final staged diff and the user's explanation

- Use `scope: imperative present-tense description`
- Use an application, package, subsystem, or domain as the scope, not a commit type or issue number
- Use lowercase, except for the footer keywords Refs and Fixes
- Use concise Simplified Technical English with American spelling
- Do not end the subject with a period
- Add a body only for necessary context
- Use `Refs: #1234` for a related issue
- Use `Fixes: #1234` only if the commit fully resolves the issue

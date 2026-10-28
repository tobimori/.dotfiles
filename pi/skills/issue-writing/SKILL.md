---
name: issue-writing
description: Write or rewrite issues in Tobias's voice, for Linear, GitHub, or any other tracker. Use when asked to create, draft, rewrite, or update an issue or ticket, usually after a brainstorm.
---

# Write an issue

Tell a colleague what to do and why. The reader must understand the issue without seeing our chat. It should sound like Tobias wrote it quickly, not like a report.

Most issues follow a long brainstorm. The brainstorm is not the issue. Most of what we found and discussed stays in the chat. Use Tobias's messages as the source, keep his words, and add only the facts the reader needs.

## Before you write

1. Find what Tobias wants and why. Write it in one or two sentences from his own messages. Do not replace his reason with another one, even a correct one. If you are unsure, ask before writing.
2. Think about the reader. Usually a developer on another team who knows their own codebase, but not our chat, our plans, or names we made up.
3. Check who decided each point:
   - Tobias decided it, or agreed to your proposal: write it as fixed. Do not call it a suggestion or ask the reader to decide it again
   - Tobias proposed it and said the reader can change it: write it as a suggestion
   - You proposed it and Tobias did not react: leave it out, unless the task cannot be done without it. Then mark it as a suggestion
   - Tobias rejected it: leave it out and do not mention it
   - Tobias said it is open: say what is unknown, why it matters, which options he mentioned, and who decides (the reader, or Tobias)
4. If you have a question for Tobias about a point, do not write that point as fixed.

## What goes in

Only include a fact if the reader needs it to understand or do the task. Leave out the rest, even if it is true or took a lot of work to find.

Keep:

- What we need and why, and real examples such as a request and response, a production row, or a count from real data
- Details the reader would likely get wrong, if they are real and affect this task
- Links to issues and PRs, by number, for example `org/repo#123`. If you don't know the number, find it or ask

Leave out:

- How you found things, guesses about the current code, line numbers, and class or file names the reader does not need. Name code only when the reader must change exactly that code and would not find it easily
- Numbers that do not change what the reader does, such as local test sizes or how many rows are active
- How other parts of the system work inside, such as frontend components, drawers, or prefetching. Mention them only as what the user sees, in one sentence if needed
- Investigations, extra scope, other entities, or edge cases that Tobias did not raise. Tell Tobias about real risks in the chat instead
- Findings turned into tasks. What you found in the code or data is background. Do not mix up what the code does today with old data Tobias said to ignore
- Options we did not pick, and answers to questions the reader never asked, such as "no extra type field is needed"
- Instructions that were meant for you, such as "don't touch the audit log yet". Turn them into what the reader needs ("leave out the audit log for now"), or drop them
- Content of attachments. Say what an attachment contains and what to do with it
- Terms only used in our chat or in another repo, such as an internal library name, "option 3", "the PR I made" or a branch name. Explain or replace them
- Your own reasons in Tobias's mouth. Write "I think" or "I don't want" only for things he said

For an investigation, write the question to answer and the options Tobias mentioned. Do not assume the answer.

## Length

Start short and add only what the reader is missing. If Tobias asks for a length, such as "4 lines" or "5 paragraphs", follow it. Otherwise, as a guide:

- A bug or small change: about 80 to 200 words
- A request for an API or another team's change: about 150 to 400 words
- A larger spec with many decided parts: up to about 800 words

Too short is also wrong. If the reader would not know what exists today or why we need the change, add one or two sentences and a real example.

When the draft is done, read it once as the reader and remove every sentence they would not miss. Check that the first paragraph still says what we need and why.

## Form

- Title: short, sentence case, names the task or visible problem, such as `Parcelly import: delivery note shows twice as Note and Instructions`
- Start with a paragraph that says what we need and why, with no heading before it. Start with the need, not with the technology, the frontend, or a list of symptoms. Do not promise a result this issue does not deliver
- Most bugs and short issues need no headings. Use `**Expected:**` for the expected result if it helps
- In long issues, use headings only for separate parts, named after the content, such as `## Auth callback`. Never add "Out of scope", "Goal", "Problem", "Context", "Summary", "Notes", "Acceptance criteria" or "Risks" unless Tobias asks
- If an open question changes the design of the whole issue, put it near the top. Other open points go where they belong, usually after the parts we know
- When you name more than two fields of a request, response or table, show the shape in a short code block, never as a sentence or nested bullets. Use whatever reads like pseudocode, often a TypeScript-like type, or the language of the reader's codebase. Show all known values, but not a full class with attributes and configuration. Show the current state as real SQL or real rows
- Use bullets for real lists, such as columns, files, or rules. Write reasons and requests as sentences, not as a list of commands
- Mark a suggestion where it appears, in a few words, for example before the endpoint block. Do not write a paragraph that sorts the issue into decided and suggested parts, and do not reuse a fixed phrase
- No bold sentences, no bold labels at the start of list items, no Title Case headings, no em-dashes
- No "The fix is a …", "The reason: …", "So we need 2 changes.", "rather than", or "not X but Y". Use "instead of" only when the contrast really matters
- No sets of three and no closing summary
- English, even if the chat was in German

## Voice

Write like a developer talking to a colleague. Short, direct sentences: "We need", "please", "I will do", "feel free to". It is fine to say "I don't know yet" or "I think". Avoid formal spec language like "must be ensured" or "source of truth".

When Tobias dictates or writes a passage, keep his order and reasons. Fix grammar and remove filler, but do not rearrange it, make it more formal, or add facts. Ask if his text conflicts with the facts.

## Process

- Only write the issue; do not implement anything
- Update an existing issue instead of creating a second one. Keep parts Tobias asked to keep, such as a TLDR
- Use the team or project that owns the work. Ask Tobias if it is not clear
- Do not set an assignee, priority, labels, or comments unless he asks
- Ask your questions in the chat, never in the issue
- Show Tobias the draft and wait for confirmation before saving, unless he asked you to save directly
- For a personal to-do for Tobias, a clear title and one line are enough

## Examples

The examples are invented. They show the tone, length and form, not real tasks.

### Short bug

> **Parcelly import: delivery note shows twice as Note and Instructions**
>
> Parcelly sends the customer's delivery note in 2 fields: `shipment.note` and `shipment.parcels[].instructions`. Their API docs describe both as notes for the whole shipment. We copy both into our label fields `Note` and `Instructions`, so the packing slip and the tracking page show the same note twice.
>
> In all 3,210 Parcelly shipments from the last 6 months that have both fields, the text is the same. Shipments with a different text never occurred.
>
> **Expected:** Add `Instructions` only when its text is different from `Note`. Existing shipments are not changed.

### Dictation to intro

Tobias said:

> the activity table needs an export of the rows the user currently sees with the columns below or whatever the user most likely wants please figure out a good shape for the endpoint but feel free to take my suggestion important it's still open how we do this technically […] workspace wide exports could have millions of events […] we already have the job queue so maybe use that […] put the file on S3 and send the user an email with a link it's fine if it takes a few minutes or an hour […] the important part is that a big export does not slow down the database for everyone else

Good intro:

> The activity table needs an export of the rows the user currently sees, with the columns listed below. The endpoint below is a suggestion. Please decide what works best on your side.
>
> The technical design is still open. Workspace-wide exports could contain millions of events, so we need to design for that size. A large export must not slow down the database for other users. Since we already have the job queue, it might make sense to run exports there. We could store the file on S3 and email the user a link when it is ready. Taking a few minutes or even an hour is fine.

### A suggested shape

> The export uses the same `filters` and `sort` as the table, plus a format. My suggestion for the endpoints:
>
> ```ts
> POST /v1/activity/export                            // the whole workspace
> POST /v1/projects/{projectId}/activity/export       // one project
>
> body: { filters, sort, format: "csv" | "xlsx" }  // filters and sort as in POST /v1/activity/query
> response: { exportId: string }                   // the file comes by email when it is ready
> ```
>
> Durations are numbers in seconds (`90`). In Excel they must be number cells, so users can calculate with them.

### Parts of a longer issue

> ## Webhook retries
>
> Keep in mind that the payment provider retries a webhook up to 5 times when we take longer than 10 s to answer. So the handler has to accept the same event more than once.
>
> The event ID is in the `Event-Id` header, so we can store it and skip events we already handled.
>
> ## Provider dashboard
>
> I will change the webhook URL in the provider dashboard.

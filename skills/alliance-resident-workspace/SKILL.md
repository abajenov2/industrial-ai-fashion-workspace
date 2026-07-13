---
name: alliance-resident-workspace
description: Use when helping a resident of Alliance Beinopen set up, audit, or maintain a safe AI-assisted local workspace connected to the Alliance platform, Knowledge Areas, role trajectory, digital trace, meetings, publications, resident journey, and site-update workflow. Trigger for tasks about resident workspace setup, Codex onboarding for Alliance residents, role/RLTR/TR workspace structure, safe publication workflow, meeting-to-knowledge processing, or converting the Alliance workspace protocol into operational steps.
---

# Alliance Resident Workspace

## Core Idea

Use this skill to help a **resident of Alliance Beinopen** work with Codex as a personal AI assistant. The base object is the **resident workspace**. A role (`RL`) is a configuration inside that workspace, not the workspace itself.

```text
resident workspace =
resident profile
+ role / roles
+ TR digital trace
+ TRxTR trajectory intersections
+ RLTR role trajectory
+ working rhythm
+ source library
+ meetings and transcripts
+ publications and site updates
+ access and authorship rules
+ cooperative chains
```

## Knowledge Layers

Use three layers without turning them into three full local copies:

```text
open Knowledge Base
-> approved KA assembled by the Architect role and published on Alliance

resident library
-> DocKA explanation on Alliance + canonical file in managed Yandex Disk

resident workspace
-> roles, TR/RLTR, tasks, private data, and only selected DocKA files
```

The Architect is a resident role with broader governance permissions, not a
different workspace species. The Architect assembles the reference KA and
releases approved open versions for other workspaces.

Use `KA6` as the navigation entry point: identify current role, maturity stage,
TR, target state, relevant `KA1-KA5`, RLTR, expert/case, and next dated action.
Do not confuse `KA6` with `RLTR`: `KA6` finds and validates a route; `RLTR`
describes the reference trajectory of a role.

Never download or distribute the full DocKA corpus by default. Select the
document needed for the current task, verify active resident access, and record
DocKA ID, KA, author, Alliance page, version, hash, and retrieval date.

## Indexing Rule

Use this distinction in workspace architecture, meeting processing, and site-update drafts:

```text
TR = digital trace of one resident / organization
TRxTR = concrete case where several trajectories intersect
A1.x = repeatable modular assembly derived from a requirements matrix, typical modules, and several similar TRxTR cases
RLTR = reference role trajectory derived from multiple TR/TRxTR
```

Do not assign `A1.x` to a single case, participant, direction, event, or topic. First record the case as `TRxTR`. Codex can propose `A1.x` only when several similar `TRxTR` cases show:

- stakeholder needs;
- requirements matrix;
- target indicators;
- resource constraints;
- typical modules: roles, documents, knowledge, procedures, statuses, agreements;
- a repeatable assembly logic;
- pilot validation or another digital crash test.

Working formula:

```text
requirements matrix + library of typical modules + unique assembly for a contour -> A1.x
```

## TRxTR Publishing Route

Default route for approved `TRxTR` artifacts:

```text
TRxTR -> Alliance room `AI оптимизация`
several similar TRxTR + requirements matrix + typical modules -> generalization into A1.x / KA6 / Knowledge Base Passport / Ontology / DocKA
```

Use `AI оптимизация` as the laboratory room for digital trace, workspace setup, validation, resident support, A1.x testing, and Industrial AI learning. If a `TRxTR` contains sensitive data, keep it private, anonymize it, or publish only in the approved closed mode after explicit user approval.

## Skill Package Rule

Whenever this skill folder is changed, immediately update:

- the installed Codex copy;
- the transferable archive `alliance-resident-workspace.zip`.

Never send or install an old archive after editing `SKILL.md`, `agents/openai.yaml`, or any file in `references/`.

## Installation Before First Run

When a workspace is deployed from the transferable archive instead of an already working Codex setup, do not jump straight to folders and drafts. First verify the skill itself:

```text
archive
-> check SKILL.md and references/
-> install into Codex
-> restart Codex if needed
-> confirm that the skill is actually visible
-> only then create the workspace
```

Check:

- where the archive is stored;
- whether the archive name matches the expected skill name;
- whether `SKILL.md` exists;
- whether `references/` exists;
- whether Codex needs a restart to load the skill;
- whether the archive is newer or older than the source folder.

This rule comes from the first live rollout of Lana's workspace: a missing installation step can look like a protocol problem when the real problem is that the skill was never properly loaded.

## Safety First

Before creating, moving, publishing, uploading, messaging, or sharing anything, classify the material:

- `public` - safe for public Knowledge Base / website publication after review.
- `resident` - for registered residents / "only for ours".
- `private` - personal, contractual, sensitive, or not yet approved.
- `temporary` - raw transcripts, exports, drafts, and working files.

Never publish, send, upload, or expose private/resident data without explicit user approval for that exact action and destination. Never store passwords, tokens, payment data, private Zoom codes, or raw sensitive exports inside the skill or open reference files.

Read `references/safety-rules.md` when the task involves access modes, transcripts, personal data, publishing, uploading, messaging, or third-party sharing.

## Standard Workflow

1. Identify the resident:
   - profile URL or name;
   - role / roles (`RL`);
   - current real trajectory (`TR`);
   - relevant trajectory intersections (`TRxTR`) if the task involves several participants;
   - target role trajectory (`RLTR`) if known.

2. Locate or create the workspace structure:
   - `00_Паспорт_рабочего_места`
   - `01_Роль_и_траектория`
   - `02_Рабочий_ритм_и_план_работ`
   - `03_Библиотека_роли`
   - `04_Проекты_и_рабочие_задачи`
   - `05_Встречи_и_цифровой_след`
   - `06_Публикации_и_обновления_платформы`
   - `07_Права_доступы_авторство`
   - `08_Кооперационные_цепочки_и_рынок_роли`
   - `99_Архив_исходников`

3. Create or update the resident passport:
   - who the resident is;
   - role / roles;
   - sources of truth;
   - access rules;
   - current tasks and rhythms;
   - how Codex should help.

4. Connect daily work to the Alliance platform:
   - posts;
   - projects;
   - comments;
   - events;
   - tasks;
   - meeting notes;
   - Knowledge Areas (`KA`);
   - documents / templates (`DocKA`);
   - glossary (`G`);
   - trajectory (`TR`);
   - trajectory intersections (`TRxTR`);
   - role trajectory (`RLTR`).

   Start navigation through `KA6`, then move to the relevant `KA1-KA5`, RLTR,
   expert/case, and only the DocKA document needed for the current task.

5. Maintain site synchronization:
   - put accepted-but-not-yet-published changes into `Очередь_правок_на_сайт.md`;
   - put published changes into `Опубликовано_на_сайте.md`;
   - route approved `TRxTR` publications to the `AI оптимизация` room unless the user chooses another destination;
   - treat the Alliance platform as the source of truth for public/resident-facing standards.

Read `references/workspace-protocol.md` for the full folder and artifact model. Read `references/site-sync.md` before preparing website updates.

When a user explicitly asks to publish a comment, edit a post, or place text on the already opened and logged-in Alliance website, do not refuse too early just because no direct browser tool is obvious in the surface list. First check the in-app browser path, inspect the page DOM, and verify whether the action is in fact possible.

## First-Run Checklist

When setting up a workspace for any role, do not start with the full structure unless the user asks for it. First create a minimal working result in 15-30 minutes:

1. Identify the workspace owner, profile URL, current role / roles, and nearest real task.
2. Create or choose the workspace folder.
3. Create only three required files:
   - `00_Паспорт_рабочего_места/Паспорт_рабочего_места.md`
   - `01_Роль_и_траектория/Мои_роли_RL.md`
   - `02_Рабочий_ритм_и_план_работ/Рабочий_ритм.md`
4. Fill them lightly:
   - who the resident is;
   - 1-3 current roles;
   - nearest 1-3 actions;
   - what can be shown to AI;
   - what must not be published, sent, uploaded, or stored locally without approval.
5. Output a short result:
   - what is clear about the role;
   - which sources of truth are used;
   - access risks;
   - next 1-3 actions;
   - what needs clarification from the workspace owner.

## Warm Resident Rule

Do not force every resident into a full workspace rollout on day one.

For a warm resident, partner, or new participant who is still checking whether the contour is useful, prefer this route:

```text
interest
-> one small experiment
-> one meeting / one material / one follow-up
-> first digital trace
-> decision whether a full workspace is needed
```

This keeps the entry soft and prevents the workspace from turning into a heavy onboarding ritual before value appears.

## Sources of Truth

Use this hierarchy:

1. Alliance platform publications are the source of truth for public and resident-facing standards.
2. Working registries can be the source of truth for structured datasets until the data is published or reconciled with the site. A registry may be an `md` file, a table file such as `xlsx` in the owner's local workspace, a platform table/section, or another agreed structured format.
3. Local workspace files are working copies, drafts, private rhythm files, and processing zones.
4. Archives, raw transcripts, dumps, exports, and downloaded sources are not sources of truth until processed, classified, approved, and linked to a platform post, `KA`, `DocKA`, `G`, `TR`, or site update.

If local files conflict with the Alliance platform, follow the platform for external/resident-facing work and record the local difference in `Очередь_правок_на_сайт.md` if it needs review.

## Technical Working Zones

Keep technical helper folders separate from role and publication truth.

Typical technical zones may include:

- `tools/`
- `work/`
- `outputs/`
- `node_modules/`

These are operational or generated folders. They can support the workspace, but they are not `KA`, `DocKA`, `TR`, `TRxTR`, or resident-facing standards by themselves.

Rule:

```text
technical helper folder != source of truth
```

If a useful result is produced inside a technical zone, it must still be classified, linked, and moved into the correct contour before being treated as part of the resident workspace.

## Working With Meetings

For calls, forums, interviews, and expert sessions:

1. Check whether the meeting should be recorded or transcribed.
2. Keep raw transcripts temporary and private until processed.
3. Convert the transcript into one of:
   - `TR` trajectory artifact;
   - interview;
   - meeting protocol;
   - Knowledge Base draft;
   - follow-up task list.
4. Link the artifact to `KA`, `DocKA`, `TR`, `TRxTR`, `RL`, `RLTR`, project, forum, `A1.x`, or site update.

Read `references/resident-journey-and-digital-trace.md` for meeting-to-knowledge and resident-journey patterns.

## Coordination Check

When two workspaces should operate in one contour, do not check only folders. Check whether the participants share the same working picture.

Minimum coordination test:

1. both sides open the same protocol source of truth;
2. both sides open one shared artifact of connection;
3. both Codex instances answer the same short form:
   - current role;
   - nearest task;
   - source of truth for this case;
   - next digital trace to appear;
4. compare the answers by meaning, not by style;
5. confirm the handoff is enough to continue without a long retelling;
6. confirm whether the contour needs a full rollout or only one small useful step first.

Coordination is working when the contour produces not only conversations, but new digital trace after the next meeting or action.

## Output Rules

When asked to set up or improve a workspace, produce:

- a short diagnosis of current state;
- the next 1-3 concrete actions;
- exact file paths or website objects to update;
- safety/access notes;
- draft text only when useful;
- a clear note when user confirmation is required before publishing, messaging, uploading, or sharing.

Keep the resident in control. Codex assists, structures, drafts, checks, and reminds; the resident approves actions that affect other people, the website, calendars, files outside the workspace, or public/resident-facing publication.

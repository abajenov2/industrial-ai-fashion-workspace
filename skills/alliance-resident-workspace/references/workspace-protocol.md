# Resident Workspace Protocol

The base object is the **resident workspace**. It belongs to a registered Alliance resident and is configured through one or more roles (`RL`).

## Core Formula

```text
resident workspace =
resident profile
+ role / roles
+ TR digital trace
+ TRxTR trajectory intersections
+ RLTR role trajectory
+ working rhythm
+ role library
+ meetings and transcripts
+ publications and site updates
+ access and authorship rules
+ cooperative chains
```

## Knowledge Layer Architecture

```text
open Knowledge Base
-> approved KA assembled by the Architect role and published on Alliance

resident library
-> DocKA page on Alliance + canonical file in managed Yandex Disk

resident workspace
-> roles, TR/RLTR, tasks, private data, selected DocKA files
```

The Architect is a resident with broader governance permissions. It is a role
configuration of the same workspace, not a separate workspace product.

`KA6` is the resident's entry point for navigation and validation:

```text
role + maturity + current TR + target
-> relevant KA1-KA5
-> RLTR / expert / case
-> selected DocKA if needed
-> action + owner + date
-> digital trace
```

`KA6` finds the route; `RLTR` describes the reference trajectory. Keep personal
practice in `TR` and joint cases in `TRxTR`.

Do not clone the full DocKA library into GitHub or every workspace. Select only
the file needed for the current task and record its DocKA ID, KA, author,
Alliance page, version, hash, and retrieval date. The canonical file should live
in one managed Yandex Disk catalog.

## Indexing Model

Use this model for workspace architecture:

```text
TR = digital trace of one resident / organization
TRxTR = concrete case where several trajectories intersect
A1.x = repeatable modular assembly derived from a requirements matrix, typical modules, and several similar TRxTR cases
RLTR = reference role trajectory derived from multiple TR/TRxTR
```

`RLTR` is named for a role, not for the person or organization whose trajectory
first exposed the pattern. A single `TR` or `TRxTR` creates an `RLTR` hypothesis,
not a reference trajectory. Keep the candidate in the internal RLTR registry
until several independent trajectories support its transitions and role
holders, adjacent roles, and the Architect validate it.

Use `TRxTR` as the bridge between two role trajectories. It must answer:

- where the first role was immediately before the intersection;
- what constraint or cost of error made another role necessary at that moment;
- what evidence or prior case made the second role trustworthy;
- what bounded product, document, or action connected the roles;
- what measurable result followed;
- which transition in each `RLTR` the case confirms, challenges, or leaves open.

Example: `Miditi x Alina Tsutsu` records the point where an expert enters the
trajectory of an M brand after internal stabilization and before a risky new
channel launch. The expert has a demonstrated prior case and a small entry
product, but the new pilot remains an unproven `TRxTR` until its result is
measured. The case can later refine both the `RLTR` of an M brand and the `RLTR`
of an expert.

A single case, participant, event, topic, or direction is not `A1.x`. First record the case as `TRxTR`; propose an `A1.x` only when several similar `TRxTR` cases show a repeatable assembly and can be described through:

- stakeholder needs;
- requirements matrix;
- target indicators;
- resource constraints;
- typical modules: roles, documents, knowledge, procedures, statuses, agreements;
- pilot validation or another digital crash test.

Working formula:

```text
requirements matrix + library of typical modules + unique assembly for a contour -> A1.x
```

## TRxTR Publishing Route

Default route:

```text
TRxTR -> Alliance room `AI оптимизация`
several similar TRxTR + requirements matrix + typical modules -> generalization into A1.x / KA6 / Knowledge Base Passport / Ontology / DocKA
```

Use `AI оптимизация` as the laboratory room for digital trace, workspace setup, validation, resident support, A1.x testing, and Industrial AI learning. Sensitive cases stay private, are anonymized, or are published only in the approved closed mode.

## Installation Before First Run

If the workspace is being launched from a transferred archive, first verify the skill itself:

```text
archive
-> check SKILL.md and references/
-> install into Codex
-> restart Codex if needed
-> confirm the skill is visible
-> only then create the workspace
```

Do not diagnose the protocol before checking whether the skill was actually installed and loaded.

## Standard Structure

Use this structure when creating or auditing a local workspace:

```text
00_Паспорт_рабочего_места/
01_Роль_и_траектория/
02_Рабочий_ритм_и_план_работ/
03_Библиотека_роли/
04_Проекты_и_рабочие_задачи/
05_Встречи_и_цифровой_след/
06_Публикации_и_обновления_платформы/
07_Права_доступы_авторство/
08_Кооперационные_цепочки_и_рынок_роли/
99_Архив_исходников/
```

## First-Run Checklist

For the first setup of any role, create a minimal working result before filling the full structure.

Required first files:

```text
00_Паспорт_рабочего_места/Паспорт_рабочего_места.md
01_Роль_и_траектория/Мои_роли_RL.md
02_Рабочий_ритм_и_план_работ/Рабочий_ритм.md
```

The first run should answer:

- who owns the workspace;
- what profile / role / roles are known;
- what the nearest real task is;
- current `KA6` position: role, maturity, TR, target, and main question;
- what can be shown to AI;
- what must not be published, sent, uploaded, or stored locally without approval;
- which 1-3 actions should happen today or tomorrow.

## Warm Resident Path

Not every resident needs a full rollout immediately.

For a warm resident or pilot participant, prefer:

```text
interest
-> one small experiment
-> one meeting / one material / one follow-up
-> first digital trace
-> decision whether a full workspace is needed
```

This keeps the entry light and tests value before scaling the contour.

## Passport Contents

The passport should contain:

- resident identity and profile URL;
- role / roles (`RL`);
- current trajectory (`TR`);
- trajectory intersections (`TRxTR`) when several residents / roles / organizations work together;
- target role trajectory (`RLTR`) if known;
- candidate `A1.x` only if a repeatable modular assembly is visible and can be checked against needs, requirements, modules, validation, result, and repeatability;
- publication room for approved `TRxTR`: usually `AI оптимизация`;
- sources of truth;
- access rules;
- working rhythm;
- current projects;
- what Codex should help with;
- what Codex must not do without approval.

## Sources of Truth

Each workspace should distinguish:

- platform truth: published Alliance posts, docs, events, comments, profiles, and standards;
- registry truth: working registries used for structured datasets; they may be `md`, table files such as `xlsx` in the owner's local workspace, platform tables/sections, or another agreed structured format;
- local truth: private rhythm, drafts, tasks, and local workspace structure;
- raw inputs: transcripts, dumps, exports, downloaded files, and archives.

For public or resident-facing claims, prefer platform truth. For structured registry work, use the current agreed registry but reconcile it with the published site. For private daily work, use local truth. Treat raw inputs as evidence to process, not as final standards.

## Technical Working Zones

Technical folders may exist near the workspace, for example:

- `tools/`
- `work/`
- `outputs/`
- `node_modules/`

They are support zones, not sources of truth.

If a result appears there, it still must be classified and linked before it becomes part of `KA`, `DocKA`, `TR`, `TRxTR`, or another resident-facing contour.

## Role Configuration

A role is not a separate base workspace. It is a configuration of the resident workspace.

Describe each role with:

- `RBS`: requirements for role success;
- `FBS`: functions;
- `SBS`: components, tools, documents, people;
- `WBS`: regular work and rhythms;
- `DSM`: connections to people, KA, DocKA, TR, TRxTR, RLTR, A1.x, projects, markets.

## Archive Rule

`99_Архив_исходников` is not a source of truth. It is a routing zone:

```text
delete
or move into active workspace
or turn into post / comment / protocol / TR / TRxTR / DocKA / KA / A1.x update
or leave archived with status
```

## Coordination Check

Two workspaces are coordinated when the people behind them can answer the same operational questions, not merely when their folders look similar.

Minimum check:

1. open the same protocol source of truth;
2. open one shared artifact of connection;
3. ask both Codex instances the same short form:
   - current role;
   - nearest task;
   - source of truth for this case;
   - next digital trace;
4. compare the answers by meaning, not by style;
5. confirm the handoff is enough to continue the work without a long retelling;
6. confirm whether a small useful step is enough before a full rollout.

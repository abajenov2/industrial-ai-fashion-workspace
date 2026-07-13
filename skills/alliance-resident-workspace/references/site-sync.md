# Site Synchronization

Use this reference when work changes the Alliance platform, Knowledge Base, glossary, ontology, events, posts, comments, or resident-facing standards.

## Skill Archive Synchronization

If any file in the skill folder changes, update the installed Codex copy and rebuild the transferable archive before sharing it:

```text
alliance-resident-workspace/
-> installed Codex copy
-> alliance-resident-workspace.zip
```

The archive is the file sent to residents. It must always match the current skill folder.

## Source of Truth

For public and resident-facing standards, the Alliance platform is the source of truth.

Core platform sources include:

- Offer: https://alliance.beinopen.ru/post/1487/
- About Alliance: https://alliance.beinopen.ru/docs/about/
- Alliance Ontology: https://alliance.beinopen.ru/post/3341/
- Knowledge Areas (`KA`): https://alliance.beinopen.ru/docs/2836/
- Knowledge Base Passport: https://alliance.beinopen.ru/post/3775/
- A1 modular assemblies / contours: https://alliance.beinopen.ru/post/2169/
- Resident workspace protocol: https://alliance.beinopen.ru/post/3871/

Local files are:

- drafts;
- working copies;
- local indexes;
- private or temporary processing zones.

Working registries may be the source of truth for structured datasets until reconciled with the site. A registry may be an `md` file, a table file such as `xlsx` in the owner's local workspace, a platform table/section, or another agreed structured format. If a registry conflicts with the published Knowledge Base, prefer the site for `KA` structure and record the registry mismatch for review.

Archives, raw transcripts, dumps, exports, downloaded files, and temporary materials are not sources of truth. They are analysis inputs until processed, classified, approved, and linked to a platform post, `KA`, `DocKA`, glossary entry, trajectory, or site update.

## Pending Updates

Use `Очередь_правок_на_сайт.md` for accepted local decisions not yet moved to the site.

Record:

- date;
- material / decision;
- where to update on site;
- access mode;
- author / coauthors;
- why it matters;
- links to KA / RL / TR / DocKA;
- who checks;
- status;
- verification rule after publication.

## Published Updates

Use `Опубликовано_на_сайте.md` after the change is published.

Record:

- date;
- title;
- URL;
- access mode;
- authors / coauthors;
- what changed semantically;
- verification result;
- remaining follow-up.

## Publication Workflow

```text
local draft
-> review with resident / owner
-> access classification
-> website update
-> verification on site
-> entry in `Опубликовано_на_сайте.md`
-> follow-up task if needed
```

Do not publish or send without explicit user approval.

## Browser Publication Rule

If the user explicitly asks Codex to publish a comment, edit a post, or place approved text on the Alliance site, and the site is already open in the in-app browser, do not conclude too early that publication is impossible.

First:

1. check whether the in-app browser route is available;
2. open or reuse the relevant tab;
3. confirm login state and presence of the form in the DOM;
4. inspect the real editor implementation.

Important:

- some Alliance fields are not plain visible `textarea` elements;
- the visible editor may be CodeMirror or another markdown UI;
- the hidden form field may sync only after typing into the visible editor.

So the operational rule is:

```text
do not refuse -> inspect DOM -> identify the real editor -> type into the visible editor -> submit -> verify the published result
```

After submission, always verify:

- the text appeared on the page;
- the URL / anchor resolves if it is a comment;
- access mode, draft/public status, and coauthors did not change unexpectedly.

## Coauthors

When adding coauthors on the Alliance platform, use comma-separated usernames if the site field expects nicknames. Verify after saving:

- access mode did not change;
- draft/public status is correct;
- all coauthors are visible;
- links to profiles resolve.

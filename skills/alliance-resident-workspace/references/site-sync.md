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

## Opening the In-App Browser Yourself

An empty tab list or a browser webview attach timeout is not yet a user blocker.
Before asking the user to open a tab, try the application-level recovery path.

On the current macOS Codex / ChatGPT desktop app:

1. invoke `View -> Open Browser Tab` in the application menu;
2. focus the browser address bar;
3. paste the exact URL through the clipboard and press Enter;
4. do not type a Latin URL with simulated keystrokes: the active Russian
   keyboard layout can turn it into a malformed search query;
5. once the page exists, attach or claim that tab through the in-app browser
   API; if needed, create one fresh controlled tab after the browser panel is
   open and navigate directly with `goto`;
6. only after this recovery path fails should Codex return a browser blocker.

Do not inspect or transfer cookies, passwords, browser profiles, local storage,
or session databases. The recovery action opens the supported browser surface;
authentication continues to use the user's existing in-app session.

Operational sequence:

```text
explicit publication approval
-> View / Open Browser Tab
-> clipboard-paste exact URL
-> attach or create controlled tab
-> confirm login and form in DOM
-> identify visible editor and hidden submitted field
-> replace only approved content
-> verify exact editor-to-form synchronization
-> save
-> verify rendered page
-> independent public GET when the page is public
-> move entry from site queue to publication journal
```

## Alliance Markdown Editor

On Alliance post edit pages the visible Markdown editor may be CodeMirror while
the submitted value lives in hidden `textarea#id_text`. A reliable replacement
pattern is:

1. inspect `input` and `textarea` attributes in the DOM;
2. require exactly one visible editor, commonly
   `textarea:not(#id_text)`;
3. write the approved text to the browser clipboard;
4. press `ControlOrMeta+a`, then `ControlOrMeta+v` in the visible editor;
5. read `#id_text.value` back into the tool session and compare it exactly with
   the approved source before saving;
6. verify that the title, access radio, room, coauthors and tags still have the
   intended values;
7. submit through the unique save button and verify the resulting URL.

Do not compare only a short visual excerpt. For a full post replacement, exact
length and exact body equality are the pre-save gate. Also scan the outgoing
body for private paths, contacts, transcripts, tokens and other data outside the
approved publication scope.

## Publication Verification

After saving an approved post or comment:

1. confirm the browser navigated to the expected public or resident URL;
2. check several unique markers from the new text and the required external
   links in the rendered DOM;
3. confirm forbidden private markers are absent;
4. for a public page, fetch the URL independently and check the same markers;
5. add the verified result to `Опубликовано_на_сайте.md`;
6. remove the corresponding entry from `Очередь_правок_на_сайт.md`;
7. keep the final page open as a deliverable when it is useful to the user.

The publication is not complete merely because the save button was clicked.
It is complete after the rendered page and journal agree with the approved
source.

## Coauthors

When adding coauthors on the Alliance platform, use comma-separated usernames if the site field expects nicknames. Verify after saving:

- access mode did not change;
- draft/public status is correct;
- all coauthors are visible;
- links to profiles resolve.

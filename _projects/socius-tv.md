---
title: "Socius TV"
subtitle: "Digital signage with no server and no build step, where the screens are a git commit away — and an agent can change what is on the wall by being asked."
blurb: "A signage system whose published state is a file in the repository, wrapped in a purpose-built MCP server with draft, validate and publish semantics so an agent can safely update a public display."
order: 9
kind: "Signage + MCP server"
stack: "Plain HTML, CSS, JavaScript, Vercel, MCP server"
techniques: "Authored MCP server, draft-validate-publish tool design, agent-operated public display"
role: "Designer and sole engineer"
period: "2026"
status: "Live on the wall"
status_kind: "live"
domain: "Operations & communication"
live: "https://sociustv.vercel.app"
repo_note: "Private repository"
mermaid: true
---

## Problem

The gym has televisions on the wall. They should show the class schedule, what is
coming up, a countdown to the next event, and whatever needs announcing this week.

Commercial digital signage sells this as a subscription per screen, with a hosted
editor, an account, and a player application to install and keep updated. For two
screens in a gym that is a recurring cost and an ongoing dependency in exchange for
a great deal of functionality nobody here needs.

The actual requirement is small and specific: someone should be able to change what
is on the screens in under a minute, from a phone, without logging into anything;
the screens should pick the change up on their own; and the whole thing should still
work in two years without anyone maintaining it. The last point rules out most of
the obvious approaches — a signage system that needs a dependency upgrade to keep
displaying a schedule has failed at its one job.

## What I built

Two pages and a file.

An **editor** builds a display. A **player** renders one full-screen and is what the
television points at. And a single **published snapshot file, committed to the
repository, is the only source of truth for what is on the screens.** Committing a
change to that file redeploys the site, and every screen picks it up on its next
poll.

<div class="diagram">
<div class="diagram__cap">Figure 1 — The published file is the state</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  ED["Editor<br/>build a display"] --> SNAP["published snapshot<br/>committed to the repo"]
  MCP["MCP server<br/>agent tools"] --> DRAFT["Draft"]
  DRAFT --> VAL{"validate"}
  VAL -- fails --> DRAFT
  VAL -- passes --> PUBACT["publish"]
  PUBACT --> SNAP
  SNAP --> DEPLOY["Static deploy"]
  DEPLOY --> P1["Screen — player"]
  DEPLOY --> P2["Screen — player"]
  P1 -. "polls" .-> DEPLOY
  P2 -. "polls" .-> DEPLOY
</pre>
</div>
</div>

No build step. No server. No framework. No database. The state of the physical
screens in a physical room is a versioned file, which means it has a history, a
diff, an author per change, and a one-command rollback. Signage systems costing
hundreds of dollars a year do not give you that.

It is also deliberately its **own repository and its own deployment**, separate from
the business dashboard that links to it. Nothing imports across the boundary.
Working on signage cannot break the dashboard and working on the dashboard cannot
take down the screens on the wall. When two systems have genuinely different
failure consequences, coupling them to share a little code is a bad trade.

## How it works

The more interesting half is that the signage is **agent-operable**, because I wrote
an MCP server for it.

Model Context Protocol is how a language model is given typed tools instead of being
told to go and edit files. The server exposes the operations signage actually needs —
set the ticker, set a countdown, post or remove an announcement, set the weekly
schedule, replace schedule rows, add an image slide, prune expired items, inspect the
current state, validate, and publish.

The design decision that matters is that **every content tool writes to a draft, and
only `publish` pushes the draft to the screens.** There is a separate `validate` that
checks the draft first.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Why the draft boundary exists</div>
<div class="diagram__body">
<pre class="mermaid">
sequenceDiagram
  autonumber
  participant P as Person
  participant A as Agent
  participant D as Draft
  participant S as Screens

  P->>A: "no kids class Monday,<br/>and put the tournament countdown up"
  A->>D: set announcement
  A->>D: set countdown
  A->>D: update schedule rows
  A->>A: validate draft
  A-->>P: here is what will change
  P->>A: go ahead
  A->>S: publish
  Note over D,S: nothing reaches the wall<br/>until publish is called
</pre>
</div>
</div>

This is the part I would point to as tool design rather than plumbing. An agent
editing a public display is a small but real trust problem — the output is visible to
every member and visitor in the building, and a partial edit is worse than no edit. A
tool surface where every write is reversible and invisible until one explicit
irreversible call makes the whole capability safe to expose. The agent can work
freely; the wall only changes on purpose.

The practical result is that changing the screens is a sentence. "No kids class
Monday, put up the tournament countdown" updates the schedule, posts the
announcement, sets the countdown, and reports what will change before anything
changes. Expired announcements are pruned rather than accumulating, which is the
failure mode of every noticeboard ever built.

## AI techniques used

- **An MCP server, authored for this system.** Not a generic file-editing agent
  pointed at a repository — a purpose-built tool surface expressing the operations
  the domain actually has.
- **Draft-validate-publish tool semantics.** Every write is to a draft; a validator
  checks it; one explicit call commits. The safety property is in the shape of the
  tool surface, not in instructions asking the model to be careful.
- **Validation as a first-class tool** the agent can call on itself before showing a
  human anything.
- **Narrow, domain-shaped tools.** "Set the countdown" and "prune expired" rather
  than "write this JSON". Narrow tools are harder to misuse and their failures are
  legible.
- **Reversibility by design.** Published state is a committed file, so every change
  has an author, a diff and a rollback.

## Outcome

- Two screens running on a static deployment with no subscription and no player
  software to maintain.
- The state of the screens is version-controlled, with history and one-command
  rollback.
- Updating the wall is a spoken sentence rather than a login, and the person doing it
  does not need to know how any of it works.
- No build step and no dependencies means nothing to keep alive. It will still work
  in two years.
- Isolated from the business dashboard, so neither can take the other down.

## What I'd do differently

The player trusts that the published file is well-formed, because validation happens
before publishing rather than at render. That is the right place for it in the normal
path, but it means a malformed file reaching the screens has no graceful degradation —
the display just breaks, in public, in front of everyone. I would add a
last-known-good fallback in the player: if the current snapshot fails to parse, keep
rendering the previous one and surface the problem quietly rather than showing a blank
television.

I would also give the editor and the MCP server a shared schema definition. Right now
both understand the snapshot format and they agree because I wrote them together. That
agreement is a convention, not an enforced contract, and the first divergence will be
found on the wall.

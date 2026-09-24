---
title: "SociusVault"
subtitle: "An agent-maintained knowledge base with a hard boundary between immutable source material and derived knowledge — so the librarian can never overwrite the library."
blurb: "A second brain where a language model is the only writer and a human is the only reader. Immutable sources, a governed schema, cross-referenced entities, and tracked unknowns."
order: 8
kind: "Agent-maintained knowledge base"
stack: "Markdown, Obsidian, Python, MCP, Claude Code agent skills"
techniques: "Schema-governed agent writes, immutable source layer, entity cross-referencing, explicit unknown tracking"
role: "Architect and sole engineer"
period: "2026 — maintained continuously"
status: "In production"
status_kind: "live"
domain: "Knowledge management"
repo_note: "Private repository"
mermaid: true
---

## Problem

A note-taking system fails in one of two ways. Either capture is easy and retrieval
is impossible — a thousand files, no structure, nothing findable — or the structure
is good and capture is too much work, so it goes stale within a month and you stop
trusting it.

The reason both happen is that the same person has to do both jobs. Capturing wants
to be instant and unstructured: a voice note in the car, a screenshot, a paragraph
dumped after a conversation. Organising wants to be deliberate and consistent: the
right folder, the right title, links to related things, contradictions with what was
already recorded resolved rather than duplicated. Nobody does the second job
faithfully for material they captured in three seconds.

So split the jobs. A person captures. An agent organises. The interesting question is
what structure that requires in order to be safe, because an agent with write access
to your knowledge base can also quietly destroy it.

## What I built

A vault with three layers and a strict rule about who may write to each.

<div class="diagram">
<div class="diagram__cap">Figure 1 — The write boundary</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  H["Human"] -->|"drops source material"| RAW["raw/<br/>immutable sources"]
  H -->|"dictates, pastes, recaps"| CAP["Capture"]
  CAP --> AG["Agent"]
  RAW -->|"read only, never modified"| AG
  GOV["Governing schema document<br/>folders, conventions, workflows"] --> AG
  AG -->|"sole writer"| WIKI["wiki/<br/>derived knowledge base"]
  WIKI -->|"read in Obsidian"| H
  AG --> TBD["Tracked unknowns<br/>open questions"]
  TBD --> H
  ARCH["Retired sections<br/>frozen, marked, not deleted"] -.- WIKI
</pre>
</div>
</div>

**The source layer is immutable.** Anything dropped in — a document, a roster, a
clipped article, a raw voice note — is read by the agent and never altered by it.
This single rule is what makes the system safe to hand an agent. If a derived page is
wrong, it can be regenerated from sources that are still intact. Without it, one
confused pass can destroy the evidence and you have no way back.

**The derived layer has exactly one writer.** The knowledge base is agent-maintained
end to end: it files, titles, cross-references, resolves contradictions and maintains
hub pages. The human reads it in an ordinary Markdown editor and does not hand-edit
it. Two writers with different conventions is how a schema dies.

**The schema is a document the agent must obey.** Folder structure, naming, required
front matter, how entities are cross-referenced, what happens when new information
contradicts old — all of it is written down in a governing file the agent reads every
session. The structure survives because it is enforced on every write, not because
someone remembers it.

**Entities, not just notes.** People, events, projects and concepts are first-class,
each in a known place, cross-linked. Three domains — personal life, the academy, and
the tournament production business — share one people directory, because the same
person genuinely appears in more than one and duplicating them across silos is how a
knowledge base starts lying to you.

**Unknowns are tracked, not silently dropped.** When capture leaves something
open — a name not caught, a date unconfirmed, a follow-up owed — it becomes an
explicit tracked item rather than vanishing. This matters more than it sounds. The
default failure of LLM summarisation is confident smoothing: the gap gets papered
over with something plausible and you never learn it was a gap. Recording the unknown
as an unknown is what keeps the base honest.

**Retirement is marked, not deleted.** When a section's responsibility moves
elsewhere — the inventory ledger graduated out of the vault into the business
operating system — the old material is frozen, labelled with what replaced it and
when, and left in place. Deleting it loses history; leaving it unmarked means someone
answers a question from stale data. Marking it costs a line and prevents both.

## How it works

Capture is conversational and deliberately unstructured. A dictated life update, a
pasted message thread, a recap of a class that just finished, a calendar reminder — it
all goes in the same way and the agent works out what it is, what it concerns, which
existing entities it touches, and where it belongs. Different inputs route to
different capture flows, and the routing is part of the committed procedure rather
than improvised each time.

Querying goes the same channel: a plain question, answered from the base with the
pages it came from. That, ultimately, is the point of the structure — the reason to
enforce a schema on every write is so a question can be answered from the base
instead of from a search across a thousand loose files.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Capture, maintain, query</div>
<div class="diagram__body">
<pre class="mermaid">
sequenceDiagram
  autonumber
  participant H as Human
  participant A as Agent
  participant R as raw/
  participant W as wiki/

  H->>A: unstructured capture
  A->>A: classify: what is this about?
  A->>W: read existing entities
  A->>A: reconcile with what is recorded
  A->>W: file, link, update hub pages
  A->>H: report open unknowns
  Note over A,W: schema enforced on every write

  H->>A: "what do we know about X?"
  A->>W: traverse entities and links
  A-->>H: answer with its sources
  H->>A: lint the vault
  A->>W: find orphans, broken links,<br/>schema violations, stale pages
</pre>
</div>
</div>

A maintenance pass runs on demand: orphaned pages, broken cross-references, schema
violations and pages that have gone stale. Without it, entropy wins slowly enough
that you do not notice until retrieval has already stopped working.

## AI techniques used

- **Schema-governed agent writes.** A committed governing document constrains every
  write. Consistency is enforced per-operation, not audited later.
- **An immutable source layer** that bounds the blast radius of any bad pass and
  makes derived content regenerable.
- **Single-writer discipline.** Exactly one agent maintains the derived layer; the
  human reads. No convention drift from competing editors.
- **Entity extraction and cross-referencing** from unstructured conversational
  input — working out who and what a capture concerns and linking it into the
  existing graph.
- **Explicit unknown tracking** as a counter to confident smoothing. Gaps are
  recorded as gaps.
- **Scheduled self-linting** — the agent audits its own output for structural decay.
- **MCP integrations** so captures can be drawn from connected systems rather than
  only pasted in.

## Outcome

- Capture takes seconds and requires no decisions, while the base stays structured.
  Both halves of the usual trade-off, because two different parties do them.
- Questions get answered from the base with sources attached, rather than from
  recollection.
- Three domains that genuinely overlap share one entity graph instead of three
  diverging copies of the same people.
- Follow-ups and unconfirmed facts are visible as a list rather than lost in prose.
- The knowledge base has not gone stale, which is the failure every previous attempt
  reached within about a month.

## What I'd do differently

The vault accumulated working scratch files — intermediate extractions and
analysis output, some of it containing personal data — sitting alongside the
knowledge base rather than in a clearly quarantined, ignored location. It is
private and it is now ignored, but the right design is a temporary workspace that
is structurally incapable of being committed, decided on day one. Data handling
should be a property of the layout, not a `.gitignore` entry added after someone
notices.

I would also make the schema versioned. It has evolved, and pages written under
earlier conventions are not automatically migrated — so the base holds several
generations of structure at once and the agent has to tolerate all of them. A
version stamp per page plus a migration pass would be considerably cleaner than
tolerance.

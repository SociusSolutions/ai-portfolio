---
title: "Socius OS"
subtitle: "An AI operating system that runs a real business — accounting, members, leads, comms, curriculum and reporting — from one version-controlled brain."
blurb: "A single repository that operates a business. Six domains, eighteen generated dashboards, fourteen agent skills, and a read-only HUD that answers where the numbers stand without anyone opening a spreadsheet."
order: 1
kind: "AI operating system"
stack: "Python, PowerShell, TypeScript, FastAPI, SQLite, Claude Code agents & MCP"
techniques: "Agent skills as procedure, MCP tool integration, read-only analyst subagent, spec-driven automation"
role: "Architect and sole engineer"
period: "2026 — present, committed to daily"
status: "In production"
status_kind: "live"
domain: "Business operations"
repo_note: "Private repository"
mermaid: true
---

## Problem

Running a brick-and-mortar business generates a specific kind of exhaustion that
has nothing to do with the work itself. The membership system knows who pays. The
CRM knows who enquired. The accounting software knows what was spent. The booking
system knows who showed up. None of them talk, so every real question — *are we
growing, did that ad work, how many of those trials converted, what did we
actually spend on gear* — becomes an hour of tab-switching and mental arithmetic.

Worse, the answer expires. Whatever you worked out on Tuesday is wrong by Friday,
so the work repeats. The cost is not the hour; it is that you stop asking, and
then you are operating blind.

I wanted one place that knew everything, refreshed itself, and could be asked a
question in plain language.

## What I built

Socius OS is a single repository that functions as the operating brain for the
business. It is not an application with a UI — it is a structured knowledge base,
an integration layer, a set of executable procedures, and a generated dashboard,
all under version control and all readable by a language-model agent.

The organising principle is **hub and satellite**. The OS holds the maps, the
procedures, the integration contracts and the decision record. The customer-facing
applications — the website, the members platform, the tournament tooling, the
signage — stay in their own repositories with their own deploys, and the OS reaches
them through pointer files and domain maps. It references; it never absorbs. That
constraint is what keeps a system this broad from collapsing into a monolith
nobody can change safely.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Hub and satellite architecture</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  KNOW["The brain<br/>context · domains · references · playbooks"]
  SK["skills + agents<br/>executable procedure"]
  DEC["decisions/log.md<br/>append-only"]
  INTEG["Integration layer — MCP<br/>CRM · gym management · accounting · ads"]
  OUT["Generated outputs<br/>JARVIS HUD · 18 dashboards · inventory · finance"]
  SAT["Satellites — own repos, own deploys<br/>website · members · tournament · signage"]

  KNOW --> SK
  SK --> INTEG
  INTEG --> OUT
  SK --> DEC
  KNOW -. "pointers, never absorbs" .-> SAT
</pre>
</div>
</div>

Four pieces do the real work.

**Domain maps.** Eight documents, one per operational area, each describing what
the area is, where its data lives, what is automated and what is still manual. A
domain map is deliberately *not* the code. It is the thing an agent reads to
orient itself before touching anything, which is why a new capability can be added
without re-explaining the business every time.

**Integration contracts.** Every wired system has a contract document, and each one
opens with the same two sections: what is UI-only, and what fails silently. That
ordering is not stylistic. The expensive failures in integration work are never the
documented endpoints — they are the write that returns `200` and does nothing, and
the field the API will happily read but never let you set. Writing those down first
turned a recurring multi-hour tax into a five-minute read.

**Skills as procedure.** Fourteen agent skills encode the recurring operational
work: a morning check that reports what is overdue and what moved, a funnel refresh,
an inbox triage that drafts replies, a spam sweep, a stale-lead scan, a monthly
financial close, an inventory ledger, a curriculum planner. Each is a
version-controlled document that an agent executes, which means the procedure is
reviewable, diffable and improvable — the opposite of instructions living in
someone's head.

**A read-only HUD.** The JARVIS dashboard is a static page with no build step and
no server. It never queries anything live. Instead the agent is the write head: a
refresh re-probes every integration, pulls current figures, runs the record loaders
and regenerates a single data file. The dashboard just renders it. Splitting write
from read this way means the dashboard cannot be slow, cannot be down, and cannot
lie about freshness — it carries the timestamp of the refresh that produced it.

## How it works

The daily cycle is scheduled, not manual.

<div class="diagram">
<div class="diagram__cap">Figure 2 — The daily refresh cycle</div>
<div class="diagram__body">
<pre class="mermaid">
sequenceDiagram
  autonumber
  participant S as Scheduler
  participant A as Agent
  participant X as External systems
  participant R as Records store
  participant D as Dashboard

  S->>A: morning chain
  A->>X: probe every integration
  X-->>A: health + current figures
  A->>A: funnel, spam sweep, inbox triage,<br/>stale leads, ad performance
  A->>R: load and roll up records
  R-->>A: derived series
  A->>D: regenerate data file
  A->>A: write dashboards to disk
  Note over A,D: dashboard renders a snapshot,<br/>stamped with refresh time
</pre>
</div>
</div>

Two design decisions carry most of the weight.

**Append-only decision log.** Every non-obvious decision gets a dated entry with
its reasoning. The value is not documentation discipline for its own sake — it is
that an agent picking up work months later can read *why* something is the way it
is, and stops proposing the thing that was already tried and rejected.

**Playbooks that encode losses.** After one paid campaign spent $751 and produced
three attended trials and zero members, the outcome became ten non-negotiable rules
with a pre-flight checklist that must be run before any spend goes live. Encoding a
failure as an executable gate is considerably more useful than remembering it.

## AI techniques used

- **Skills as version-controlled procedure.** Operational work is written as
  documents an agent executes, not as code paths. Procedures get reviewed in pull
  requests like anything else.
- **A read-only analyst subagent** for questions that need figures cross-checked
  across the membership, CRM and accounting systems. It returns the reconciled
  conclusion rather than the raw pulls, and cannot write anything.
- **MCP as the integration boundary.** Each external system is reached through a
  Model Context Protocol server — some vendor-published and self-hosted, one
  written from scratch for the signage system — so the agent gets typed tools
  instead of ad-hoc HTTP, and access is auditable per system.
- **Contract-first tool use.** The agent reads the API contract document before
  its first call against any system. The contracts lead with the silent-failure
  cases because that is where the hours go.
- **Generated artefacts, never hand-edited.** Dashboards and data files are
  outputs. The generator is the source of truth, and drift between them is a bug
  with an owner.

## Outcome

- The weekly question *where does the business stand* went from an hour of
  tab-switching to opening one page.
- Membership, CRM, accounting, ad spend and attendance are reconciled in one
  place, on a schedule, without anyone remembering to do it.
- Lead handling moved fully in-house after an outsourced provider was dropped,
  with the trial flow — enquiry, booked, showed, closed — instrumented end to end.
- Financial close, inventory counts and tax classification run as documented
  procedures rather than annual archaeology.
- Recurring operational work is now reviewable. When a procedure is wrong, the fix
  is a diff, and it stays fixed.

## What I'd do differently

I split lead automation into a second repository early on, and the two converged on
the same problems independently — an opt-out audit and a spam classifier each got
built twice before anyone noticed. The boundary was drawn around *how* the work ran
rather than *what* it was about. I would draw it around the domain instead, and
require a search of the other repository before any new check ships. It is now
written into the contributing rules, which is the cheap version of the lesson.

I would also add the eval harness earlier. The classification skills — expense
categories, spam, lead stage — were trusted on inspection for longer than they
should have been. Retrieval and extraction quality is measurable, and measuring it
changes what you are willing to automate.

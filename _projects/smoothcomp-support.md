---
title: "Tournament Support App"
subtitle: "Turns a registration export into an accurate schedule: division merges, match counts, mat assignments and a defensible finish time — before competition day."
blurb: "Multi-tenant tournament planning with four-role access control enforced in the database, and a preview tier that lets organisers model a live registration without touching canonical data."
order: 6
kind: "Operations SaaS"
stack: "React 19, TypeScript, Vite, Tailwind 4, Radix, Supabase (Postgres + RLS)"
techniques: "Spec-driven agent development, in-repo agent skill, phase-gated delivery with UAT records"
role: "Architect and sole engineer"
period: "2026 — four milestones shipped"
status: "In production use"
status_kind: "live"
domain: "Tournament operations"
repo_note: "Private repository"
mermaid: true
---

## Problem

A grappling tournament is a scheduling problem disguised as a sporting event. Several
hundred competitors register across divisions split by age, weight, belt and gender.
Many divisions end up with two or three entrants — too few for a real bracket — so
the organiser merges compatible ones. Every merge changes the bracket format, which
changes the number of matches, which changes how long the day runs.

Organisers do this in a spreadsheet, and the estimate is a guess. The consequences
land on everyone: a day that runs three hours long means competitors warming up five
times, parents leaving before their kid competes, referees past their limit, and a
venue charging overtime. A day that finishes early means a venue booked and paid for
nothing.

The question the tool has to answer is exactly one: **given this registration list
and these merges, when does the event actually finish?**

## What I built

A multi-tenant application that takes the registration platform's export and walks
an organiser from raw registrants to a time-accurate mat schedule.

<div class="diagram">
<div class="diagram__cap">Figure 1 — From export to schedule</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  CSV["Registration export"] --> IMP["Import<br/>validate columns"]
  IMP --> DIV["Divisions<br/>aggregate, filter, sort"]
  DIV --> MRG["Merge planning<br/>suggest compatible divisions"]
  MRG --> EST["Match estimation<br/>count by bracket format"]
  EST --> SCH["Schedule<br/>mats, start times, day assignment"]
  SCH --> DUR["Projected duration<br/>and finish time"]
  CFG["Bracket profiles<br/>per organiser"] --> EST
  CFG --> CON["Conflict detection"]
</pre>
</div>
</div>

The pipeline is straightforward. The access model is where the engineering is.

**Four roles, enforced twice.** Administrators, editors, managers and viewers have
genuinely different capabilities, and those capabilities are enforced in the database
through row-level security *and* reflected in the interface. Both layers matter and
for different reasons: the database is the boundary that actually holds, and the
interface is what stops a manager from discovering their limits by clicking a button
that then fails. Hiding a control without securing the row is theatre; securing the
row without hiding the control is a bad product.

**Roles are per-event, not global.** A person can be an editor on one organiser's
event and a viewer on another's. Every routing and interface decision resolves the
role *for the event in hand* rather than reading a global flag — the kind of
distinction that looks pedantic until a shared user account leaks one organiser's
registration data to another.

**A preview tier that cannot contaminate the real data.** This was the hardest
requirement. Managers want to upload a registration snapshot mid-registration to see
projected match counts and timings. They must not be able to alter the canonical
import that the actual event runs on. Rather than bolting on a permission check, the
separation is a column on the data itself — every row is tagged canonical or preview,
and every query in the application respects that tag. Isolation is a property of the
schema, not a rule someone has to remember to apply at each call site.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Two data tiers under one schema</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  subgraph ROLES["Per-event roles"]
    A["Admin"]
    E["Editor"]
    M["Manager"]
    V["Viewer"]
  end

  A --> CAN["Canonical tier<br/>the event that runs"]
  E --> CAN
  M --> PRE["Preview tier<br/>modelling only"]
  M -. "schedule adjustments only" .-> CAN
  V --> READ["Read-only views"]

  CAN --> RLS{"Row-level security<br/>plus tier tag on every query"}
  PRE --> RLS
  READ --> RLS
  RLS --> DB[("Postgres")]
</pre>
</div>
</div>

Registration gating ties it together: administrators and editors mark an event's
registration open or closed, and a manager can only upload previews while it is open.
The permission is a function of the event's state, not just the person.

## How it works

React 19 with Vite and Tailwind on the front, Supabase for authentication, Postgres
and row-level security behind it. Authentication covers email and password plus
federated sign-in, with administrator-created accounts and per-organisation role
assignment.

The delivery process is as much the artefact as the application. The repository
carries its own planning system: a project definition, a roadmap, per-milestone
requirements, phase plans with research notes, and user-acceptance records for each
phase. Four milestones have shipped through it. Each phase has a written plan and a
signed-off acceptance record, which is why a solo project accumulated a genuine
audit trail of what was built and why — and why the codebase analysis documents
(stack, architecture, conventions, integrations, testing, concerns) stay current
enough for an agent to read before touching anything.

## AI techniques used

- **Spec-driven agent development.** Every milestone began as written requirements
  and a roadmap, then phase plans, then implementation. Agents executed the plans;
  the plans were the reviewable artefact.
- **An agent skill committed to the repository**, so the recurring operational run
  is a version-controlled procedure rather than a remembered sequence.
- **Codebase analysis as maintained documentation** — architecture, conventions,
  integrations, testing and known concerns kept as files an agent reads first, which
  is what keeps agent-written code consistent with what is already there.
- **Phase-gated delivery with acceptance records**, so agent-built work has a human
  verification step before it counts as shipped.

## Outcome

- Organisers get a defensible projected finish time before the event, from the
  registration list and the merge plan they actually intend to use.
- Four milestones shipped, each with requirements, a plan and an acceptance record.
- Managers can model a live registration without any path to the canonical data,
  enforced by the schema rather than by discipline.
- Access control holds at the database boundary, so an interface bug is not a data
  breach.
- The estimating idea that started as a single-purpose calculator became a
  multi-tenant product with real roles.

## What I'd do differently

The role model grew one role at a time — three, then four, with per-event precision
arriving in a later milestone as a correction. Each step was a migration plus an
audit of every query and every interface guard. The requirement was foreseeable: a
tool serving multiple organisers was always going to need per-tenant roles. I would
model the full permission matrix up front and implement it incrementally against
that shape, rather than discovering the shape by extending it.

I would also put the estimation engine under test with real historical event data
earlier. The match-count arithmetic per bracket format is the whole product, and it
was validated against expectation before it was validated against what actually
happened on the day.

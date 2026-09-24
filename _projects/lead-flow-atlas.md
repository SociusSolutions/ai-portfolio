---
title: "Lead Flow Atlas"
subtitle: "The CRM's API refuses to describe its own automations. So the automations became specifications, and the specifications became testable."
blurb: "A marketing platform that will not tell you what its own workflows do, answered with portable YAML specs, outcome-reconstructed monitoring, and a conversation auditor that finds the messages a human would wince at."
order: 2
kind: "Automation as spec"
stack: "Python (stdlib), YAML, generated HTML console, unittest"
techniques: "Spec-as-source-of-truth, fingerprint attribution, LLM conversation auditing, agent browser automation"
role: "Architect and sole engineer"
period: "2026"
status: "In production"
status_kind: "live"
domain: "Lead generation & CRM"
repo_note: "Private repository"
mermaid: true
---

## Problem

The business runs its lead handling — enquiry, follow-up, booking, reminders,
no-show recovery, re-engagement — on a commercial marketing platform. Roughly
twenty-five workflows, each a branching sequence of emails, texts, waits and tag
changes, all built by dragging boxes in a browser.

Then a reasonable question arrives: *which of these is actually running, and what
does it say?*

The platform's public API cannot answer it. I verified this against the live
account:

```
GET /workflows/?locationId=...      200   id, name, status, version, updatedAt
GET /workflows/{id}                 404
GET /workflows/{id}/executions      404
GET /workflows/{id}/contacts        404
GET /workflows/{id}/enrollments     404
```

You can list the workflows. You cannot read inside one, and you cannot see a single
execution. The visual builder is the only way in, which makes every audit a manual
click-through and every piece of institutional knowledge a screenshot.

Two consequences fall out of that, and they shape the entire design. **Nothing can
import your automation** — no tool can extract it, so any machine-readable
description has to be authored. And **there is no engine telemetry** — an outbound
message records that its source was "a workflow" but never which one, so monitoring
cannot be read off the platform at all. It has to be reconstructed from outcomes.

## What I built

The Atlas is three things: a portable specification of every lead automation, a
sync that reconstructs what is actually running, and an auditor that reads
conversations the way a person would.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Specs in, console out</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  GEN["gen_flows.py<br/>author of record"] --> FLOWS["flows/*.yaml<br/>~25 portable specs"]
  BIND["bindings/gym.yaml<br/>the only local file"] --> BUILD
  TAX["taxonomy.yaml<br/>four axes"] --> FACETS["facets.yaml<br/>hand-corrected"]
  FLOWS --> FACETS
  FLOWS --> BUILD["build.py"]
  FACETS --> BUILD
  CRM[("Marketing platform<br/>list + messages only")] --> SYNC["sync.py"]
  SYNC --> SNAP["snapshot.json<br/>reconstructed telemetry"]
  SNAP --> BUILD
  BUILD --> CONSOLE["console.html<br/>review + request changes"]
  CRM --> AUDIT["audit.py<br/>conversation auditor"]
  AUDIT --> FINDINGS["findings<br/>shapes a human would wince at"]
</pre>
</div>
</div>

**The specs are the source of truth, and a generator owns them.** Each workflow is
a YAML document describing its trigger, its steps, its waits, its branches and its
exact message copy. Critically, the spec files are *written by a generator* — hand
edit one and the next run silently reverts you. The generator is the author of
record, and a run against unchanged inputs must leave the spec directory
byte-identical. That property is what makes the specs trustworthy rather than
decorative.

**Everything is portable except one file.** A spec says "submits the trial enquiry
form" and "send the adult welcome message". A single bindings file maps those names
to this gym's actual form identifiers, calendars and booking links. Standing the
whole system up for a different gym is: copy the bindings file, swap the
identifiers, leave every spec untouched. The automation design became an asset
independent of the account it runs in.

**Monitoring is reconstructed by fingerprint.** Since the platform records only
that a message came from "a workflow", the sync attributes each send by matching its
body against the copy in the specs. Retired wordings are kept in a `previous_bodies`
list so historical sends stay correctly attributed after copy changes — otherwise
every edit would silently orphan its own history.

**A classification vocabulary, applied deliberately.** A taxonomy defines four
gym-agnostic axes; a derivation script drafts each flow's position on them from its
spec; then those drafts are hand-corrected and committed. Machine-drafted,
human-ratified — the draft saves the typing, the review is where the correctness
comes from.

## How it works

The most interesting component is the auditor, because it is the part that needed a
language model rather than a rule.

Ordinary monitoring can catch a hard failure. What it cannot catch is
*embarrassment*: an automated reminder firing into the middle of a live human
conversation, a message naming a day for a class nobody ever replied about, a
follow-up going out after someone asked to be left alone. These are not schema
violations. They are judgement calls, and they are exactly what damages a small
business's reputation.

The auditor reads whole conversations in time order — every inbound and outbound
message, automated and human together — and looks for those shapes.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Audit pass over one conversation</div>
<div class="diagram__body">
<pre class="mermaid">
flowchart TD
  A["Pull full conversation<br/>in time order"] --> B["Attribute each outbound<br/>by copy fingerprint"]
  B --> C{"Automation sent<br/>after a human reply?"}
  C -- yes --> F1["Finding: talking over a person"]
  C -- no --> D{"Named a day<br/>nobody confirmed?"}
  D -- yes --> F2["Finding: unanswered commitment"]
  D -- no --> E{"Sent after<br/>an opt-out?"}
  E -- yes --> F3["Finding: compliance breach"]
  E -- no --> OK["Clean"]
  F1 --> R["Ranked findings<br/>with the transcript excerpt"]
  F2 --> R
  F3 --> R
</pre>
</div>
</div>

A second thing the tests enforce is subtler. The platform automatically appends its
own opt-out line to the first text message a contact ever receives, whichever
workflow happens to send it. So any message body that *also* carries an opt-out line
reads as two the moment it lands first. A unit test asserts no spec body contains
its own opt-out text — a formatting rule that only exists because of an undocumented
platform behaviour, now permanently enforced.

Because workflow interiors can only be changed through the browser, the change side
is agent-driven browser automation. That produced its own catalogue of hard-won
detail, all of it now written down: an occluded browser window delivers clicks to
the parent page but silently drops them inside a cross-origin builder iframe, so
every click vanishes while the page looks perfectly healthy; the singular builder
URL loads and the plural one spins forever in a way that is indistinguishable from
that same bug; saving a step leaves the workflow dirty and needs a separate
top-level save; and merge fields are interactive chips, so select-all-and-retype
destroys them silently.

## AI techniques used

- **Specification as the primary artefact.** The language model's job is to author
  and maintain precise specs, not to improvise against a live system. The spec is
  reviewable; the live change is mechanical.
- **LLM-judged conversation auditing** for failure modes that are qualitative
  rather than structural — tone, timing and talking over people.
- **Fingerprint attribution** to recover causality from a system that discards it,
  with versioned copy history so the reconstruction survives edits.
- **Machine-drafted, human-ratified classification.** Facets are derived
  automatically then corrected by hand and committed, so the vocabulary stays
  accurate without being typed from scratch.
- **Agent browser automation with a documented failure catalogue.** Every trap that
  cost a session is recorded as a pre-flight check rather than re-learned.

## Outcome

- Every lead automation has a precise, diffable description for the first time.
  Reviewing what the business says to a prospect is reading a file, not clicking
  through a builder.
- The automation design is portable. Another gym is a bindings file, not a rebuild.
- Sends are attributed to specific workflows despite the platform never reporting
  which one, so monitoring exists where the vendor provides none.
- Compliance and tone problems surface as ranked findings with the transcript
  attached, instead of surfacing as a complaint.
- Platform behaviours that cost hours are now unit tests and pre-flight checks.

## What I'd do differently

The generator arrived after the first specs were hand-written, which meant a
migration and a period where both were half-true. Generated artefacts should be
generated from the first commit — the discipline is cheap at the start and expensive
to retrofit.

I would also treat the fingerprint attribution as a measured component rather than
an assumed-correct one. It works, but I know that by inspection. It deserves a
labelled set and a reported accuracy figure, because every monitoring number
downstream inherits its error.

---
title: "How I build with AI"
subtitle: "The working method behind the systems on this site: procedures as version-controlled documents, typed tool surfaces instead of improvisation, specifications before code, and measurement before trust."
eyebrow: "Method"
description: "Agent skills, MCP tool design, spec-driven delivery and evaluation — the method behind the systems in this portfolio."
mermaid: true
---

Most of what is described on this site was built by one person, alongside running a
business. That is only possible because of a specific way of working, and the method is
more transferable than any individual system.

Five principles, each of which I arrived at by getting it wrong first.

## Procedures are documents, not habits

The recurring work of a business is procedural: close the books, refresh the funnel,
triage the inbox, plan the week's classes, sweep the spam. Traditionally that knowledge
lives in someone's head and degrades.

I write each one as a **version-controlled document that an agent executes**. Roughly
fourteen of them across the business. The consequences are larger than they first look:

- A procedure can be **reviewed in a pull request** like any other change.
- When it is wrong, the fix is a **diff**, and it stays fixed.
- It carries its own validators, so the quality bar travels with the capability.
- It can be invoked by a schedule, by a person, or by another procedure.

The failure this replaces is not forgetting to do the work. It is doing the work
slightly differently every time, so the output cannot be compared across months.

## Tools should be typed, narrow, and shaped like the domain

The lazy way to give a model capability is filesystem access and a hopeful instruction.
The better way is a **tool surface that expresses the operations the domain actually
has**.

I write MCP servers for this. The clearest example is the
[signage system]({{ '/projects/socius-tv/' | relative_url }}), where the tools are "set
the ticker", "set the countdown", "post an announcement", "prune expired", "validate",
"publish" — not "write this file".

The design decision that mattered most there is worth stating on its own, because it
generalises to every agent that touches something real:

<div class="diagram">
<div class="diagram__cap">Figure 1 — Safety from tool shape, not from instructions</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  AG["Agent"] --> W1["Content tools<br/>many, reversible"]
  W1 --> DR["Draft<br/>invisible to the world"]
  DR --> VAL["validate<br/>a tool the agent calls on itself"]
  VAL --> H{"Human sees<br/>what will change"}
  H -- approves --> PUB["publish<br/>one explicit, irreversible call"]
  PUB --> REAL["The real world"]
  H -- rejects --> DR
</pre>
</div>
</div>

Every write goes to a draft. A validator can be called by the agent on its own work.
Exactly one call has consequences. The agent can then work freely, because the shape of
the tool surface — not the model's carefulness — is what prevents a half-finished edit
from reaching anyone.

The same idea appears in the finance work as a harder constraint: those tools are
**read-only against the accounting system entirely**. The output is a fix list a human
applies. Some systems should not be writable by an agent at all, and deciding which is
a design judgement, not a capability limit.

## Contracts before calls, and failures written down

Integration work does not go wrong at the documented endpoints. It goes wrong at the
write that returns success and does nothing, the field the API will read but never let
you set, and the operation that only exists in the web interface.

So every wired system in my systems has a **contract document, and each one opens with
two sections: what is user-interface-only, and what fails silently.** That ordering is
the whole point. An agent reads the contract before its first call against a system, and
a recurring multi-hour tax became a five-minute read.

The same discipline applies to the tooling itself. Working through a vendor's visual
builder produced a catalogue of traps — an occluded browser window that delivers clicks
to the parent page but silently drops them into a cross-origin iframe, a URL that
differs by one character between "loads" and "hangs forever in a way indistinguishable
from that same bug". Each one is now a **pre-flight check rather than a lesson
re-learned**, and one of them was already written down when it cost a second session,
which is its own lesson about reading your own notes.

## Specifications are the artefact; code is the output

Every substantial system here began as a written specification and an implementation
plan, reviewed as documents, before code existed.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Delivery loop</div>
<div class="diagram__body">
<pre class="mermaid">
flowchart TD
  IDEA["Intent"] --> Q["Clarify: purpose,<br/>constraints, success criteria"]
  Q --> SPEC["Written specification<br/>reviewed as a document"]
  SPEC --> PLAN["Phase plan"]
  PLAN --> IMPL["Agent implementation<br/>against the plan"]
  IMPL --> UAT["Acceptance record<br/>human verification"]
  UAT -- passes --> SHIP["Shipped"]
  UAT -- fails --> PLAN
  SHIP --> DEC["Decision log<br/>append-only, dated, with reasoning"]
  DEC -.-> SPEC
</pre>
</div>
</div>

The [tournament application]({{ '/projects/smoothcomp-support/' | relative_url }}) is the
clearest case: four milestones, each with requirements, a roadmap, phase plans, research
notes and a signed acceptance record — a genuine audit trail on a solo project.

Two supporting habits do a disproportionate amount of work:

**Maintained codebase analysis.** Architecture, conventions, integrations, testing and
known concerns kept as current files in the repository. This is what keeps agent-written
code consistent with what is already there instead of subtly foreign to it.

**An append-only decision log.** Dated entries with reasoning. The value is not
documentation for its own sake — it is that an agent resuming work months later reads
*why*, and stops proposing what was already tried and rejected.

## Measure before you trust, and keep a human at the gate

This is the principle I was slowest to adopt and would now put first.

A language model always returns something. An extractor always extracts. A retrieval
system always retrieves. Confidence is free and completely uncorrelated with
correctness, so "it looks right" is not evidence — it is the absence of evidence.

Where it matters, quality gets a number:

- The [retrieval pipeline]({{ '/projects/document-intelligence-pipeline/' | relative_url }})
  carries an evaluation harness with known-answer query sets, so a change to chunking or
  ranking moves a measurable figure. Without that, tuning retrieval is superstition.
- The [curriculum engine]({{ '/projects/members-portal/' | relative_url }}) scores every
  generated candidate against a rubric with a pass threshold, and gates each audience
  rendering on a machine-checked readability standard. Unscored generation produces
  volume, and volume of mediocre output is worse than none — it costs the reviewer their
  time and then disappoints the reader.

And where the output reaches a person, a person approves it:

- Generated document metadata is a draft until reviewed; nothing becomes discoverable
  unreviewed.
- Drafted replies to members and prospects are never auto-sent. That is a written rule,
  not a setting.
- Ambiguous record matches are **flagged rather than guessed**, because a confidently
  wrong match makes a gap invisible, which is worse than the gap.

The one to be most alert to is the failure mode nobody notices: **confident smoothing.**
Asked to summarise or extract, a model will paper over what it did not find with
something plausible. In my knowledge base, unknowns are therefore recorded *as unknowns* —
an explicit tracked item rather than a gap prose closed over. It is a small mechanism
against the single most expensive thing these systems do wrong.

## What this adds up to

| Principle | Mechanism | The failure it prevents |
|---|---|---|
| Procedures as documents | Version-controlled agent skills | Drift, unreviewable process, knowledge in one head |
| Typed, narrow tools | Purpose-built MCP servers | Half-finished edits reaching the real world |
| Draft, validate, publish | One irreversible call | An agent changing something in public by accident |
| Contracts before calls | Silent-failure sections first | Hours lost to writes that return success |
| Specs before code | Reviewed plans, acceptance records | Building the wrong thing efficiently |
| Measure before trust | Eval harnesses, rubric thresholds | Believing a system that is confidently wrong |
| Human at the gate | Review before publish or send | Generated content becoming fact unchallenged |
| Generate, never hand-edit | Generator owns the artefact | Reports that quietly disagree with their source |

None of this is about prompting. It is ordinary engineering discipline applied to a
component that is fluent, eager, and wrong often enough to matter.

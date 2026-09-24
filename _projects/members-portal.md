---
title: "Members Platform & Curriculum Engine"
subtitle: "Generates a week of kids classes as structured game specifications, then renders the same plan three ways — for the coach, for the kid, and for the parent — each validated against its own readability standard."
blurb: "A curriculum engine that writes constraints-led lesson plans, scores them against a rubric before they are kept, and produces three audience-specific renderings of one plan with automated reading-level gates."
order: 7
kind: "Generative content platform"
stack: "Next.js, TypeScript, Supabase (Postgres + RLS), Google OAuth"
techniques: "Schema-constrained generation, rubric-scored candidates, multi-audience rendering, readability validation gates"
role: "Architect and sole engineer"
period: "2026"
status: "In production"
status_kind: "live"
domain: "Members & curriculum"
live: "https://members.sociusbjj.com"
repo_note: "Private repository"
mermaid: true
---

## Problem

Planning children's classes was the single largest time sink in the business — the
owner's own assessment, and the reason this exists.

The teaching method is constraints-led: instead of drilling a technique by
repetition, you design a game with rules and constraints that force the skill to
emerge. It works considerably better than demonstration-and-drill, and it is far
harder to plan. Every session needs games that target a specific skill, scale to two
different age bands, work with whatever number of kids turn up, and stay genuinely
fun — because a bored eight-year-old simply stops.

Then the same plan has to be communicated to three audiences who need completely
different things from it. A coach needs setup, constraints, coaching cues and
progressions. A kid needs to know how to win, in words a nine-year-old reads without
help. A parent needs to know what their child worked on, in a way that prompts a
conversation in the car rather than a shrug.

Written by hand that is several hours a week, every week, forever. And the quality
drifts with how tired you were on Sunday night.

## What I built

An engine that generates a week's games as structured specifications, scores them
against a rubric before any are kept, packages the survivors into a class plan, and
renders that one plan into three audience-specific views — each of which must pass
its own automated validation.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Generation, scoring, rendering</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  REQ["Skill bucket + week<br/>e.g. pinning, frames and hips"] --> GEN["Candidate generation<br/>schema-constrained"]
  GEN --> DUAL["Dual age bands<br/>same game, scaled twice"]
  DUAL --> RUB["Rubric evaluator<br/>scored, not eyeballed"]
  RUB --> PASS{"Threshold"}
  PASS -- below --> DROP["Rejected"]
  PASS -- above --> LIB[("Game library<br/>persisted specs")]
  LIB --> PLAN["Class plan<br/>dateless, schedulable"]
  PLAN --> V1["Coach view<br/>setup, constraints, cues"]
  PLAN --> V2["Kid card<br/>how to win"]
  PLAN --> V3["Parent prose<br/>what they worked on"]
  V1 --> CHK1{"Structurally complete"}
  V2 --> CHK2{"Reading level 5 or below"}
  V3 --> CHK3{"Level 8 or below,<br/>ends with a question"}
</pre>
</div>
</div>

Four decisions make this work rather than produce plausible-sounding filler.

**Games are schemas, not prose.** A generated game is a structured object with named
fields — objective, constraints, win condition, space, progressions, the skill it
targets. Because it is structured, it can be validated, stored, queried, compared and
reused. Prose can only be read and re-read. Everything downstream depends on this
choice.

**Every game is generated twice, as one game.** The same game is produced scaled for
younger and older bands simultaneously, rather than generating separately and hoping
they correspond. Coaches run mixed classes; the two versions have to be recognisably
the same game or the session falls apart.

**Candidates are scored, not inspected.** A rubric evaluator runs over every
generated candidate and only those above threshold are kept. This is the part that
distinguishes a generator from a content firehose. Unscored generation produces
volume, and volume of mediocre lesson plans is worse than none — it costs the coach
the review time and then disappoints the class.

**Each audience view has a machine-checked standard.** The kid card must come in at a
fifth-grade reading level or below. The parent view must be eighth-grade or below and
must end with a question, because a question is what actually starts a conversation
in the car. The coach view must be structurally complete — no missing setup, no
missing progression. These are automated gates, not review guidance, and a draft that
fails one does not ship.

<div class="diagram">
<div class="diagram__cap">Figure 2 — One plan, three audiences, three standards</div>
<div class="diagram__body">
<pre class="mermaid">
flowchart LR
  P["Class plan<br/>structured"] --> C["Coach"]
  P --> K["Kid"]
  P --> R["Parent"]
  C --> CN["Needs: setup,<br/>constraints, cues,<br/>progressions"]
  K --> KN["Needs: how to win,<br/>readable unaided"]
  R --> RN["Needs: what they did,<br/>a reason to talk"]
  CN --> CG["Gate: structural<br/>completeness"]
  KN --> KG["Gate: reading level"]
  RN --> RG["Gate: reading level<br/>+ ends on a question"]
</pre>
</div>
</div>

**Plans are dateless.** Generation produces a plan; scheduling assigns the date and
the coach later. Separating the two means a plan is reusable content rather than a
calendar entry, and the library accumulates instead of expiring.

The platform side is a Next.js application on Supabase with row-level security and
federated sign-in, running in production for members, with invite-based onboarding.

## How it works

The generation cycle is a batch, not a request. A skill bucket and a week's theme go
in; candidates come out in both age bands; the rubric evaluator scores them; those
above threshold are persisted to the library with their scores recorded. Packaging a
batch into a class plan fills a plan template and renders the three views, each run
through its validator before it is written to disk.

The validators are where most of the reliability lives. A readability threshold is a
crude measure of writing quality and an excellent measure of *audience fit* — it
catches the specific, constant failure of a language model writing for children,
which is drifting into adult sentence construction while keeping simple words. The
rule is mechanical and it holds every time, which is more than can be said for
remembering to check.

## AI techniques used

- **Schema-constrained generation.** Output is a structured object against a defined
  schema, which is what makes it validatable, storable and reusable.
- **Rubric-based candidate evaluation** with an explicit pass threshold, so
  generation quality is enforced rather than assumed.
- **Paired multi-variant generation** — one game, two age bands, generated together
  so they stay coherent.
- **Multi-audience rendering from a single source** with a different standard per
  audience, rather than three independently written documents that drift apart.
- **Automated readability gates** as the mechanical check on audience fit, catching
  the failure mode that human review reliably misses when tired.
- **Agent skills as the interface.** Generation and packaging are invoked as
  version-controlled procedures with their validators attached, so the quality bar
  travels with the capability.

## Outcome

- The largest recurring time cost in the business — several hours of class planning a
  week — became a batch run plus a review.
- Lesson quality stopped depending on how tired the planner was on a Sunday night,
  because the threshold is enforced by a rubric rather than by judgement at the end
  of a long day.
- Coaches, kids and parents each get material written for them, instead of one
  document that half-serves all three.
- The game library accumulates as structured, searchable, reusable content rather
  than a folder of documents.
- Parent communication went from nothing to a weekly note that reliably ends in a
  question — the cheapest engagement mechanism in the business.

## What I'd do differently

The rubric was written before there was much generated output to calibrate it
against, so the early thresholds were guesses. They needed adjustment once real
candidates existed, and a batch scored under the old thresholds is not comparable to
one scored under the new. I would version the rubric explicitly and record which
version scored each game, so quality trends over time mean something.

I would also close the loop with what actually happened in class. Right now the
system knows whether a game passed the rubric; it does not know whether the kids
enjoyed it or the skill emerged. A one-tap coach rating after each session would make
the library self-improving instead of merely growing, and that feedback signal is
worth more than any further refinement of the generator.

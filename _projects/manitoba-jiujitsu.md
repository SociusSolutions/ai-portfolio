---
title: "Provincial Association Site & Regulatory Archive"
subtitle: "A WordPress replacement that ships as static files, generates its own regulatory PDFs from typed source content, and tracks athlete licensing compliance from an email inbox."
blurb: "Static-export site replacing a legacy CMS, with a PDF generator reading typed content modules directly and an agent-run sweep that reconciles regulatory licence submissions against the athlete roster."
order: 10
kind: "Static site + compliance tooling"
stack: "Next.js 16 (App Router), Tailwind 4, static export, rsync deploy, Python, Gmail API"
techniques: "Agent-run inbox reconciliation, generated compliance reporting"
role: "Designer and sole engineer"
period: "2026"
status: "Live"
status_kind: "live"
domain: "Sport governance & compliance"
live: "https://www.manitobajiujitsu.com"
repo_note: "Private repository"
mermaid: true
---

## Problem

A provincial sport association had a WordPress site doing two unrelated jobs badly.

It was the public face of the province's largest grappling competition — schedule,
divisions, rules, registration information — content that must be exactly right in
the weeks before the event and is read mostly on phones in a hurry.

It was also the archive for combative-sports regulation: the rules, the licensing
requirements, and the documents athletes and officials actually have to comply with.
Reference material, with a long life, that needs to be citable and available as
documents rather than only as web pages.

WordPress served both through a stack of plugins, a database, and a theme nobody
remembered configuring — an attack surface and a maintenance obligation for a
volunteer-run organisation, in exchange for a content editor nobody was using.

Behind the site sat a separate and genuinely painful problem. Every competitor needs a
licence number from the provincial combative sports commission. Collecting several
hundred of them arrives as replies trickling into a shared inbox over weeks, in no
format, and someone has to reconcile that against the roster and chase whoever is
missing — before a hard regulatory deadline, with the event unable to run for anyone
unlicensed.

## What I built

**A static site with no server-side anything.** Next.js on the App Router, built as a
static export and deployed by rsync to shared hosting. No Node runs on the server; no
database; no plugin ever needs updating. For a volunteer organisation this is the
right trade — the site cannot be compromised through a stack it does not have, and it
will still be serving correctly with nobody tending it.

**A PDF generator that reads the site's own typed content.** The regulatory documents
are generated from the same typed content modules the web pages render from, imported
directly by the generator at build time rather than duplicated into a separate
document pipeline. One source of truth: the page and the PDF cannot disagree, because
they are the same content. This is the reason the project pins a modern runtime — the
generator imports the typed modules directly, which needs type stripping at runtime,
and an older runtime rejects it outright.

<div class="diagram">
<div class="diagram__cap">Figure 1 — One content source, two outputs</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  SRC["Typed content modules<br/>rules, divisions, regulation"] --> WEB["Static site build"]
  SRC --> PDFGEN["PDF generator<br/>imports the modules directly"]
  WEB --> OUT["Static export"]
  PDFGEN --> DOCS["Regulatory PDFs"]
  DOCS --> OUT
  OUT --> RSYNC["rsync to shared hosting"]
  RSYNC --> LIVE["Live site — no server runtime"]
</pre>
</div>
</div>

**Deployment is deliberately manual.** The pipeline could be automated and is not,
because the target directory held the live legacy site during cutover, and an
automated deploy that overwrites a production document root is a single mistake away
from taking a provincial association offline in competition season. The rule is
written into the deployment documentation with its reasoning attached, so the next
person to look at it understands why the convenient thing was refused.

## How it works

**Licence compliance is an agent-run reconciliation.** Replies land in a shared
inbox. An agent procedure sweeps it, extracts licence numbers from unstructured
replies, reconciles them against the athlete roster, updates the submission record,
refreshes a tracker, and exports a current list of who is still missing.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Licence reconciliation sweep</div>
<div class="diagram__body">
<pre class="mermaid">
flowchart TD
  INBOX["Shared inbox<br/>replies in any format"] --> SWEEP["Sweep for new replies"]
  SWEEP --> EX["Extract licence number<br/>from unstructured text"]
  EX --> MATCH{"Match to roster"}
  MATCH -- matched --> REC["Update submission record"]
  MATCH -- ambiguous --> FLAG["Flag for a human"]
  REC --> TRACK["Refresh tracker"]
  TRACK --> MISSING["Export current missing list"]
  MISSING --> CHASE["Targeted follow-up"]
  FLAG --> CHASE
</pre>
</div>
</div>

The sweep is re-runnable and reports a current count on demand, which changes the
character of the deadline entirely. Instead of one frantic reconciliation the week
before, the organiser can ask at any point how many are outstanding and chase exactly
those people. Ambiguous matches are flagged rather than guessed — a misattributed
licence number is worse than a missing one, because it makes a gap invisible.

A separate archival procedure exports the regulatory correspondence into a structured
record, so the association has a durable archive rather than an inbox.

## AI techniques used

- **Extraction from unstructured replies.** Licence numbers arrive in prose, in
  signatures, in forwarded messages, in photographs of documents. Pulling them out
  reliably is the work.
- **Reconciliation against a known roster**, with ambiguity flagged for a human
  rather than resolved by guessing. Silent wrong matches defeat the purpose of
  tracking.
- **Idempotent re-runnable sweeps.** Running it twice changes nothing, so it can be
  run whenever someone wants a number.
- **Generated reporting.** The tracker and the missing list are outputs of the sweep,
  never hand-maintained, so they cannot drift from the source record.

## Outcome

- The legacy CMS is gone. The site is static, has no database and no plugins, and
  requires no maintenance to keep serving.
- Regulatory documents and web pages come from one typed source and cannot disagree.
- Licence compliance went from a deadline-driven scramble to a number available on
  demand, with follow-up targeted at exactly the people still outstanding.
- Regulatory correspondence is archived as a structured record rather than living in
  an inbox.
- A volunteer organisation now runs on infrastructure that does not need a volunteer
  to tend it.

## What I'd do differently

The manual deploy was the right call during cutover and is now just friction — the
legacy site it was protecting is gone. It should graduate to an automated deploy with
a dry-run diff and an explicit confirmation step, which keeps the safety property that
motivated the rule while removing the toil. Leaving a temporary safeguard in place
after its reason expires is its own kind of technical debt.

I would also give the extraction step a labelled test set. It works, and I know that
because the numbers reconcile — but the failure I actually care about is a silent
mismatch, and that is precisely the one an unmeasured extractor will not tell me
about.

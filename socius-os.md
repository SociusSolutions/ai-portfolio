---
title: "Socius OS, by business domain"
subtitle: "The same operating system, broken out the way the business actually is. What is automated in each area, what it replaced, and the specific engineering problem each one turned out to be."
eyebrow: "Domain breakout"
description: "Socius OS by business domain — accounting, members and onboarding, leads and funnel, comms, curriculum, and reporting."
mermaid: true
---

The [Socius OS deep dive]({{ '/projects/socius-os/' | relative_url }}) covers the
architecture. This page covers the coverage — what the system actually does in each
part of the business, because a claim to have automated *operations* means nothing
until you can say which operations.

Six domains. Each one started as recurring manual work, and each turned out to have a
genuinely different technical problem at the centre of it.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Six domains over one integration layer</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  subgraph SRC["Systems of record"]
    GYM["Gym management<br/>memberships, check-ins"]
    CRM["CRM<br/>3 sub-accounts"]
    BOOKS["Accounting"]
    ADS["Ad platforms"]
  end

  subgraph DOM["Domains"]
    D1["1 · Finance and accounting"]
    D2["2 · Members and onboarding"]
    D3["3 · Leads and funnel"]
    D4["4 · Comms"]
    D5["5 · Curriculum"]
    D6["6 · Ops and reporting"]
  end

  BOOKS --> D1
  GYM --> D2
  CRM --> D3
  ADS --> D3
  CRM --> D4
  GYM --> D2
  D1 --> HUD["Dashboard + 18 generated reports"]
  D2 --> HUD
  D3 --> HUD
  D4 --> HUD
  D5 --> HUD
  D6 --> HUD
</pre>
</div>
</div>

<div class="domains">

<div class="domain">
<span class="domain__num">Domain 01</span>
<h3>Finance and accounting</h3>
<p>Monthly close, expense classification and tax preparation, run against the
accounting system through a self-hosted MCP server. The interesting problem here
is that one expense needs classifying on three independent axes at once — operating
versus other, deductible or not, recurring versus one-time — because each axis feeds a
different question. Collapsing them into a single category, which is what most
bookkeeping does, destroys the ability to answer any of them.</p>
<ul>
  <li>Monthly income and expense report built from the ledger, not from memory</li>
  <li>Three-axis classification with a growing vendor rules table, so a vendor seen before is not re-decided</li>
  <li>Only genuinely new or ambiguous transactions are surfaced for a human call</li>
  <li>Three parallel views: as the books see it, business-only, and recurring run-rate</li>
  <li>Backlog triage and a drift audit that re-checks already-classified expenses</li>
  <li>Statutory expense codes validated against the national tax schedule</li>
  <li>Read-only against the accounting system — it produces a fix list, never a write</li>
</ul>
</div>

<div class="domain">
<span class="domain__num">Domain 02</span>
<h3>Members and onboarding</h3>
<p>The lifecycle from first visit to settled member. The technical problem is that
intent lives in one system and truth lives in another: the CRM records that someone
was <em>invited</em> to a class, and only the gym's check-in data knows whether they
actually turned up. Every honest number in this domain comes from reconciling the two
rather than trusting either.</p>
<ul>
  <li>Onboarding cohort tracking with a visible renewal date, so the deadline is not a surprise</li>
  <li>Attendance read from check-in records rather than from anyone remembering to mark it</li>
  <li>Members who never attended do not silently age out of the cohort — the case most likely to be lost</li>
  <li>Self check-in kiosk for the front door, the primary path for parents checking in kids</li>
  <li>Members platform with invite-based onboarding</li>
  <li>Physical inventory ledger — count, catalogue, supplier pipeline, and a reason recorded for every movement</li>
</ul>
</div>

<div class="domain">
<span class="domain__num">Domain 03</span>
<h3>Leads and funnel</h3>
<p>Enquiry to enrolment, measured weekly. Three separate problems: the history is
split across sub-accounts with two incompatible tag vocabularies, the same human
appears in more than one of them, and the conversion window is far longer than
anyone's intuition. See the
<a href="{{ '/projects/lead-flow-atlas/' | relative_url }}">Lead Flow Atlas</a> for the
automation specification layer.</p>
<ul>
  <li>Twelve-week funnel by ISO week: lead, replied, booked, showed, enrolled</li>
  <li>Two tag vocabularies translated into one stage model, so pre-migration history stays comparable</li>
  <li>People deduplicated across accounts on email <em>or</em> phone, because neither alone is reliable</li>
  <li>"Showed" derived from actual trial reservations, never from a CRM tag someone forgot to set</li>
  <li>Stale-lead buckets calibrated to a <strong>measured 117-day median lead-to-join lag</strong> — not the two-week cutoff that intuition suggests, which would have written off most eventual members as cold</li>
  <li>One-way delta sync between accounts with union-merged tags, so a destination-only tag is never clobbered</li>
  <li>Paid-ads pre-flight gate: ten rules derived from a campaign that spent $751 for three attended trials and zero members</li>
</ul>
</div>

<div class="domain">
<span class="domain__num">Domain 04</span>
<h3>Comms</h3>
<p>Inbound across text, email, social messages and voice. The problem is triage: the
inbox is mostly noise, the signal is time-sensitive, and the cost of missing a real
prospect is a member. Classification has to be good enough that the human only reads
what matters.</p>
<ul>
  <li>Every conversation scanned, classified, and reduced to what genuinely needs a reply</li>
  <li>Replies drafted in the owner's voice, copy-paste ready, with a clear reply / mark-read / archive action per thread</li>
  <li>Spam swept by category — vendor cold outreach, verification-badge phishing, follower-selling, manufacturer pitches — tagged for bulk archive <em>and</em> excluded from funnel counts so junk never inflates a metric</li>
  <li>Voice agent health monitoring on the inbound line</li>
  <li>Never auto-sends external member-facing messages — drafts go to a human first, by rule</li>
</ul>
</div>

<div class="domain">
<span class="domain__num">Domain 05</span>
<h3>Curriculum</h3>
<p>Class planning for kids and adults, and the largest single time saving in the whole
system. Covered in full in the
<a href="{{ '/projects/members-portal/' | relative_url }}">curriculum engine deep
dive</a> — generation constrained by schema, candidates scored against a rubric before
they are kept, and one plan rendered for three audiences with a machine-checked
readability standard for each.</p>
<ul>
  <li>Constraints-led games generated per skill bucket, scaled for two age bands as one game</li>
  <li>Rubric evaluator gates what enters the library</li>
  <li>Coach, kid and parent views from a single plan, each with its own validator</li>
  <li>Plans are dateless — scheduling assigns date and coach later, so plans stay reusable</li>
  <li>Seminar transcription feeding source material into the library</li>
</ul>
</div>

<div class="domain">
<span class="domain__num">Domain 06</span>
<h3>Ops and reporting</h3>
<p>The layer that makes the other five legible. A read-only dashboard, eighteen
generated reports, and a scheduled morning chain. The design rule throughout: the
agent is the write head and every artefact is generated, so nothing is ever
hand-edited into disagreement with its source.</p>
<ul>
  <li>Read-only dashboard over the whole system — mission progress, integration health, funnel, finance, comms, social, events, campaigns, onboarding cohort</li>
  <li>Eighteen dashboards, each regenerated by its own script and refreshed by its own skill</li>
  <li>Scheduled morning chain: funnel, spam sweep, inbox triage, ad performance, attendance sync, scorecard</li>
  <li>Start-of-day briefing that reports what is overdue and recommends the next three actions</li>
  <li>Append-only decision log, so the reasoning behind a choice outlives the memory of it</li>
  <li>Wall signage driven from the same system — see <a href="{{ '/projects/socius-tv/' | relative_url }}">Socius TV</a></li>
  <li>Marketing content engine with documented brand voice for two brands</li>
</ul>
</div>

</div>

## The pattern across all six

Each domain arrived as the same shape of problem: recurring manual work whose cost was
not the time but the *staleness*. The answer expired faster than it could be produced,
so it stopped being produced.

Three rules turned out to generalise across every one of them.

**Reconcile, never trust a single system.** Every number worth acting on comes from at
least two sources that disagree. Attendance, enrolment, revenue and ad performance are
all reconciliations, and the reconciliation is the product.

**Measure before you calibrate.** The stale-lead thresholds are the clearest case. Every
instinct said a lead cold after two weeks is gone. The measured median from first contact
to joining was 117 days. A system built on the intuition would have discarded most of the
people who eventually became members — and would have looked perfectly reasonable while
doing it.

**Generate everything; hand-edit nothing.** Every dashboard, data file and report is an
output with a generator that owns it. Drift between a generated artefact and its source
is a bug with an owner, not a discrepancy someone reconciles by hand each month.

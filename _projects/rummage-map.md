---
title: "RummageMap"
subtitle: "A city-wide garage-sale map where hosts post in two minutes with no account, and the map builds itself."
blurb: "A consumer product with the hard parts solved: no-account publishing with magic-link ownership, client-side photo processing, spatial queries and a moderation queue."
order: 5
kind: "Consumer web app"
stack: "Next.js (App Router), Vercel, Neon Postgres + PostGIS, Mapbox, Resend, Vercel Blob, Turnstile"
techniques: "Agent-driven development; no model in the request path, by design"
role: "Designer and sole engineer"
period: "2026"
status: "Live"
status_kind: "live"
domain: "Consumer / local marketplace"
live: "https://the-garage-psi.vercel.app"
repo_note: "Private repository"
mermaid: true
---

## Problem

Garage sales are advertised in the worst possible place: buried in community
Facebook groups, as a photo of a handwritten sign, with the address in a comment.
Shoppers cannot plan a route. Hosts cannot reach anyone outside the group. Every
weekend the same information is re-posted and re-lost.

The obvious product is a map. The reason one does not already exist in most cities
is the part that is not obvious: **the supply side will not sign up.**

Someone holding a garage sale on Saturday is not going to create an account, verify
an email, learn an interface and manage a listing. They have about two minutes of
patience and they are probably on a phone. Any friction in posting means an empty
map, and an empty map gives shoppers no reason to come, which gives hosts no reason
to post. Every design decision follows from that single constraint.

## What I built

A map that anyone can add to in about two minutes, with no account, and still
manage afterwards.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Posting without an account</div>
<div class="diagram__body">
<pre class="mermaid">
sequenceDiagram
  autonumber
  participant H as Host (phone)
  participant P as Post form
  participant B as Bot check
  participant DB as Postgres + PostGIS
  participant M as Email

  H->>P: address autocomplete, drag pin
  H->>P: pick days, add up to 5 photos
  Note over P: photos resized and<br/>EXIF-stripped in the browser
  H->>B: submit
  B-->>P: verified human
  P->>DB: publish immediately
  P->>M: send private manage link
  P-->>H: show the manage link on screen
  Note over H,M: link is the credential —<br/>no account, no password
  H->>DB: later: edit, cancel a day,<br/>or cancel the sale
</pre>
</div>
</div>

**Ownership without accounts.** Publishing returns a private link that *is* the
credential. It is emailed and also shown on screen immediately, because a host who
mistypes their email must not lose their sale — and there is a resend path for the
one who closes the tab anyway. This removes the entire account system: no passwords,
no verification wall, no reset flow, and nothing stored that needs protecting.

**Photos handled in the browser.** Images are resized and stripped of EXIF metadata
client-side before upload. That is bandwidth on a phone connection, but the real
reason is privacy: phone photos carry GPS coordinates, and a host uploading a picture
of their driveway should not be publishing the precise location of the inside of
their house. Stripping it before it leaves the device means the server never holds
it.

**Filters that combine, on a real spatial index.** Day, category, distance from the
shopper and keyword all apply together, backed by genuine geospatial queries rather
than a bounding-box approximation. Sales cluster on the map at low zoom and resolve
to pins as you approach, because a working-class neighbourhood on garage-sale
Saturday is dozens of overlapping markers otherwise.

**Shared links that look like something.** Every sale has its own page carrying
proper preview tags, so a link pasted into the community Facebook group — which is
still where this spreads — unfurls with the address, the days and a photo. The
product meets its distribution channel instead of fighting it.

**Moderation as a real feature.** Anonymous publishing invites abuse. There is a
moderation surface behind allowlisted magic-link sign-in with hide and unhide
actions and a reports queue. Unmoderated user-generated content is not a launch;
it is a liability.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Surfaces and roles</div>
<div class="diagram__body">
<pre class="mermaid">
graph LR
  subgraph PUB["Public"]
    BROWSE["Browse<br/>clustered map or list"]
    SALE["Sale page<br/>preview tags for sharing"]
  end
  subgraph HOST["Host — link is the credential"]
    POST["Post"]
    MANAGE["Manage<br/>edit, cancel a day, cancel sale"]
    RESEND["Resend lost link"]
  end
  subgraph MOD["Moderator — allowlisted"]
    ADMIN["Hide / unhide"]
    REPORTS["Reports queue"]
  end
  POST --> DB[("Postgres + PostGIS")]
  MANAGE --> DB
  RESEND --> MANAGE
  DB --> BROWSE
  DB --> SALE
  ADMIN --> DB
  REPORTS --> ADMIN
</pre>
</div>
</div>

## How it works

Next.js on the App Router, deployed on Vercel. Postgres with PostGIS handles the
spatial queries — distance filtering and clustering are database work, not
application work, and doing them properly at the start meant the map stayed fast as
listings grew. Mapbox renders. Transactional email sends the manage link. Blob
storage holds the processed photos. A bot check guards the one unauthenticated write
path in the system, which is the obvious thing to attack.

The design rationale and the launch plan are both committed in the repository, which
matters more than it sounds: months later, the reason a choice was made is still
there, and the choices that looked arbitrary turn out to have had constraints behind
them.

## AI techniques used

Honestly: **none at runtime, and that is deliberate.**

There is no model in the request path. A garage-sale map needs to load in two
seconds on a phone on mobile data in a driveway. Adding inference to categorisation
or search would have added latency, cost and a failure mode in exchange for nothing
the user would notice. Choosing not to use a model where it does not earn its place
is part of the same judgement as using one where it does.

Where AI was decisive was in **building it**. This is a full product — spatial
queries, client-side image processing, tokenised ownership, transactional email,
bot mitigation, a moderation surface, preview metadata — shipped solo. It was built
agent-driven against written specifications, with the design rationale and roadmap
maintained as repository documents that an agent reads before making a change. The
leverage was in scope reached by one person, not in a feature the user can see.

## Outcome

- Live, publishing real sales, with posting that takes about two minutes on a phone
  and requires no account.
- The supply-side constraint that blocks this category is solved rather than
  designed around.
- Location privacy handled at the device, before upload — the server never receives
  photo GPS data.
- Moderation existed at launch, not after the first incident.
- A complete consumer product delivered by one person, which is the actual claim
  this project supports.

## What I'd do differently

The magic-link model is right for hosts and wrong for the handful of people who post
every single weekend. They want one place to see all their sales, and the design
gives them a pile of emails. I would add an optional account that *claims* existing
link-owned sales rather than gating posting behind one — keep the two-minute path as
the default, let the repeat hosts upgrade into something better.

I would also instrument the funnel from the first deploy. I know posting works
because sales appear. I do not know how many people opened the form and abandoned
it, or where. For a product whose entire thesis is supply-side friction, that is the
one number I should have been measuring from day one.

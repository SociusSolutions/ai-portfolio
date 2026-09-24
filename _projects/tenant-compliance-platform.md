---
title: "Tenant Compliance Platform"
subtitle: "An Azure-hosted platform that discovers, inventories and continuously assesses a multi-tenant enterprise identity estate against a versioned security baseline."
blurb: "Corporate engagement. A cloud identity estate spread across many business units, brought under one authoritative inventory with scheduled read-only assessment and drift reporting."
order: 3
kind: "Cloud security platform"
stack: "Azure, TypeScript, PowerShell, Bicep, Microsoft Graph, SQL"
techniques: "Agent-assisted delivery, spec-driven implementation planning"
role: "Engineer on the delivering team"
period: "2026"
status: "Internal, in service"
status_kind: "private"
domain: "Cloud security & compliance"
repo_note: "Private — client engagement"
corporate: true
mermaid: true
---

## Problem

A large organisation that grows by acquisition accumulates cloud identity tenants
the way a house accumulates keys. Each acquired business unit arrives with its own
directory, its own administrators, its own security posture, and its own set of
trust relationships to partners and to other units.

Two questions become surprisingly hard to answer at that scale. *What do we
actually have?* — because no single system owns the list, and the list changes
without announcement. And *does any of it meet our standard?* — because the standard
exists as a written document while the reality exists as configuration in dozens of
separate places.

Answering either by hand does not work. Administrators check their own tenant, in
their own way, at whatever interval they remember, and report the result in prose.
By the time the picture is assembled it is out of date, and nothing distinguishes a
tenant that was assessed and passed from one that was never assessed at all.

## What I built

A platform that holds the authoritative inventory and assesses it on a schedule.

It does three things. It maintains a **registry** of every tenant in the estate,
with a real lifecycle — tenants enter by manual entry, by a self-service request
from the owning business unit, or by being surfaced through automated discovery, and
move through review to an approved or retired state. Access to the registry is
scoped by role, so a business-unit administrator sees their own and central
operators see everything.

It runs **scheduled assessment** of each tenant against a versioned internal
baseline, so posture is a current measurement rather than a remembered claim.

And it performs **relationship discovery**, mapping the cross-tenant trusts and
delegations that exist between units and with outside parties — the footprint that
tends to be invisible precisely because no one tenant owns it.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Capability view</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  subgraph EST["Enterprise identity estate"]
    T1["Business unit tenant"]
    T2["Business unit tenant"]
    T3["Business unit tenant"]
  end

  subgraph PLAT["Platform"]
    REG["Registry<br/>inventory + lifecycle + role-scoped access"]
    ASSESS["Scheduled assessment<br/>read-only, against a versioned baseline"]
    DISC["Relationship discovery<br/>cross-tenant trusts and delegations"]
    DRIFT["Drift classification<br/>current posture vs standard"]
  end

  subgraph CONS["Consumers"]
    PORTAL["Portal<br/>posture, history, operator notes"]
    OWNERS["Business unit owners"]
    CENTRAL["Central security operations"]
  end

  T1 --> ASSESS
  T2 --> ASSESS
  T3 --> ASSESS
  ASSESS --> DRIFT
  DISC --> REG
  REG --> DRIFT
  DRIFT --> PORTAL
  PORTAL --> OWNERS
  PORTAL --> CENTRAL
</pre>
</div>
</div>

## Approach

Assessment is **read-only and consent-based**. The platform reads posture through
the cloud provider's directory API using an application identity with read
permissions only, which the owning tenant's administrator approves once during
onboarding. It changes nothing in a member tenant, which is what makes central
assessment politically viable as well as technically safe.

Because consent cannot be assumed across an estate assembled from acquisitions,
there is a **fallback submission path** for tenants that will not grant it — a
signed script an administrator can run locally, returning its results through an
authenticated endpoint. Coverage does not depend on universal cooperation.

Individual checks are implemented behind a **common interface**, independent of
where their data comes from, so a given control can be evaluated from the directory
API, from a specialised assessment tool, or from a submitted payload without the
rest of the system caring. Results are scored against the baseline and the
deviations surface in the portal with per-check history and space for operator
notes, so a known and accepted exception reads differently from a new regression.

Infrastructure is declared as code and deployed from the repository, so an
environment is reproducible rather than hand-assembled.

<div class="note">
<span class="note__label note__label--blue">Scope note</span>
<p>The baseline's contents, the tenant estate's size and composition, the
assessment findings and the client's identity are not described here. The
architecture summary above is deliberately one level more abstract than the
implementation.</p>
</div>

## AI techniques used

The delivery method is worth more here than the internals I cannot describe.

- **Specification before implementation.** The platform was scoped as a written
  requirements document and an implementation plan, reviewed as documents, before
  code existed. The plan then drove the build phase by phase.
- **Agent-assisted implementation** against those specs, with the repository
  carrying its own working instructions so an agent picking up a phase reads the
  established conventions rather than inventing new ones.
- **Checks as testable units.** Assessment logic sits behind an interface with a
  mockable context, so each control can be exercised in isolation. That is what
  made agent-written checks reviewable rather than a leap of faith.

## Problem class

This is identity-security and compliance work at multi-tenant scale: consent-scoped
read-only assessment across organisational boundaries, configuration drift
detection against a versioned standard, relationship and trust discovery, and
role-scoped reporting to owners who are accountable for their own unit but not
entitled to see others.

The transferable part is the shape of the problem. A central team needs an accurate,
current picture of an estate it does not administer, cannot change, and cannot
compel to cooperate — and it needs that picture to distinguish *assessed and
compliant* from *never assessed*, which is the distinction most inventories quietly
lose.

<div class="note note--redacted">
<span class="note__label">Availability</span>
<p>Implementation detail, the baseline control set and the measured results are
available on request, subject to the terms of the engagement.</p>
</div>

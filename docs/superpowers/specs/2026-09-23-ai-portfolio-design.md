# AI Portfolio Site — Design

**Date:** 2026-09-23
**Status:** Approved
**Owner:** Randal Boiteau (SociusSolutions)

## Intended outcome

A public GitHub Pages site that demonstrates Randal's AI engineering capability to
hiring managers and prospective clients. Organised around *what was built and how*,
readable top-to-bottom by a non-engineer, with technical depth available below the
fold on every page.

Success looks like: a reader lands on the site, and within five minutes can state
what Randal builds, which AI techniques he uses, and point to three concrete
systems as evidence.

## Constraints

- **Public.** Nothing in the repo may contain secrets, API keys, `.env` contents,
  member PII, customer data, or client identifiers.
- **Corporate work is capability-only.** RTBsec projects describe what the tool
  does and the problem class. No results, no architecture depth, no client names.
- **Source repos stay private.** The portfolio describes them; it never vendors
  their code or data.
- Consistent structure and voice across every page. Concrete over vague.

## Redaction list (build-gated)

`HarrisComputer`, `Harris Computer`, `CIT`, `MTO`, `#hub`, `hub-poc`, `trcp`,
tenant GUIDs, member names, internal hostnames. Enforced by
`scripts/check-redactions.sh` against the built site — non-zero exit blocks publish.

## Hosting

- Repo: `SociusSolutions/ai-portfolio`, public.
- `https://sociussolutions.github.io/ai-portfolio/`
- Jekyll, built natively by GitHub Pages. Custom layouts and CSS; **no plugins**
  beyond the Pages-supported set, so there is no build pipeline to rot.
- CNAME-ready for a later custom domain.

## Information architecture

```
/                    positioning, skills matrix, flagship grid, complete repo index
/capabilities/       how Randal builds with AI
/socius-os/          hub, then one section per business domain
/projects/<slug>/    ten deep-dive pages
/about/              bio and contact
```

### Flagship deep dives (10)

| Slug | Source | Kind |
|---|---|---|
| `socius-os` | SociusSolutions/SociusOS | AI operating system |
| `lead-flow-atlas` | SociusSolutions/SociusLeads | automation-as-spec |
| `tenant-compliance-platform` | rtbsec/trcp | corporate, capability-only |
| `document-intelligence-pipeline` | rtbsec/hcms | corporate, capability-only |
| `rummage-map` | SociusSolutions/the-garage | consumer web app |
| `smoothcomp-support` | SociusSolutions/SCSmoothSupport | support tooling |
| `socius-tv` | SociusSolutions/sociustv | digital signage |
| `members-portal` | SociusSolutions/SociusKids | members + onboarding |
| `socius-vault` | SociusSolutions/SociusVault | agent-maintained knowledge base |
| `manitoba-jiujitsu` | SociusSolutions/mbweb | static site + PDF generation |

### Socius OS domains

finance & accounting · members & onboarding · leads & funnel · comms ·
curriculum · ops & reporting

### Index-only repos

`sociuskiosk`, `emotion26`, `Tournament-Estimator-app`, `registration-analyser`,
`LegacyStatsTracker`, `GrapplingIndustries-Merges`, `sociuswebsite`,
`FamilyFunds`, `kalie`, `socius-kids`, `LegacyBasic`, `SociusWebsite-Bolt`,
`nextjs-with-supabase*`

### Excluded

- `web-check` — upstream is Lissy93/web-check, not authored work.
- `rtbsec/CIPP`, `CIPP-API`, `AzureHound`, `EntraFalcon` — forks of public tools.
  Mentioned only as tools worked with, never as authored work.

## Page template

Every project page, same section order:

1. **Snapshot** — role, stack, status, links
2. **Problem**
3. **What I built**
4. **How it works** — includes a Mermaid architecture diagram
5. **AI techniques used**
6. **Outcome**
7. **What I'd do differently**

Corporate pages swap two sections: *How it works* becomes a shallow **Approach**
paragraph; *Outcome* becomes **Problem class**. Each closes with
"Implementation detail and results available on request."

## Diagrams

Mermaid from CDN, initialised in the default layout, theme-aware for light and
dark. Every project page carries an architecture diagram. Automation-heavy
projects additionally carry a workflow or sequence diagram. User-facing apps
carry a wireframe-style layout diagram.

## Verification (all must pass before publish)

- `scripts/check-redactions.sh` — no forbidden string in the built site
- `scripts/check-structure.sh` — every project page has all required sections
- `scripts/check-links.sh` — no broken internal link
- Human review of the rendered site, repo private until Randal approves going public

## Non-goals

- No live data, credentials, or screenshots containing member names
- Not a résumé replacement
- No per-repo pages for scaffold repos — index rows only

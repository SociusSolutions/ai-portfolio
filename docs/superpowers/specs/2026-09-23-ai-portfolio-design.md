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

## Redaction gate

Client legal entity names, internal team and programme names, project codenames,
CRM account and form identifiers, the business phone line and street address,
tenant GUIDs, member names and internal hostnames must never reach the built site.

Enforced by `scripts/check-redactions.sh`; a non-zero exit blocks deployment.

**The identifier list is deliberately not committed.** Writing the forbidden strings
into a public repository would publish the very thing the gate exists to prevent.
Shape-based patterns (token formats, GUIDs, phone numbers) live in
`_data/redactions.yml`; the client-specific list lives in an uncommitted
`.redactions.local.yml` locally and in a repository secret in CI, merged via the
`REDACTIONS_EXTRA` environment variable.

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

| Slug | Kind |
|---|---|
| `socius-os` | AI operating system |
| `lead-flow-atlas` | automation-as-spec |
| `tenant-compliance-platform` | corporate, capability-only |
| `document-intelligence-pipeline` | corporate, capability-only |
| `rummage-map` | consumer web app |
| `smoothcomp-support` | tournament operations |
| `socius-tv` | digital signage + MCP server |
| `members-portal` | members platform + curriculum engine |
| `socius-vault` | agent-maintained knowledge base |
| `manitoba-jiujitsu` | static site + compliance tooling |

Source repositories are private and are not named here.

### Socius OS domains

finance & accounting · members & onboarding · leads & funnel · comms ·
curriculum · ops & reporting

### Index-only entries

Smaller tools, earlier attempts and superseded work appear as rows in the index
table on the landing page, driven by `_data/index_repos.yml`. Scaffold and
template repositories are excluded entirely.

### Excluded

- One repository whose upstream is a third party's open-source project, not
  authored work.
- Four forks of public security tools. Mentioned only as tools worked with, never
  as authored work.

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
- The portfolio describes the source repositories; it never vendors their code or data

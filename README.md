# AI portfolio — source

Source for **[sociussolutions.github.io/ai-portfolio](https://sociussolutions.github.io/ai-portfolio/)**,
a portfolio of AI applications, agents, automation systems and platforms.

Jekyll, custom layouts, no theme. Diagrams are Mermaid, rendered client-side.
Built and deployed by GitHub Actions — see `.github/workflows/pages.yml`.

## Layout

```
_config.yml                  site config; baseurl is /ai-portfolio
index.html                   landing: skills matrix, flagship grid, full index
capabilities.md              how I build with AI — the method
socius-os.md                 the operating system, broken out by business domain
about.md                     bio, what I'm looking for, contact
_projects/*.md               ten deep-dive pages, one per flagship system
_layouts/                    default, page, project
_includes/                   masthead, footer, title block, mermaid init
_data/skills.yml             the skills matrix
_data/index_repos.yml        the "also built" index table
_data/redactions.yml         shape-based forbidden patterns (see below)
assets/css/main.css          the whole design system
scripts/*.sh                 verification gates
docs/superpowers/specs/      the design spec this was built from
```

## Build

```bash
bundle install
bundle exec jekyll serve      # http://localhost:4000/ai-portfolio/
bundle exec jekyll build      # -> _site/
```

## Verification

Three gates. All three run in CI **before** anything is deployed; a failure blocks
the deploy rather than reporting after the fact.

```bash
bash scripts/verify.sh        # all three
```

| Gate | Checks |
|---|---|
| `check-structure.sh` | every project page has the required front matter, the full section template, a diagram, balanced diagram blocks, and unique plate numbers |
| `check-redactions.sh` | no forbidden string or secret-shaped token appears in the built site |
| `check-links.sh` | every internal link resolves, and none is missing the `baseurl` prefix |

### The redaction gate, and why its list is not in this repository

Corporate work here is described at capability level only. Client names, internal
programme and project codenames, CRM account identifiers and similar must never
reach the built site.

**Writing those strings into a public repository would publish them** — which is
exactly what the gate exists to prevent. So the list is split:

- `_data/redactions.yml` — committed. Shape-based patterns only: token formats,
  private-key blocks, GUIDs, phone numbers. Nothing sensitive is named.
- `.redactions.local.yml` — **not committed** (gitignored). The client and account
  identifier list, for local runs.
- In CI — the same list arrives from the `REDACTIONS_EXTRA` repository secret,
  written to a temp file for the gate and deleted afterwards.

The checker merges whichever extra list it finds. If none is present it runs the
shape patterns, prints a loud warning that the gate is partial, and CI fails
outright rather than passing a weakened check.

To set up a fresh clone:

```bash
cp .redactions.local.example.yml .redactions.local.yml   # then fill it in
```

## Content rules

- Corporate pages use the template with two sections swapped — `Approach` instead
  of `How it works`, `Problem class` instead of `Outcome` — and must carry an
  availability note. `check-structure.sh` enforces this.
- Nothing here vendors code or data from the source repositories. It describes them.
- Open-source tools operated but not authored are never presented as authored work.
- Where a project has no AI in it, its page says so.

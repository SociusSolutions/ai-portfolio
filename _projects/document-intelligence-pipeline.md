---
title: "Document Intelligence Pipeline"
subtitle: "An Azure-native retrieval system that takes an unstructured document archive from upload to answerable, with a human review gate before anything is published."
blurb: "Corporate engagement. A proof of the full document lifecycle — extract, enrich, embed, index, review, publish — built on Azure with a measured retrieval evaluation harness."
order: 4
kind: "RAG / retrieval platform"
stack: "Azure Functions (Python), Document Intelligence, Azure OpenAI, PostgreSQL + pgvector, Azure AI Search, Bicep"
techniques: "Hybrid retrieval, embeddings, LLM metadata extraction, OCR, retrieval evaluation harness"
role: "Engineer on the delivering team"
period: "2026"
status: "Proof of concept, delivered"
status_kind: "private"
domain: "Knowledge management & retrieval"
repo_note: "Private — client engagement"
corporate: true
mermaid: true
---

## Problem

Every established organisation has an archive: years of PDFs, Word documents and
slide decks in shared folders, holding most of what the organisation actually knows.
It is searchable only by filename, which is to say it is not searchable. The
knowledge is present and unreachable, and the cost shows up as questions answered
from memory, decisions repeated, and the same document rewritten because nobody
could find the original.

Full-text search is the obvious answer and an insufficient one. A scanned document
has no text to index. Filenames and folder structures encode a taxonomy that made
sense to whoever created them in the year they created them. And someone searching
rarely knows the vocabulary the document used — they know what they need it *for*.

The question to answer was narrow and worth answering precisely: can the entire
lifecycle be made to work, on a real sample of the real archive, on managed cloud
services, with quality good enough to trust?

## What I built

A proof of concept covering the complete loop — upload, extract, enrich, index,
search, human review, publish — over a representative sample of the actual archive,
spanning the document formats in real use.

<div class="diagram">
<div class="diagram__cap">Figure 1 — Document lifecycle</div>
<div class="diagram__body">
<pre class="mermaid">
graph TB
  UP["Upload<br/>object storage"] --> EX["Text extraction + OCR<br/>document intelligence service"]
  EX --> META["Metadata enrichment<br/>language model"]
  META --> M1["summary"]
  META --> M2["tags + categories"]
  META --> M3["inferred authorship"]
  EX --> EMB["Embeddings<br/>chunked vectors"]
  M1 --> STORE
  M2 --> STORE
  M3 --> STORE
  EMB --> STORE[("Postgres + pgvector<br/>metadata and vectors")]
  STORE --> IDX["Search index<br/>full-text + vector"]
  IDX --> Q["Hybrid query<br/>keyword and semantic"]
  Q --> REV{"Human review"}
  REV -- approve --> PUB["Published<br/>discoverable"]
  REV -- reject --> BACK["Back for correction"]
  EVAL["Evaluation harness"] -.-> Q
</pre>
</div>
</div>

The pipeline runs as serverless functions, so ingestion scales with the queue and
costs nothing at rest. Every secret lives in a managed vault; the whole environment
is declared as infrastructure code and deployed from the repository, so the proof is
reproducible rather than a hand-built demo that dies with its author.

Three decisions mattered more than the service choices.

**OCR is not optional.** A meaningful share of any real archive is scanned or
image-based. A managed document-understanding service handles extraction and layout
for both native and scanned files, which is what makes the *whole* archive eligible
rather than the convenient half of it.

**Metadata is generated, then reviewed.** A language model produces a summary, tags,
categories and inferred authorship for each document. This is the step that replaces
the folder taxonomy — the model describes what the document is about rather than
where someone once filed it. But generated metadata is a draft: nothing becomes
discoverable until a person approves it. The review gate is the difference between a
knowledge base and a plausible-sounding one.

**Retrieval is hybrid, not vector-only.** Keyword search and semantic search fail in
opposite directions. Keyword search misses paraphrase; vector search misses exact
terms — part numbers, product names, specific identifiers — which is precisely what
people search for in a technical archive. Running both and combining the results
covers both failure modes.

## Approach

The part I would emphasise in a hiring conversation is the evaluation harness,
because it is what separates this from a demo.

A retrieval system always returns something. Confidence is free and unrelated to
correctness, so "it seems to work" is not a finding — it is the absence of one. The
repository carries a dedicated evaluation directory holding query sets with known
expected documents, so a change to chunking, to the embedding model, or to how
keyword and vector results are combined produces a *number* that moves in a
direction. Without that, tuning a retrieval pipeline is superstition.

<div class="diagram">
<div class="diagram__cap">Figure 2 — Why hybrid retrieval</div>
<div class="diagram__body">
<pre class="mermaid">
flowchart LR
  QQ["Query"] --> K["Keyword search<br/>exact terms, identifiers"]
  QQ --> V["Vector search<br/>paraphrase, intent"]
  K --> C["Combine and rank"]
  V --> C
  C --> R["Results"]
  K -. "misses paraphrase" .-> W1["a query in different words"]
  V -. "misses exact tokens" .-> W2["a part number"]
</pre>
</div>
</div>

<div class="note">
<span class="note__label note__label--blue">Scope note</span>
<p>The client, the archive's contents and subject matter, the evaluation scores and
the production rollout are not described here. What is described is the
architecture class and the engineering approach.</p>
</div>

## AI techniques used

- **Retrieval-augmented generation architecture** end to end: chunking, embedding,
  vector storage, hybrid retrieval and ranking.
- **LLM metadata extraction** — summary, tags, categories and authorship inference
  from document text, replacing a folder taxonomy with a described one.
- **OCR and layout-aware extraction** so scanned material is first-class rather
  than skipped.
- **Hybrid search** combining lexical and semantic retrieval to cover both failure
  modes.
- **A retrieval evaluation harness** with known-answer query sets, so pipeline
  changes are measured rather than believed.
- **Human-in-the-loop publishing.** Model output is a draft; a person approves
  before anything becomes discoverable.

## Problem class

This is applied retrieval engineering on managed cloud infrastructure: making a
heterogeneous, partly-scanned, decades-deep document archive answerable, at a
quality level that can be stated as a number, with an approval gate that keeps
generated metadata from silently becoming fact.

The transferable part is the discipline. Standing up a vector index is a weekend.
Knowing whether it is good enough to put in front of people who will trust its
answers requires a measurement harness, a human gate, and an honest account of
what the system does when it does not know — and that is the part that determines
whether a proof of concept ever becomes production.

<div class="note note--redacted">
<span class="note__label">Availability</span>
<p>Implementation detail, evaluation methodology and the measured results are
available on request, subject to the terms of the engagement.</p>
</div>

---
name: design-doc-elite-review
version: 0.1.0
description: >
  Conducts multi-round design document reviews with an elite cross-functional
  panel, forcing both supportive and opposing analysis before decisions.
  Enforces enterprise-grade and big-tech production standards as release gates.
author: praxis-maintainers
license: MIT
tags: [design-review, architecture, product, governance, enterprise]
triggers:
  auto:
    - condition: "A design document or architecture proposal is being drafted, reviewed, or approved."
    - condition: "A user asks for support-vs-opposition analysis, architecture trade-offs, or pre-implementation readiness checks."
  manual:
    - command: "/design-doc-elite-review"
      description: "Run the full elite multi-round review workflow"
    - command: "/design-doc-elite-review --fast"
      description: "Run one compressed round for time-constrained decisions"
compatible_tools: [claude-code, cursor, copilot, codex, gemini, windsurf, cline]
---

# Elite Design Document Review

> Strong design emerges from disciplined disagreement, not unchecked consensus.

## Core Philosophy

1. **Adversarial Collaboration** — Every design MUST survive both "why this should ship" and "why this should fail" scrutiny.
2. **Role-Complete Judgment** — Architecture, engineering, and product viewpoints are all mandatory; missing any one creates blind spots.
3. **Evidence Before Opinion** — Claims are only valid when tied to concrete assumptions, constraints, and measurable outcomes.
4. **Platform-Agnostic by Default** — Designs are expected to be portable, observable, scalable, and failure-tolerant across different runtime environments.
5. **Production Readiness Over Novelty** — Favor approaches that can be operated safely at scale with clear rollback paths.
6. **Decision Traceability** — Every accepted or rejected proposal MUST include explicit reasoning and risk ownership.

## The Elite Multi-Round Review Process

Execute these steps in order.

### Step 1: FRAME — Normalize Scope and Success Criteria

Read the design document and extract scope, assumptions, constraints, and explicit non-goals.

Inputs:
- Design document or architecture proposal
- Business goals, timeline, and resourcing constraints
- Existing platform constraints (runtime, data stores, compliance)

Output:
- `Review Brief` with:
  - Problem statement
  - Decision boundaries
  - Success metrics (latency, reliability, cost, delivery date)
  - Unresolved questions

### Step 2: STAFF — Assemble the Elite Review Panel

Create a role-complete panel before reviewing content.

Required roles:
1. Top Architect (system boundaries, consistency, evolution path)
2. Top Engineer (implementation feasibility, complexity, failure handling)
3. Top Product Manager (user value, prioritization, adoption risk)

Recommended roles for production-critical systems:
1. SRE/Platform Lead (SLOs, operability, incident readiness)
2. Security Lead (threat model, trust boundaries, compliance)
3. Data Lead (schema evolution, data quality, migration risk)

For each required role, define both lenses:
- Support lens: strongest case for shipping this design
- Opposition lens: strongest case against shipping this design

Output:
- `Panel Matrix` mapping role -> support lens owner -> opposition lens owner -> decision authority

### Step 3: ROUND 1 (Support) — Build the Best-Case Argument

Run a steelman review where each role argues the strongest valid case for the proposal.

Review prompts:
- What core problem does this design solve better than alternatives?
- Which trade-offs are acceptable and why?
- Which assumptions must hold for this design to succeed?
- What measurable outcomes justify proceeding?

Output:
- `Support Findings` including:
  - Top strengths and differentiators
  - Preconditions for success
  - Expected business and technical upside

### Step 4: ROUND 2 (Opposition) — Red-Team the Design

Run an explicit opposition review where each role challenges failure modes and hidden costs.

Review prompts:
- Where can this fail in production and what is the blast radius?
- Which assumptions are fragile or unvalidated?
- What debt, coupling, or migration traps are being introduced?
- What makes this hard to operate, secure, or evolve?

Output:
- `Opposition Findings` with risk register:
  - Risk ID, severity (P0/P1/P2/P3), likelihood, owner, mitigation
  - Blocking issues requiring design changes before approval

### Step 5: ROUND 3 (Synthesis) — Gate Against Enterprise and Big-Tech Standards

Merge support and opposition findings into a revised, testable design.

Use this standards gate:

| Domain | Gate Questions |
|--------|----------------|
| Architecture | Are boundaries explicit, APIs versioned, and dependencies minimized? |
| Scalability & Resilience | Can the design scale predictably and recover gracefully under load and partial failure? |
| Reliability | Are SLI/SLO targets defined, failure modes covered, and rollback paths tested? |
| Operability | Are logs, metrics, traces, alerts, runbooks, and on-call ownership defined? |
| Security | Are authn/authz, secret handling, auditability, and threat mitigations explicit? |
| Delivery | Are migration, canary, rollback, and compatibility plans defined? |
| Product | Are user value, adoption metric, and deprecation/transition impacts clear? |

Output:
- `Standards Gate Report` with PASS/CONDITIONAL/FAIL by domain
- Updated architecture decision record (ADR-style summary)

### Step 6: DECIDE — Issue Final Verdict and Action Plan

Choose exactly one outcome:
1. Approve
2. Approve with conditions
3. Revise and re-review
4. Reject

Required decision payload:
- Final verdict
- Explicit rationale linked to findings
- Required changes with owners and dates
- Residual risks accepted by whom

Output:
- `Review Decision Package` ready for engineering kickoff or redesign cycle

## Safety Guards

1. **Never issue an approval verdict before completing both support and opposition rounds** — one-sided review is invalid.
2. **Always include at least the three core roles (architect, engineer, product manager)** — incomplete panel composition is invalid.
3. **Never mark a design as ready when any unmitigated P0 or P1 risk remains open** — unresolved critical risks block release.
4. **Always run the enterprise and big-tech standards gate before final decision** — architectural quality must be explicitly verified.
5. **Never omit ownership and deadlines for required changes** — decisions without accountability are non-executable.
6. **Cap each invocation at three review rounds and one verdict** — prevents review sprawl and indecisive loops.

## Quick Reference

```text
FRAME   -> Normalize scope, constraints, success metrics (input: design doc, output: Review Brief)
STAFF   -> Build elite panel with architect/engineer/PM + support/opposition lenses (output: Panel Matrix)
ROUND 1 -> Steelman support case (output: Support Findings)
ROUND 2 -> Red-team opposition case (output: Opposition Findings + risk register)
ROUND 3 -> Synthesize and run enterprise-grade + big-tech standards gates (output: Standards Gate Report)
DECIDE  -> Approve | Approve with conditions | Revise | Reject (output: Review Decision Package)

GUARDS  -> No one-sided approvals | Core roles required | No open P0/P1 | Standards gate mandatory | Owner+date required
```

# Skill Authoring Guide

A step-by-step guide to writing a praxis skill.

## Before You Start

Ask yourself:

1. **What recurring problem does this solve?** A skill should address something that happens regularly in coding workflows, not a one-off task.
2. **Can an LLM follow this process?** Skills are executed by language models. If the process requires human judgment that can't be codified, it may not be suitable as a skill.
3. **Is it general enough?** Skills should work across multiple projects and tech stacks. Project-specific workflows belong in project configuration.

## Step 1: Define the Problem

Write a 2-3 sentence description of what problem your skill solves. This becomes the `description` field in frontmatter.

**Good**: "Analyzes recent work to extract patterns, lessons, and coding standards, then stores them for continuous improvement."

**Bad**: "Helps with coding." (Too vague — an LLM can't act on this.)

## Step 2: Design the Process

Break your skill into 3-7 sequential steps. Each step should have:

- A **verb name** (OBSERVE, EXTRACT, VALIDATE, etc.)
- A **clear input** (what it consumes from the previous step or environment)
- A **clear output** (what it produces for the next step)
- **Examples** where the step could be ambiguous

```markdown
### Step 1: OBSERVE — Gather Learning Material

Collect evidence from git history, current session, and code reviews.

**Output**: Numbered list of 1-10 candidate events.
```

### Process Design Tips

- **Be sequential.** Steps should flow in one direction. Avoid loops or cycles.
- **Allow early termination.** Not every invocation needs to run all steps. Add clear exit conditions.
- **Include examples.** Good and bad examples help LLMs distinguish edge cases.
- **Specify formats.** Don't say "output a list" — show the exact format.

## Step 3: Write Safety Guards

Guards are the most important part of your skill. They prevent harm and maintain user trust.

For each guard, ask: "What's the worst thing that could happen if this guard didn't exist?"

**Template:**

```markdown
## Safety Guards

1. **Never {dangerous action}** — {why this matters}.
2. **Always {required action}** — {why this is mandatory}.
3. **Cap at {N} per invocation** — {what this prevents}.
```

### Guard Writing Tips

- **Be absolute.** Guards use "never" and "always," not "try to" or "consider."
- **Be specific.** "Never delete existing rules" is enforceable. "Be careful with rules" is not.
- **No exceptions.** If a guard has an exception, it's not a guard.
- **Test adversarially.** Ask: "How could a bad actor or confused LLM bypass this guard?"

## Step 4: Write the Frontmatter

```yaml
---
name: your-skill-name
version: 0.1.0
description: >
  Your 2-3 sentence description from Step 1.
author: your-name
license: MIT
tags: [relevant, tags]
triggers:
  auto:
    - condition: "When X happens during a coding session"
  manual:
    - command: "/your-skill-name"
      description: "Run the full workflow"
---
```

### Naming Conventions

- **Skill name**: kebab-case, 2-50 characters (e.g., `self-improve`, `test-first`)
- **Tags**: lowercase, 1-5 tags for discovery
- **Version**: start with `0.1.0` for drafts, `1.0.0` for stable releases

## Step 5: Write the Core Philosophy

List 3-7 guiding principles. These help the LLM understand the spirit of the skill, not just the letter.

```markdown
## Core Philosophy

1. **Single Source of Truth** — One canonical place for standards.
2. **Self-Evolution** — Standards learn from practice, not just theory.
3. **User Control** — Users can inspect, manage, and override all skill state.
```

## Step 6: Write the Quick Reference

A compact summary that fits in a single code block. An agent reading only this section should understand the core workflow.

```markdown
## Quick Reference

```
OBSERVE  →  What happened? (git log, session review)
EXTRACT  →  What's the lesson? (Always/Never X when Y; because Z)
VALIDATE →  Is it new? Is it specific? Is it reusable?
STORE    →  Show user → get approval → write → validate
```
```

## Step 7: Assemble and Test

1. Put it all together in `skills/your-skill-name/SKILL.md`
2. Run through the [validation checklist](../SKILL_SPEC.md#6-validation-checklist)
3. Install in your AI tool of choice
4. Run the skill on a real task — not a toy example
5. Iterate based on what the agent gets wrong

## Step 8: Write Supporting Files

- `skills/your-skill-name/README.md` — human-readable quick start
- Add an entry to `registry.yaml`
- Update `CHANGELOG.md`

## Step 9: Submit

1. Open a [New Skill Proposal](https://github.com/praxis-skills/praxis/issues/new?template=new-skill-proposal.md) issue (if you haven't already)
2. Open a PR following the [PR template](https://github.com/praxis-skills/praxis/blob/main/.github/PULL_REQUEST_TEMPLATE.md)
3. Respond to review feedback

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Vague instructions ("handle errors properly") | Specific commands ("Always wrap API calls in try/catch with typed error responses") |
| No safety guards | Add at least one non-negotiable constraint |
| No examples | Add good and bad examples for ambiguous steps |
| Undefined terms ("significant work") | Define with measurable criteria |
| Mermaid diagrams | Use ASCII art — not all tools render Mermaid |
| Missing outputs for steps | Every step should say what it produces |
| Too many auto-triggers | Keep to 2-4 precise triggers, move the rest to manual |

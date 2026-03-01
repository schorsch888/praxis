---
name: your-skill-name
version: 0.1.0
description: >
  One to three sentences describing what this skill teaches an AI coding
  agent to do. Be specific about the outcome.
author: your-name
license: MIT
tags: [tag1, tag2]
triggers:
  auto:
    - condition: "When X happens during a coding session"
  manual:
    - command: "/your-skill-name"
      description: "Run the full workflow"
---

# Your Skill Title

> A one-line quote capturing the skill's core insight.

## Core Philosophy

1. **Principle One** — Explain the first guiding principle of this skill.
2. **Principle Two** — Explain the second guiding principle.
3. **Principle Three** — Explain the third guiding principle.

---

## The {Your Process Name}

Execute these steps in order.

### Step 1: {VERB} — {What This Step Does}

Describe what the agent should do in this step. Include:
- What inputs to gather
- What to look for
- When to stop early

**Output**: Describe what this step produces for the next step.

---

### Step 2: {VERB} — {What This Step Does}

Describe the second step.

**Output**: Describe what this step produces.

---

### Step 3: {VERB} — {What This Step Does}

Describe the third step.

**Output**: Describe what this step produces.

---

## Safety Guards

These rules are **non-negotiable**. They override all other instructions in this skill.

1. **Never {dangerous action}** — explain why this guard exists and what it prevents.
2. **Always {required action}** — explain why this is mandatory.
3. **Cap at {N} per invocation** — prevent runaway behavior.

---

## Quick Reference

```text
STEP1  →  {Brief description} (input: X, output: Y)
STEP2  →  {Brief description} (input: Y, output: Z)
STEP3  →  {Brief description} (input: Z, output: result)

GUARDS →  Never {X} | Always {Y} | Cap at {N}
```

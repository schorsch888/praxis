# Praxis Skill Specification 1.0.0

This document defines the normative format for praxis skills. A **skill** is a Markdown file that an LLM coding agent reads and follows to learn a specific workflow, process, or capability. Skills are not code — they are structured specifications that guide agent behavior.

All skills in the praxis registry MUST conform to this specification.

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

---

## 1. File Structure

A skill is a single Markdown file named `SKILL.md` located in its own directory under `skills/`:

```text
skills/
  my-skill/
    SKILL.md       # Required: the skill specification
    README.md      # Optional: human-readable quick start
```

---

## 2. Frontmatter

Every `SKILL.md` MUST begin with a YAML frontmatter block delimited by `---`:

```yaml
---
name: my-skill
version: 1.0.0
description: >
  A one-to-three sentence description of what this skill teaches
  an AI coding agent to do.
author: your-name
license: MIT
tags: [category1, category2]
triggers:
  auto:
    - condition: "Description of when this skill auto-activates"
  manual:
    - command: "/my-skill"
      description: "Run the full workflow"
---
```

### Required Fields

| Field | Type | Rules |
|-------|------|-------|
| `name` | string | Kebab-case, 2-50 chars, MUST match directory name. Kebab-case means: starts with a lowercase letter, followed by lowercase letters, digits, or single hyphens. Consecutive hyphens (`--`) and trailing hyphens (`name-`) are NOT allowed. |
| `version` | string | Semantic versioning (e.g., `1.0.0`, `0.2.1`) |
| `description` | string | 1-3 sentences, plain text, no Markdown |

### Optional Fields

| Field | Type | Rules |
|-------|------|-------|
| `author` | string | Author name or team identifier |
| `license` | string | SPDX license identifier (default: `MIT`) |
| `tags` | list | 1-5 lowercase tags for discovery |
| `triggers.auto` | list | Conditions for automatic activation |
| `triggers.manual` | list | Commands the user can invoke |
| `compatible_tools` | list | AI tools confirmed to work (e.g., `claude-code`, `cursor`) |

> **Note**: The fields `state.schema` and `dependencies` are reserved for future specification versions. They MUST NOT appear in skills targeting this version.

---

## 3. Required Body Sections

After frontmatter, the Markdown body MUST contain these sections. Their relative order MUST be preserved as listed below. Optional sections (§4) MAY be interleaved between required sections, provided the required sections maintain their relative ordering.

### 3.1 Title (`# Title`)

A single H1 heading. SHOULD be descriptive, not just the skill name.

```markdown
# Self-Improving Coding Standards
```

### 3.2 Core Philosophy (`## Core Philosophy`)

A numbered list of 3-7 principles that guide the skill's behavior. Each principle MUST have a bold name and a one-sentence explanation.

```markdown
## Core Philosophy

1. **Principle Name** — One-sentence explanation of the principle.
2. **Another Principle** — Why this matters for the skill's operation.
```

### 3.3 The Process (`## The {Process Name}`)

The core workflow the skill teaches. This is the heart of the skill. The section heading SHOULD name the process (e.g., `## The Learning Loop`, `## The Debug Cycle`).

Requirements:
- MUST contain numbered, sequential steps
- Each step MUST have a clear name and description
- Steps MUST define inputs (what they consume) and outputs (what they produce)
- SHOULD include concrete examples where the process could be ambiguous
- MUST use fenced code blocks for any commands, templates, or formats

### 3.4 Safety Guards (`## Safety Guards`)

Non-negotiable rules that override all other instructions in the skill. These prevent the skill from causing harm.

Requirements:
- MUST contain at least 1 guard, no maximum
- MUST use bold numbering: `1. **Guard description** — explanation`
- Guards MUST be specific and enforceable, not vague
- Guards MUST be absolute — no "unless," "except," or "consider" language. If a guard requires cross-referencing another guard or section, use an explicit reference (e.g., "except as specified in Guard 3")

```markdown
## Safety Guards

1. **Never delete existing rules** — only append new ones. Existing rules may only be
   updated with user approval.
2. **Always show the user** what will be written before writing it.
3. **Cap at N items** per invocation — prevent runaway output.
```

### 3.5 Quick Reference (`## Quick Reference`)

A compact summary of the entire skill in a single fenced code block. An agent that reads only this section SHOULD understand the skill's core workflow.

````markdown
## Quick Reference

```text
STEP1  →  What happens (brief)
STEP2  →  What happens (brief)
STEP3  →  What happens (brief)
```
````

---

## 4. Optional Body Sections

These sections MAY appear in any order after or between the required sections, as long as the required sections maintain their relative order:

### `## Definitions & Storage Specification`

Define terms, file paths, schemas, and formats used by the skill. REQUIRED for stateful skills. Each term MUST have a machine-parseable definition.

### `## State Machine`

For skills with multiple operating modes. Use text-based box-drawing characters for state diagrams (not Mermaid — not all consumers render it).

````markdown
```text
              +----------+          +------------+
              |  ACTIVE  |--------->|MANUAL_ONLY |
              +----------+          +------------+
                    ^                      |
                    +----------------------+
```
````

### `## Trigger Conditions`

When the skill activates automatically vs. manually. Use tables to list triggers with their conditions and criteria.

### `## Subcommands`

If the skill supports multiple invocations (e.g., `/skill --status`, `/skill --list`). Document each with usage and behavior.

### `## Periodic Review`

For skills that accumulate state over time. Define when and how to review accumulated data for staleness, contradictions, or promotion.

---

## 5. Format Conventions

### Lessons / Rules

Use the "Always/Never X when Y; because Z" format for actionable rules:

```markdown
* **[YYYY-MM Module]**: Always set connection_timeout when creating Redis client; because default infinite timeout causes hanging connections
```

### Guards

Use bold numbering with em-dash explanations:

```markdown
1. **Never modify code** — this skill only writes to config/documentation files.
```

### State Diagrams

Use text-based box-drawing characters (`+`, `-`, `|`, `>`, `^`). Do not use Mermaid, PlantUML, or other diagram languages that require rendering.

### Code Blocks

Use fenced syntax with language identifiers:

````markdown
```yaml
key: value
```

```bash
git log --oneline -20
```
````

### Tables

Use standard Markdown tables with header separators:

```markdown
| Column | Column |
|--------|--------|
| value  | value  |
```

---

## 6. Validation Checklist

A valid skill MUST pass all of these checks:

- [ ] File is named `SKILL.md` in its own directory under `skills/`
- [ ] Begins with valid YAML frontmatter between `---` delimiters
- [ ] Frontmatter contains `name`, `version`, and `description`
- [ ] `name` is kebab-case, matches the directory name, no consecutive/trailing hyphens
- [ ] `version` follows semantic versioning (`MAJOR.MINOR.PATCH`)
- [ ] Contains `# Title` (H1 heading)
- [ ] Contains `## Core Philosophy` with 3-7 numbered principles
- [ ] Contains `## The {Process}` with sequential steps including inputs/outputs
- [ ] Contains `## Safety Guards` with at least 1 bold-numbered guard
- [ ] Contains `## Quick Reference` with a summary code block
- [ ] Required sections appear in the order specified in §3
- [ ] No Mermaid or PlantUML diagrams (text-based box-drawing only)
- [ ] All code blocks use fenced syntax with language identifiers
- [ ] No `state.schema` or `dependencies` fields in frontmatter (reserved)
- [ ] Guards are absolute — no "unless"/"except" without explicit cross-references
- [ ] Process steps define inputs and outputs

---

## 7. Versioning

Skills follow semantic versioning:

- **Major** (2.0.0): Breaking changes to the process, removed steps, changed safety guards
- **Minor** (1.1.0): New optional sections, new subcommands, expanded triggers
- **Patch** (1.0.1): Typo fixes, clarifications, example updates

Update the `version` field in frontmatter and add an entry to the skill's changelog (if maintained) or the project CHANGELOG.md.

This specification itself follows semantic versioning. Breaking changes to required fields, sections, or validation rules constitute a major version bump. Additions to optional fields or checklist items constitute a minor version bump.

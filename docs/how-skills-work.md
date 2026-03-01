# How Skills Work

## What is a Skill?

A skill is a Markdown file that teaches an AI coding agent a specific workflow. When loaded into an agent's context, the skill acts as a behavioral specification — defining what the agent should do, when it should do it, and what it should never do.

Skills are not code. They are structured documents written in Markdown with YAML frontmatter, designed to be read and followed by large language models (LLMs). There is no runtime, no interpreter, and no API. The LLM reads the skill and follows the instructions.

## How LLMs Consume Skills

When you install a skill into your AI tool (Claude Code, Cursor, Copilot, etc.), the tool loads the skill's Markdown content into the LLM's context window alongside your code. The LLM then:

1. **Reads the frontmatter** to understand the skill's name, triggers, and metadata
2. **Reads the body sections** to understand the workflow, safety guards, and decision framework
3. **Follows the process** when trigger conditions are met (automatically or on user command)
4. **Enforces safety guards** as non-negotiable constraints on its behavior

This works because LLMs are trained to follow structured instructions. A well-written skill with clear, specific steps produces consistent behavior across invocations.

## Why Markdown?

- **LLMs read Markdown natively.** It is the most natural format for language models. No parsing, no serialization, no SDK.
- **Humans can read it too.** Skills are reviewable, editable, and version-controllable with standard tools.
- **Zero dependencies.** No runtime, no build step, no package manager. Copy a file and you're done.
- **Portable.** The same skill file works across every AI coding tool that accepts system prompts or instruction files.

## Anatomy of a Skill

```
┌──────────────────────────────────────────┐
│ YAML Frontmatter                         │
│   name, version, description             │
│   triggers (when to activate)            │
│   tags (for discovery)                   │
├──────────────────────────────────────────┤
│ # Title                                  │
│                                          │
│ ## Core Philosophy                       │
│   Guiding principles (numbered list)     │
│                                          │
│ ## The {Process}                         │
│   Step-by-step workflow with             │
│   inputs, outputs, examples             │
│                                          │
│ ## Safety Guards                         │
│   Non-negotiable rules that              │
│   override everything else              │
│                                          │
│ ## Quick Reference                       │
│   Compact summary in a code block       │
└──────────────────────────────────────────┘
```

## Stateful vs. Stateless Skills

**Stateless skills** define a process that runs to completion with no persistent state. Each invocation is independent.

**Stateful skills** (like `self-improve`) maintain state between invocations — tracking counters, recording decisions, and accumulating data. These skills define:

- A **state file** schema (YAML) with defaults and validation rules
- A **state machine** describing operating modes and transitions
- **Storage specifications** for where and how data is persisted

## Trigger Conditions

Skills can activate in two ways:

- **Auto-triggers**: the agent recognizes a situation matching the skill's trigger conditions (e.g., "after fixing a bug") and activates the skill automatically
- **Manual triggers**: the user invokes a command (e.g., `/self-improve`) to run the skill on demand

Well-designed skills have a small number of precise auto-triggers (to avoid noise) and always support manual invocation as a fallback.

## Safety Guards

Every skill must define at least one safety guard — a non-negotiable rule that the agent must follow regardless of context. Guards prevent:

- Harmful outputs (deleting code, writing insecure rules)
- Noise accumulation (too many rules, too frequent activation)
- User friction (writing without permission, ignoring rejections)

Guards are the most important part of a skill. They are what make the difference between a helpful assistant and a runaway process.

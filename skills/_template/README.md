# Skill Template

Use this template to create a new praxis skill.

## Getting Started

1. Copy this directory to `skills/your-skill-name/`
2. Edit `SKILL.md` following the inline placeholders
3. Verify your skill passes the [Skill Spec](../../SKILL_SPEC.md) checklist

## Checklist

Before submitting your skill:

- [ ] `name` in frontmatter is kebab-case and matches directory name
- [ ] `version` follows semver (start with `0.1.0` for drafts)
- [ ] `description` is 1-3 concrete sentences
- [ ] `## Core Philosophy` has 3-7 numbered principles
- [ ] `## The {Process}` has sequential, numbered steps
- [ ] Each step defines inputs and outputs
- [ ] `## Safety Guards` has at least 1 non-negotiable guard
- [ ] `## Quick Reference` summarizes the workflow in a code block
- [ ] No Mermaid diagrams (use ASCII art)
- [ ] All code blocks have language identifiers

## Tips

- **Be specific.** "Always validate JWT expiry before trusting claims" beats "handle auth properly."
- **Define your terms.** If a step references "significant work" or "candidate events," define exactly what qualifies.
- **Include examples.** Good and bad examples help LLMs understand intent.
- **Test with a real agent.** Install the skill in your AI tool and run it on a real task before submitting.

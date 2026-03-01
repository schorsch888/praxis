# Contributing to Praxis

Thank you for your interest in contributing to praxis. This guide covers how to propose new skills, improve existing ones, and contribute integration guides.

## Ways to Contribute

1. **Submit a new skill** — share a workflow you've found valuable
2. **Improve an existing skill** — fix bugs, clarify language, add examples
3. **Add an integration guide** — document how to use praxis with a specific tool
4. **Report issues** — file bugs or suggest improvements

## Developer Setup

```bash
# Clone the repository
git clone https://github.com/praxis-skills/praxis.git
cd praxis

# Verify the CLI works
bash cli/praxis.sh --version
bash cli/praxis.sh help

# Validate a skill
bash cli/praxis.sh validate skills/self-improve/SKILL.md
```

No build step or dependencies are required beyond `bash` and `curl`.

## Proposing a New Skill

Before writing a skill, open a [New Skill Proposal](https://github.com/praxis-skills/praxis/issues/new?template=new-skill-proposal.md) issue to discuss:

- What problem does the skill solve?
- What AI coding workflow does it improve?
- Is it general enough to benefit multiple projects?

This prevents duplicate effort and ensures alignment with the project's goals.

## Writing a Skill

### Prerequisites

1. Read the [Skill Specification](SKILL_SPEC.md) — the normative format standard
2. Read the [Authoring Guide](docs/authoring-guide.md) — step-by-step instructions
3. Copy the [template](skills/_template/) as your starting point

### Skill Authoring Checklist

Before submitting your skill PR, verify:

- [ ] **Directory structure**: `skills/<name>/SKILL.md` (name matches frontmatter)
- [ ] **Frontmatter**: valid YAML with `name`, `version`, `description`
- [ ] **Name**: kebab-case, 2-50 characters, no consecutive or trailing hyphens
- [ ] **Version**: semantic versioning (start with `0.1.0` for new skills)
- [ ] **Required sections present**:
  - [ ] `# Title` — descriptive H1 heading
  - [ ] `## Core Philosophy` — 3-7 numbered principles
  - [ ] `## The {Process}` — sequential steps with inputs/outputs
  - [ ] `## Safety Guards` — at least 1 bold-numbered non-negotiable rule
  - [ ] `## Quick Reference` — summary code block
- [ ] **Section ordering**: required sections appear in the order listed above
- [ ] **Specificity**: rules use "Always/Never X when Y; because Z" format
- [ ] **No Mermaid**: diagrams use text-based box-drawing only
- [ ] **Code blocks**: all have language identifiers
- [ ] **Tested**: installed in at least one AI tool and run on a real task
- [ ] **Registry**: added entry to `registry.yaml`
- [ ] **README**: added `skills/<name>/README.md` with quick start

### Quality Standards

Skills are read by LLMs, so clarity and precision matter more than brevity:

- **Be specific.** Vague instructions produce inconsistent results. "Always validate JWT expiry before trusting claims" is better than "handle auth properly."
- **Define your terms.** If a step references a concept like "significant work," define exactly what qualifies.
- **Include examples.** Good and bad examples help LLMs distinguish intent.
- **Add safety guards.** Every skill should have at least one non-negotiable rule that prevents harm.
- **Test with a real agent.** The gap between what you wrote and what an LLM understands can be surprising.

## Review Process

1. **Automated checks** — CI validates frontmatter, required sections, and registry consistency
2. **Maintainer review** — at least one maintainer reviews the skill for quality, safety, and fit
3. **Community feedback** — PRs are open for community discussion for at least 48 hours

### What Reviewers Look For

- Does the skill solve a real, recurring problem?
- Are the safety guards sufficient to prevent misuse?
- Is the process specific enough for an LLM to follow deterministically?
- Are there good and bad examples to illustrate intent?
- Does it work with multiple AI tools, or is it tool-specific?

## Improving Existing Skills

For changes to existing skills:

- **Patch** (typos, clarifications): submit directly as a PR
- **Minor** (new optional sections, examples): open an issue first if the change is substantial
- **Major** (changed process, modified guards): requires a proposal issue and maintainer approval

Always bump the `version` field in frontmatter according to semver.

## Code of Conduct

All contributors are expected to follow our [Code of Conduct](CODE_OF_CONDUCT.md). Be respectful, constructive, and specific in all interactions. Focus on the work, not the person. Skills affect how AI agents behave in real projects — take quality and safety seriously.

## Developer Certificate of Origin

By contributing to this project, you certify that your contribution is compatible with the project's [MIT license](LICENSE) and that you have the right to submit it. See the [Developer Certificate of Origin](https://developercertificate.org/) for details.

## Getting Help

- Open an issue for questions about the skill format or contribution process
- Check existing skills for examples of well-structured specifications
- Read the [Authoring Guide](docs/authoring-guide.md) for detailed writing instructions

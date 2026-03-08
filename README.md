# praxis

**Open-source skill framework for AI coding agents.**

*praxis* (Greek: "practice/action") — learning by doing.

---

## Table of Contents

- [What is a Skill?](#what-is-a-skill)
- [Quick Start](#quick-start)
- [Available Skills](#available-skills)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [The Self-Improve Skill](#the-self-improve-skill)
- [Writing Your Own Skill](#writing-your-own-skill)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)

## What is a Skill?

A skill is a Markdown specification that teaches an AI coding agent a specific workflow. Skills are not code plugins — they are structured documents consumed by LLMs, defining processes, safety guards, and decision frameworks that guide agent behavior. One skill file works across Claude Code, Cursor, Copilot, Codex, Gemini, Windsurf, and Cline.

## Quick Start

```bash
# Install the CLI
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/cli/praxis.sh -o praxis.sh
chmod +x praxis.sh

# Install your first skill
./praxis.sh install self-improve
```

Or install globally:

```bash
sudo mv praxis.sh /usr/local/bin/praxis
praxis install self-improve
```

Or manually: copy any [`SKILL.md`](skills/) file into your project's AI configuration directory.

`praxis` CLI is for skill distribution and validation. Skill workflows (for example `/self-improve`) run inside your AI agent, not inside this CLI.

## Available Skills

| Skill | Version | Description |
|-------|---------|-------------|
| [design-doc-elite-review](skills/design-doc-elite-review/) | 0.1.0 | Runs multi-round, cross-functional design document reviews with explicit support and opposition analysis, then issues a decision using enterprise and big-tech production standards |
| [self-improve](skills/self-improve/) | 1.1.0 | Teaches AI agents to learn from practice — extracting patterns, lessons, and coding standards from bugs fixed, reviews completed, and features shipped |

## How It Works

```text
+-----------------------------------------------------------+
|                     SKILL.md                              |
|                                                           |
|  ---                                                      |
|  name: self-improve          <- YAML frontmatter          |
|  version: 1.0.0                (metadata + triggers)      |
|  ---                                                      |
|                                                           |
|  # Title                     <- Markdown body             |
|  ## Core Philosophy            (process + guards)         |
|  ## The Learning Loop                                     |
|  ## Safety Guards                                         |
|  ## Quick Reference                                       |
|                                                           |
+----------------+------------------------------------------+
                 |
                 |  AI tool loads skill as context
                 v
+-----------------------------------------------------------+
|              AI Coding Agent                              |
|                                                           |
|  Reads the skill specification and follows the            |
|  defined process, safety guards, and decision             |
|  framework during normal coding work.                     |
|                                                           |
|  Supported: Claude Code, Cursor, Copilot, Codex,         |
|             Gemini, Windsurf, Cline                       |
+-----------------------------------------------------------+
```

## Installation

### Option A: CLI (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/cli/praxis.sh -o praxis.sh
chmod +x praxis.sh
./praxis.sh install self-improve
```

The CLI installs and validates skills only. Execution happens in your AI tool after the skill is loaded.

### Option B: Global install

```bash
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/cli/praxis.sh -o /usr/local/bin/praxis
chmod +x /usr/local/bin/praxis
praxis install self-improve
```

### Option C: Manual copy

1. Browse the [skills/](skills/) directory
2. Copy `SKILL.md` into your project
3. Configure your AI tool to load it (see [integration guides](docs/integration/))

### Option D: Git submodule

```bash
git submodule add https://github.com/praxis-skills/praxis.git .praxis
```

### Tool-Specific Setup

| Tool | Guide |
|------|-------|
| Claude Code | [docs/integration/claude-code.md](docs/integration/claude-code.md) |
| Cursor | [docs/integration/cursor.md](docs/integration/cursor.md) |
| GitHub Copilot | [docs/integration/copilot.md](docs/integration/copilot.md) |
| Codex | [docs/integration/codex.md](docs/integration/codex.md) |
| Gemini | [docs/integration/gemini.md](docs/integration/gemini.md) |
| Windsurf | [docs/integration/windsurf.md](docs/integration/windsurf.md) |
| Cline | [docs/integration/cline.md](docs/integration/cline.md) |

## The Self-Improve Skill

The flagship skill. After fixing bugs, completing features, or receiving code reviews, the agent:

1. **Observes** — scans git history and session for learning material
2. **Extracts** — turns observations into actionable rules ("Always/Never X when Y; because Z")
3. **Validates** — deduplicates, quality-filters, checks for recurring patterns
4. **Stores** — shows the user, gets approval, writes to project config or agent memory

Patterns must be observed 3 times before promotion to team-wide standards. Security issues skip the queue. 12 safety guards prevent harmful output. See the [full specification](skills/self-improve/SKILL.md).

## Writing Your Own Skill

1. Read the [Skill Specification](SKILL_SPEC.md) for the normative format
2. Copy the [template](skills/_template/) as a starting point
3. Follow the [Authoring Guide](docs/authoring-guide.md) for step-by-step instructions
4. Submit a PR — see [Contributing](CONTRIBUTING.md)

## Contributing

We welcome new skills, improvements to existing ones, and integration guides. See [CONTRIBUTING.md](CONTRIBUTING.md) for the process.

## Roadmap

Planned for future releases:

- Additional skills (test-first, debugging, code-review)
- Skill composition (combining multiple skills)
- Programmatic validation beyond the CLI
- Community skill registry
- Skill analytics and usage tracking

## Philosophy

Skills encode hard-won engineering knowledge as agent-readable specifications. They are:

- **Markdown, not code** — LLMs read Markdown natively. No runtime, no dependencies, no build step.
- **Portable** — one skill file works across every major AI coding tool.
- **Opinionated** — skills define specific processes with safety guards, not vague guidelines.
- **Community-driven** — the best practices of many engineers, distilled into reusable workflows.

The name *praxis* reflects the core belief: the best standards come from practice, not theory.

## License

[MIT](LICENSE)

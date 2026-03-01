# Using Praxis Skills with GitHub Copilot

## Installation

### Option A: Skills directory (recommended)

```bash
mkdir -p .github/copilot-skills
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o .github/copilot-skills/self-improve.md
```

### Option B: Copilot instructions file

Copy the skill content to your Copilot instructions file. If appending to an existing file, add a separator first:

```bash
printf '\n---\n\n' >> .github/copilot-instructions.md
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o /tmp/self-improve.md
cat /tmp/self-improve.md >> .github/copilot-instructions.md
rm /tmp/self-improve.md
```

> **Note**: Be cautious with `>>` (append) — verify the file content is what you expect after appending.

### Option C: Using the CLI

```bash
./praxis.sh install self-improve
cp .praxis/skills/self-improve/SKILL.md .github/copilot-skills/self-improve.md
```

## Usage

In Copilot Chat, invoke the skill:

```text
Run /self-improve on my recent changes
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

GitHub Copilot reads `.github/copilot-instructions.md` as custom instructions. The agent follows the skill's process when triggered.

Skills write lessons to:
- `.github/copilot-instructions.md` for project-level rules
- Agent memory directory for personal notes

## Notes

- Copilot's context window is limited. If using multiple skills, consider which are most valuable.
- Copilot instruction files are committed to the repo and shared with the team.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

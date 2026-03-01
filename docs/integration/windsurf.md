# Using Praxis Skills with Windsurf

## Installation

### Option A: .windsurfrules file

Copy the skill content to your `.windsurfrules` file. If appending to an existing file, add a separator first:

```bash
printf '\n---\n\n' >> .windsurfrules
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o /tmp/self-improve.md
cat /tmp/self-improve.md >> .windsurfrules
rm /tmp/self-improve.md
```

> **Note**: Be cautious with `>>` (append) — verify the file content is what you expect after appending.

### Option B: Separate file

```bash
mkdir -p .windsurf/skills
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o .windsurf/skills/self-improve.md
```

### Option C: Using the CLI

```bash
./praxis.sh install self-improve
cp .praxis/skills/self-improve/SKILL.md .windsurf/skills/self-improve.md
```

## Usage

In Windsurf, invoke the skill:

```text
Run /self-improve on my recent changes
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

Windsurf reads `.windsurfrules` as project-level instructions. The agent follows the skill's process when triggered.

Skills write lessons to:
- `.windsurfrules` for project-level rules
- Agent memory directory for personal notes

## Notes

- `.windsurfrules` is committed to the repo. Review changes before committing.
- Windsurf's context handling may vary — test with your skill to verify it loads correctly.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

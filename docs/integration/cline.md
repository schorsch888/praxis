# Using Praxis Skills with Cline

## Installation

### Option A: .clinerules file

Copy the skill content to your `.clinerules` file. If appending to an existing file, add a separator first:

```bash
printf '\n---\n\n' >> .clinerules
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o /tmp/self-improve.md
cat /tmp/self-improve.md >> .clinerules
rm /tmp/self-improve.md
```

> **Note**: Be cautious with `>>` (append) — verify the file content is what you expect after appending.

### Option B: Separate file

```bash
mkdir -p .cline/skills
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o .cline/skills/self-improve.md
```

### Option C: Using the CLI

```bash
./praxis.sh install self-improve
cp .praxis/skills/self-improve/SKILL.md .cline/skills/self-improve.md
```

## Usage

In Cline, invoke the skill:

```text
Run /self-improve on my recent changes
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

Cline reads `.clinerules` as project-level instructions. The agent follows the skill's process when triggered.

Skills write lessons to:
- `.clinerules` for project-level rules
- Agent memory directory for personal notes

## Notes

- `.clinerules` is committed to the repo. Review changes before committing.
- Cline supports custom instructions — check its documentation for the latest conventions.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

# Using Praxis Skills with Gemini

## Installation

### Option A: Separate file (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o self-improve-skill.md
```

Reference the skill in your `GEMINI.md`:

```markdown
## Skills

Follow the process defined in `self-improve-skill.md` for learning from practice.
```

### Option B: Append to GEMINI.md

Copy the skill content to your `GEMINI.md` file. If appending to an existing file, add a separator first:

```bash
printf '\n---\n\n' >> GEMINI.md
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o /tmp/self-improve.md
cat /tmp/self-improve.md >> GEMINI.md
rm /tmp/self-improve.md
```

> **Note**: Be cautious with `>>` (append) — verify the file content is what you expect after appending.

### Option C: Using the CLI

```bash
./praxis.sh install self-improve
```

Then reference `.praxis/skills/self-improve/SKILL.md` from your `GEMINI.md`.

## Usage

In Gemini, invoke the skill:

```text
Run /self-improve on my recent work
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

Gemini reads `GEMINI.md` as project-level instructions. The agent follows the skill's process when triggered.

Skills write lessons to:
- `GEMINI.md` for project-level rules
- Agent memory directory for personal notes

## Notes

- Check Gemini's current documentation for the latest instruction file conventions.
- `GEMINI.md` is committed to the repo and shared with the team.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

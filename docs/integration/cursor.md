# Using Praxis Skills with Cursor

## Installation

### Option A: Rules directory (recommended for Cursor 0.40+)

```bash
mkdir -p .cursor/rules
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o .cursor/rules/self-improve.md
```

### Option B: .cursorrules file

Copy the skill content to your `.cursorrules` file. If appending to an existing file, add a separator first:

```bash
printf '\n---\n\n' >> .cursorrules
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o /tmp/self-improve.md
cat /tmp/self-improve.md >> .cursorrules
rm /tmp/self-improve.md
```

> **Note**: Be cautious with `>>` (append) — verify the file content is what you expect after appending.

### Option C: Using the CLI

```bash
./praxis.sh install self-improve
cp .praxis/skills/self-improve/SKILL.md .cursor/rules/self-improve.md
```

## Usage

In Cursor chat, reference the skill:

```text
@self-improve — run the learning loop on my recent work
```

Or invoke manually in the chat:

```text
Run /self-improve on the changes I just made
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

Cursor loads `.cursor/rules/*.md` (or `.cursorrules`) as system-level instructions. The agent reads the skill specification and follows the defined process during coding sessions.

Skills write lessons to:
- `.cursorrules` or `.cursor/rules/` for project-level rules
- Agent memory directory for personal notes

## Notes

- Cursor loads rules at session start. Restart the chat to pick up changes.
- Large skills may consume significant context window space. Monitor token usage if using multiple skills.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

# Using Praxis Skills with Codex (OpenAI)

## Installation

### Option A: Separate file (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o self-improve-skill.md
```

Reference the skill in your `AGENTS.md`:

```markdown
## Skills

Follow the process defined in `self-improve-skill.md` for learning from practice.
```

### Option B: Using the CLI

```bash
./praxis.sh install self-improve
```

Then reference `.praxis/skills/self-improve/SKILL.md` from your `AGENTS.md`.

## Usage

In Codex, invoke the skill:

```text
Run /self-improve on the changes in this session
```

The skill activates automatically after trigger conditions are met (e.g., after fixing a bug or completing a feature).

## How It Works

Codex reads `AGENTS.md` as agent instructions. By referencing the skill file, the agent loads and follows the skill specification.

Skills write lessons to:
- `AGENTS.md` for project-level rules
- Agent memory directory for personal notes

## Notes

- Place the skill file where Codex can access it (project root or a referenced directory).
- Codex's sandboxed execution may limit file system access — verify the agent can read/write to the expected locations.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

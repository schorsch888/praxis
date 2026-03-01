# Using Praxis Skills with Claude Code

## Installation

### Option A: Skills directory (recommended)

```bash
# Create skills directory
mkdir -p .claude/skills

# Install with CLI
./praxis.sh install self-improve
cp .praxis/skills/self-improve/SKILL.md .claude/skills/self-improve.md
```

Claude Code automatically loads all `.md` files from `.claude/skills/` as skill context.

### Option B: Reference from CLAUDE.md

Add a reference in your project's `CLAUDE.md`:

```markdown
## Skills

See `.praxis/skills/self-improve/SKILL.md` for the self-improving coding standards skill.
```

### Option C: Manual copy

```bash
mkdir -p .claude/skills
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/skills/self-improve/SKILL.md \
  -o .claude/skills/self-improve.md
```

## Usage

Once installed, skills activate automatically based on their trigger conditions (e.g., after fixing a bug or completing a feature). You can also invoke them manually:

```text
/self-improve          # Run the learning loop
/self-improve --status # Check skill state
```

## How It Works

Claude Code loads skills as part of the system context. The agent reads the skill specification and follows the defined process during normal coding work. Skills integrate with Claude Code's native features:

- **Agent memory**: Skills can write to `~/.claude/projects/<project>/memory/`
- **CLAUDE.md**: Skills can append lessons to project-level configuration
- **Slash commands**: Manual triggers work as slash commands

## Notes

- Skills are loaded at session start. Changes to skill files take effect in the next session.
- Claude Code's permission system applies — the agent will ask before writing to files.

## See Also

- [Skill Specification](../../SKILL_SPEC.md) — format standard
- [Authoring Guide](../authoring-guide.md) — writing your own skills
- [CLI Reference](../../cli/README.md) — installing and managing skills

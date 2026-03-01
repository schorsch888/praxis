# Praxis CLI

A single-file Bash script for managing praxis skills. Zero dependencies beyond `bash` and `curl`.

## Installation

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/main/cli/praxis.sh -o praxis.sh
chmod +x praxis.sh

# Or add to your PATH for global access
sudo mv praxis.sh /usr/local/bin/praxis
```

## Commands

| Command | Description |
|---------|-------------|
| `praxis install <skill>` | Download and install a skill into the current project |
| `praxis uninstall <skill>` | Remove an installed skill |
| `praxis list` | Show available skills from the registry |
| `praxis update` | Update all installed skills to latest versions |
| `praxis info <skill>` | Show metadata for a skill |
| `praxis validate <path>` | Validate a SKILL.md file against the spec |
| `praxis help` | Show help message |

## Usage

```bash
# List available skills
praxis list

# Install a skill into the current project
praxis install self-improve

# Show skill metadata
praxis info self-improve

# Update all installed skills
praxis update

# Validate a skill file
praxis validate skills/my-skill/SKILL.md

# Show version
praxis --version
```

## How It Works

The CLI fetches `registry.yaml` from the praxis GitHub repository, downloads skill files, and places them in your project under `.praxis/skills/`.

Installed skills are tracked in a `.praxis.lock` file in your project root. The lock file records each installed skill's version and SHA-256 checksum for integrity verification.

## Lock File

The `.praxis.lock` file is automatically managed by the CLI:

```text
self-improve=1.0.0 sha256:3ab1a0986e84d86990690c6b7e410890a45274b3c7be66fbc61959aecbaf1c85
```

- Created/updated on `install` and `update`
- Cleaned up on `uninstall`
- Removed automatically when empty
- Should be added to `.gitignore` (consumer-side artifact)

## Custom Install Directory

Set `PRAXIS_DIR` to change where skills are installed:

```bash
PRAXIS_DIR=.claude/skills praxis install self-improve
```

`PRAXIS_DIR` must be a relative path (no absolute paths or `..` components).

## After Installing

Copy the `SKILL.md` file to your AI tool's configuration directory:

| Tool | Destination |
|------|-------------|
| Claude Code | `.claude/skills/` or reference from `CLAUDE.md` |
| Cursor | `.cursor/rules/` or `.cursorrules` |
| GitHub Copilot | `.github/copilot-skills/` |
| Codex | Reference from `AGENTS.md` |
| Gemini | Reference from `GEMINI.md` |
| Windsurf | `.windsurfrules` |
| Cline | `.clinerules` |

See the [integration guides](../docs/integration/) for tool-specific instructions.

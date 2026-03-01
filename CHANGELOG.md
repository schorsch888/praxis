# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-03-01

### Added

- **Skill Specification** (`SKILL_SPEC.md`): normative format standard for praxis skills — defines frontmatter schema, required body sections, format conventions, and validation checklist
- **self-improve skill** (`skills/self-improve/`): flagship skill teaching AI agents to learn from practice through a 4-step loop (OBSERVE, EXTRACT, VALIDATE, STORE) with 12 safety guards, three-strike promotion, graduated trust, and stagnation backoff
- **Skill template** (`skills/_template/`): skeleton for new skill authors with all required sections
- **CLI** (`cli/praxis.sh`): single-file Bash script for installing, listing, updating, and inspecting skills — zero dependencies beyond bash and curl
- **Registry** (`registry.yaml`): machine-readable skill catalog
- **Documentation**: conceptual explainer, authoring guide, and integration guides for 7 AI coding tools (Claude Code, Cursor, Copilot, Codex, Gemini, Windsurf, Cline)
- **CI**: GitHub Actions workflow validating YAML frontmatter, required sections, and registry consistency
- **GitHub templates**: issue templates for skill proposals and bug reports, PR template with skill checklist

[1.0.0]: https://github.com/praxis-skills/praxis/releases/tag/v1.0.0

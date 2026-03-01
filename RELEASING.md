# Releasing Praxis

This document describes the process for releasing a new version of Praxis.

## Version Bump Checklist

Before creating a release:

- [ ] All CI checks pass on `main`
- [ ] `CHANGELOG.md` has an entry for the new version with the release date
- [ ] `VERSION` in `cli/praxis.sh` matches the release version
- [ ] `RELEASE_TAG` in `cli/praxis.sh` is `v{VERSION}`
- [ ] `registry.yaml` version field is updated
- [ ] All skill SHA-256 checksums in `registry.yaml` are current
- [ ] `SKILL_SPEC.md` title version matches (if spec changed)
- [ ] All new/changed skills pass `praxis validate`

## Release Procedure

### 1. Update version numbers

```bash
# Update cli/praxis.sh VERSION
# Update registry.yaml version
# Update CHANGELOG.md with release date
```

### 2. Verify checksums

```bash
sha256sum skills/*/SKILL.md
# Update registry.yaml sha256 fields if any skill files changed
```

### 3. Run validation

```bash
bash cli/praxis.sh validate skills/self-improve/SKILL.md
bash cli/praxis.sh --version
bash cli/praxis.sh help
```

### 4. Create the release commit

```bash
git add -A
git commit -m "release: vX.Y.Z"
```

### 5. Tag the release

```bash
git tag -a vX.Y.Z -m "Praxis vX.Y.Z"
git push origin main --tags
```

### 6. Create GitHub Release

```bash
gh release create vX.Y.Z --title "Praxis vX.Y.Z" --notes-file CHANGELOG_EXCERPT.md
```

Or use the GitHub UI to create a release from the tag, copying the relevant CHANGELOG section as release notes.

## Versioning Policy

- **Major** (2.0.0): Breaking changes to the skill spec, CLI interface changes, registry schema changes
- **Minor** (1.1.0): New skills, new CLI commands, new optional spec sections
- **Patch** (1.0.1): Bug fixes, documentation updates, checksum updates

## Post-Release

- [ ] Verify the release tag is visible on GitHub
- [ ] Verify `curl -fsSL https://raw.githubusercontent.com/praxis-skills/praxis/vX.Y.Z/cli/praxis.sh` works
- [ ] Announce in relevant channels

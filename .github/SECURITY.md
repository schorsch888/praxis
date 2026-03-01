# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 1.0.x   | Yes                |

## Reporting a Vulnerability

If you discover a security vulnerability in Praxis, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, use [GitHub's private vulnerability reporting](https://github.com/praxis-skills/praxis/security/advisories/new) to submit a report. Include:

1. A description of the vulnerability
2. Steps to reproduce the issue
3. The potential impact
4. Any suggested fixes (optional)

### What to Expect

- **Acknowledgment**: Within 48 hours of your report
- **Assessment**: Within 7 days, we will assess severity and impact
- **Fix timeline**: Critical issues will be patched within 14 days; other issues within 30 days
- **Disclosure**: We will coordinate disclosure timing with you

### Scope

The following are in scope:

- **CLI (`cli/praxis.sh`)**: Command injection, path traversal, symlink attacks, integrity bypass
- **Registry (`registry.yaml`)**: Tampering, checksum bypass, supply chain issues
- **CI pipeline (`.github/workflows/`)**: Workflow injection, secret exposure
- **Skill specification**: Safety guard bypass vectors

The following are out of scope:

- Skills themselves (report to the skill author)
- Social engineering
- Denial of service against GitHub infrastructure

### Credit

We gratefully acknowledge security researchers who report vulnerabilities responsibly. With your permission, we will credit you in the release notes and CHANGELOG.

## Security Best Practices for Skill Authors

- Never include secrets, API keys, or credentials in skill files
- Safety guards should be specific and enforceable
- Skills that read from untrusted sources (git history, review comments) should document sanitization requirements
- See the [Skill Specification](../SKILL_SPEC.md) for security-related requirements

#!/usr/bin/env bash
# Copyright (c) 2026 praxis contributors
# SPDX-License-Identifier: MIT
#
# praxis — skill manager for AI coding agents
# https://github.com/praxis-skills/praxis
#
# Zero dependencies beyond bash and curl.

set -euo pipefail

VERSION="1.0.0"
REPO_OWNER="schorsch888"
REPO_NAME="praxis"
RELEASE_TAG="main"
RAW_BASE="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/${RELEASE_TAG}"
REGISTRY_URL="${RAW_BASE}/registry.yaml"
LOCK_FILE=".praxis.lock"
CACHE_DIR="${HOME}/.cache/praxis"
CACHE_TTL=3600  # 1 hour in seconds
_ISSUE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/issues"

# Temp file tracking for cleanup
_TMPFILES=()

_cleanup() {
  for f in "${_TMPFILES[@]:-}"; do
    rm -f "$f" 2>/dev/null || true
  done
}
trap _cleanup EXIT INT TERM HUP

# Register a temp file for cleanup
_register_tmp() {
  _TMPFILES+=("$1")
}

# Colors (disabled if not a terminal)
if [ -t 1 ]; then
  BOLD=$'\033[1m'
  DIM=$'\033[2m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  RESET=$'\033[0m'
else
  BOLD="" DIM="" GREEN="" YELLOW="" RED="" RESET=""
fi

usage() {
  cat <<EOF
${BOLD}praxis${RESET} v${VERSION} — skill manager for AI coding agents

${BOLD}USAGE${RESET}
  praxis <command> [options] [arguments]

${BOLD}COMMANDS${RESET}
  install <skill>      Download and install a skill
  uninstall <skill>    Remove an installed skill
  list                 Show available skills from the registry
  update               Update all installed skills to latest versions
  info <skill>         Show metadata for a skill
  validate <path>      Validate a SKILL.md file against the spec
  help                 Show this help message

${BOLD}OPTIONS${RESET}
  -g, --global         Install to user home (~/) instead of current project
  -a, --agent <tool>   Target a specific agent (claude-code, cursor, copilot, etc.)
  --version            Show praxis version

${BOLD}EXAMPLES${RESET}
  praxis install self-improve              # project-local, auto-detect tools
  praxis install self-improve -g           # global install to ~/.<tool>/skills/
  praxis install self-improve -a cursor    # target Cursor only
  praxis list
  praxis validate skills/my-skill/SKILL.md

${BOLD}ENVIRONMENT${RESET}
  PRAXIS_DIR           Install directory (default: .praxis/skills)

EOF
}

die() {
  printf "%s\n" "${RED}error:${RESET} $1" >&2
  printf "%s\n" "If this is a bug, please report it: ${_ISSUE_URL}" >&2
  exit 1
}

info() {
  printf "%s\n" "${GREEN}=>${RESET} $1"
}

warn() {
  printf "%s\n" "${YELLOW}warning:${RESET} $1"
}

# Validate a skill name: lowercase, digits, hyphens only
# Must start with a letter, 2-50 chars, no consecutive or trailing hyphens
validate_skill_name() {
  local name="$1"
  if ! printf '%s' "$name" | grep -qE '^[a-z][a-z0-9-]{1,49}$'; then
    die "Invalid skill name '${name}': must be lowercase letters, digits, and hyphens (2-50 chars)"
  fi
  # Reject consecutive hyphens
  if printf '%s' "$name" | grep -qF -- '--'; then
    die "Invalid skill name '${name}': consecutive hyphens are not allowed"
  fi
  # Reject trailing hyphen
  if printf '%s' "$name" | grep -qE -- '-$'; then
    die "Invalid skill name '${name}': trailing hyphen is not allowed"
  fi
}

# Fetch a URL to stdout. Tries curl, then wget. Enforces HTTPS.
fetch() {
  local url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --proto =https --max-redirs 5 --max-time 30 "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO- --timeout=30 "$url"
  else
    die "curl or wget is required"
  fi
}

# Fetch a URL safely to a file (atomic write via temp file)
fetch_to_file() {
  local url="$1"
  local dest="$2"
  local tmpfile
  tmpfile="$(mktemp "${dest}.XXXXXX")"
  _register_tmp "$tmpfile"
  if fetch "$url" > "$tmpfile"; then
    mv "$tmpfile" "$dest"
  else
    rm -f "$tmpfile"
    return 1
  fi
}

# Get cached registry or fetch fresh copy
fetch_registry() {
  mkdir -p "$CACHE_DIR"
  chmod 700 "$CACHE_DIR"
  local cache_file="${CACHE_DIR}/registry.yaml"

  # Check cache freshness
  if [ -f "$cache_file" ]; then
    local now cache_mtime age
    now=$(date +%s 2>/dev/null) || { cat "$cache_file"; return 0; }
    # Portable stat: try GNU, then BSD
    cache_mtime=$(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null || echo 0)
    age=$((now - cache_mtime))
    if [ "$age" -lt "$CACHE_TTL" ]; then
      cat "$cache_file"
      return 0
    fi
  fi

  # Fetch and cache
  local registry
  registry="$(fetch "$REGISTRY_URL")" || die "Failed to fetch registry from $REGISTRY_URL"
  printf '%s\n' "$registry" > "$cache_file"
  printf '%s\n' "$registry"
}

# Extract a skill block from registry YAML
# Uses awk with -v to avoid injection
extract_skill_block() {
  local skill="$1"
  local registry="$2"
  printf '%s\n' "$registry" | awk -v skill="$skill" '
    $0 == "  " skill ":" { found=1; next }
    found && /^  [a-z]/ { exit }
    found { print }
  '
}

# Parse a simple YAML value from a block of text
# Only handles flat key: value lines — sufficient for registry.yaml
parse_yaml_field() {
  local key="$1"
  local content="$2"
  printf '%s\n' "$content" \
    | grep -F "    ${key}:" \
    | head -n 1 \
    | sed "s/^[[:space:]]*${key}:[[:space:]]*//" \
    | sed "s/^[\"']//; s/[\"'][[:space:]]*$//"
}

# Get the install directory, with validation
install_dir() {
  local dir="${PRAXIS_DIR:-.praxis/skills}"
  # Reject absolute paths
  case "$dir" in
    /*) die "PRAXIS_DIR must not be an absolute path: '${dir}'" ;;
  esac
  # Reject path traversal
  case "$dir" in
    *../*|*/..) die "PRAXIS_DIR must not contain '..' components: '${dir}'" ;;
  esac
  printf '%s' "$dir"
}

# Atomically update the lock file
update_lock() {
  local skill="$1"
  local version="$2"
  local sha="$3"
  local tmpfile

  # Reject symlink on lock file
  if [ -L "$LOCK_FILE" ]; then
    die "Lock file '${LOCK_FILE}' is a symlink — refusing to write"
  fi

  tmpfile="$(mktemp "${LOCK_FILE}.XXXXXX")"
  _register_tmp "$tmpfile"

  # Copy existing entries (excluding this skill) to temp file
  if [ -f "$LOCK_FILE" ]; then
    grep -v "^${skill}=" "$LOCK_FILE" > "$tmpfile" 2>/dev/null || true
  fi

  # Append new entry
  printf '%s=%s sha256:%s\n' "$skill" "$version" "$sha" >> "$tmpfile"

  # Atomic replace
  mv "$tmpfile" "$LOCK_FILE"
}

# Remove a skill from the lock file
remove_from_lock() {
  local skill="$1"
  if [ ! -f "$LOCK_FILE" ]; then
    return 0
  fi

  # Reject symlink on lock file
  if [ -L "$LOCK_FILE" ]; then
    die "Lock file '${LOCK_FILE}' is a symlink — refusing to write"
  fi

  local tmpfile
  tmpfile="$(mktemp "${LOCK_FILE}.XXXXXX")"
  _register_tmp "$tmpfile"
  grep -v "^${skill}=" "$LOCK_FILE" > "$tmpfile" 2>/dev/null || true
  mv "$tmpfile" "$LOCK_FILE"

  # Remove lock file if empty
  if [ ! -s "$LOCK_FILE" ]; then
    rm -f "$LOCK_FILE"
  fi
}

# Compute SHA-256 of a file (mandatory — die if unavailable)
compute_sha256() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | cut -d' ' -f1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | cut -d' ' -f1
  else
    die "SHA-256 tool required: install sha256sum or shasum"
  fi
}

# Validate a skill path matches expected pattern
validate_skill_path() {
  local path="$1"
  if ! printf '%s' "$path" | grep -qE '^skills/[a-z][a-z0-9-]+/SKILL\.md$'; then
    die "Invalid skill path '${path}': must match skills/<name>/SKILL.md"
  fi
}

# ---- Agent directory mappings ----
# Each agent has a project-scope and global-scope skills directory.
# Follows the Vercel skills ecosystem conventions.

# Copy skill file to an agent directory, creating it if needed
_link_skill() {
  local skill_file="$1"
  local skill="$2"
  local target_dir="$3"
  local agent_name="$4"
  mkdir -p "${target_dir}/${skill}"
  cp "$skill_file" "${target_dir}/${skill}/SKILL.md"
  info "Linked to ${agent_name}: ${target_dir}/${skill}/SKILL.md"
}

# Auto-detect and link to all detected AI tool directories (project scope)
_link_project() {
  local skill_file="$1"
  local skill="$2"
  local linked=0

  # Claude Code
  if [ -d ".claude" ] || [ -f "CLAUDE.md" ]; then
    _link_skill "$skill_file" "$skill" ".claude/skills" "Claude Code"
    linked=$((linked + 1))
  fi
  # Cursor
  if [ -d ".cursor" ] || [ -f ".cursorrules" ]; then
    _link_skill "$skill_file" "$skill" ".cursor/skills" "Cursor"
    linked=$((linked + 1))
  fi
  # GitHub Copilot
  if [ -d ".github" ]; then
    _link_skill "$skill_file" "$skill" ".github/copilot-skills" "Copilot"
    linked=$((linked + 1))
  fi
  # Windsurf
  if [ -d ".windsurf" ] || [ -f ".windsurfrules" ]; then
    _link_skill "$skill_file" "$skill" ".windsurf/skills" "Windsurf"
    linked=$((linked + 1))
  fi
  # Cline
  if [ -d ".cline" ] || [ -f ".clinerules" ]; then
    _link_skill "$skill_file" "$skill" ".cline/skills" "Cline"
    linked=$((linked + 1))
  fi
  # Gemini
  if [ -f "GEMINI.md" ] || [ -d ".gemini" ]; then
    _link_skill "$skill_file" "$skill" ".gemini/skills" "Gemini"
    linked=$((linked + 1))
  fi
  # Codex
  if [ -f "AGENTS.md" ]; then
    _link_skill "$skill_file" "$skill" ".agents/skills" "Codex"
    linked=$((linked + 1))
  fi
  # Universal (.agents/skills) — always install if nothing else detected
  if [ "$linked" -eq 0 ]; then
    _link_skill "$skill_file" "$skill" ".agents/skills" "Universal"
  fi
}

# Link to global (user home) directories
_link_global() {
  local skill_file="$1"
  local skill="$2"
  local agent_filter="${3:-}"

  if [ -z "$agent_filter" ] || [ "$agent_filter" = "claude-code" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.claude/skills" "Claude Code (global)"
  fi
  if [ -z "$agent_filter" ] || [ "$agent_filter" = "cursor" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.cursor/skills" "Cursor (global)"
  fi
  if [ -z "$agent_filter" ] || [ "$agent_filter" = "copilot" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.copilot/skills" "Copilot (global)"
  fi
  if [ -z "$agent_filter" ] || [ "$agent_filter" = "windsurf" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.codeium/windsurf/skills" "Windsurf (global)"
  fi
  if [ -z "$agent_filter" ] || [ "$agent_filter" = "gemini" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.gemini/skills" "Gemini (global)"
  fi
  if [ -z "$agent_filter" ] || [ "$agent_filter" = "cline" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.agents/skills" "Cline (global)"
  fi
  # Universal — always
  if [ -z "$agent_filter" ]; then
    _link_skill "$skill_file" "$skill" "${HOME}/.agents/skills" "Universal (global)"
  fi
}

# Link to a single agent (project scope)
_link_agent() {
  local skill_file="$1"
  local skill="$2"
  local agent="$3"

  case "$agent" in
    claude-code) _link_skill "$skill_file" "$skill" ".claude/skills" "Claude Code" ;;
    cursor)      _link_skill "$skill_file" "$skill" ".cursor/skills" "Cursor" ;;
    copilot)     _link_skill "$skill_file" "$skill" ".github/copilot-skills" "Copilot" ;;
    windsurf)    _link_skill "$skill_file" "$skill" ".windsurf/skills" "Windsurf" ;;
    cline)       _link_skill "$skill_file" "$skill" ".cline/skills" "Cline" ;;
    gemini)      _link_skill "$skill_file" "$skill" ".gemini/skills" "Gemini" ;;
    codex)       _link_skill "$skill_file" "$skill" ".agents/skills" "Codex" ;;
    universal)   _link_skill "$skill_file" "$skill" ".agents/skills" "Universal" ;;
    *)           die "Unknown agent '${agent}'. Supported: claude-code, cursor, copilot, windsurf, cline, gemini, codex, universal" ;;
  esac
}

# ---- Commands ----

cmd_install() {
  local global=false
  local agent_filter=""
  local skill=""

  # Parse flags
  while [ $# -gt 0 ]; do
    case "$1" in
      -g|--global) global=true; shift ;;
      -a|--agent)  [ -z "${2:-}" ] && die "usage: praxis install <skill> -a <agent>"; agent_filter="$2"; shift 2 ;;
      -*)          die "Unknown option: $1" ;;
      *)           if [ -z "$skill" ]; then skill="$1"; else die "Unexpected argument: $1"; fi; shift ;;
    esac
  done

  [ -z "$skill" ] && die "usage: praxis install <skill> [-g] [-a <agent>]"
  validate_skill_name "$skill"

  info "Fetching registry..."
  local registry
  registry="$(fetch_registry)"

  # Extract skill block
  local skill_block
  skill_block="$(extract_skill_block "$skill" "$registry")"
  [ -z "$skill_block" ] && die "Skill '${skill}' not found in registry"

  local skill_path skill_version expected_sha
  skill_path="$(parse_yaml_field "path" "$skill_block")"
  [ -z "$skill_path" ] && die "No path found for skill '${skill}'"

  # Validate skill path against traversal
  validate_skill_path "$skill_path"

  skill_version="$(parse_yaml_field "version" "$skill_block")"
  expected_sha="$(parse_yaml_field "sha256" "$skill_block")"

  local skill_url="${RAW_BASE}/${skill_path}"
  local dest_dir
  dest_dir="$(install_dir)/${skill}"
  mkdir -p "$dest_dir"

  info "Downloading ${skill} v${skill_version}..."
  fetch_to_file "$skill_url" "${dest_dir}/SKILL.md" || die "Failed to download skill"

  # Verify integrity (checksum is mandatory)
  local actual_sha
  actual_sha="$(compute_sha256 "${dest_dir}/SKILL.md")"
  if [ -n "$expected_sha" ]; then
    if [ "$actual_sha" != "$expected_sha" ]; then
      rm -f "${dest_dir}/SKILL.md"
      die "Integrity check failed for '${skill}'. Expected SHA-256: ${expected_sha}, got: ${actual_sha}"
    fi
    info "Integrity verified (SHA-256: ${actual_sha:0:12}...)"
  fi

  # Also try to fetch the skill README
  fetch_to_file "${RAW_BASE}/skills/${skill}/README.md" "${dest_dir}/README.md" 2>/dev/null || true

  # Update lock file with checksum
  update_lock "$skill" "$skill_version" "$actual_sha"

  info "Installed ${BOLD}${skill}${RESET} v${skill_version} to ${dest_dir}/"

  # Link skill to AI tool directories
  local skill_file="${dest_dir}/SKILL.md"

  if [ "$global" = true ]; then
    _link_global "$skill_file" "$skill" "$agent_filter"
  elif [ -n "$agent_filter" ]; then
    _link_agent "$skill_file" "$skill" "$agent_filter"
  else
    _link_project "$skill_file" "$skill"
  fi
}

cmd_uninstall() {
  local skill="${1:-}"
  [ -z "$skill" ] && die "usage: praxis uninstall <skill>"
  validate_skill_name "$skill"

  local dest_dir
  dest_dir="$(install_dir)/${skill}"

  if [ ! -d "$dest_dir" ]; then
    die "Skill '${skill}' is not installed"
  fi

  rm -rf "$dest_dir"
  remove_from_lock "$skill"

  info "Uninstalled ${BOLD}${skill}${RESET}"
}

cmd_list() {
  info "Fetching registry..."
  local registry
  registry="$(fetch_registry)"

  printf '\n%sAvailable skills:%s\n\n' "$BOLD" "$RESET"
  printf '  %s%-20s %-10s %-10s %s%s\n' "$BOLD" "SKILL" "VERSION" "MATURITY" "DESCRIPTION" "$RESET"
  printf '  %-20s %-10s %-10s %s\n' "-----" "-------" "--------" "-----------"

  # Parse skills from registry
  local current_skill="" current_version="" current_desc="" current_maturity=""
  while IFS= read -r line; do
    # Match skill name lines (2-space indent, ends with colon)
    if printf '%s' "$line" | grep -qE '^  [a-z][a-z0-9-]+:$'; then
      # Print previous skill if we have one
      if [ -n "$current_skill" ]; then
        printf '  %-20s %-10s %-10s %s\n' "$current_skill" "$current_version" "$current_maturity" "$current_desc"
      fi
      current_skill="$(printf '%s' "$line" | sed 's/^  \(.*\):$/\1/')"
      current_version=""
      current_desc=""
      current_maturity=""
    fi
    # Match version
    if printf '%s' "$line" | grep -qE '^[[:space:]]+version:'; then
      current_version="$(printf '%s' "$line" | sed 's/.*version:[[:space:]]*//' | tr -d '"')"
    fi
    # Match description
    if printf '%s' "$line" | grep -qE '^[[:space:]]+description:'; then
      current_desc="$(printf '%s' "$line" | sed 's/.*description:[[:space:]]*//' | tr -d '"' | cut -c1-50)"
    fi
    # Match maturity
    if printf '%s' "$line" | grep -qE '^[[:space:]]+maturity:'; then
      current_maturity="$(printf '%s' "$line" | sed 's/.*maturity:[[:space:]]*//' | tr -d '"')"
    fi
  done <<< "$registry"

  # Print last skill
  if [ -n "$current_skill" ]; then
    printf '  %-20s %-10s %-10s %s\n' "$current_skill" "$current_version" "$current_maturity" "$current_desc"
  fi
  printf '\n'
}

cmd_update() {
  if [ ! -f "$LOCK_FILE" ]; then
    die "No ${LOCK_FILE} found. Install skills first with: praxis install <skill>"
  fi

  info "Checking for updates..."
  local registry
  registry="$(fetch_registry)"

  # Read lock file into an array first (avoid modifying during iteration)
  local -a entries=()
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    entries+=("$line")
  done < "$LOCK_FILE"

  local updated=0
  for entry in "${entries[@]}"; do
    local skill installed_version
    skill="${entry%%=*}"
    installed_version="${entry#*=}"
    installed_version="${installed_version%% *}"  # strip sha256 suffix

    [ -z "$skill" ] && continue
    validate_skill_name "$skill" 2>/dev/null || continue

    local skill_block
    skill_block="$(extract_skill_block "$skill" "$registry")"
    local latest_version
    latest_version="$(parse_yaml_field "version" "$skill_block")"

    if [ -z "$latest_version" ]; then
      warn "Skill '${skill}' not found in registry — skipping"
      continue
    fi

    if [ "$installed_version" != "$latest_version" ]; then
      info "Updating ${skill}: ${installed_version} -> ${latest_version}"
      cmd_install "$skill"
      updated=$((updated + 1))
    else
      printf '  %s%s v%s is up to date%s\n' "$DIM" "$skill" "$installed_version" "$RESET"
    fi
  done

  if [ "$updated" -eq 0 ]; then
    info "All skills are up to date."
  else
    info "Updated ${updated} skill(s)."
  fi
}

cmd_info() {
  local skill="${1:-}"
  [ -z "$skill" ] && die "usage: praxis info <skill>"
  validate_skill_name "$skill"

  info "Fetching registry..."
  local registry
  registry="$(fetch_registry)"

  local skill_block
  skill_block="$(extract_skill_block "$skill" "$registry")"
  [ -z "$skill_block" ] && die "Skill '${skill}' not found in registry"

  local version desc author maturity tags sha
  version="$(parse_yaml_field "version" "$skill_block")"
  desc="$(parse_yaml_field "description" "$skill_block")"
  author="$(parse_yaml_field "author" "$skill_block")"
  maturity="$(parse_yaml_field "maturity" "$skill_block")"
  tags="$(parse_yaml_field "tags" "$skill_block")"
  sha="$(parse_yaml_field "sha256" "$skill_block")"

  printf '\n%s%s%s v%s\n\n' "$BOLD" "$skill" "$RESET" "$version"
  printf '  %sDescription:%s  %s\n' "$BOLD" "$RESET" "$desc"
  printf '  %sAuthor:%s       %s\n' "$BOLD" "$RESET" "$author"
  printf '  %sMaturity:%s     %s\n' "$BOLD" "$RESET" "$maturity"
  printf '  %sTags:%s         %s\n' "$BOLD" "$RESET" "$tags"
  [ -n "$sha" ] && printf '  %sSHA-256:%s      %s\n' "$BOLD" "$RESET" "$sha"
  printf '  %sSource:%s       %s/skills/%s/SKILL.md\n' "$BOLD" "$RESET" "$RAW_BASE" "$skill"
  printf '\n'

  # Check if installed locally
  local dest_dir
  dest_dir="$(install_dir)/${skill}"
  if [ -f "${dest_dir}/SKILL.md" ]; then
    printf '  %sInstalled%s at %s/\n\n' "$GREEN" "$RESET" "$dest_dir"
  else
    printf '  %sNot installed. Run: praxis install %s%s\n\n' "$DIM" "$skill" "$RESET"
  fi
}

cmd_validate() {
  local file="${1:-}"
  [ -z "$file" ] && die "usage: praxis validate <path-to-SKILL.md>"
  [ ! -f "$file" ] && die "File not found: ${file}"

  local errors=0 warnings=0

  info "Validating: ${file}"
  printf '\n'

  # Check 1: Frontmatter exists
  if ! head -n 1 "$file" | grep -q '^---$'; then
    printf '  %sFAIL%s  Missing YAML frontmatter (must start with ---)\n' "$RED" "$RESET"
    errors=$((errors + 1))
  else
    printf '  %sPASS%s  YAML frontmatter present\n' "$GREEN" "$RESET"

    # Extract frontmatter using awk (first block only)
    local frontmatter
    frontmatter="$(awk 'NR==1 && /^---$/ { next } /^---$/ { exit } { print }' "$file")"

    # Check 2: Required fields
    for field in name version description; do
      if printf '%s\n' "$frontmatter" | grep -q "^${field}:"; then
        printf '  %sPASS%s  Required field: %s\n' "$GREEN" "$RESET" "$field"
      else
        printf '  %sFAIL%s  Missing required field: %s\n' "$RED" "$RESET" "$field"
        errors=$((errors + 1))
      fi
    done

    # Check 3: Name is kebab-case (no consecutive/trailing hyphens)
    local fm_name
    fm_name="$(printf '%s\n' "$frontmatter" | grep '^name:' | sed 's/^name:[[:space:]]*//')"
    if printf '%s' "$fm_name" | grep -qE '^[a-z][a-z0-9-]{1,49}$' \
       && ! printf '%s' "$fm_name" | grep -qF -- '--' \
       && ! printf '%s' "$fm_name" | grep -qE -- '-$'; then
      printf '  %sPASS%s  Name is valid kebab-case: %s\n' "$GREEN" "$RESET" "$fm_name"
    else
      printf '  %sFAIL%s  Name is not valid kebab-case: %s\n' "$RED" "$RESET" "$fm_name"
      errors=$((errors + 1))
    fi

    # Check 3b: Name matches directory (FAIL, not WARN)
    local dir_name
    dir_name="$(basename "$(dirname "$file")")"
    if [ "$fm_name" = "$dir_name" ]; then
      printf '  %sPASS%s  Name matches directory: %s\n' "$GREEN" "$RESET" "$dir_name"
    else
      printf '  %sFAIL%s  Name "%s" does not match directory "%s"\n' "$RED" "$RESET" "$fm_name" "$dir_name"
      errors=$((errors + 1))
    fi

    # Check 4: Version is semver
    local fm_version
    fm_version="$(printf '%s\n' "$frontmatter" | grep '^version:' | sed 's/^version:[[:space:]]*//')"
    if printf '%s' "$fm_version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+'; then
      printf '  %sPASS%s  Version is valid semver: %s\n' "$GREEN" "$RESET" "$fm_version"
    else
      printf '  %sFAIL%s  Version is not valid semver: %s\n' "$RED" "$RESET" "$fm_version"
      errors=$((errors + 1))
    fi
  fi

  # Check 5: Required sections with ordering validation
  local -a required_patterns=("^# " "^## Core Philosophy" "^## The " "^## Safety Guards" "^## Quick Reference")
  local -a section_names=("H1 Title" "Core Philosophy" "The {Process}" "Safety Guards" "Quick Reference")
  local prev_line=0

  for i in "${!required_patterns[@]}"; do
    local line_num
    line_num="$(grep -n "${required_patterns[$i]}" "$file" | head -n 1 | cut -d: -f1)"
    if [ -n "$line_num" ]; then
      printf '  %sPASS%s  Section: %s (line %s)\n' "$GREEN" "$RESET" "${section_names[$i]}" "$line_num"
      # Validate monotonic ordering
      if [ "$line_num" -le "$prev_line" ] && [ "$prev_line" -gt 0 ]; then
        printf '  %sFAIL%s  Section "%s" appears before previous required section (line %s <= %s)\n' \
          "$RED" "$RESET" "${section_names[$i]}" "$line_num" "$prev_line"
        errors=$((errors + 1))
      fi
      prev_line="$line_num"
    else
      printf '  %sFAIL%s  Missing section: %s\n' "$RED" "$RESET" "${section_names[$i]}"
      errors=$((errors + 1))
    fi
  done

  # Check 6: Safety guards have bold numbering (scoped to Safety Guards section)
  local guard_count
  guard_count="$(sed -n '/^## Safety Guards/,/^## /p' "$file" | grep -cE '^[0-9]+\. \*\*' 2>/dev/null || echo 0)"
  if [ "$guard_count" -ge 1 ]; then
    printf '  %sPASS%s  Safety guards: %s bold-numbered guards found\n' "$GREEN" "$RESET" "$guard_count"
  else
    printf '  %sFAIL%s  No bold-numbered safety guards found in Safety Guards section\n' "$RED" "$RESET"
    errors=$((errors + 1))
  fi

  # Check 7: No Mermaid
  if grep -q '```mermaid' "$file"; then
    printf '  %sFAIL%s  Contains Mermaid diagram (use ASCII art instead)\n' "$RED" "$RESET"
    errors=$((errors + 1))
  else
    printf '  %sPASS%s  No Mermaid diagrams\n' "$GREEN" "$RESET"
  fi

  # Check 8: Code blocks have language identifiers (awk state machine)
  local bare_opens
  bare_opens="$(awk '
    BEGIN { bare = 0; in_block = 0 }
    /^```[a-zA-Z]/ { in_block = 1; next }
    /^```$/ {
      if (in_block) { in_block = 0 }
      else { bare++; in_block = 1 }
      next
    }
  END { print bare }
  ' "$file")"
  if [ "$bare_opens" -gt 0 ]; then
    printf '  %sWARN%s  %s code block(s) without language identifier\n' "$YELLOW" "$RESET" "$bare_opens"
    warnings=$((warnings + 1))
  else
    printf '  %sPASS%s  All code blocks have language identifiers\n' "$GREEN" "$RESET"
  fi

  # Check 9: File size
  local file_size
  file_size="$(wc -c < "$file")"
  if [ "$file_size" -gt 102400 ]; then
    printf '  %sWARN%s  File is %s bytes (>100KB may consume excessive context)\n' "$YELLOW" "$RESET" "$file_size"
    warnings=$((warnings + 1))
  else
    printf '  %sPASS%s  File size: %s bytes\n' "$GREEN" "$RESET" "$file_size"
  fi

  # Summary
  printf '\n'
  if [ "$errors" -eq 0 ] && [ "$warnings" -eq 0 ]; then
    info "Validation passed with no issues."
  elif [ "$errors" -eq 0 ]; then
    info "Validation passed with ${warnings} warning(s)."
  else
    printf '%s\n' "${RED}Validation failed: ${errors} error(s), ${warnings} warning(s).${RESET}"
    return 1
  fi
}

# ---- Main ----

main() {
  local cmd="${1:-help}"
  shift || true

  case "$cmd" in
    install)    cmd_install "$@" ;;
    uninstall)  cmd_uninstall "$@" ;;
    list)       cmd_list ;;
    update)     cmd_update ;;
    info)       cmd_info "$@" ;;
    validate)   cmd_validate "$@" ;;
    help|-h|--help) usage ;;
    --version|-v)   echo "praxis v${VERSION}" ;;
    *)          die "Unknown command: ${cmd}. Run 'praxis help' for usage." ;;
  esac
}

main "$@"

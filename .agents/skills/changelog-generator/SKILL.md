# Changelog Generator Skill

Automatically generates and updates the CHANGELOG.md file based on merged pull requests, commit history, and semantic versioning conventions.

## Overview

This skill analyzes the git history and pull request metadata to produce a well-structured changelog following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format. It groups changes by type (Added, Changed, Deprecated, Removed, Fixed, Security) and organizes them under versioned sections.

## Trigger Conditions

This skill is triggered when:
- A pull request is merged into the `main` branch
- A new version tag is pushed
- Manually invoked via workflow dispatch
- A release PR is opened or updated

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `since_tag` | The git tag to use as the starting point for changelog generation | No (defaults to latest tag) |
| `target_version` | The version string for the new changelog section | No (auto-detected from pyproject.toml) |
| `pr_number` | Pull request number to include in the changelog entry | No |
| `dry_run` | If `true`, outputs the changelog diff without writing to file | No (default: `false`) |

## Outputs

- Updated `CHANGELOG.md` file committed to the repository
- Summary comment posted on the triggering pull request (if applicable)
- Structured JSON summary of changes grouped by category

## Behavior

### Change Classification

Pull requests and commits are classified based on:
- Conventional commit prefixes (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `perf:`, `security:`)
- PR labels (`enhancement`, `bug`, `documentation`, `breaking-change`, `security`)
- Manual override via PR description tags (e.g., `changelog: Added`)

### Version Detection

The skill reads the current version from `pyproject.toml` (under `[project].version` or `[tool.poetry].version`). If a `target_version` input is provided, it takes precedence.

### Deduplication

The skill avoids duplicate entries by checking existing changelog content before appending new entries. Commits already referenced in a previous changelog section are skipped.

## Configuration

Optional configuration via `.agents/skills/changelog-generator/config.yaml`:

```yaml
changelog_file: CHANGELOG.md
commit_types:
  feat: Added
  fix: Fixed
  docs: Changed
  refactor: Changed
  perf: Changed
  security: Security
  deprecate: Deprecated
exclude_labels:
  - skip-changelog
  - dependencies
  - automated
max_entries_per_section: 50
```

## Example Output

```markdown
## [0.2.0] - 2024-11-15

### Added
- Add streaming support for agent responses (#142)
- Add new `on_handoff` lifecycle hook for agent transitions (#138)

### Fixed
- Fix race condition in concurrent tool execution (#145)
- Resolve memory leak in long-running agent sessions (#140)

### Changed
- Improve error messages for invalid tool schemas (#143)
```

## Notes

- The skill respects the `skip-changelog` label on PRs to exclude trivial changes
- Breaking changes are highlighted with a `⚠️ BREAKING` prefix automatically
- The generated changelog follows semantic versioning; patch releases only include `Fixed` and `Security` sections unless overridden

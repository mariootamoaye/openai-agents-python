# PR Review Skill

This skill enables automated pull request review capabilities, analyzing code changes for quality, correctness, and adherence to project standards.

## Overview

The PR Review skill performs automated analysis of pull requests, providing structured feedback on:
- Code quality and style consistency
- Potential bugs or logic errors
- Test coverage gaps
- Documentation completeness
- Breaking changes detection

## Usage

This skill is triggered when a pull request is opened or updated. It analyzes the diff and provides actionable review comments.

## Inputs

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pr_number` | integer | yes | The pull request number to review |
| `repo` | string | yes | Repository in `owner/repo` format |
| `focus_areas` | array | no | Specific areas to focus review on (e.g., `["security", "performance"]`) |
| `severity_threshold` | string | no | Minimum severity to report: `info`, `warning`, `error` (default: `warning`) |

## Outputs

| Field | Type | Description |
|-------|------|-------------|
| `summary` | string | High-level summary of the review |
| `comments` | array | List of inline review comments with file, line, and message |
| `verdict` | string | Overall verdict: `approve`, `request_changes`, or `comment` |
| `score` | integer | Quality score from 0-100 |

## Configuration

The skill reads from `.agents/skills/pr-review/agents/openai.yaml` for model configuration.

## Examples

### Basic Usage
```yaml
skill: pr-review
inputs:
  pr_number: 42
  repo: myorg/myrepo
```

### Focused Security Review
```yaml
skill: pr-review
inputs:
  pr_number: 42
  repo: myorg/myrepo
  focus_areas:
    - security
    - input-validation
  severity_threshold: warning
```

## Review Criteria

1. **Code Quality**: Checks for code smells, complexity, and maintainability
2. **Security**: Identifies potential security vulnerabilities (injection, XSS, etc.)
3. **Performance**: Flags inefficient patterns or unnecessary operations
4. **Tests**: Verifies adequate test coverage for changed code
5. **Docs**: Ensures public APIs and significant changes are documented
6. **Breaking Changes**: Detects changes that may break existing consumers

## Notes

- Reviews are non-blocking by default; set `verdict: block_on_error` to enforce
- Large PRs (>500 lines changed) may receive summarized feedback
- The skill respects `.agents/skills/pr-review/ignore-patterns.txt` if present

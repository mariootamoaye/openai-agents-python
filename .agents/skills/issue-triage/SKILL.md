# Issue Triage Skill

Automatically triages new GitHub issues by analyzing content, applying labels, assigning priority, and routing to appropriate team members.

## What This Skill Does

- Reads newly opened or updated GitHub issues
- Classifies the issue type (bug, feature request, question, documentation, etc.)
- Applies relevant labels based on content analysis
- Assigns a priority level (P0–P3) based on severity indicators
- Suggests or assigns relevant team members or code owners
- Posts a structured triage comment summarizing findings
- Flags duplicates by searching existing issues for similarity

## Trigger Conditions

This skill should be invoked when:
- A new issue is opened in the repository
- An issue is edited and has not yet been triaged (no `triaged` label)
- Manually requested via a comment containing `/triage`

## Inputs

| Field | Description |
|-------|-------------|
| `issue_number` | The GitHub issue number to triage |
| `repo` | Repository in `owner/repo` format |
| `github_token` | GitHub API token with `issues:write` permission |

## Outputs

The skill will:
1. Apply one or more classification labels from the taxonomy below
2. Apply a priority label (`priority: P0` through `priority: P3`)
3. Post a triage comment on the issue
4. Optionally request review from a relevant code owner

## Label Taxonomy

### Type Labels
- `type: bug` — Something is broken or behaving unexpectedly
- `type: feature` — Request for new functionality
- `type: question` — User asking for help or clarification
- `type: docs` — Documentation improvement or correction
- `type: chore` — Maintenance, dependency updates, refactoring
- `type: performance` — Performance degradation or improvement request
- `type: security` — Security vulnerability or concern

### Priority Labels
- `priority: P0` — Critical, production-breaking, immediate attention required
- `priority: P1` — High priority, significant user impact
- `priority: P2` — Medium priority, moderate impact
- `priority: P3` — Low priority, nice-to-have or minor issue

### Status Labels
- `triaged` — Issue has been reviewed and classified
- `needs-info` — Waiting for more information from the reporter
- `duplicate` — Duplicate of an existing issue

## Priority Heuristics

| Indicator | Priority |
|-----------|----------|
| Keywords: crash, data loss, security, CVE, broken in production | P0 |
| Keywords: broken, regression, blocks users, no workaround | P1 |
| Keywords: unexpected behavior, workaround available | P2 |
| Feature requests, minor UX issues, documentation typos | P3 |

## Triage Comment Template

The skill posts a comment in the following format:

```
## 🤖 Automated Triage

**Type:** bug  
**Priority:** P1  
**Labels applied:** `type: bug`, `priority: P1`  

**Summary:** Brief one-sentence summary of the issue.

**Reasoning:** Explanation of why these classifications were chosen.

**Suggested next steps:**
- [ ] Reproduce the issue locally
- [ ] Identify affected versions

**Possible duplicates:** #123, #456 (if any found)

---
_This triage was performed automatically. A human reviewer will follow up shortly._
```

## Configuration

See `agents/openai.yaml` for model and agent configuration.

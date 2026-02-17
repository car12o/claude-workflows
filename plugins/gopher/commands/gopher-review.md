---
description: "Quick Go code review: check staged changes, specific files, a diff range, or a GitHub PR for Go idioms, errors, concurrency, and security."
argument-hint: "[file|--staged|--diff <base>|--pr [number]]"
---

Perform a quick Go code review without running the full development workflow.

## Arguments

Parse from `$ARGUMENTS`:
- **no args**: review all uncommitted changes
- **file path(s)**: review specific file(s)
- **--staged**: review only staged changes
- **--diff <base>**: review changes since `<base>` (branch or commit)
- **--pr**: review the current branch's pull request
- **--pr <number>**: review a specific pull request by number

## Steps

### 1. Determine Scope

Based on arguments, identify the files to review:

```bash
# No args — all uncommitted changes
git diff --name-only
git diff --cached --name-only

# --staged
git diff --cached --name-only

# --diff <base>
git diff <base>...HEAD --name-only

# --pr (current branch's PR)
gh pr diff --name-only

# --pr <number> (specific PR)
gh pr diff <number> --name-only

# Specific files — use as-is
```

For `--pr` mode, also fetch PR metadata for context:

```bash
# Current branch PR
gh pr view --json number,title,body,baseRefName

# Specific PR
gh pr view <number> --json number,title,body,baseRefName
```

If `gh` is not available or the PR is not found, report the error and suggest using `--diff <base>` instead.

Filter to `.go` files only.

**If no `.go` files are found** in the specified scope, report "No Go files to review" and suggest alternative scopes (e.g., `--staged`, `--diff main`, or specific file paths).

### 2. Launch Review

Use the **Task tool** with `subagent_type: "gopher:go-reviewer"` to delegate the review. Include in the task prompt:
- The list of files to review
- The diff content for context
- For `--pr` mode: include the PR title and description as additional context
- Instruction to focus on the targeted scope (not the entire codebase)

### 3. Present Results

Show the review output with:
- Verdict (PASS / NEEDS IMPROVEMENT) — note: DESIGN VIOLATION is not applicable for quick reviews since there is no design doc
- Issues grouped by severity (critical, major, minor, info)
- Specific file:line references
- Actionable recommendations

## Quick Review Focus

The review should prioritize:
1. Error handling correctness
2. Context propagation
3. Concurrency safety
4. Security issues
5. Go idiom violations

Lower priority (mention but don't block):
- Performance suggestions
- Style preferences
- Documentation gaps

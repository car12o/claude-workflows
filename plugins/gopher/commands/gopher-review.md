---
description: "Quick Go code review: check staged changes, specific files, or a diff range for Go idioms, errors, concurrency, and security."
argument-hint: "[file|--staged|--diff <base>]"
---

Perform a quick Go code review without running the full development workflow.

## Arguments

Parse from `$ARGUMENTS`:
- **no args**: review all uncommitted changes
- **file path(s)**: review specific file(s)
- **--staged**: review only staged changes
- **--diff <base>**: review changes since `<base>` (branch or commit)

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

# Specific files — use as-is
```

Filter to `.go` files only.

### 2. Launch Review

Invoke the **go-reviewer** agent with:
- The list of files to review
- The diff content for context
- Instruction to focus on the targeted scope (not the entire codebase)

### 3. Present Results

Show the review output with:
- Verdict (PASS / NEEDS IMPROVEMENT)
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

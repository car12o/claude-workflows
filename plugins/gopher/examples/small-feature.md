# Example: Small Feature with /gopher-dev

This walkthrough shows how `/gopher-dev` handles a small feature (1-2 files, single package).

## Scenario

You have a Go service and want to add input validation for user email addresses.

## Usage

```
/gopher-dev Add email validation to the user service
```

## What Happens

### Phase 1: Analysis

The go-analyzer agent examines your codebase and determines:

```
Scale: small (1 file modified, 1 test file)
ADR Required: no
Packages affected: internal/service
New interfaces: none
```

### Phase 2: Design (inline)

Because it's small, the go-designer produces an inline plan instead of a full design doc:

```
## Design

### Changes
- internal/service/user.go: add ValidateEmail function
- internal/service/user_test.go: add table-driven tests

### Error Types
- ErrInvalidEmail = errors.New("invalid email")
- ErrEmptyEmail = errors.New("empty email")

### Tasks
1. Add email validation function with sentinel errors
   - Files to create: none
   - Files to modify: internal/service/user.go, internal/service/user_test.go
   - Blast radius: none
2. Integrate validation into CreateUser flow
   - Files to create: none
   - Files to modify: internal/service/user.go, internal/service/user_test.go
   - Blast radius: internal/handler/user.go (calls CreateUser)
```

### [STOP 1: Design Approval]

You see the plan and approve it.

### Phase 3: Implementation (autonomous)

**Task 1:**
- go-implementer writes failing tests for ValidateEmail
- go-implementer writes the validation function
- go-quality-gate runs all 8 gates
- Commit: `feat(service): add email validation`

**Task 2:**
- go-implementer writes tests for CreateUser with validation
- go-implementer integrates validation into CreateUser
- go-quality-gate runs all 8 gates
- Commit: `feat(service): integrate email validation into user creation`

### Phase 4: Review

The go-reviewer checks both commits:

```
Verdict: PASS
- Error handling: proper wrapping with context
- Tests: table-driven with good edge cases
- No issues found
```

### [STOP 2: Final Approval]

You review and approve. Done!

## Time

For a small feature like this, the entire workflow typically completes with just the two approval stops. The autonomous implementation phase handles everything in between.

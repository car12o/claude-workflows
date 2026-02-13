# Contributing to claude-workflows

Thanks for your interest in contributing! This repository hosts a collection of Claude Code workflow plugins for software development.

## Getting Started

1. Fork and clone the repository
2. Install a plugin locally: `claude --plugin-dir ./plugins/<plugin-name>`
3. Make your changes
4. Test by using the commands in a relevant project

## Project Structure

```
claude-workflows/
├── .claude-plugin/
│   └── marketplace.json          # Root registry
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin manifest
│       ├── agents/               # Specialized agent definitions
│       ├── commands/             # User-facing slash commands
│       ├── skills/               # Domain knowledge files
│       ├── hooks/                # Post-edit hooks
│       └── examples/             # Usage examples
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Adding a New Plugin

1. Create `plugins/<plugin-name>/` with the standard layout above
2. Add a `.claude-plugin/plugin.json` manifest with `name`, `description`, `version`, and `author`
3. Register the plugin in the root `.claude-plugin/marketplace.json` under the `plugins` array
4. Add a `README.md` to the plugin directory with installation instructions, commands, and usage details
5. Submit a PR

## Guidelines

### Skills

- Each skill should be **under 200 lines**
- Focus on one domain per skill
- Use YAML frontmatter with `name` and `description`
- Include practical code examples, not just rules

### Agents

- Use YAML frontmatter with `name`, `description`, `tools`, and optionally `model`
- Keep agent scope narrow — one job per agent
- Include clear output format specifications
- Define escalation paths for edge cases

### Commands

- Use YAML frontmatter with `description` and `argument-hint`
- Commands orchestrate agents — they don't implement logic directly
- Document stop points and user interaction patterns

### Hooks

- Hooks should advise, not enforce — quality gates handle enforcement
- Keep hooks fast (< 10s timeout)
- Fail gracefully — never block the user's workflow

## Testing Changes

Since these are Claude Code plugins (markdown files, not executable code), testing means:

1. **Install the plugin** in Claude Code: `claude --plugin-dir ./plugins/<plugin-name>`
2. **Run each command** in a real or test project
3. **Verify** that skills activate in relevant conversations
4. **Check** that agents produce expected outputs
5. **Confirm** hooks fire correctly for relevant file edits

## Pull Requests

- Keep PRs focused on a single change
- Describe what you changed and why
- If adding a new skill or agent, explain the use case
- If changing an existing file, note what was wrong or missing

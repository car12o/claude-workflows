# claude-workflows

A collection of Claude Code workflow plugins for software development.

## Plugins

| Plugin | Description |
|--------|-------------|
| [gopher](plugins/gopher/README.md) | Go 1.24+ development workflow with TDD, quality gates, and code review |

## Installation

```bash
# Add the marketplace and install plugins from within a Claude session
/plugin marketplace add car12o/claude-workflows
/plugin install [plugin] # e.g. /plugin install gopher

# Or from the command line
claude plugin marketplace add car12o/claude-workflows
claude plugin install [plugin] # e.g. claude plugin install gopher

# Or clone and install a specific plugin for development
git clone https://github.com/car12o/claude-workflows.git
claude --plugin-dir ./claude-workflows/plugins/[plugin] # e.g. claude --plugin-dir ./claude-workflows/plugins/gopher
```

## Project Structure

```
claude-workflows/
├── .claude-plugin/
│   └── marketplace.json          # Root registry
├── plugins/
│   └── gopher/
│   └── ...
├── README.md
├── CONTRIBUTING.md
└── LICENSE
```

## Adding a New Plugin

1. Create a directory under `plugins/<plugin-name>/`
2. Add a `.claude-plugin/plugin.json` manifest
3. Add agents, commands, skills, and hooks as needed
4. Create a `README.md` for the plugin
5. Register the plugin in `.claude-plugin/marketplace.json`

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## License

MIT

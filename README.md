# OpenKodo 古道

**古道** (kodo - "Ancient Path") - Context management CLI and plugin marketplace for AI coding tools.

## Quick Install

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.ps1 | iex
```

### Manual Download

Download from [Releases](https://github.com/paxtone-io/openkodo/releases):
- **macOS Intel**: `kodo-v*-x86_64-apple-darwin.tar.gz`
- **macOS Apple Silicon**: `kodo-v*-aarch64-apple-darwin.tar.gz`
- **Linux x64**: `kodo-v*-x86_64-unknown-linux-gnu.tar.gz`
- **Linux ARM64**: `kodo-v*-aarch64-unknown-linux-gnu.tar.gz`
- **Windows x64**: `kodo-v*-x86_64-pc-windows-msvc.zip`
- **Windows ARM64**: `kodo-v*-aarch64-pc-windows-msvc.zip`

## Plugin Marketplace

Kodo plugins extend Claude Code with specialized workflows:

| Plugin | Description |
|--------|-------------|
| [kodo](plugins/kodo/) | Core development workflows: planning, review, debugging, self-learning |
| [kodo-design](plugins/kodo-design/) | UI/UX design with WCAG AAA accessibility |
| [kodo-supabase](plugins/kodo-supabase/) | Supabase: databases, migrations, Edge Functions |
| [kodo-posthog](plugins/kodo-posthog/) | PostHog: events, feature flags, experiments |
| [kodo-analyzer](plugins/kodo-analyzer/) | Codebase analysis: security, performance, documentation |

### Install Plugins

```bash
# Install individual plugins
kodo plugin install kodo
kodo plugin install kodo-design

# List available plugins
kodo plugin list --available

# List installed plugins
kodo plugin list
```

### Plugin-Only Install (Claude Code)

For Claude Code users who only want the plugins without the full CLI:

```bash
# Or use Claude Code's native plugin install
# In Claude Code, type /plugin → Add Marketplace → paxtone-io/openkodo
```

## Usage

```bash
# Initialize in a project
kodo init

# Capture learnings from a coding session
kodo reflect

# Query accumulated context
kodo query "how do we handle authentication?"

# Add context manually
kodo curate --topic architecture "We use a hexagonal architecture pattern"

# Analyze codebase
kodo analyze --tech-stack --architecture
```

## Documentation

- [Getting Started](docs/GETTING-STARTED.md) - Installation and first steps
- [CLI Reference](docs/CLI-REFERENCE.md) - Full command documentation
- [Plugin Development](docs/PLUGIN-DEVELOPMENT.md) - Create custom plugins

## License

MIT License - see [LICENSE](LICENSE) for details.

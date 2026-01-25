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
| [kodo-core](plugins/kodo-core/) | Core development workflows: planning, review, debugging |
| [kodo-design](plugins/kodo-design/) | UI/UX design with WCAG AAA accessibility |
| [kodo-supabase](plugins/kodo-supabase/) | Supabase: databases, migrations, Edge Functions |
| [kodo-posthog](plugins/kodo-posthog/) | PostHog: events, feature flags, experiments |
| [kodo-analyzer](plugins/kodo-analyzer/) | Codebase analysis: security, performance, docs |

### Install Plugins

```bash
# Install individual plugins
kodo plugin install kodo-core
kodo plugin install kodo-design

# List available plugins
kodo plugin list --available

# List installed plugins
kodo plugin list
```

### Plugin-Only Install (Claude Code)

For Claude Code users who only want the plugins without the full CLI:

```bash
# Clone plugins directly to Claude Code plugins directory
git clone --depth 1 --filter=blob:none --sparse https://github.com/paxtone-io/openkodo.git ~/.claude/plugins/kodo
cd ~/.claude/plugins/kodo
git sparse-checkout set plugins/kodo-core plugins/kodo-design
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

- [Getting Started](https://github.com/paxtone-io/openkodo/wiki/Getting-Started)
- [Plugin Development](https://github.com/paxtone-io/openkodo/wiki/Plugin-Development)
- [CLI Reference](https://github.com/paxtone-io/openkodo/wiki/CLI-Reference)

## License

MIT License - see [LICENSE](LICENSE) for details.

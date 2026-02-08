#!/bin/bash
# Purpose: Download and install the latest OpenKodo CLI binary from GitHub releases
# LLM-Note:
#   Dependencies: requires curl, tar, uname; optionally sudo (if /usr/local/bin is not writable)
#   Data flow: detects OS (linux/darwin) + arch (x86_64/aarch64) -> fetches latest release tag
#              from GitHub API -> downloads platform-specific tar.gz archive -> extracts kodo
#              binary -> installs to /usr/local/bin/kodo
#   State/Effects: installs or overwrites /usr/local/bin/kodo binary, creates temp dir (auto-cleaned)
#   Usage: curl -fsSL https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.sh | bash
#   Safety: uses mktemp with trap for cleanup, checks write permissions before sudo,
#           verifies installation via `kodo --version`, warns if not in PATH
set -e

# OpenKodo installer
# Usage: curl -fsSL https://raw.githubusercontent.com/paxtone-io/openkodo/main/install.sh | bash

REPO="paxtone-io/openkodo"
BINARY_NAME="kodo"
INSTALL_DIR="/usr/local/bin"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}→${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; exit 1; }

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "darwin" ;;
        *)       error "Unsupported operating system: $(uname -s)" ;;
    esac
}

# Detect architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "x86_64" ;;
        amd64)   echo "x86_64" ;;
        aarch64) echo "aarch64" ;;
        arm64)   echo "aarch64" ;;
        *)       error "Unsupported architecture: $(uname -m)" ;;
    esac
}

# Get target triple
get_target() {
    local os=$(detect_os)
    local arch=$(detect_arch)

    case "$os" in
        darwin)
            echo "${arch}-apple-darwin"
            ;;
        linux)
            echo "${arch}-unknown-linux-gnu"
            ;;
    esac
}

# Get latest release version
get_latest_version() {
    curl -sL "https://api.github.com/repos/${REPO}/releases/latest" | \
        grep '"tag_name":' | \
        sed -E 's/.*"([^"]+)".*/\1/'
}

main() {
    info "Installing OpenKodo (古道)..."

    local os=$(detect_os)
    local arch=$(detect_arch)
    local target=$(get_target)

    info "Detected: $os ($arch)"

    # Get latest version
    info "Fetching latest release..."
    local version=$(get_latest_version)

    if [ -z "$version" ]; then
        error "Failed to get latest version"
    fi

    info "Latest version: $version"

    # Construct download URL
    local filename="kodo-${target}.tar.gz"
    local url="https://github.com/${REPO}/releases/download/${version}/${filename}"

    info "Downloading from: $url"

    # Create temp directory
    local tmpdir=$(mktemp -d)
    trap "rm -rf $tmpdir" EXIT

    # Download
    if ! curl -fsSL "$url" -o "$tmpdir/$filename"; then
        error "Failed to download $url"
    fi

    # Extract
    info "Extracting..."
    tar -xzf "$tmpdir/$filename" -C "$tmpdir"

    # Install
    info "Installing to $INSTALL_DIR..."
    if [ -w "$INSTALL_DIR" ]; then
        mv "$tmpdir/$BINARY_NAME" "$INSTALL_DIR/"
    else
        sudo mv "$tmpdir/$BINARY_NAME" "$INSTALL_DIR/"
    fi

    chmod +x "$INSTALL_DIR/$BINARY_NAME"

    # Verify
    if command -v kodo &> /dev/null; then
        info "Installation complete!"
        echo ""
        kodo --version
        echo ""
        info "Run 'kodo init' in your project to get started."
    else
        warn "Installed but 'kodo' not found in PATH."
        warn "You may need to add $INSTALL_DIR to your PATH."
    fi
}

main "$@"

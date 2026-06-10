#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  SUDO=sudo
else
  SUDO=
fi

echo "==> Checking Ubuntu build prerequisites"

if ! need_cmd apt-get; then
  echo "apt-get not found. This script is intended for Ubuntu/Debian systems." >&2
  exit 1
fi

$SUDO apt-get update
$SUDO apt-get install -y build-essential pkg-config curl ca-certificates git

if ! need_cmd rustup; then
  echo "==> rustup not found. Installing Rust stable toolchain"
  curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain stable
fi

# shellcheck disable=SC1090
source "$HOME/.cargo/env"

rustup toolchain install stable
rustup default stable

echo "==> Environment ready"
rustc -V
cargo -V
gcc --version | head -n 1


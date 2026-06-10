#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$ROOT_DIR/vendor/ocrs"
DIST_DIR="$ROOT_DIR/dist"
OUTPUT_BIN="$DIST_DIR/img2text"
FETCH_MODELS="$SCRIPT_DIR/fetch-models-ubuntu.sh"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Upstream source not found: $SOURCE_DIR" >&2
  exit 1
fi

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1090
  source "$HOME/.cargo/env"
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "Cargo not found. Run scripts/setup-ubuntu.sh first." >&2
  exit 1
fi

echo "==> Building ocrs release binary"
cd "$SOURCE_DIR"
cargo build -p ocrs-cli --release

mkdir -p "$DIST_DIR"
cp -f "$SOURCE_DIR/target/release/ocrs" "$OUTPUT_BIN"
chmod +x "$OUTPUT_BIN"

bash "$FETCH_MODELS"

if [[ -f "$ROOT_DIR/models/strong/text-detection.rten" && -f "$ROOT_DIR/models/strong/text-recognition.rten" ]]; then
  mkdir -p "$DIST_DIR/models/strong"
  cp -f "$ROOT_DIR/models/strong/text-detection.rten" "$DIST_DIR/models/strong/text-detection.rten"
  cp -f "$ROOT_DIR/models/strong/text-recognition.rten" "$DIST_DIR/models/strong/text-recognition.rten"
fi

echo "==> Binary ready: $OUTPUT_BIN"


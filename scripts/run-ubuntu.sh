#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_BIN="$ROOT_DIR/dist/img2text"
MODEL_PROFILE="${IMG2TEXT_MODEL_PROFILE:-default}"
STRONG_DET="$ROOT_DIR/dist/models/strong/text-detection.rten"
STRONG_REC="$ROOT_DIR/dist/models/strong/text-recognition.rten"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/run-ubuntu.sh <image-path> [ocr-args...]" >&2
  exit 1
fi

IMAGE_PATH="$1"
shift

if [[ ! -x "$DIST_BIN" ]]; then
  echo "Binary not found: $DIST_BIN" >&2
  echo "Run scripts/build-ubuntu.sh first." >&2
  exit 1
fi

if [[ "$MODEL_PROFILE" == "strong" && -f "$STRONG_DET" && -f "$STRONG_REC" ]]; then
  exec "$DIST_BIN" "$IMAGE_PATH" --detect-model "$STRONG_DET" --rec-model "$STRONG_REC" "$@"
fi

exec "$DIST_BIN" "$IMAGE_PATH" "$@"


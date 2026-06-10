#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_MODELS="$ROOT_DIR/dist/models"
CACHE_MODELS="$HOME/.cache/ocrs"

DET_FILE="text-detection.rten"
REC_FILE="text-recognition.rten"
DET_URL="https://ocrs-models.s3-accelerate.amazonaws.com/text-detection.rten"
REC_URL="https://ocrs-models.s3-accelerate.amazonaws.com/text-recognition.rten"
DET_SHA256="f15cfb56bd02c4bf478a20343986504a1f01e1665c2b3a0ad66340f054b1b5ca"
REC_SHA256="e484866d4cce403175bd8d00b128feb08ab42e208de30e42cd9889d8f1735a6e"

mkdir -p "$DIST_MODELS"

verify_hash() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(sha256sum "$file" | awk '{print $1}')"
  [[ "$actual" == "$expected" ]]
}

ensure_model() {
  local name="$1"
  local url="$2"
  local expected="$3"
  local dest="$DIST_MODELS/$name"
  local cache="$CACHE_MODELS/$name"

  if [[ -f "$dest" ]] && verify_hash "$dest" "$expected"; then
    return 0
  fi

  if [[ -f "$cache" ]]; then
    cp -f "$cache" "$dest"
    if verify_hash "$dest" "$expected"; then
      return 0
    fi
  fi

  echo "Downloading $name ..."
  curl -L "$url" -o "$dest"
  if ! verify_hash "$dest" "$expected"; then
    echo "SHA256 mismatch for $dest" >&2
    return 1
  fi
}

ensure_model "$DET_FILE" "$DET_URL" "$DET_SHA256"
ensure_model "$REC_FILE" "$REC_URL" "$REC_SHA256"

echo "==> Offline models are ready in $DIST_MODELS"


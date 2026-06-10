# Model Profiles

This project supports bundled offline models for portable execution.

## Default profile (bundled by build scripts)

The following files are downloaded/copied into `dist/models/` during build:

- `text-detection.rten`
- `text-recognition.rten`

These are verified by SHA256 in the fetch scripts:

- `scripts/fetch-models-windows.bat`
- `scripts/fetch-models-ubuntu.sh`

## Strong profile (optional)

If you have a stronger compatible RTEN model pair, place files here before build:

- `models/strong/text-detection.rten`
- `models/strong/text-recognition.rten`

The build scripts copy them to `dist/models/strong/`.

To use the strong profile at runtime:

- Windows: set `IMG2TEXT_MODEL_PROFILE=strong`
- Ubuntu: `export IMG2TEXT_MODEL_PROFILE=strong`

If strong files are missing, runtime falls back to default profile automatically.


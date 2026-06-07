#!/bin/bash
# Generates the progression snapshot and writes it to sosciencity/0snapshot/.
# Can be run from any directory.

# Stops immediately if any command fails, rather than continuing with broken state.
set -e

cd "$(dirname "$0")/.."

OUTPUT_DIR="sosciencity/0snapshot"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Building Docker image..."
docker build \
    --tag sosciencity-snapshot \
    --file sosciencity/snapshot-setup/Dockerfile \
    --quiet \
    .

echo "Running export..."
docker run \
    --rm \
    --user "$(id -u):$(id -g)" \
    --volume "$PWD/$OUTPUT_DIR:/opt/factorio/script-output" \
    sosciencity-snapshot

echo "Done! Snapshot written to $OUTPUT_DIR"

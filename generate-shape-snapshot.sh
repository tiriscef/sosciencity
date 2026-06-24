#!/bin/bash
# Regenerates the prototype-shape regression snapshot into sosciencity/0shape/.
#
# The shape dump is a golden master for any behaviour-preserving change: a refactor that
# shouldn't alter prototypes (e.g. reworking tirislib internals) must not change it.
# 0shape/ is gitignored from the main repo and holds its own local git repo, so the
# workflow is:
#
#   bash sosciencity/generate-shape-snapshot.sh        # regenerate the dump
#   git -C sosciencity/0shape diff                     # empty == nothing changed
#   git -C sosciencity/0shape commit -am "..."         # accept + advance the baseline

set -e
cd "$(dirname "$0")/.."

OUTPUT_DIR="sosciencity/0shape"
OUTPUT_FILE="$OUTPUT_DIR/prototype-shape.lua"
mkdir -p "$OUTPUT_DIR"

echo "Building Docker image..."
docker build \
    --tag sosciencity-snapshot \
    --file sosciencity/snapshot-setup/Dockerfile \
    --quiet \
    .

echo "Running export..."

# The dump is logged at the end of the data stage, between markers. We slice it out of
# stdout rather than trusting the container exit code (the export scenario's own timeout
# is irrelevant to us - our dump is already emitted during load).
docker run --rm sosciencity-snapshot 2>&1 \
    | awk '/SOSCIENCITY-SHAPE-START/ {f = 1; next} /SOSCIENCITY-SHAPE-END/ {f = 0} f' \
    > "$OUTPUT_FILE"

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "ERROR: shape dump is empty - markers not found in container output" >&2
    exit 1
fi

# serpent.block closes with a brace; a missing one means load was killed mid-serialize.
if [ "$(tail -c 2 "$OUTPUT_FILE" | tr -d '[:space:]')" != "}" ]; then
    echo "ERROR: shape dump looks truncated (does not end with '}')" >&2
    exit 1
fi

echo "Wrote $OUTPUT_FILE ($(wc -l < "$OUTPUT_FILE") lines, $(du -h "$OUTPUT_FILE" | cut -f1))"

#!/bin/bash

timeout 10s /opt/factorio/bin/x64/factorio \
    --start-server-load-scenario "sosciencity/export_sosciencity" \
    --server-settings "$CONFIG/server-settings.json" \
    --mod-directory "$MODS" \
    2>&1 | tee /tmp/factorio.log
FACTORIO_EXIT="${PIPESTATUS[0]}"

# 124 = timeout reached, which is expected: export finished, server killed cleanly
if [ "$FACTORIO_EXIT" -ne 0 ] && [ "$FACTORIO_EXIT" -ne 124 ]; then
    echo "Factorio crashed (exit code $FACTORIO_EXIT)"
    exit "$FACTORIO_EXIT"
fi

grep -q "SNAPSHOT DONE" /tmp/factorio.log && exit 0 || { echo "SNAPSHOT DONE marker not found in log"; exit 1; }

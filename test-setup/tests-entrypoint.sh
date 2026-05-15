#!/bin/bash

timeout 5s /opt/factorio/bin/x64/factorio \
    --start-server-load-scenario "sosciencity/test_sosciencity" \
    --server-settings "$CONFIG/server-settings.json" \
    --mod-directory "$MODS" \
    2>&1 | tee /tmp/factorio.log
FACTORIO_EXIT="${PIPESTATUS[0]}"

# 124 = timeout reached, which is expected: tests finished, server killed cleanly
if [ "$FACTORIO_EXIT" -ne 0 ] && [ "$FACTORIO_EXIT" -ne 124 ]; then
    echo "Factorio crashed (exit code $FACTORIO_EXIT)"
    exit "$FACTORIO_EXIT"
fi

grep -q "ALL PASSED" /tmp/factorio.log && exit 0 || exit 1

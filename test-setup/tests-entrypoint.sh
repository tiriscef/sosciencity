#!/bin/bash

RESULTS=/opt/factorio/script-output/test-results.txt
rm -f "$RESULTS"

timeout 10s /opt/factorio/bin/x64/factorio \
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

# The data stage tests only log their summary and don't stop the mod from loading,
# so a failure there shows up as a "FAILED:" line in the log.
if grep -q "^FAILED:" /tmp/factorio.log; then
    echo "Tests failed"
    exit 1
fi

# The control stage writes its summary to the results file once its run is finished.
if [ ! -f "$RESULTS" ] || ! grep -q "ALL PASSED" "$RESULTS"; then
    echo "Control stage tests didn't finish"
    exit 1
fi

exit 0

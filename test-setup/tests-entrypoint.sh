#!/bin/bash

RESULTS=/opt/factorio/script-output/test-results.txt
LOG=/tmp/factorio.log
# Upper bound only: the server is stopped as soon as the results are written.
# Slow CI runners need much longer than a local machine (~10 s).
MAX_SECONDS=600

rm -f "$RESULTS"

/opt/factorio/bin/x64/factorio \
    --start-server-load-scenario "sosciencity/test_sosciencity" \
    --server-settings "$CONFIG/server-settings.json" \
    --mod-directory "$MODS" \
    > "$LOG" 2>&1 &
FACTORIO_PID=$!
tail -n +1 -f "$LOG" --pid="$FACTORIO_PID" &

# The control stage writes its summary to the results file once its run is finished,
# so wait for the file (or for the server to quit on its own, e.g. after a crash).
STOPPED_BY_US=false
for ((second = 0; second < MAX_SECONDS; second++)); do
    if ! kill -0 "$FACTORIO_PID" 2>/dev/null; then
        break
    fi
    if [ -s "$RESULTS" ]; then
        STOPPED_BY_US=true
        kill -TERM "$FACTORIO_PID"
        break
    fi
    sleep 1
done
if kill -0 "$FACTORIO_PID" 2>/dev/null && [ "$STOPPED_BY_US" = false ]; then
    echo "Timed out after $MAX_SECONDS s"
    STOPPED_BY_US=true
    kill -TERM "$FACTORIO_PID"
fi
wait "$FACTORIO_PID"
FACTORIO_EXIT=$?
sleep 1 # let tail print the last lines

if [ "$STOPPED_BY_US" = false ] && [ "$FACTORIO_EXIT" -ne 0 ]; then
    echo "Factorio crashed (exit code $FACTORIO_EXIT)"
    exit "$FACTORIO_EXIT"
fi

# The data stage tests only log their summary and don't stop the mod from loading,
# so a failure there shows up as a "FAILED:" line in the log.
if grep -q "^FAILED:" "$LOG"; then
    echo "Tests failed"
    exit 1
fi

if [ ! -f "$RESULTS" ] || ! grep -q "ALL PASSED" "$RESULTS"; then
    echo "Control stage tests didn't finish or failed"
    exit 1
fi

exit 0

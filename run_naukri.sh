#!/bin/bash
# Runs the Naukri resume update. Intended to be called by cron or launchd.
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOGFILE="$PROJECT_DIR/naukri_log.txt"

# Minimal PATH for cron
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

cd "$PROJECT_DIR" || exit 1
echo "----------------------------------------" >> "$LOGFILE"
echo "$(date): Job started" >> "$LOGFILE"

# Refresh the session copy from the live Chrome profile. FORCE=1 snapshots
# the cookie DB even while Chrome is open. If this fails, the previous copy
# is kept and the run continues with it.
if FORCE=1 "$PROJECT_DIR/copy_chrome_profile.sh" >> "$LOGFILE" 2>&1; then
    echo "$(date): Session copied from Chrome" >> "$LOGFILE"
else
    echo "$(date): Session copy failed, using previous copy" >> "$LOGFILE"
fi

if "$PROJECT_DIR/venv/bin/python" naukri.py >> "$LOGFILE" 2>&1; then
    echo "$(date): Job finished successfully" >> "$LOGFILE"
else
    echo "$(date): Job failed (exit $?). If the session expired, run FORCE=1 ./copy_chrome_profile.sh" >> "$LOGFILE"
    exit 1
fi

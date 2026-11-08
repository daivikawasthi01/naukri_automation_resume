#!/bin/bash
# Runs the Naukri resume update. Intended to be called by cron or launchd.
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOGFILE="$PROJECT_DIR/naukri_log.txt"

# Minimal PATH for cron
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

cd "$PROJECT_DIR" || exit 1
echo "----------------------------------------" >> "$LOGFILE"
echo "$(date): Job started" >> "$LOGFILE"

if "$PROJECT_DIR/venv/bin/python" naukri.py >> "$LOGFILE" 2>&1; then
    echo "$(date): Job finished successfully" >> "$LOGFILE"
else
    echo "$(date): Job failed (exit $?). If the session expired, run FORCE=1 ./copy_chrome_profile.sh" >> "$LOGFILE"
    exit 1
fi

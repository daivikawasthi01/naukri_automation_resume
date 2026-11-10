#!/bin/bash
# Copies the logged-in parts of a Chrome profile into ./chrome_profile.
# Close Chrome completely before running this.
set -e

SRC="$HOME/Library/Application Support/Google/Chrome"
PROFILE="${1:-${CHROME_PROFILE_DIR:-Default}}"
FINAL="$(cd "$(dirname "$0")" && pwd)/chrome_profile"
DEST="$FINAL.new"

if [ -z "$FORCE" ] && pgrep -x "Google Chrome" >/dev/null; then
    echo "Chrome is running. Quit it (Cmd+Q) and run this again." >&2
    exit 1
fi

rm -rf "$DEST"
mkdir -p "$DEST/$PROFILE"
cp "$SRC/Local State" "$DEST/"

for item in Network "Local Storage" "Session Storage" IndexedDB Preferences "Secure Preferences" Cookies; do
    [ -e "$SRC/$PROFILE/$item" ] && cp -R "$SRC/$PROFILE/$item" "$DEST/$PROFILE/"
done

# With Chrome open, take a consistent snapshot of the cookie DB
if [ -n "$FORCE" ]; then
    for c in "Network/Cookies" "Cookies"; do
        if [ -f "$SRC/$PROFILE/$c" ]; then
            rm -f "$DEST/$PROFILE/$c"*
            mkdir -p "$(dirname "$DEST/$PROFILE/$c")"
            sqlite3 "file:$SRC/$PROFILE/$c?mode=ro" ".backup '$DEST/$PROFILE/$c'"
        fi
    done
fi

# Swap in the new copy only after everything above succeeded
rm -rf "$FINAL"
mv "$DEST" "$FINAL"

echo "Copied profile '$PROFILE' to $FINAL"

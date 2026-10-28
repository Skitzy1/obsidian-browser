#!/usr/bin/env sh
set -eu
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
browser_path="$project_root/engine/target/release/servoshell"
if [ ! -x "$browser_path" ]; then
    echo 'Neptunium has not been built. See README.md for the Servo build requirements.' >&2
    exit 1
fi
exec "$browser_path" --multiprocess --sandbox 'neptunium:newtab'

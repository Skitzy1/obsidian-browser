#!/usr/bin/env sh
set -eu
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
git -C "$project_root/engine" diff --check
git -C "$project_root/engine" diff --output="$project_root/patches/obsidian.patch"
git -C "$project_root/engine" apply --reverse --check "$project_root/patches/obsidian.patch"
echo 'Updated patches/obsidian.patch.'

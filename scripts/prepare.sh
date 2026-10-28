#!/usr/bin/env sh
set -eu
project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
engine_root="$project_root/engine"
revision=471f5decafec4c2cbf7d3004db4ea10823548d8d
if [ ! -d "$engine_root/.git" ]; then
    git clone --depth 1 --filter=blob:none --no-checkout https://github.com/servo/servo.git "$engine_root"
    git -C "$engine_root" sparse-checkout set --no-cone '/*' '!/tests/' '/tests/unit/' '/tests/capi/' '/tests/wpt/tests/tools/'
    git -C "$engine_root" fetch --depth 1 origin "$revision"
    git -C "$engine_root" checkout --detach "$revision"
fi
if [ "$(git -C "$engine_root" rev-parse HEAD)" != "$revision" ]; then
    echo 'The existing Servo checkout is not at the pinned revision; left untouched.' >&2
    exit 1
fi
patch_file="$project_root/patches/neptunium.patch"
if ! git -C "$engine_root" apply --reverse --check "$patch_file" 2>/dev/null; then
    git -C "$engine_root" apply --check "$patch_file"
    git -C "$engine_root" apply "$patch_file"
fi
cp "$project_root/assets/logo.png" "$engine_root/resources/neptunium.png"
resource_root="$engine_root/resources/resource_protocol"
cp "$project_root/assets/logo.png" "$resource_root/neptunium.png"
sed -e "s/img-src 'self'/img-src resource:/" -e 's|assets/logo.png|resource:///neptunium.png|' \
    "$project_root/start.html" > "$resource_root/neptunium-newtab.html"
cp "$project_root/about.html" "$resource_root/neptunium-about.html"
echo 'Neptunium source is prepared.'

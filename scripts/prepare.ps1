$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineRoot = Join-Path $projectRoot 'engine'
$revision = '471f5decafec4c2cbf7d3004db4ea10823548d8d'
if (-not (Test-Path -LiteralPath (Join-Path $engineRoot '.git'))) {
    & git clone --depth 1 --filter=blob:none --no-checkout https://github.com/servo/servo.git $engineRoot
    if ($LASTEXITCODE -ne 0) { throw 'Servo clone failed.' }
    & git -C $engineRoot sparse-checkout set --no-cone '/*' '!/tests/' '/tests/unit/' '/tests/capi/' '/tests/wpt/tests/tools/'
    if ($LASTEXITCODE -ne 0) { throw 'Sparse checkout setup failed.' }
    & git -C $engineRoot fetch --depth 1 origin $revision
    if ($LASTEXITCODE -ne 0) { throw 'Could not fetch pinned Servo revision.' }
    & git -C $engineRoot checkout --detach $revision
    if ($LASTEXITCODE -ne 0) { throw 'Pinned Servo checkout failed.' }
}
$currentRevision = & git -C $engineRoot rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $currentRevision.Trim() -ne $revision) {
    throw "Expected Servo revision $revision. Existing checkout left untouched."
}
$patchFile = Join-Path $projectRoot 'patches/obsidian.patch'
& git -C $engineRoot apply --reverse --check $patchFile 2>$null
if ($LASTEXITCODE -ne 0) {
    & git -C $engineRoot apply --check $patchFile
    if ($LASTEXITCODE -ne 0) { throw 'Patch conflicts with local edits; no changes applied.' }
    & git -C $engineRoot apply $patchFile
    if ($LASTEXITCODE -ne 0) { throw 'Patch failed.' }
}
Copy-Item -LiteralPath (Join-Path $projectRoot 'assets/logo.png') -Destination (Join-Path $engineRoot 'resources/obsidian.png')
$resourceRoot = Join-Path $engineRoot 'resources/resource_protocol'
Copy-Item -LiteralPath (Join-Path $projectRoot 'assets/logo.png') -Destination (Join-Path $resourceRoot 'obsidian.png')
$homepage = [IO.File]::ReadAllText((Join-Path $projectRoot 'start.html'))
$homepage = $homepage.Replace("img-src 'self'", 'img-src resource:').Replace('assets/logo.png', 'resource:///obsidian.png')
[IO.File]::WriteAllText((Join-Path $resourceRoot 'obsidian-newtab.html'), $homepage, [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath (Join-Path $projectRoot 'about.html') -Destination (Join-Path $resourceRoot 'obsidian-about.html')
Write-Host 'Obsidian source is prepared.'

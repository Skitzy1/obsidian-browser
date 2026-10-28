$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$browserPath = Join-Path $projectRoot 'engine/target/release/servoshell.exe'
if (-not (Test-Path -LiteralPath $browserPath)) {
    throw 'Obsidian has not been built. See README.md for the Servo build requirements.'
}
& $browserPath --multiprocess 'obsidian:newtab'
exit $LASTEXITCODE

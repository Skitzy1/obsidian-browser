param(
    [string]$ToolsRoot,
    [switch]$WithoutMedia,
    [ValidateRange(1, 64)][int]$Jobs = 8
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'prepare.ps1')
. (Join-Path $PSScriptRoot 'build-env.ps1') -ToolsRoot $ToolsRoot
foreach ($tool in @('rustup', 'cargo', 'uv', 'cmake', 'clang-cl', 'lld-link')) {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Missing build tool: $tool" }
}
$buildDrive = [IO.DriveInfo]::new([IO.Path]::GetPathRoot($env:CARGO_TARGET_DIR))
if ($buildDrive.AvailableFreeSpace -lt 20GB) { throw 'The build drive needs at least 20 GB free.' }
$mediaStack = if ($WithoutMedia) { 'dummy' } else { 'gstreamer' }
Push-Location (Join-Path $projectRoot 'engine')
try {
    ./mach.ps1 build --release --jobs $Jobs --media-stack $mediaStack
    if ($LASTEXITCODE -ne 0) { throw "Browser build failed with exit code $LASTEXITCODE." }
} finally {
    Pop-Location
}

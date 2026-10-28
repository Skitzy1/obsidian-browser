$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$engineRoot = Join-Path $projectRoot 'engine'
$patchFile = Join-Path $projectRoot 'patches/neptunium.patch'
& git -C $engineRoot diff --check
if ($LASTEXITCODE -ne 0) { throw 'Fix whitespace errors before exporting.' }
& git -C $engineRoot diff "--output=$patchFile"
if ($LASTEXITCODE -ne 0) { throw 'Patch export failed.' }
& git -C $engineRoot apply --reverse --check $patchFile
if ($LASTEXITCODE -ne 0) { throw 'Exported patch does not match the working source.' }
Write-Host 'Updated patches/neptunium.patch.'

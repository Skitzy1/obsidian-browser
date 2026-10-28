param([string]$ToolsRoot)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not $ToolsRoot) { $ToolsRoot = Join-Path $projectRoot '.tools' }
$ToolsRoot = [IO.Path]::GetFullPath($ToolsRoot)
foreach ($folder in @('rustup','cargo','temp','uv-cache')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $ToolsRoot $folder) | Out-Null
}
$env:RUSTUP_HOME = Join-Path $ToolsRoot 'rustup'
$env:CARGO_HOME = Join-Path $ToolsRoot 'cargo'
$env:TEMP = Join-Path $ToolsRoot 'temp'
$env:TMP = $env:TEMP
$env:UV_CACHE_DIR = Join-Path $ToolsRoot 'uv-cache'
$engineItem = Get-Item -LiteralPath (Join-Path $projectRoot 'engine') -ErrorAction SilentlyContinue
if ($engineItem) {
    $physicalEngine = if ($engineItem.LinkType -eq 'Junction') { [string]($engineItem.Target | Select-Object -First 1) } else { $engineItem.FullName }
    $env:CARGO_TARGET_DIR = Join-Path $physicalEngine 'target'
}
$rustupBin = Join-Path $env:USERPROFILE '.cargo\bin'
$pythonScripts = & python -c "import sysconfig; print(sysconfig.get_path('scripts',scheme='nt_user'))"
if ($LASTEXITCODE -ne 0) { throw 'Python 3 is required to locate uv.' }
$localCargoBin = Join-Path $env:CARGO_HOME 'bin'
$env:PATH = "$localCargoBin;$rustupBin;$pythonScripts;$env:PATH"
$vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path -LiteralPath $vswhere) {
    $visualStudio = & $vswhere -latest -products '*' -property installationPath
    if ($visualStudio) {
        $llvmBin = Join-Path $visualStudio 'VC\Tools\Llvm\x64\bin'
        if (Test-Path -LiteralPath (Join-Path $llvmBin 'libclang.dll')) {
            $env:PATH = "$llvmBin;$env:PATH"
            $env:LIBCLANG_PATH = $llvmBin
        }
    }
}

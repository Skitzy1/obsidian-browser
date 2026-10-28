@echo off
setlocal
set "BROWSER=%~dp0engine\target\release\servoshell.exe"
if not exist "%BROWSER%" (
    echo Obsidian has not been built yet. See README.md for setup instructions.
    pause
    exit /b 1
)
start "" "%BROWSER%" --multiprocess obsidian:newtab

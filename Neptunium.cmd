@echo off
setlocal
set "BROWSER=%~dp0engine\target\release\servoshell.exe"
if not exist "%BROWSER%" (
    echo Neptunium has not been built yet. See README.md for setup instructions.
    pause
    exit /b 1
)
start "" "%BROWSER%" --multiprocess neptunium:newtab

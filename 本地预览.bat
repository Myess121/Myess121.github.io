@echo off
REM Double-click to start the local preview of the blog (drafts included).
REM Close this window or press Ctrl+C to stop the preview.
cd /d "%~dp0"
title Hugo local preview

where hugo >nul 2>nul
if errorlevel 1 (
    echo [ERROR] hugo was not found. Please check that Hugo is installed and on PATH.
    pause
    exit /b 1
)

echo Starting local preview at http://localhost:1313/
echo Drafts are shown. Close this window or press Ctrl+C to stop.
echo.

REM Open the browser after 3 seconds, when the server is ready.
start "" /min cmd /c "timeout /t 3 /nobreak >nul & start "" http://localhost:1313/"

hugo server -D

echo.
echo Preview stopped.
pause

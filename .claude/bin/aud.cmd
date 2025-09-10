@echo off
REM Auto-generated wrapper for project-local aud
set PROJ=%~dp0..\..
if exist "%PROJ%\.auditor_venv\Scripts\aud.exe" (
    "%PROJ%\.auditor_venv\Scripts\aud.exe" %*
    exit /b %ERRORLEVEL%
)
REM Fallback to module execution
"%PROJ%\.auditor_venv\Scripts\python.exe" -m theauditor.cli %*
exit /b %ERRORLEVEL%

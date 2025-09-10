# Auto-generated wrapper for project-local aud
$proj = Split-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -Parent
$aud = Join-Path $proj ".auditor_venv\Scripts\aud.exe"
if (Test-Path $aud) {
    & $aud @args
    exit $LASTEXITCODE
}
# Fallback to module execution
$python = Join-Path $proj ".auditor_venv\Scripts\python.exe"
& $python "-m" "theauditor.cli" @args
exit $LASTEXITCODE

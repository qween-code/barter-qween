# Firebase Emulator Starter Script
param(
    [string]$ProjectId = "bogazici-barter"
)

Write-Host "🔥 Starting Firebase Emulator..." -ForegroundColor Green
Write-Host "Project: $ProjectId" -ForegroundColor Cyan
Write-Host "Emulator UI will be available at: http://localhost:4000" -ForegroundColor Yellow

cd "C:\Users\qw\Desktop\barter_qween"
firebase emulators:start --project=$ProjectId

Write-Host "Emulator stopped." -ForegroundColor Red

Write-Host "Generating launcher icons..." -ForegroundColor Green
Write-Host ""

Write-Host "Step 1: Getting dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Step 2: Generating launcher icons..." -ForegroundColor Yellow
flutter pub run flutter_launcher_icons:main

Write-Host ""
Write-Host "Step 3: Cleaning and rebuilding..." -ForegroundColor Yellow
flutter clean
flutter pub get

Write-Host ""
Write-Host "Done! Your custom launcher icon has been generated." -ForegroundColor Green
Write-Host "You may need to uninstall and reinstall the app to see the changes." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to continue"

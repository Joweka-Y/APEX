@echo off
echo Generating launcher icons...
echo.

echo Step 1: Getting dependencies...
flutter pub get

echo.
echo Step 2: Generating launcher icons...
flutter pub run flutter_launcher_icons:main

echo.
echo Step 3: Cleaning and rebuilding...
flutter clean
flutter pub get

echo.
echo Done! Your custom launcher icon has been generated.
echo You may need to uninstall and reinstall the app to see the changes.
echo.
pause

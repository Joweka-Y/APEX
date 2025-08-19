# Custom App Icon Instructions

## How to Add Your Custom Icon

1. **Prepare Your Icon Image:**
   - Use a **PNG** format image
   - Recommended size: **1024x1024 pixels** (square)
   - Make sure it has a transparent background if you want transparency
   - The image should be clear and recognizable at small sizes

2. **Replace the Placeholder:**
   - Delete this README.md file
   - Place your icon image in this folder
   - Rename it to `icon.png`

3. **Generate the Launcher Icons:**
   - Run this command in your terminal:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main
   ```

4. **Clean and Rebuild:**
   - Run these commands to ensure the new icon is applied:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Icon Requirements

- **Format**: PNG (recommended) or JPG
- **Size**: 1024x1024 pixels minimum
- **Background**: Transparent or solid color
- **Design**: Simple, recognizable, and works well at small sizes

## What This Will Update

- Android launcher icon (all densities)
- iOS launcher icon
- Web favicon
- Windows desktop icon
- macOS dock icon

## Troubleshooting

If the icon doesn't update:
1. Make sure you ran `flutter pub run flutter_launcher_icons:main`
2. Try `flutter clean` and rebuild
3. Uninstall and reinstall the app on your device/emulator
4. Check that the image path in `pubspec.yaml` matches your file name

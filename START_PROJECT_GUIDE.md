# 🚀 Flutter Project Startup Guide - ChatWave App

## 📋 Complete Startup Checklist

### Step 1: Clean Previous Builds (IMPORTANT!)
```bash
# Navigate to your project directory
cd c:\Users\777al\AndroidStudioProjects\chatwave_app

# Clean all build artifacts and caches
flutter clean

# Remove pub cache (if you have persistent issues)
flutter pub cache repair
```

### Step 2: Get Dependencies
```bash
# Get all packages and dependencies
flutter pub get

# Upgrade packages to latest compatible versions (optional)
flutter pub upgrade
```

### Step 3: Verify Flutter Setup
```bash
# Check Flutter doctor for any issues
flutter doctor

# Check Flutter doctor with verbose output
flutter doctor -v
```

**Fix any issues shown by `flutter doctor` before proceeding!**

### Step 4: Analyze Code (Check for Errors)
```bash
# Run static analysis to find errors
flutter analyze

# Should show: "No issues found!"
```

### Step 5: Build/Run the App

#### Option A: Run on Connected Device/Emulator
```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Run in release mode (faster, no debug info)
flutter run --release
```

#### Option B: Build APK (Android)
```bash
# Build debug APK
flutter build apk --debug

# Build release APK (for production)
flutter build apk --release

# Build split APKs (smaller file size)
flutter build apk --split-per-abi
```

#### Option C: Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

---

## 🔧 Advanced Cleanup Commands

### If You Still Have Issues:

```bash
# 1. Deep clean (removes everything)
flutter clean
rm -rf build/  # On Windows: rmdir /s /q build
rm -rf .dart_tool/  # On Windows: rmdir /s /q .dart_tool

# 2. Clear Flutter cache
flutter pub cache clean

# 3. Reinstall dependencies
flutter pub get --verbose

# 4. Clear IDE caches (if using Android Studio)
# File > Invalidate Caches / Restart > Invalidate and Restart
```

---

## 📱 Device-Specific Commands

### Android
```bash
# Check connected Android devices
adb devices

# Clear app data (if app is installed)
adb shell pm clear com.wavy_chat.chatwave_app

# Uninstall app
adb uninstall com.wavy_chat.chatwave_app

# Install APK
flutter install
```

### iOS (if you have Mac)
```bash
# Clean iOS build
cd ios
pod deintegrate
pod install
cd ..

# Run on iOS
flutter run -d <ios-device-id>
```

---

## 🎯 Recommended Startup Sequence

### For Daily Development:
```bash
# Quick start (use this most of the time)
flutter clean
flutter pub get
flutter run
```

### For First Time Setup:
```bash
# Complete setup
flutter clean
flutter pub cache repair
flutter pub get
flutter doctor
flutter analyze
flutter run
```

### When You Have Errors:
```bash
# Deep clean and rebuild
flutter clean
rm -rf build/ .dart_tool/
flutter pub cache clean
flutter pub get
flutter doctor
flutter analyze
flutter run --verbose
```

---

## ⚡ Performance Tips

### 1. Use Release Mode for Testing Performance
```bash
flutter run --release
```

### 2. Enable Hot Reload (Development)
- Press `r` in terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### 3. Use Profile Mode for Performance Analysis
```bash
flutter run --profile
```

### 4. Build with Specific Target
```bash
# Build only for specific architecture (faster)
flutter build apk --target-platform android-arm64
```

---

## 🐛 Troubleshooting Common Issues

### Issue: "Package not found" or "Dependency error"
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Issue: "Build failed" or "Gradle error"
```bash
# Android specific
cd android
./gradlew clean  # On Windows: gradlew.bat clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Firebase not initialized"
- Check `google-services.json` is in `android/app/`
- Verify `firebase_options.dart` exists
- Run `flutter clean` and rebuild

### Issue: "App crashes on startup"
```bash
flutter clean
flutter pub get
flutter run --verbose  # Check logs for errors
```

### Issue: "Out of memory" or "Slow build"
```bash
# Increase Gradle memory (android/gradle.properties)
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m

# Then rebuild
flutter clean
flutter pub get
flutter run
```

---

## 📝 Pre-Run Checklist

Before running your app, ensure:

- [ ] ✅ `flutter doctor` shows no critical issues
- [ ] ✅ `flutter analyze` shows "No issues found!"
- [ ] ✅ All dependencies installed (`flutter pub get` successful)
- [ ] ✅ Device/Emulator is connected and recognized
- [ ] ✅ Firebase configuration files are in place
- [ ] ✅ Internet connection is active (for Firebase)
- [ ] ✅ Sufficient disk space available

---

## 🎨 IDE-Specific Tips

### Android Studio / IntelliJ IDEA
1. **Invalidate Caches**: File > Invalidate Caches / Restart
2. **Enable Flutter Plugin**: Settings > Plugins > Flutter
3. **Configure SDK**: Settings > Languages & Frameworks > Flutter
4. **Use Flutter Inspector**: View > Tool Windows > Flutter Inspector

### VS Code
1. **Install Flutter Extension**: Extensions > Flutter
2. **Open Command Palette**: Ctrl+Shift+P > "Flutter: Run"
3. **Use Debug Console**: View > Debug Console
4. **Hot Reload**: Save file or press Ctrl+F5

---

## 🔥 Quick Commands Reference

```bash
# Clean everything
flutter clean

# Get dependencies
flutter pub get

# Check for issues
flutter doctor
flutter analyze

# Run app
flutter run

# Build APK
flutter build apk --release

# List devices
flutter devices

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Quit app (while running)
# Press 'q' in terminal
```

---

## 📚 Additional Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Firebase Setup**: Check `FIREBASE_STORAGE_SETUP.md` in your project
- **Dart Analysis**: Run `flutter analyze` regularly
- **Performance**: Use `flutter run --profile` for profiling

---

## ✅ Success Indicators

Your app is ready to run when:
- ✅ `flutter doctor` shows green checkmarks
- ✅ `flutter analyze` shows "No issues found!"
- ✅ `flutter pub get` completes without errors
- ✅ Device is connected and recognized
- ✅ App builds without errors
- ✅ App launches and shows login screen

---

**Happy Coding! 🎉**

# ⚡ Quick Start Guide - ChatWave App

## 🚀 Fastest Way to Start (3 Commands)

```bash
flutter clean
flutter pub get
flutter run
```

That's it! These 3 commands will:
1. Clean all old build files
2. Install/update all dependencies
3. Run your app on connected device

---

## 📱 Step-by-Step for First Time

### 1. Open Terminal/Command Prompt
Navigate to your project:
```bash
cd c:\Users\777al\AndroidStudioProjects\chatwave_app
```

### 2. Clean Everything
```bash
flutter clean
```
**Why?** Removes old build files that might cause conflicts.

### 3. Get Dependencies
```bash
flutter pub get
```
**Why?** Downloads all packages your app needs (Firebase, etc.).

### 4. Check Setup
```bash
flutter doctor
```
**Why?** Verifies Flutter, Android SDK, and tools are properly installed.

### 5. Check for Errors
```bash
flutter analyze
```
**Why?** Finds code errors before running.

### 6. Run App
```bash
flutter run
```
**Why?** Launches your app on connected device/emulator.

---

## 🎯 Use the Quick Start Script (Windows)

Double-click `quick_start.bat` in your project folder!

It will automatically:
- ✅ Clean builds
- ✅ Get dependencies  
- ✅ Check setup
- ✅ Analyze code
- ✅ Run the app

---

## 🔥 Most Common Commands

| Command | What It Does |
|---------|-------------|
| `flutter clean` | Remove all build files |
| `flutter pub get` | Install dependencies |
| `flutter doctor` | Check Flutter setup |
| `flutter analyze` | Check for code errors |
| `flutter run` | Run app on device |
| `flutter build apk` | Build Android APK |
| `flutter devices` | List connected devices |

---

## ⚠️ If Something Goes Wrong

### Problem: "Package not found"
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Problem: "Build failed"
```bash
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run
```

### Problem: "Device not found"
```bash
flutter devices
# Make sure your device/emulator is running
# For Android: Start Android Studio > AVD Manager > Start emulator
```

### Problem: "Firebase error"
- Check `android/app/google-services.json` exists
- Check `lib/firebase_options.dart` exists
- Run `flutter clean` and rebuild

---

## 💡 Pro Tips

1. **Always run `flutter clean`** when you:
   - Update Flutter version
   - Add new packages
   - Get strange build errors
   - Switch between branches

2. **Use Hot Reload** while app is running:
   - Press `r` = Hot reload (fast)
   - Press `R` = Hot restart (slower, but more thorough)
   - Press `q` = Quit app

3. **Check logs** if app crashes:
   ```bash
   flutter run --verbose
   ```

4. **Build release version** for testing:
   ```bash
   flutter run --release
   ```

---

## ✅ Success Checklist

Before running, make sure:
- [ ] Device/Emulator is connected (`flutter devices`)
- [ ] No errors in `flutter doctor`
- [ ] No errors in `flutter analyze`
- [ ] Internet connection active (for Firebase)
- [ ] `google-services.json` file exists

---

## 🎉 You're Ready!

Run these commands in order:
```bash
flutter clean
flutter pub get
flutter run
```

**That's it!** Your app should start smoothly. 🚀

For detailed information, see `START_PROJECT_GUIDE.md`

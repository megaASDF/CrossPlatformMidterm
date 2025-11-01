
## 📋 Table of Contents

- [Project Overview](#project-overview)
- [System Requirements](#system-requirements)
- [Installation & Setup](#installation--setup)
- [Running the Application](#running-the-application)
- [Features & State Management Demonstrations](#features--state-management-demonstrations)
- [Testing Guide](#testing-guide)
- [Project Structure](#project-structure)
- [State Management Analysis](#state-management-analysis)
- [Troubleshooting](#troubleshooting)

##  System Requirements

### Required
- **Operating System:** Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **Flutter SDK:** Version 3.1.0 or higher
- **Dart SDK:** Version 3.1.0 or higher (included with Flutter)
- **IDE:** Visual Studio Code, Android Studio, or IntelliJ IDEA
- **Git:** For cloning the repository

### Platform-Specific Requirements

#### For Android Testing
- Android SDK (API Level 21+)
- Android Emulator or physical Android device with USB debugging enabled

#### For iOS Testing (macOS only)
- Xcode 14.0 or higher
- iOS Simulator or physical iOS device
- CocoaPods installed

#### For Web Testing
- Chrome, Edge, Firefox, or Safari browser

---

## Installation & Setup

### Step 1: Install Flutter

If you don't have Flutter installed:

1. Download Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Extract and add Flutter to your PATH
3. Verify installation:
   ```bash
   flutter --version
   flutter doctor
   ```
4. Resolve any issues shown by `flutter doctor`

### Step 2: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/megaASDF/CrossPlatformMidterm.git

# Navigate to project directory
cd CrossPlatformMidterm
```

### Step 3: Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get

# Run code generation for Riverpod and Freezed
flutter pub run build_runner build --delete-conflicting-outputs
```

**Note:** The `build_runner` command generates necessary files for:
- Riverpod providers (`.g.dart` files)
- Freezed models (`.freezed.dart` files)
- JSON serialization

### Step 4: Verify Setup

```bash
# Check for any issues
flutter doctor

# List available devices
flutter devices
```

---

## ▶Running the Application

### Option 1: Run on Emulator/Simulator

```bash
# Start an Android emulator or iOS simulator first, then:
flutter run
```

### Option 2: Run on Physical Device

```bash
# Connect your device via USB, enable USB debugging, then:
flutter run
```

### Option 3: Run on Web

```bash
# Run in Chrome
flutter run -d chrome

# Or build and serve
flutter build web
```

### Option 4: Run with Hot Reload (Recommended for Development)

```bash
# Run in debug mode with hot reload
flutter run

# Then press:
# 'r' - Hot reload
# 'R' - Hot restart
# 'q' - Quit
```

### Platform-Specific Commands

```bash
# Run on specific platform
flutter run -d windows      # Windows desktop
flutter run -d macos        # macOS desktop
flutter run -d linux        # Linux desktop
flutter run -d android      # Android
flutter run -d ios          # iOS (macOS only)
flutter run -d chrome       # Web browser
```

---


## Quick Start Summary

```bash
# 1. Clone repository
git clone https://github.com/megaASDF/CrossPlatformMidterm.git
cd CrossPlatformMidterm

# 2. Install dependencies
flutter pub get

# 3. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run

# 5. Test features
# - Toggle theme (sun/moon icon)
# - Add expenses (FAB button)
# - View analytics (chart icon)
# - Try filters (expand overview)
# - Check state demo (menu → State Demo)
```


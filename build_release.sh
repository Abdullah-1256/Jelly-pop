#!/bin/bash
# build_release.sh - Build optimized release APK

echo "🚀 Building optimized release APK..."

# Clean first
./cleanup.sh

# Build APK split by ABI (smaller per-device size)
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

# Build App Bundle for Play Store
flutter build appbundle --release

echo "✅ Build complete! APKs found in build/app/outputs/flutter-apk/"

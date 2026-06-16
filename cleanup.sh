#!/bin/bash
# cleanup.sh - Clean junk files from Flutter project

echo "🧹 Cleaning project junk files..."

# Remove build directory
if [ -d "build" ]; then
    echo "Deleting build/..."
    rm -rf build
fi

# Remove .dart_tool directory
if [ -d ".dart_tool" ]; then
    echo "Deleting .dart_tool/..."
    rm -rf .dart_tool
fi

# Remove OS-specific junk
find . -name ".DS_Store" -delete
find . -name "Thumbs.db" -delete

# Flutter clean
flutter clean

# Get dependencies
flutter pub get

echo "✅ Cleanup complete!"

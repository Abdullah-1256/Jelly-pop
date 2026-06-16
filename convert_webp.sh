#!/bin/bash
# convert_webp.sh - Convert all PNG images to WebP

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null
then
    echo "❌ Error: cwebp could not be found. Please install webp (sudo apt install webp or brew install webp)"
    exit 1
fi

echo "🖼️ Converting PNGs to WebP..."

find assets/images -name "*.png" | while read -r img; do
    webp_path="${img%.png}.webp"
    echo "Converting: $img -> $webp_path"
    cwebp -q 75 "$img" -o "$webp_path"
    
    # Optional: remove original PNG (uncomment if you are sure)
    # rm "$img"
done

echo "✅ Conversion complete! Don't forget to update pubspec.yaml and your code."

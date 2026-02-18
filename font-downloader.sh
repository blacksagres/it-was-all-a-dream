#!/bin/bash
# Nerd Fonts Downloader for Pop!_OS
# source: https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0

# Check for required dependencies
if ! command -v wget &> /dev/null; then
    echo "❌ Error: wget is not installed."
    echo "On Pop!_OS, you can install it with:"
    echo "sudo apt install wget"
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "❌ Error: unzip is not installed."
    echo "On Pop!_OS, you can install it with:"
    echo "sudo apt install unzip"
    exit 1
fi

# Check for fontconfig (for fc-cache)
if ! command -v fc-cache &> /dev/null; then
    echo "⚠️  Warning: fc-cache not found. Font cache will not be updated."
    echo "On Pop!_OS, you can install it with:"
    echo "sudo apt install fontconfig"
fi

declare -a fonts=(
    BitstreamVeraSansMono
    CodeNewRoman
    DroidSansMono
    FiraCode
    FiraMono
    Go-Mono
    Hack
    Hermit
    JetBrainsMono
    Meslo
    Noto
    Overpass
    ProggyClean
    RobotoMono
    SourceCodePro
    SpaceMono
    Ubuntu
    UbuntuMono
)

# Get the latest version automatically
if command -v curl &> /dev/null; then
    echo "🔍 Checking for latest Nerd Fonts version..."
    version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    if [[ -z "$version" ]]; then
        echo "⚠️  Could not fetch latest version, using fallback version 3.3.0"
        version='3.3.0'
    else
        echo "✅ Latest version found: v$version"
    fi
else
    echo "⚠️  curl not found, using fallback version 3.3.0"
    version='3.3.0'
fi

fonts_dir="${HOME}/.local/share/fonts"

# Create fonts directory if it doesn't exist
if [[ ! -d "$fonts_dir" ]]; then
    echo "📁 Creating fonts directory at $fonts_dir"
    mkdir -p "$fonts_dir"
fi

echo "🚀 Starting Nerd Fonts installation..."
echo "========================================"

success_count=0
fail_count=0

for font in "${fonts[@]}"; do
    zip_file="${font}.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "📥 Downloading $font..."
    
    if ! wget -q --show-progress "$download_url"; then
        echo "❌ Failed to download $font, skipping..."
        fail_count=$((fail_count + 1))
        continue
    fi

    if ! unzip -o -q "$zip_file" -d "$fonts_dir"; then
        echo "❌ Failed to extract $font, skipping..."
        rm -f "$zip_file"
        fail_count=$((fail_count + 1))
        continue
    fi

    rm "$zip_file"
    echo "✅ Successfully installed $font"
    success_count=$((success_count + 1))
done

echo "========================================"
echo "📊 Installation Summary:"
echo "✅ Successfully installed: $success_count fonts"
echo "❌ Failed to install: $fail_count fonts"

# Clean up Windows Compatible files
windows_files=$(find "$fonts_dir" -name '*Windows Compatible*' 2>/dev/null | wc -l)
if [[ $windows_files -gt 0 ]]; then
    echo "🧹 Removing $windows_files Windows Compatible files..."
    find "$fonts_dir" -name '*Windows Compatible*' -delete
fi

# Update font cache if available
if command -v fc-cache &> /dev/null; then
    echo "🔄 Updating font cache..."
    fc-cache -fv
else
    echo "ℹ️  Skipping font cache update (fc-cache not available)"
fi

# Set default monospace font for GNOME (Pop!_OS uses GNOME)
if command -v gsettings &> /dev/null; then
    echo "🎨 Setting FiraCode Nerd Font as default monospace font..."
    gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode Nerd Font 11'
    echo "💡 You can change this in GNOME Tweaks if desired"
fi

echo ""
echo "🎉 Nerd Fonts installation complete!"
echo "💡 To use these fonts in your terminal:"
echo "   1. Open your terminal preferences"
echo "   2. Select a 'Nerd Font' (e.g., FiraCode Nerd Font)"
echo "   3. Restart your terminal"
echo ""
echo "🚀 Enjoy your new fonts! 🎨"

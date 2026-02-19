#!/bin/bash
# Nerd Fonts Downloader
# source: https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0

OS="$(uname -s)"

# --- Dependency checks ---

if [[ "$OS" == "Linux" ]]; then
    if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
        echo "❌ Error: neither wget nor curl is installed."
        echo "Install one with: sudo apt install wget"
        exit 1
    fi

    if ! command -v unzip &> /dev/null; then
        echo "❌ Error: unzip is not installed."
        echo "Install it with: sudo apt install unzip"
        exit 1
    fi

    if ! command -v fc-cache &> /dev/null; then
        echo "⚠️  Warning: fc-cache not found. Font cache will not be updated."
        echo "Install it with: sudo apt install fontconfig"
    fi
elif [[ "$OS" == "Darwin" ]]; then
    if ! command -v curl &> /dev/null; then
        echo "❌ Error: curl is not installed."
        exit 1
    fi

    if ! command -v unzip &> /dev/null; then
        echo "❌ Error: unzip is not installed."
        echo "Install it with: brew install unzip"
        exit 1
    fi
fi

# --- Download helper ---

download_file() {
    local url="$1"
    local output="$2"
    if command -v wget &> /dev/null; then
        wget -q --show-progress -O "$output" "$url"
    else
        curl -L --progress-bar -o "$output" "$url"
    fi
}

# --- Font list ---

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

# --- Resolve latest version ---

echo "🔍 Checking for latest Nerd Fonts version..."
version=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
if [[ -z "$version" ]]; then
    echo "⚠️  Could not fetch latest version, using fallback version 3.3.0"
    version='3.3.0'
else
    echo "✅ Latest version found: v$version"
fi

# --- Font directory ---

if [[ "$OS" == "Darwin" ]]; then
    fonts_dir="${HOME}/Library/Fonts"
else
    fonts_dir="${HOME}/.local/share/fonts"
fi

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

    if ! download_file "$download_url" "$zip_file"; then
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

# Update font cache (Linux only)
if [[ "$OS" == "Linux" ]]; then
    if command -v fc-cache &> /dev/null; then
        echo "🔄 Updating font cache..."
        fc-cache -fv
    else
        echo "ℹ️  Skipping font cache update (fc-cache not available)"
    fi

    # Set default monospace font for GNOME
    if command -v gsettings &> /dev/null; then
        echo "🎨 Setting FiraCode Nerd Font as default monospace font..."
        gsettings set org.gnome.desktop.interface monospace-font-name 'FiraCode Nerd Font 11'
        echo "💡 You can change this in GNOME Tweaks if desired"
    fi
fi

echo ""
echo "🎉 Nerd Fonts installation complete!"
echo "💡 To use these fonts in your terminal:"
echo "   1. Open your terminal preferences"
echo "   2. Select a 'Nerd Font' (e.g., FiraCode Nerd Font)"
echo "   3. Restart your terminal"
echo ""
echo "🚀 Enjoy your new fonts! 🎨"

#!/usr/bin/env bash
set -euo pipefail

# crypt-backup.sh - Encrypt/decrypt folders with AES256 GPG encryption
# Usage:
#   ./crypt-backup.sh --encrypt SOURCE_DIR    # Creates SOURCE_DIR.tar.gz.gpg
#   ./crypt-backup.sh --decrypt FILE.gpg       # Extracts to current directory

# --- Usage ---
usage() {
    echo "Usage:"
    echo "  $0 --encrypt SOURCE_DIR    # Creates SOURCE_DIR.tar.gz.gpg"
    echo "  $0 --decrypt FILE.gpg       # Extracts to current directory"
    exit 1
}

# --- Encrypt ---
encrypt() {
    local source_dir="$1"
    local archive_name="$(basename "$source_dir")"
    local archive_path="${archive_name}.tar.gz"
    local encrypted_path="${archive_name}.tar.gz.gpg"

    # Create compressed archive
    tar -czvf "$archive_path" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"

    # Encrypt with AES256 (symmetrical, you'll be prompted for a passphrase)
    gpg -c --cipher-algo AES256 "$archive_path"

    # Remove unencrypted archive
    rm -f "$archive_path"

    echo "Encrypted backup created: $encrypted_path"
    echo "WARNING: Keep your passphrase safe. Without it, the backup cannot be restored."
}

# --- Decrypt ---
decrypt() {
    local encrypted_file="$1"
    local decrypted_file="${encrypted_file%.gpg}"

    # Decrypt (prompts for passphrase)
    gpg -d "$encrypted_file" > "$decrypted_file"

    # Extract
    tar -xzvf "$decrypted_file"

    # Remove decrypted archive
    rm -f "$decrypted_file"

    echo "Restored from: $encrypted_file"
}

# --- Main ---
if [[ "$#" -lt 2 ]]; then
    usage
fi

case "$1" in
    --encrypt)
        encrypt "$2"
        ;;
    --decrypt)
        decrypt "$2"
        ;;
    *)
        usage
        ;;
esac

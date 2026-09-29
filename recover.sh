#!/data/data/com.termux/files/usr/bin/bash
set -e

REPO="https://raw.githubusercontent.com/Gdi321/abdo-ai-recovery/main"
ARCHIVE_URL="$REPO/abdo_ai_recovery.tar.gz.enc"
WORK="$HOME/.abdo_ai_recovery"
ENC="$WORK/abdo_ai_recovery.tar.gz.enc"
TAR="$WORK/abdo_ai_recovery.tar.gz"
TARGET="$HOME/abdo_ai_bot"

echo "=== Abdo AI Recovery ==="
echo "Downloading latest encrypted backup..."

rm -rf "$WORK"
mkdir -p "$WORK"

curl -fL "$ARCHIVE_URL" -o "$ENC"

echo "Enter recovery password:"
PASS=$(python -c 'import getpass; print(getpass.getpass())')

echo "Decrypting..."
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
  -in "$ENC" -out "$TAR" -pass pass:"$PASS"

unset PASS

echo "Checking archive..."
tar -tzf "$TAR" >/dev/null

if [ -d "$TARGET" ]; then
    BACKUP="$HOME/abdo_ai_bot_before_recovery_$(date +%Y%m%d_%H%M%S)"
    echo "Existing project found. Moving it to:"
    echo "$BACKUP"
    mv "$TARGET" "$BACKUP"
fi

echo "Restoring project..."
mkdir -p "$TARGET"
tar -xzf "$TAR" -C "$TARGET"

if [ -f "$TARGET/requirements.txt" ]; then
    echo "Installing dependencies..."
    python -m pip install -r "$TARGET/requirements.txt"
fi

rm -rf "$WORK"

echo
echo "================================"
echo "RECOVERY_SUCCESS"
echo "Project restored to:"
echo "$TARGET"
echo "================================"
echo
echo "IMPORTANT: .env is intentionally not included."
echo "Restore your API keys/environment variables separately."

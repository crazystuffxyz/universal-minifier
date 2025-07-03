#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
INSTALL_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.uniminify-backups"
SOURCE_EXEC_NAME="uniminify-macos"
TARGET_EXEC_NAME="uniminify"
TARGET_EXEC_PATH="$INSTALL_DIR/$TARGET_EXEC_NAME"
DOWNLOAD_URL="https://github.com/crazystuffxyz/universal-minifier/releases/download/v2.0.0-binary/$SOURCE_EXEC_NAME"

if [ ! -f "$SCRIPT_DIR/$SOURCE_EXEC_NAME" ]; then
    echo "Source executable '$SOURCE_EXEC_NAME' not found. Downloading..."
    curl -LsSfo "$SCRIPT_DIR/$SOURCE_EXEC_NAME" "$DOWNLOAD_URL"
    if [ $? -ne 0 ]; then
        echo "ERROR: Download failed. Please check your internet connection or the URL."
        exit 1
    fi
    echo "Download complete."
fi

if [ ! -d "$INSTALL_DIR" ]; then
    echo "Creating installation folder: \"$INSTALL_DIR\""
    mkdir -p "$INSTALL_DIR"
fi

if [ -f "$TARGET_EXEC_PATH" ]; then
    echo
    echo "WARNING: The command '$TARGET_EXEC_NAME' already exists in your install directory."
    echo "Backing up the existing version before proceeding..."
    mkdir -p "$BACKUP_DIR"
    TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
    BACKUP_FILE="$BACKUP_DIR/${TARGET_EXEC_NAME}_${TIMESTAMP}.bak"
    cp "$TARGET_EXEC_PATH" "$BACKUP_FILE"
    echo "Backup saved to: \"$BACKUP_FILE\""
    echo
    read -p "Press Enter to overwrite the active file in \"$INSTALL_DIR\" (or Ctrl+C to cancel)..."
fi

echo "Installing new version of $TARGET_EXEC_NAME to \"$INSTALL_DIR\"..."
cp -f "$SCRIPT_DIR/$SOURCE_EXEC_NAME" "$TARGET_EXEC_PATH"
chmod +x "$TARGET_EXEC_PATH"
echo "Successfully installed $TARGET_EXEC_NAME."

add_to_path() {
    local profile_file
    local shell_name
    if [ -n "$ZSH_VERSION" ]; then
        shell_name="zsh"
        profile_file="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        shell_name="bash"
        profile_file="$HOME/.bashrc"
    else
        profile_file="$HOME/.profile"
    fi
    echo
    if [ -f "$profile_file" ]; then
        if ! grep -q "export PATH=.*$INSTALL_DIR" "$profile_file"; then
            echo "Adding \"$INSTALL_DIR\" to your PATH in $profile_file."
            echo -e "\n# Added by uniminify installer\nexport PATH=\"$INSTALL_DIR:\$PATH\"" >> "$profile_file"
            echo "Your $shell_name profile has been updated."
        else
            echo "\"$INSTALL_DIR\" is already configured in your PATH in $profile_file."
        fi
    else
        echo "Could not find a shell profile file ($profile_file)."
        echo "Please add the following line to your shell's startup file manually:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    fi
}

add_to_path

echo
echo "[DONE] For the PATH change to take effect, please run 'source $HOME/.zshrc'"
echo "       (or 'source $HOME/.bashrc') or open a new terminal."
echo "       Then you can run:"
echo "       uniminify --help"
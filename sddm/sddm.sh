#!/usr/bin/env bash

# Script Dir
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"
SYSTEM_THEMES_DIR="/usr/share/sddm/themes"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="$SDDM_CONF_DIR/theme.conf"

# Reset Colors
trap 'echo -ne "\033[0m"' EXIT

# Palette
C_MAIN='\033[38;2;202;169;224m'
C_ACCENT='\033[38;2;145;177;240m'
C_DIM='\033[38;2;129;122;150m'
C_GREEN='\033[38;2;166;209;137m'
C_YELLOW='\033[38;2;229;200;144m'
C_RED='\033[38;2;231;130;132m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

header() {
    clear
    echo -e "${C_MAIN}${C_BOLD}"
    echo " ╭──────────────────────────────────────────╮"
    echo " │           󱓞 SDDM THEME SETUP 󱓞           │"
    echo " ╰──────────────────────────────────────────╯"
    echo -e "${C_RESET}"
}

info() {
    echo -e "${C_MAIN}${C_BOLD} ╭─ 󰓅 $1${C_RESET}"
}

substep() {
    echo -e "${C_MAIN}${C_BOLD} │  ${C_DIM}❯ ${C_RESET}$1"
}

success() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_GREEN}✔ ${C_RESET}$1\n"
}

error() {
    echo -e "${C_MAIN}${C_BOLD} ╰─ ${C_RED}✘ ${C_RESET}$1\n"
}

# Core Logic
header

# Deps Check
info "Checking dependencies..."

if ! command -v sddm &> /dev/null; then
    error "SDDM is not installed. Install it with: pacman -S sddm"
    exit 1
fi
substep "SDDM found"

if ! sudo -n true 2>/dev/null; then
    substep "${C_YELLOW}Note: sudo may prompt for your password during installation${C_RESET}"
fi

success "Dependencies verified"

# Themes Check
if [ ! -d "$THEMES_DIR" ]; then
    error "Themes directory not found at $THEMES_DIR"
    exit 1
fi

# Selection Logic
info "Selecting a theme..."

if ! command -v fzf &> /dev/null; then
    substep "fzf not found. Using basic list..."
    THEMES=($(ls -1 "$THEMES_DIR"))
    for i in "${!THEMES[@]}"; do
        echo -e "${C_MAIN}${C_BOLD} │  ${C_ACCENT}$((i+1)) ${C_DIM}❯ ${C_RESET}${THEMES[$i]}"
    done
    echo -ne "${C_MAIN}${C_BOLD} ╰─ ${C_YELLOW}Choice: ${C_RESET}"
    read -rp "" SELECTION
    if [[ "$SELECTION" =~ ^[0-9]+$ ]] && [ "$SELECTION" -ge 1 ] && [ "$SELECTION" -le "${#THEMES[@]}" ]; then
        SELECTED_THEME="${THEMES[$((SELECTION-1))]}"
    else
        error "Invalid selection. Exiting."
        exit 1
    fi
else
    SELECTED_THEME=$(ls -1 "$THEMES_DIR" | fzf --prompt="Select theme: " --height=15 --reverse --border --header="Use arrow keys/Enter to select")
fi

if [ -z "$SELECTED_THEME" ]; then
    error "No theme selected. Exiting."
    exit 0
fi

INSTALL_NAME="${INSTALL_NAME:-$SELECTED_THEME}"

substep "Selected: ${C_ACCENT}${SELECTED_THEME}${C_RESET}"

# Font Check
FONT_COUNT=$(ls -1 "$THEMES_DIR/$SELECTED_THEME/font" 2>/dev/null | grep -E "\.(ttf|otf)$" | wc -l)
if [ "$FONT_COUNT" -eq 0 ]; then
    echo -e "${C_YELLOW}${C_BOLD} ╭─   MISSING FONT DETECTED${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_RESET}  ${C_DIM}This theme looks better with its specific font!${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_RESET}  ${C_DIM}Please put the .ttf/.otf file in:${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} │${C_ACCENT}$THEMES_DIR/$SELECTED_THEME/font/${C_RESET}"
    echo -e "${C_YELLOW}${C_BOLD} ╰─ ${C_DIM}Refer to README.md for font suggestions.${C_RESET}\n"
fi

# Install Logic
info "Applying configuration changes..."

# Dir Init
if [ ! -d "$SYSTEM_THEMES_DIR" ]; then
    substep "Creating system directory..."
    sudo mkdir -p "$SYSTEM_THEMES_DIR"
fi

# Copy Theme
substep "Removing old version if exists..."
sudo rm -rf "$SYSTEM_THEMES_DIR/$INSTALL_NAME"
substep "Copying theme to /usr/share/sddm/themes/$INSTALL_NAME/..."
sudo cp -r "$THEMES_DIR/$SELECTED_THEME" "$SYSTEM_THEMES_DIR/$INSTALL_NAME"

# Update SDDM
substep "Updating sddm settings..."
if [ ! -d "$SDDM_CONF_DIR" ]; then
    sudo mkdir -p "$SDDM_CONF_DIR"
fi

if [ ! -f "$SDDM_CONF" ]; then
    echo -e "[Theme]\nCurrent=$INSTALL_NAME" | sudo tee "$SDDM_CONF" > /dev/null
else
    if grep -q "^Current=" "$SDDM_CONF"; then
        sudo sed -i "s|^Current=.*|Current=$INSTALL_NAME|" "$SDDM_CONF"
    else
        if grep -q "^\[Theme\]" "$SDDM_CONF"; then
            sudo sed -i "/^\[Theme\]/a Current=$INSTALL_NAME" "$SDDM_CONF"
        else
            echo -e "\n[Theme]\nCurrent=$INSTALL_NAME" | sudo tee -a "$SDDM_CONF" > /dev/null
        fi
    fi
fi

success "Theme '$INSTALL_NAME' is now active!"

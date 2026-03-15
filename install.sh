#!/bin/bash
# Installation script for aniar
# Author: Mickael D Leonhart

show_banner() {
    cat << "EOF"
                                                                  _______  _              _______
                                                                 (  ___  )( \   |\     /|(  ___  )
                                                                 | (   ) || (   ( \   / )| (   ) |
                                                                 | (___) || |    \ (_) / | (___) |
                                                                 |  ___  || |     \   /  |  ___  |
                                                                 | (   ) || |      ) (   | (   ) |
                                                                 | )   ( || (____/\| |   | )   ( |
                                                                 |/     \|(_______/\_/   |/     \|

                                                                    Arabic Anime Streaming Tool
EOF
    echo -e "By Mickael D Leonhart\n"
}

show_banner
echo "Installing aniar..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please don't run as root. The script will use sudo when needed.${NC}"
    exit 1
fi

# Detect package manager
detect_package_manager() {
    if command -v pacman >/dev/null; then echo "arch"
    elif command -v apt >/dev/null;   then echo "debian"
    elif command -v dnf >/dev/null;   then echo "fedora"
    elif command -v yum >/dev/null;   then echo "rhel"
    elif command -v zypper >/dev/null; then echo "suse"
    elif command -v brew >/dev/null;  then echo "macos"
    else echo "unknown"
    fi
}

PM=$(detect_package_manager)

install_package() {
    local pkg=$1
    case $PM in
        arch)   sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null ;;
        debian) sudo apt update && sudo apt install -y "$pkg" 2>/dev/null ;;
        fedora|rhel) sudo dnf install -y "$pkg" 2>/dev/null ;;
        suse)   sudo zypper install -y "$pkg" 2>/dev/null ;;
        macos)  brew install "$pkg" 2>/dev/null ;;
        *)      return 1 ;;
    esac
}

install_hint() {
    case $PM in
        arch)   echo "    sudo pacman -S $1" ;;
        debian) echo "    sudo apt install $1" ;;
        fedora) echo "    sudo dnf install $1" ;;
        macos)  echo "    brew install $1" ;;
        *)      echo "    Check your package manager" ;;
    esac
}

# Check and install required dependencies
echo -e "${BLUE}Checking dependencies...${NC}"
MISSING=()
for dep in curl yt-dlp mpv; do
    if command -v "$dep" >/dev/null; then
        echo -e "  ${GREEN}[ok] $dep${NC}"
    else
        echo -e "  ${YELLOW}[missing] $dep${NC}"
        MISSING+=("$dep")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Installing missing dependencies...${NC}"
    for dep in "${MISSING[@]}"; do
        echo -e "  Installing $dep..."
        if install_package "$dep"; then
            echo -e "  ${GREEN}[ok] $dep installed${NC}"
        else
            echo -e "  ${RED}[failed] Could not install $dep — install manually:${NC}"
            install_hint "$dep"
        fi
    done
fi

# fzf is optional but strongly recommended
if ! command -v fzf >/dev/null; then
    echo -e "\n${YELLOW}fzf is optional but strongly recommended for the best experience.${NC}"
    read -p "Install fzf? [Y/n]: " answer
    if [[ ! "$answer" =~ ^[Nn] ]]; then
        if install_package "fzf"; then
            echo -e "  ${GREEN}[ok] fzf installed${NC}"
        else
            echo -e "  ${YELLOW}fzf not installed — you can add it later${NC}"
        fi
    fi
else
    echo -e "  ${GREEN}[ok] fzf${NC}"
fi

# Download aniar
echo -e "\n${BLUE}Downloading aniar...${NC}"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if curl -sL "https://github.com/MickaelDLeonhart/aniar/releases/download/v1.0.2/aniar" -o "aniar"; then
    echo -e "  ${GREEN}[ok] Downloaded${NC}"

    echo -e "\n${BLUE}Installing to /usr/local/bin...${NC}"
    sudo mkdir -p /usr/local/bin
    sudo cp aniar /usr/local/bin/aniar
    sudo chmod +x /usr/local/bin/aniar

    mkdir -p "$HOME/.config/aniar"

    # Create desktop entry if supported
    if [ -d "$HOME/.local/share/applications" ]; then
        cat > "$HOME/.local/share/applications/aniar.desktop" << EOF
[Desktop Entry]
Name=aniar
Comment=Arabic Anime Streaming Tool
Exec=aniar
Icon=video-x-generic
Terminal=true
Type=Application
Categories=AudioVideo;Player;
Keywords=anime;arabic;stream;
EOF
    fi

    cd /
    rm -rf "$TEMP_DIR"

    echo -e "\n${GREEN}Installation complete!${NC}"
    echo -e "\n${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}aniar \"detective conan\"${NC}   # Search and play"
    echo -e "  ${GREEN}aniar download \"bleach\"${NC}   # Download series"
    echo -e "  ${GREEN}aniar help${NC}                # Show all commands"
    echo -e "\n${BLUE}Config:${NC} $HOME/.config/aniar/config"
    echo -e "${BLUE}GitHub:${NC} https://github.com/MickaelDLeonhart/aniar"
else
    echo -e "  ${RED}[failed] Could not download aniar${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

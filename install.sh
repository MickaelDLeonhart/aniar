#!/bin/bash
# Installation script for aniar
# Created by Mickael D Leonhart

set -e

show_banner() {
    cat << "EOF"
    _    _ _ 
   / \  | (_) __ _ 
  / _ \ | | |/ _` |
 / ___ \| | | (_| |
/_/   \_\_|_|\__,_|
Arabic Anime Streaming Tool
EOF
    echo -e "By Mickael D Leonhart\n"
}

show_banner

echo "📦 Installing aniar..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please don't run as root. The script will use sudo when needed.${NC}"
    exit 1
fi

# Detect package manager
detect_package_manager() {
    if command -v pacman >/dev/null; then
        echo "arch"
    elif command -v apt >/dev/null; then
        echo "debian"
    elif command -v dnf >/dev/null; then
        echo "fedora"
    elif command -v yum >/dev/null; then
        echo "rhel"
    elif command -v zypper >/dev/null; then
        echo "suse"
    elif command -v brew >/dev/null; then
        echo "macos"
    else
        echo "unknown"
    fi
}

PM=$(detect_package_manager)

install_package() {
    local pkg=$1
    case $PM in
        arch)
            sudo pacman -S --needed --noconfirm "$pkg" 2>/dev/null || return 1
            ;;
        debian)
            sudo apt update && sudo apt install -y "$pkg" 2>/dev/null || return 1
            ;;
        fedora|rhel)
            sudo dnf install -y "$pkg" 2>/dev/null || return 1
            ;;
        suse)
            sudo zypper install -y "$pkg" 2>/dev/null || return 1
            ;;
        macos)
            brew install "$pkg" 2>/dev/null || return 1
            ;;
        *)
            return 1
            ;;
    esac
}

# Check and install dependencies
echo -e "${BLUE}🔍 Checking dependencies...${NC}"

DEPENDENCIES=("curl" "yt-dlp" "mpv")
MISSING=()

for dep in "${DEPENDENCIES[@]}"; do
    if command -v "$dep" >/dev/null; then
        echo -e "  ${GREEN}✅ $dep${NC}"
    else
        echo -e "  ${YELLOW}❌ $dep${NC}"
        MISSING+=("$dep")
    fi
done

# Install missing dependencies
if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}📦 Installing missing dependencies...${NC}"
    for dep in "${MISSING[@]}"; do
        echo -e "  Installing ${BLUE}$dep${NC}..."
        if install_package "$dep"; then
            echo -e "    ${GREEN}✅ Success${NC}"
        else
            echo -e "    ${RED}❌ Failed to install $dep${NC}"
            echo -e "    Please install it manually:"
            case $PM in
                arch) echo "    sudo pacman -S $dep" ;;
                debian) echo "    sudo apt install $dep" ;;
                fedora) echo "    sudo dnf install $dep" ;;
                macos) echo "    brew install $dep" ;;
                *) echo "    Check your package manager" ;;
            esac
        fi
    done
fi

# Install fzf (optional)
if ! command -v fzf >/dev/null; then
    echo -e "\n${YELLOW}🤔 FZF (optional but recommended)${NC}"
    read -p "Install FZF for better interface? [Y/n]: " answer
    if [[ ! "$answer" =~ ^[Nn] ]]; then
        if install_package "fzf"; then
            echo -e "  ${GREEN}✅ FZF installed${NC}"
        else
            echo -e "  ${YELLOW}⚠️  FZF optional - install manually if needed${NC}"
        fi
    fi
else
    echo -e "  ${GREEN}✅ fzf${NC}"
fi

# Download aniar
echo -e "\n${BLUE}⬇️  Downloading aniar...${NC}"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

if curl -sL "https://github.com/MickaelDLeonhart/aniar/releases/download/v1.0.0/aniar" -o "aniar"; then
    echo -e "  ${GREEN}✅ Downloaded successfully${NC}"
    
    # Install to /usr/local/bin
    echo -e "\n${BLUE}⚙️  Installing to /usr/local/bin...${NC}"
    sudo mkdir -p /usr/local/bin
    sudo cp aniar /usr/local/bin/
    sudo chmod +x /usr/local/bin/aniar
    
    # Create config directory
    echo -e "\n${BLUE}📁 Setting up configuration...${NC}"
    mkdir -p "$HOME/.config/aniar"
    
    # Create desktop entry
    if [ -d "$HOME/.local/share/applications" ]; then
        echo -e "  ${BLUE}📋 Creating desktop entry...${NC}"
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
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
    
    echo -e "\n${GREEN}✨ Installation complete!${NC}"
    echo -e "\n${BLUE}🚀 Usage:${NC}"
    echo -e "  ${GREEN}aniar \"اسم الأنمي\"${NC}     # Search and play"
    echo -e "  ${GREEN}aniar help${NC}              # Show all commands"
    echo -e "\n${BLUE}🔧 Configuration:${NC} $HOME/.config/aniar/config"
    echo -e "${BLUE}📖 GitHub:${NC} https://github.com/MickaelDLeonhart/aniar"
    echo -e "\n${YELLOW}🎉 Enjoy watching anime!${NC}"
    
else
    echo -e "  ${RED}❌ Failed to download aniar${NC}"
    exit 1
fi

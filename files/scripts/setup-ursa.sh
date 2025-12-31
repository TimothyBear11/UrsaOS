#!/bin/bash
set -ouex pipefail

# This script runs ONCE during the GitHub build process.
# Its job is to "teach" the OS how to install your dotfiles later.

echo "🐻 Configuring UrsaOS System Defaults..."

# 1. Add the 'just install-nix' command to the system
# We append this to the existing justfile so it's available globally.
cat <<EOF >>/usr/share/just/justfile

# --- UrsaOS Setup Commands ---

install-nix:
    echo "🐻 Phase 1: Installing Nix Package Manager..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    
    echo "🐻 Phase 2: Cloning TimothyBear11/nixdots..."
    # Back up existing if it exists, just in case
    if [ -d "\$HOME/nixdots" ]; then
        mv \$HOME/nixdots \$HOME/nixdots.bak.\$(date +%s)
    fi
    git clone https://github.com/TimothyBear11/nixdots.git \$HOME/nixdots
    
    echo "🐻 Phase 3: Activating Home Manager (Impure)..."
    # We use --impure to allow hardware/nixGL access if needed
    nix run home-manager/master -- switch --flake \$HOME/nixdots/#tbear --impure
    
    echo "🐠 Phase 4: Switching Shell to Fish..."
    # Safely change shell for the current user
    sudo usermod -s /usr/bin/fish \$(whoami)
    
    echo "🎉 UrsaOS Setup Complete! Please reboot to see your shells."
EOF

# 2. Fix polkit permissions for Hyprland/Qtile if needed
# (Fedora usually handles this, but this ensures standard Wayland compatibility)
echo "Ensuring Wayland session compatibility..."
